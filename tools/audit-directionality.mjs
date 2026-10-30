import { existsSync, readFileSync, readdirSync } from "node:fs";
import { extname, join, relative } from "node:path";

const SOURCE_DIRS = ["inst/assets/core", "inst/assets/components"];
const SOURCE_EXTENSIONS = new Set([".css", ".js"]);

/*
 * Each exception is matched by source text rather than a line number so the
 * audit remains stable when nearby rules move. A reason is deliberately part
 * of the data contract: physical coordinates are allowed only when the
 * component's geometry or public side API really is physical.
 */
export const DIRECTIONAL_ALLOWLIST = [
  {
    file: "inst/assets/components/carousel/carousel.js",
    pattern: /scrollLeft|offsetLeft|scrollWidth/,
    category: "geometric",
    reason: "Native horizontal scrolling is measured in viewport coordinates.",
  },
  {
    file: "inst/assets/components/scroll-area/scroll-area.js",
    pattern: /scrollLeft|scrollWidth/,
    category: "geometric",
    reason: "Native scrollbar geometry is measured in viewport coordinates.",
  },
  {
    file: "inst/assets/components/navigation-menu/navigation-menu.js",
    pattern: /style\.left/,
    category: "geometric",
    reason: "The shared viewport is clamped against measured physical geometry.",
  },
  {
    file: "inst/assets/components/slider/slider.js",
    pattern: /style\.left|\[vertical \? "bottom" : "left"\]/,
    category: "geometric",
    reason: "Slider percentages map to the horizontal track coordinate system.",
  },
  {
    file: "inst/assets/components/tabs/tabs.js",
    pattern: /offsetLeft/,
    category: "geometric",
    reason: "The active indicator follows measured track geometry in pixels.",
  },
  {
    file: "inst/assets/core/shad-runtime.js",
    pattern: /case "left"|case "right"|opposite =|side === "right"|side === "left"/,
    category: "explicit-side",
    reason: "Floating placement uses the documented physical side contract.",
  },
  {
    file: "inst/assets/core/shad-runtime.js",
    pattern: /style\.left|style\.right/,
    category: "geometric",
    reason: "Floating panels and arrows receive measured viewport coordinates.",
  },
  {
    file: "inst/assets/components/dropdown-menu/dropdown-menu.js",
    pattern: /side: "right"/,
    category: "explicit-side",
    reason: "Submenus open on the documented side of their trigger.",
  },
  {
    file: "inst/assets/components/dropdown-menu/dropdown-menu.js",
    pattern: /left-arrow/,
    category: "direction-aware",
    reason: "Keyboard tokens describe logical submenu navigation and focus return.",
  },
  {
    file: "inst/assets/components/menubar/menubar.js",
    pattern: /left-arrow/,
    category: "direction-aware",
    reason: "Keyboard tokens describe logical menubar navigation and focus return.",
  },
  {
    file: "inst/assets/components/sheet/sheet.js",
    pattern: /data-side|side =/,
    category: "explicit-side",
    reason: "Sheet side values are a documented physical placement contract.",
  },
  {
    file: "inst/assets/components/sheet/sheet.css",
    pattern: /left:|right:|border-(?:left|right):/,
    category: "explicit-side",
    reason: "Sheet side variants intentionally place the panel on the named edge.",
  },
  {
    file: "inst/assets/components/popover/popover.css",
    pattern: /border-(?:left|right):/,
    category: "explicit-side",
    reason: "Popover arrow borders hide the half facing its named side.",
  },
  {
    file: "inst/assets/core/shad-animations.css",
    pattern: /slide-(?:in-from|out-to)-(?:left|right)|animation: shad-slide-(?:in-from|out-to)-(?:left|right)/,
    category: "explicit-side",
    reason: "Sheet motion names are selected from the documented side value.",
  },
];

function sourceFiles(repoRoot) {
  const files = [];
  for (const dir of SOURCE_DIRS) {
    const root = join(repoRoot, dir);
    if (!existsSync(root)) continue;
    const visit = (current) => {
      for (const entry of readdirSync(current, { withFileTypes: true })) {
        const path = join(current, entry.name);
        if (entry.isDirectory()) visit(path);
        else if (SOURCE_EXTENSIONS.has(extname(entry.name))) files.push(path);
      }
    };
    visit(root);
  }
  return files.sort();
}

function physicalMatches(line, extension) {
  const matches = [];
  if (extension === ".css") {
    const declaration = /\b(?:left|right|[a-z-]+-(?:left|right)(?:-[a-z-]+)?)\s*:/gi;
    for (const match of line.matchAll(declaration)) matches.push(match[0].trim());
    const value = /\b(?:text-align|float|clear)\s*:\s*(?:left|right)\b/gi;
    for (const match of line.matchAll(value)) matches.push(match[0].trim());
    const animation = /(?:@keyframes|animation(?:-name)?)\s*[^;{]*(?:left|right)/gi;
    for (const match of line.matchAll(animation)) matches.push(match[0].trim());
  } else {
    const geometry = /(?:\.style\.(?:left|right)|\b(?:scrollLeft|offsetLeft|clientLeft|scrollWidth)\b)/g;
    for (const match of line.matchAll(geometry)) matches.push(match[0]);
    const side = /(?:\bside\s*[:=]\s*|["'])(?:left|right)(?:["'])?/gi;
    for (const match of line.matchAll(side)) matches.push(match[0].trim());
  }
  return [...new Set(matches)];
}

function allowlistEntry(file, text, source) {
  return DIRECTIONAL_ALLOWLIST.find((entry) =>
    entry.file === file &&
      (entry.pattern ? entry.pattern.test(source) : text.includes(entry.text)));
}

export function auditDirectionality(repoRoot) {
  const findings = [];
  for (const path of sourceFiles(repoRoot)) {
    const file = relative(repoRoot, path).replaceAll("\\", "/");
    const extension = extname(path);
    const lines = readFileSync(path, "utf8").split("\n");
    lines.forEach((line, index) => {
      for (const match of physicalMatches(line, extension)) {
        const exception = allowlistEntry(file, match, line);
        findings.push({
          file,
          line: index + 1,
          match,
          category: exception?.category ?? null,
          reason: exception?.reason ?? null,
        });
      }
    });
  }
  const reviewed = findings.filter((finding) => finding.category);
  const unreviewed = findings.filter((finding) => !finding.category);
  const report = findings.map((finding) =>
    `${finding.file}:${finding.line} ${finding.match}` +
      (finding.category ? ` [${finding.category}] ${finding.reason}` : " [UNREVIEWED]")
  ).join("\n");
  return { findings, reviewed, unreviewed, report };
}

if (process.argv[1] && process.argv[1].endsWith("audit-directionality.mjs")) {
  const result = auditDirectionality(process.cwd());
  process.stdout.write(result.report + (result.report ? "\n" : ""));
  if (result.unreviewed.length) process.exitCode = 1;
}

import { describe, expect, test } from "vitest";
import { auditDirectionality } from "../../tools/audit-directionality.mjs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import { readFileSync } from "node:fs";

const repoRoot = join(dirname(fileURLToPath(import.meta.url)), "..", "..");

describe("directionality audit", () => {
  test("requires every physical direction rule to be reviewed", () => {
    const result = auditDirectionality(repoRoot);
    expect(result.unreviewed, result.report).toEqual([]);
  });

  test("requires reviewed exceptions to explain their direction contract", () => {
    const result = auditDirectionality(repoRoot);
    expect(result.reviewed.length).toBeGreaterThan(0);
    for (const finding of result.reviewed) {
      expect(finding.category).toMatch(/^(semantic|geometric|explicit-side|direction-aware)$/);
      expect(finding.reason.length).toBeGreaterThanOrEqual(20);
    }
  });

  test("covers semantic layout and explicit directional icon opt-in", () => {
    const read = (file) => readFileSync(join(repoRoot, file), "utf8");
    const semantic = [
      "inst/assets/core/shad-base.css",
      "inst/assets/components/accordion/accordion.css",
      "inst/assets/components/calendar/calendar.css",
      "inst/assets/components/dialog/dialog.css",
      "inst/assets/components/dropdown-menu/dropdown-menu.css",
      "inst/assets/components/sidebar/sidebar.css",
      "inst/assets/components/table/table.css",
    ].map(read).join("\n");
    expect(semantic).toContain("border-inline-start");
    expect(semantic).toContain("text-align: start");
    expect(semantic).toContain("inset-inline-end");
    expect(read("inst/assets/core/shad-base.css")).toContain(
      ".shad-icon--directional[data-direction=\"forward\"]");
    expect(read("inst/assets/components/sidebar/sidebar.css")).toContain(
      "--shad-sidebar-slide: 100%");
  });
});

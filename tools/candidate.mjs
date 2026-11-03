import { Buffer } from "node:buffer";
import { createHash } from "node:crypto";
import { gunzipSync } from "node:zlib";

const recordFields = ["file", "sha256", "commit", "r"];

// What R CMD build writes that the commit does not hold.
const generatedPrefixes = ["build/", "inst/doc/"];
const buildDescriptionFields = new Set([
  "NeedsCompilation",
  "Packaged",
  "Author",
  "Maintainer",
]);

// tools:::.hidden_file_exclusions: names R CMD build always leaves out.
const rHiddenFiles = new Set([
  ".Renviron", ".Rprofile", ".Rproj.user", ".Rhistory", ".Rapp.history",
  ".tex", ".log", ".aux", ".pdf", ".png", ".backups", ".cvsignore",
  ".cproject", ".directory", ".dropbox", ".exrc", ".gdb.history",
  ".gitattributes", ".gitignore", ".gitmodules", ".hgignore", ".hgtags",
  ".htaccess", ".latex2html-init", ".project", ".seed", ".settings",
  ".tm_properties",
]);

export function sha256(bytes) {
  return createHash("sha256").update(bytes).digest("hex");
}

export function formatCandidateRecord(record) {
  return recordFields.map((key) => `${key}: ${record[key]}`).join("\n") + "\n";
}

export function parseCandidateRecord(text) {
  const found = {};
  for (const line of text.split(/\r?\n/)) {
    const match = /^([a-z0-9]+): (.*)$/.exec(line);
    if (match) found[match[1]] = match[2].trim();
  }
  for (const key of recordFields) {
    if (!found[key]) throw new Error(`candidate record lacks ${key}`);
  }
  if (!/^shadshiny_[0-9.]+\.tar\.gz$/.test(found.file)) {
    throw new Error(`candidate record file is not a shadshiny source archive: ${found.file}`);
  }
  if (!/^[0-9a-f]{64}$/.test(found.sha256)) {
    throw new Error("candidate record sha256 must be 64 lowercase hex digits");
  }
  if (!/^[0-9a-f]{40}$/.test(found.commit)) {
    throw new Error("candidate record commit must be a full 40-digit hash");
  }
  return Object.fromEntries(recordFields.map((key) => [key, found[key]]));
}

function cString(block, start, length) {
  const bytes = block.subarray(start, start + length);
  const end = bytes.indexOf(0);
  return bytes.subarray(0, end === -1 ? bytes.length : end).toString("utf8");
}

function paxPath(data) {
  let position = 0;
  while (position < data.length) {
    const space = data.indexOf(0x20, position);
    if (space === -1) break;
    const length = Number.parseInt(data.subarray(position, space).toString("utf8"), 10);
    if (!(length > 0)) break;
    const record = data.subarray(space + 1, position + length - 1).toString("utf8");
    const equals = record.indexOf("=");
    if (record.slice(0, equals) === "path") return record.slice(equals + 1);
    position += length;
  }
  return null;
}

// Regular files only, keyed by full path. Handles the ustar prefix field, GNU
// long-name entries, and pax path records, so it reads both R's and git's tar.
export function readTarEntries(bytes) {
  let buffer = Buffer.from(bytes);
  if (buffer[0] === 0x1f && buffer[1] === 0x8b) buffer = gunzipSync(buffer);

  const entries = new Map();
  let offset = 0;
  let nextPath = null;
  while (offset + 512 <= buffer.length) {
    const block = buffer.subarray(offset, offset + 512);
    if (block.every((byte) => byte === 0)) break;

    const size = Number.parseInt(cString(block, 124, 12).trim() || "0", 8);
    const type = block[156] === 0 ? "0" : String.fromCharCode(block[156]);
    const data = buffer.subarray(offset + 512, offset + 512 + size);
    offset += 512 + Math.ceil(size / 512) * 512;

    if (type === "L") {
      nextPath = cString(data, 0, data.length);
      continue;
    }
    if (type === "x") {
      nextPath = paxPath(data) ?? nextPath;
      continue;
    }
    if (type === "g") continue;

    let path = nextPath;
    nextPath = null;
    if (path === null) {
      const name = cString(block, 0, 100);
      const prefix = cString(block, 257, 6) === "ustar" ? cString(block, 345, 155) : "";
      path = prefix ? `${prefix}/${name}` : name;
    }
    if (type === "0") entries.set(path, Buffer.from(data));
  }
  return entries;
}

// R matches each .Rbuildignore line as a case-insensitive Perl regex against
// every file and directory path relative to the package root.
export function buildExclusion(rbuildignore) {
  const patterns = rbuildignore
    .split(/\r?\n/)
    .filter((line) => line.trim() !== "")
    .map((line) => new RegExp(line, "i"));
  return (path) => {
    const parts = path.split("/");
    return parts.some((part, index) => {
      const prefix = parts.slice(0, index + 1).join("/");
      return rHiddenFiles.has(part) || patterns.some((pattern) => pattern.test(prefix));
    });
  };
}

function parseDcf(text) {
  const fields = new Map();
  let current = null;
  for (const line of text.split(/\r?\n/)) {
    if (/^\s/.test(line) && current) {
      fields.set(current, `${fields.get(current)} ${line}`);
      continue;
    }
    const match = /^([^:\s]+):(.*)$/.exec(line);
    if (match) {
      current = match[1];
      fields.set(current, match[2]);
    }
  }
  for (const [key, value] of fields) fields.set(key, value.replace(/\s+/g, " ").trim());
  return fields;
}

function descriptionChanges(built, original) {
  const archive = parseDcf(built);
  const source = parseDcf(original);
  return [...new Set([...archive.keys(), ...source.keys()])]
    .filter((key) => !(buildDescriptionFields.has(key) && !source.has(key)))
    .filter((key) => archive.get(key) !== source.get(key))
    .map((key) => `DESCRIPTION (${key})`);
}

// `archive` and `source` map package-relative paths to bytes. `extra` holds
// archive files a build of this commit would not contain, `missing` commit
// files the build should have kept, and `changed` files whose bytes differ.
export function compareArchiveToSource(archive, source) {
  const excluded = buildExclusion(source.get(".Rbuildignore")?.toString("utf8") ?? "");
  const extra = [];
  const missing = [];
  const changed = [];

  for (const [path, bytes] of archive) {
    if (generatedPrefixes.some((prefix) => path.startsWith(prefix))) continue;
    const original = source.get(path);
    if (!original || excluded(path)) {
      extra.push(path);
    } else if (path === "DESCRIPTION") {
      changed.push(...descriptionChanges(bytes.toString("utf8"), original.toString("utf8")));
    } else if (!bytes.equals(original)) {
      changed.push(path);
    }
  }
  for (const path of source.keys()) {
    if (!archive.has(path) && !excluded(path)) missing.push(path);
  }

  return { extra: extra.sort(), missing: missing.sort(), changed: changed.sort() };
}

export function formatComparison(result) {
  const sections = [
    ["not in a build of the commit", result.extra],
    ["in the commit but not the archive", result.missing],
    ["different from the commit", result.changed],
  ];
  return sections
    .filter(([, paths]) => paths.length)
    .map(([label, paths]) => `${paths.length} ${label}:\n${paths.map((path) => `  ${path}`).join("\n")}`)
    .join("\n");
}

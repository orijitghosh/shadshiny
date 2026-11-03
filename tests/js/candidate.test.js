// The release candidate is one frozen source archive, checked byte for byte.
//
// 1. candidate/CANDIDATE records the archive's file name, its SHA-256, the
//    commit it was built from, and the R that built it.
// 2. The archive is read without a system tar: ustar prefixes, GNU long names
//    and pax paths all resolve, gzipped or not.
// 3. A path is left out of the build when it or a parent directory matches a
//    .Rbuildignore pattern (case-insensitive), or its name is one of R's
//    hidden-file exclusions. Local testthat problem files and the candidate
//    directory itself are left out.
// 4. Every archive file equals the commit's file byte for byte, except what
//    R CMD build generates (build/, inst/doc/) and DESCRIPTION, which build
//    reflows and extends; DESCRIPTION is compared field by field, allowing only
//    the fields build adds. Every commit file the archive lacks must be left
//    out by rule 3.
import { Buffer } from "node:buffer";
import { readFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import { gzipSync } from "node:zlib";
import { describe, expect, test } from "vitest";
import {
  buildExclusion,
  compareArchiveToSource,
  formatCandidateRecord,
  parseCandidateRecord,
  readTarEntries,
  sha256,
} from "../../tools/candidate.mjs";

const repoRoot = join(dirname(fileURLToPath(import.meta.url)), "..", "..");

function header(name, size, type = "0", prefix = "") {
  const block = Buffer.alloc(512);
  block.write(name, 0, 100, "utf8");
  block.write("0000644\0", 100);
  block.write(size.toString(8).padStart(11, "0") + "\0", 124);
  block.write(type, 156);
  block.write("ustar\u000000", 257);
  block.write(prefix, 345, 155, "utf8");
  return block;
}

function entry(name, content, type = "0", prefix = "") {
  const data = Buffer.from(content);
  const padding = Buffer.alloc((512 - (data.length % 512)) % 512);
  return Buffer.concat([header(name, data.length, type, prefix), data, padding]);
}

function paxPath(path) {
  const body = ` path=${path}\n`;
  let length = body.length + 1;
  while (String(length).length + body.length !== length) length += 1;
  return `${length}${body}`;
}

function tar(...entries) {
  return Buffer.concat([...entries, Buffer.alloc(1024)]);
}

function files(object) {
  return new Map(Object.entries(object).map(([path, text]) => [path, Buffer.from(text)]));
}

const record = {
  file: "shadshiny_0.3.0.9000.tar.gz",
  sha256: "a".repeat(64),
  commit: "b".repeat(40),
  r: "R version 4.4.3 (2025-02-28 ucrt)",
};

describe("candidate record", () => {
  test("round-trips its fields", () => {
    expect(parseCandidateRecord(formatCandidateRecord(record))).toEqual(record);
  });

  test("rejects a malformed hash or a missing field", () => {
    const text = formatCandidateRecord(record);
    expect(() => parseCandidateRecord(text.replace("a".repeat(64), "abc"))).toThrow(/sha256/);
    expect(() => parseCandidateRecord(text.replace(/^commit: .*\n/m, ""))).toThrow(/commit/);
  });

  test("hashes bytes as lowercase hex SHA-256", () => {
    expect(sha256(Buffer.from("abc"))).toBe(
      "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad",
    );
  });
});

describe("archive reading", () => {
  const long = `shadshiny/${"deep/".repeat(30)}file.R`;
  const archive = tar(
    entry("pax_global_header", paxPath("ignored"), "g"),
    entry("shadshiny/", "", "5"),
    entry("DESCRIPTION", "Package: shadshiny\n", "0", "shadshiny"),
    entry("././@LongLink", `${long}\0`, "L"),
    entry("truncated-name", "long\n"),
    entry("PaxHeader", paxPath("shadshiny/R/pax.R"), "x"),
    entry("short", "pax\n"),
  );

  test("resolves ustar prefixes, GNU long names and pax paths", () => {
    const entries = readTarEntries(archive);
    expect([...entries.keys()]).toEqual([
      "shadshiny/DESCRIPTION",
      long,
      "shadshiny/R/pax.R",
    ]);
    expect(entries.get(long).toString()).toBe("long\n");
    expect(entries.get("shadshiny/R/pax.R").toString()).toBe("pax\n");
  });

  test("reads a gzipped archive the same way", () => {
    expect([...readTarEntries(gzipSync(archive)).keys()]).toEqual([
      ...readTarEntries(archive).keys(),
    ]);
  });
});

describe("build exclusions", () => {
  test("the package build leaves out testthat problem files and the candidate", () => {
    const excluded = buildExclusion(readFileSync(join(repoRoot, ".Rbuildignore"), "utf8"));

    expect(excluded("tests/testthat/_problems/test-chat-12.R")).toBe(true);
    expect(excluded("tests/testthat/testthat-problems.rds")).toBe(true);
    expect(excluded("candidate/shadshiny_0.3.0.9000.tar.gz")).toBe(true);
    expect(excluded("candidate/CANDIDATE")).toBe(true);
    expect(excluded(".gitignore")).toBe(true);
    expect(excluded("R/chat.R")).toBe(false);
    expect(excluded("tests/testthat/test-chat.R")).toBe(false);
  });

  test("patterns match a parent directory and ignore case", () => {
    const excluded = buildExclusion("^tools$\n\n^Docs$\n");
    expect(excluded("tools/build.mjs")).toBe(true);
    expect(excluded("docs/index.html")).toBe(true);
    expect(excluded("R/tools.R")).toBe(false);
  });
});

describe("archive against source", () => {
  const source = files({
    ".Rbuildignore": "^tools$\n^\\.Rbuildignore$\n",
    ".gitignore": "node_modules\n",
    DESCRIPTION: [
      "Package: demo",
      "Version: 1.0",
      "Authors@R:",
      '    person("A", "B", role = c("aut", "cre"))',
      "Imports:",
      "    jsonlite,",
      "    shiny",
      "",
    ].join("\n"),
    "R/a.R": "a <- 1\n",
    "tools/t.mjs": "tool\n",
  });
  const built = [
    "Package: demo",
    "Version: 1.0",
    "Authors@R: ",
    '    person("A", "B", role = c("aut", "cre"))',
    "Imports: jsonlite, shiny",
    "NeedsCompilation: no",
    "Packaged: 2026-11-02 01:52:02 UTC; someone",
    "Author: A B [aut, cre]",
    "Maintainer: A B <a@b.c>",
    "",
  ].join("\n");
  const archive = files({
    DESCRIPTION: built,
    "R/a.R": "a <- 1\n",
    "build/vignette.rds": "rds",
    "inst/doc/intro.html": "<p>intro</p>",
  });

  test("a faithful build compares clean", () => {
    expect(compareArchiveToSource(archive, source)).toEqual({
      extra: [],
      missing: [],
      changed: [],
    });
  });

  test("reports files the commit lacks, lost files and changed bytes", () => {
    const drifted = new Map(archive);
    drifted.set("tests/testthat/_problems/test-a-1.R", Buffer.from("junk"));
    drifted.set("R/a.R", Buffer.from("a <- 2\n"));
    const lost = new Map(source);
    lost.set("R/b.R", Buffer.from("b <- 1\n"));

    expect(compareArchiveToSource(drifted, lost)).toEqual({
      extra: ["tests/testthat/_problems/test-a-1.R"],
      missing: ["R/b.R"],
      changed: ["R/a.R"],
    });
  });

  test("compares DESCRIPTION by field, allowing only fields build adds", () => {
    const bumped = new Map(archive);
    bumped.set(
      "DESCRIPTION",
      Buffer.from(built.replace("Version: 1.0", "Version: 1.1") + "Extra: yes\n"),
    );

    expect(compareArchiveToSource(bumped, source).changed).toEqual([
      "DESCRIPTION (Extra)",
      "DESCRIPTION (Version)",
    ]);
  });
});

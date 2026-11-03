// node tools/run-candidate.mjs build
//   Builds the release candidate from a clean export of HEAD, so nothing local
//   can enter it, and records it in candidate/CANDIDATE.
// node tools/run-candidate.mjs verify [--record FILE] [--archive FILE] [--hash-only]
//   Checks the archive's SHA-256 against the record and, unless --hash-only,
//   that its files are a faithful build of the recorded commit.
import { spawnSync } from "node:child_process";
import {
  copyFileSync,
  mkdirSync,
  mkdtempSync,
  readdirSync,
  readFileSync,
  rmSync,
  writeFileSync,
} from "node:fs";
import { tmpdir } from "node:os";
import { basename, dirname, join, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import {
  compareArchiveToSource,
  formatCandidateRecord,
  formatComparison,
  parseCandidateRecord,
  readTarEntries,
  sha256,
} from "./candidate.mjs";
import { resolveRscript } from "./rscript-command.mjs";

const repoRoot = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const candidateDir = join(repoRoot, "candidate");
const archivePattern = /^shadshiny_.*\.tar\.gz$/;
const buildScript =
  "status <- system2(file.path(R.home('bin'), 'R'), " +
  "c('CMD', 'build', shQuote(commandArgs(TRUE)[1]))); quit(status = status)";

function run(command, args) {
  const result = spawnSync(command, args, { cwd: repoRoot, maxBuffer: 1 << 30 });
  if (result.error) throw result.error;
  if (result.status !== 0) {
    throw new Error(`${command} ${args.join(" ")} failed:\n${result.stderr}`);
  }
  return result.stdout;
}

function packageFiles(entries) {
  const files = new Map();
  for (const [path, bytes] of entries) {
    if (!path.startsWith("shadshiny/")) {
      throw new Error(`archive entry outside shadshiny/: ${path}`);
    }
    files.set(path.slice("shadshiny/".length), bytes);
  }
  return files;
}

function build() {
  const dirty = run("git", ["status", "--porcelain", "--untracked-files=no"]).toString().trim();
  if (dirty) throw new Error(`commit or stash tracked changes first:\n${dirty}`);
  const commit = run("git", ["rev-parse", "HEAD"]).toString().trim();

  const work = mkdtempSync(join(tmpdir(), "shadshiny-candidate-"));
  try {
    const packageDir = join(work, "shadshiny");
    for (const [path, bytes] of readTarEntries(run("git", ["archive", "--format=tar", commit]))) {
      const target = join(packageDir, path);
      mkdirSync(dirname(target), { recursive: true });
      writeFileSync(target, bytes);
    }

    const built = spawnSync(resolveRscript(), ["-e", buildScript, packageDir], {
      cwd: work,
      stdio: "inherit",
    });
    if (built.error) throw built.error;
    if (built.status !== 0) throw new Error("R CMD build failed");
    const file = readdirSync(work).find((name) => archivePattern.test(name));
    if (!file) throw new Error("R CMD build wrote no archive");

    mkdirSync(candidateDir, { recursive: true });
    for (const old of readdirSync(candidateDir)) {
      if (archivePattern.test(old)) rmSync(join(candidateDir, old));
    }
    copyFileSync(join(work, file), join(candidateDir, file));
    const record = {
      file,
      sha256: sha256(readFileSync(join(candidateDir, file))),
      commit,
      r: run(resolveRscript(), ["-e", "cat(R.version.string)"]).toString().trim(),
    };
    writeFileSync(join(candidateDir, "CANDIDATE"), formatCandidateRecord(record));
    console.log(`Froze candidate/${file}\n  sha256 ${record.sha256}\n  commit ${commit}\n  ${record.r}`);
  } finally {
    rmSync(work, { recursive: true, force: true });
  }
  return verify({});
}

function verify(options) {
  const recordPath = options.record ?? join(candidateDir, "CANDIDATE");
  const record = parseCandidateRecord(readFileSync(recordPath, "utf8"));
  const archivePath = options.archive ?? join(dirname(recordPath), record.file);
  if (basename(archivePath) !== record.file) {
    throw new Error(`the record names ${record.file}, not ${basename(archivePath)}`);
  }

  const actual = sha256(readFileSync(archivePath));
  if (actual !== record.sha256) {
    console.error(
      `SHA-256 mismatch for ${record.file}\n  recorded ${record.sha256}\n  actual   ${actual}`,
    );
    return false;
  }
  console.log(`SHA-256 matches: ${record.file} ${actual}`);
  if (options.hashOnly) return true;

  const known = spawnSync("git", ["cat-file", "-e", `${record.commit}^{commit}`], { cwd: repoRoot });
  if (known.status !== 0) {
    throw new Error(`commit ${record.commit} is not in this clone; fetch the full history`);
  }
  const archive = packageFiles(readTarEntries(readFileSync(archivePath)));
  const source = readTarEntries(run("git", ["archive", "--format=tar", record.commit]));
  const report = formatComparison(compareArchiveToSource(archive, source));
  if (report) {
    console.error(`${record.file} is not a faithful build of ${record.commit}:\n${report}`);
    return false;
  }
  console.log(`Archive matches commit ${record.commit}: ${archive.size} files`);
  return true;
}

const [command, ...rest] = process.argv.slice(2);
const options = {};
try {
  for (let index = 0; index < rest.length; index += 1) {
    if (rest[index] === "--hash-only") options.hashOnly = true;
    else if (rest[index] === "--record") options.record = resolve(rest[(index += 1)]);
    else if (rest[index] === "--archive") options.archive = resolve(rest[(index += 1)]);
    else throw new Error(`unknown option: ${rest[index]}`);
  }
  let ok;
  if (command === "build") ok = build();
  else if (command === "verify") ok = verify(options);
  else throw new Error("usage: run-candidate.mjs build | verify [--record FILE] [--archive FILE] [--hash-only]");
  if (!ok) process.exitCode = 1;
} catch (error) {
  console.error(error.message);
  process.exitCode = 1;
}

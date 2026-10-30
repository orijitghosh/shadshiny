import { spawnSync } from "node:child_process";
import { resolve } from "node:path";
import { browserFixtureNames, resolveBrowserFixture } from "./browser-fixtures.mjs";

const name = process.argv[2];
if (!name) {
  console.error(
    "Usage: node tools/run-browser-fixture.mjs <fixture-name> [playwright args...]\n" +
    "Fixtures: " + browserFixtureNames().join(", "),
  );
  process.exitCode = 2;
} else {
  let fixture;
  try {
    fixture = resolveBrowserFixture(name);
  } catch (error) {
    console.error(error.message);
    process.exit(2);
  }
  const command = process.execPath;
  const args = [
    resolve("node_modules/@playwright/test/cli.js"),
    "test",
    "tests/browser/" + fixture.spec,
    ...process.argv.slice(3)
  ];
  const result = spawnSync(command, args, {
    stdio: "inherit",
    env: { ...process.env, SHADSHINY_BROWSER_FIXTURE: fixture.app }
  });
  if (result.error) console.error(result.error);
  process.exitCode = typeof result.status === "number" ? result.status : 1;
}

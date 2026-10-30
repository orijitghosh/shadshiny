import { spawnSync } from "node:child_process";
import { resolve } from "node:path";
import { browserFixtureNames, resolveBrowserFixture } from "./browser-fixtures.mjs";

const cli = resolve("node_modules/@playwright/test/cli.js");

function run(args, env = process.env) {
  const result = spawnSync(process.execPath, [cli, "test", ...args], {
    stdio: "inherit",
    env,
  });
  if (result.error) throw result.error;
  if (result.status !== 0) process.exit(result.status ?? 1);
}

run([]);
for (const name of browserFixtureNames()) {
  const fixture = resolveBrowserFixture(name);
  run(["tests/browser/" + fixture.spec], {
    ...process.env,
    SHADSHINY_BROWSER_FIXTURE: fixture.app,
  });
}

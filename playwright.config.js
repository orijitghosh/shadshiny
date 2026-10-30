import { defineConfig, devices } from "@playwright/test";
import { resolveRscript } from "./tools/rscript-command.mjs";

const rscript = resolveRscript();
const rEnvironment = {
  ...process.env,
  LANG: "",
  LC_ALL: "",
  LC_CTYPE: "",
};

export default defineConfig({
  testDir: "./tests/browser",
  fullyParallel: false,
  workers: 1,
  snapshotPathTemplate: "{testDir}/__screenshots__/{arg}{ext}",
  expect: {
    toHaveScreenshot: {
      animations: "disabled",
      threshold: 0.25,
      maxDiffPixelRatio: 0.02,
    },
  },
  use: {
    baseURL: "http://127.0.0.1:4173",
    viewport: { width: 1280, height: 900 },
    colorScheme: "light",
    locale: "en-US",
    timezoneId: "UTC",
    reducedMotion: "reduce",
  },
  webServer: [
    {
      command: "python -m http.server 4173 --bind 127.0.0.1",
      url: "http://127.0.0.1:4173",
      reuseExistingServer: true,
      stdout: "ignore",
      stderr: "ignore",
    },
    {
      command: `"${rscript}" --vanilla tests/browser/run-shiny-app.R .`,
      url: "http://127.0.0.1:4174",
      reuseExistingServer: true,
      stdout: "ignore",
      stderr: "pipe",
      env: rEnvironment,
      timeout: 120_000,
    },
  ],
  projects: [
    {
      name: "chromium",
      use: { ...devices["Desktop Chrome"], viewport: { width: 1280, height: 900 } },
    },
  ],
});

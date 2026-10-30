import { test, expect } from "@playwright/test";
import AxeBuilder from "@axe-core/playwright";

test("kitchen sink has no serious or critical axe violations", async ({ page }) => {
  await page.goto("/inst/assets/demo/kitchen-sink.html");
  await page.waitForLoadState("networkidle");
  await page.waitForFunction(() => window.shad && window.shad.__runtime);
  await page.waitForFunction(() => document.fonts.status === "loaded");

  const report = await new AxeBuilder({ page }).analyze();
  const blocking = report.violations.filter(
    (violation) => violation.impact === "serious" || violation.impact === "critical",
  );

  const summary = blocking.map((violation) => ({
    id: violation.id,
    impact: violation.impact,
    targets: violation.nodes.map((node) => node.target.join(" ")),
  }));

  expect(summary).toEqual([]);
});

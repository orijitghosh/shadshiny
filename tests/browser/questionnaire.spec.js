import { test, expect } from "@playwright/test";
import AxeBuilder from "@axe-core/playwright";

const APP_URL = "http://127.0.0.1:4174";

test.skip(
  process.env.SHADSHINY_BROWSER_FIXTURE !== "questionnaire-app",
  "questionnaire-app fixture is selected explicitly for this focused suite",
);

async function openFixture(page) {
  await page.goto(APP_URL);
  await page.waitForLoadState("domcontentloaded");
  await page.waitForFunction(() =>
    window.Shiny &&
    Shiny.shinyapp &&
    Shiny.shinyapp.$socket &&
    Shiny.shinyapp.$socket.readyState === WebSocket.OPEN,
  );
  await page.waitForFunction(() => window.shad && window.shad.__runtime);
  await expect(page.locator("#w1-survey")).toHaveAttribute("data-active", "1");
}

function survey(page, id = "w1") {
  return page.locator(`#${id}-survey`);
}

function question(root, name) {
  return root.locator(`fieldset[data-question-name="${name}"]`);
}

test.beforeEach(async ({ page }) => {
  await openFixture(page);
});

test("enforces required answers and advances with keyboard shortcuts", async ({ page }) => {
  const root = survey(page);
  const plan = question(root, "plan");

  await root.getByRole("button", { name: "Next" }).click();
  await expect(plan.locator("[data-question-error]")).toHaveText("This question is required.");
  await expect(plan.getByRole("radio", { name: "Server table" })).toBeFocused();

  const serverTable = plan.locator('input[type="radio"][value="data"]');
  await expect(serverTable).toHaveCount(1);
  await serverTable.press("1");
  await expect(serverTable).toBeChecked();
  await root.getByRole("button", { name: "Next" }).click();
  await expect(question(root, "features")).toBeVisible();
  await expect(root.locator("fieldset[data-question-name]")).toHaveCount(4);
  await expect(root.locator('fieldset[data-question-name="details"]')).toHaveAttribute("hidden", "");
  await expect(root.locator('fieldset[data-question-name="details"]')).toHaveAttribute("inert", "");
});

test("supports multiple answers, explicit skips, and preserves hidden branch answers", async ({ page }) => {
  const root = survey(page);
  const features = question(root, "features");
  const notes = question(root, "notes");
  const details = question(root, "details");

  await root.locator('input[type="radio"][value="data"]').check();
  await root.getByRole("button", { name: "Next" }).click();
  await features.locator('input[type="checkbox"][value="search"]').check();
  await features.locator('input[type="checkbox"][value="export"]').check();
  await root.getByRole("button", { name: "Next" }).click();
  await notes.locator('input[type="text"]').fill("preserved note");
  await root.getByRole("button", { name: "Next" }).click();
  await details.locator('input[type="text"]').fill("preserved branch");

  await root.getByRole("button", { name: "Previous" }).click();
  await root.getByRole("button", { name: "Previous" }).click();
  await root.getByRole("button", { name: "Previous" }).click();
  await root.locator('input[type="radio"][value="rtl"]').check();
  await expect(details).toHaveAttribute("hidden", "");
  await expect(details).toHaveAttribute("inert", "");
  await expect(details.locator('input[type="text"]')).toHaveValue("preserved branch");

  await root.getByRole("button", { name: "Next" }).click();
  await root.getByRole("button", { name: "Next" }).click();
  await expect(notes).toBeVisible();
  await root.getByRole("button", { name: "Skip" }).click();
  await expect(root.locator("[data-questionnaire-status]")).toHaveText("Complete");
  await expect(page.locator("#w1-state")).toContainText("complete=true");
  await expect(page.locator("#w1-state")).toContainText("skipped=notes");
});

test("server updates and reset stay scoped to one module instance", async ({ page }) => {
  const first = survey(page, "w1");
  const second = survey(page, "w2");

  await page.getByRole("button", { name: "Set notes from server" }).first().click();
  const firstNotes = question(first, "notes");
  await expect(first).toHaveAttribute("data-active", "3");
  await expect(firstNotes.locator('input[type="text"]')).toHaveValue("From server");
  await expect(second).toHaveAttribute("data-active", "1");
  await expect(question(second, "notes").locator('input[type="text"]')).toHaveValue("");

  await page.getByRole("button", { name: "Reset survey" }).first().click();
  await expect(first).toHaveAttribute("data-active", "1");
  await expect(firstNotes.locator('input[type="text"]')).toHaveValue("");
  await expect(second).toHaveAttribute("data-active", "1");
});

test("has no serious or critical accessibility violations", async ({ page }) => {
  const report = await new AxeBuilder({ page }).include("#w1-survey").analyze();
  const blocking = report.violations.filter(
    (violation) => violation.impact === "serious" || violation.impact === "critical",
  );
  expect(blocking).toEqual([]);
});

import { test, expect } from "@playwright/test";

const APP_URL = "http://127.0.0.1:4174";

test.skip(
  process.env.SHADSHINY_BROWSER_FIXTURE !== "field-family",
  "field-family fixture is selected explicitly for this focused suite",
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
}

test.beforeEach(async ({ page }) => {
  await openFixture(page);
});

test("native fieldset names and labelled separators are accessible", async ({ page }) => {
  const shipping = page.locator('fieldset[data-testid="shipping-fieldset"]');
  await expect(shipping).toBeVisible();
  await expect(shipping.locator("legend")).toHaveText("Shipping");
  await expect(shipping.locator(".shad-fieldset__description")).toHaveText(
    "Where the order will be sent.",
  );
  await expect(page.getByRole("group", { name: "Shipping" })).toHaveCount(1);

  const separator = page.locator(".shad-field-separator").filter({ hasText: "Optional" });
  await expect(separator).toBeVisible();
  await expect(separator.locator('[role="separator"]')).toHaveAttribute(
    "aria-hidden",
    "true",
  );
  await expect(separator.locator('[role="separator"]')).not.toContainText("Optional");
});

test("responsive field groups change layout without breaking field descriptions", async ({ page }) => {
  const group = page.getByTestId("responsive-group");
  const fields = group.locator(".shad-form-field");
  await expect(fields).toHaveCount(2);
  const field = fields.filter({ has: page.locator("#street") });
  await expect(field).toHaveCount(1);
  const columnsAtDesktop = await field.evaluate((el) =>
    getComputedStyle(el).gridTemplateColumns.split(" ").filter(Boolean).length,
  );
  expect(columnsAtDesktop).toBe(2);

  await page.setViewportSize({ width: 500, height: 900 });
  await expect.poll(() => field.evaluate((el) =>
    getComputedStyle(el).gridTemplateColumns.split(" ").filter(Boolean).length,
  )).toBe(1);

  const street = page.locator("#street");
  const describedBy = await street.getAttribute("aria-describedby");
  expect(describedBy).toBeTruthy();
  await expect(page.locator(`#${describedBy.split(" ")[0]}`)).toHaveText(
    "Include the building number.",
  );
});

test("nested fields retain validator error relationships and keyboard access", async ({ page }) => {
  const street = page.locator("#street");
  await page.getByRole("button", { name: "Validate fields" }).click();

  await expect(page.getByText("Required.", { exact: true })).toBeVisible();
  await expect(street).toHaveAttribute("aria-invalid", "true");
  await expect(page.getByTestId("validation-status")).toHaveText("invalid");

  await street.fill("123 Main Street");
  await page.getByRole("button", { name: "Validate fields" }).click();
  await expect(page.getByTestId("validation-status")).toHaveText("valid");
  await expect(page.getByText("Required.", { exact: true })).toHaveCount(0);
});

test("horizontal fields preserve logical label order in RTL", async ({ page }) => {
  const field = page.getByTestId("rtl-fieldset").locator(".shad-form-field");
  const label = field.locator(".shad-label");
  const input = field.locator("input");
  const labelBox = await label.boundingBox();
  const inputBox = await input.boundingBox();
  expect(labelBox).toBeTruthy();
  expect(inputBox).toBeTruthy();
  expect(labelBox.x).toBeGreaterThan(inputBox.x);
});

test("field family has no serious or critical axe violations", async ({ page }) => {
  const { AxeBuilder } = await import("@axe-core/playwright");
  const results = await new AxeBuilder({ page }).analyze();
  const serious = results.violations.filter((v) => ["serious", "critical"].includes(v.impact));
  expect(serious, JSON.stringify(serious, null, 2)).toEqual([]);
});

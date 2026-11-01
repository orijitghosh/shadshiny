import { test, expect } from "@playwright/test";

const APP_URL = "http://127.0.0.1:4174";

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

test("disabled and read-only inputs expose state and resist interaction", async ({ page }) => {
  const quantity = page.locator("#qty");
  const spinbutton = quantity.getByRole("spinbutton", { name: "Quantity" });
  const increment = quantity.getByRole("button", { name: "Increase" });
  const decrement = quantity.getByRole("button", { name: "Decrease" });

  await expect(spinbutton).toBeDisabled();
  await expect(increment).toBeDisabled();
  await expect(decrement).toBeDisabled();
  await expect(spinbutton).toHaveValue("4");

  await page.getByRole("button", { name: "Enable quantity" }).click();
  await expect(spinbutton).toBeEnabled();
  await expect(increment).toBeEnabled();
  await expect(decrement).toBeEnabled();

  const rating = page.getByRole("img", { name: "3 out of 5 stars" });
  await expect(rating).toBeVisible();
  await expect(rating.getByRole("radio")).toHaveCount(0);
  const stars = rating.locator("button");
  await expect(stars).toHaveCount(5);
  for (let i = 0; i < 5; i += 1) {
    await expect(stars.nth(i)).toBeDisabled();
  }
});

test("representative server updates reach the DOM and return through input values", async ({ page }) => {
  await expect(page.getByTestId("update-status")).toHaveText("checkbox=false; combobox=apple");

  await page.getByRole("button", { name: "Update controls" }).click();

  await expect(page.getByRole("checkbox", { name: "Server checkbox" })).toBeChecked();
  await expect(page.locator("#server_combo .shad-combobox__trigger")).toContainText("Banana");
  await expect(page.getByTestId("update-status")).toHaveText("checkbox=true; combobox=banana");
});

test("select and combobox updates match option strings and skip unknown values", async ({ page }) => {
  const warnings = [];
  page.on("console", (msg) => {
    if (msg.type() === "warning") warnings.push(msg.text());
  });
  const status = page.getByTestId("choice-status");
  const selectValue = page.locator("#num_select .shad-select__value");
  await expect(status).toHaveText("select=1 (character); combo=cheese");

  await page.getByRole("button", { name: "Send numeric values" }).click();
  await expect(selectValue).toHaveText("Big");
  await expect(status).toHaveText("select=1e+05 (character); combo=olives,basil");

  await page.getByRole("button", { name: "Send unknown values" }).click();
  await expect(status).toHaveText("select=1e+05 (character); combo=basil");
  await expect(selectValue).toHaveText("Big");
  await expect.poll(() => warnings.some((text) => text.includes("zzz"))).toBe(true);
  expect(warnings.some((text) => text.includes("anchovy"))).toBe(true);
});

test("server dates update without moving focus and skip dates outside min/max", async ({ page }) => {
  const warnings = [];
  page.on("console", (msg) => {
    if (msg.type() === "warning") warnings.push(msg.text());
  });
  const status = page.getByTestId("date-status");
  const picker = page.locator("#due");
  const trigger = picker.locator(".shad-date-picker__trigger");
  await expect(status).toHaveText("due=2026-10-14; span=<none>");

  const send = page.getByRole("button", { name: "Send dates", exact: true });
  await send.click();
  // the range arrives reversed and comes back in order
  await expect(status).toHaveText("due=2026-10-20; span=2026-10-05..2026-10-12");
  await expect(trigger).toHaveText("October 20, 2026");
  await expect(send).toBeFocused();
  await expect(picker.locator(".shad-date-picker__content")).toBeHidden();

  await page.getByRole("button", { name: "Send dates outside min/max" }).click();
  await expect.poll(() => warnings.filter((text) => text.includes("min/max")).length).toBe(2);
  await expect(status).toHaveText("due=2026-10-20; span=2026-10-05..2026-10-12");
  await expect(trigger).toHaveText("October 20, 2026");

  // an open picker stays open while a value arrives (the binding's update
  // message calls setValue), and focus stays on the grid's tab stop
  await trigger.click();
  const content = page.locator(".shad-date-picker__content");
  await expect(content).toBeVisible();
  await page.evaluate(() => {
    shad.get(document.getElementById("due")).setValue("2026-10-02");
  });
  await expect(status).toHaveText("due=2026-10-02; span=2026-10-05..2026-10-12");
  await expect(content).toBeVisible();
  await expect(content.locator(".shad-calendar__day[data-date='2026-10-02']")).toBeFocused();
});

test("dynamic UI initializes, binds, and tears down an open portal", async ({ page }) => {
  await page.getByRole("button", { name: "Insert dynamic select" }).click();

  const root = page.locator("#dynamic_choice");
  await expect(root).toBeVisible();
  await expect.poll(() => root.evaluate((el) => Boolean(shad.get(el)))).toBe(true);

  const trigger = root.locator(".shad-select__trigger");
  await trigger.click();
  await page.getByRole("option", { name: "Beta" }).click();
  await expect(page.getByTestId("dynamic-status")).toHaveText("dynamic=beta");
  await expect(root.locator(".shad-select__content")).toHaveCount(1);
  await expect(root.locator(".shad-select__content")).toBeHidden();

  await trigger.click();
  await expect(page.locator("body > .shad-select__content")).toBeVisible();
  await page.getByRole("button", { name: "Remove dynamic select" }).click();

  await expect(root).toHaveCount(0);
  await expect(page.locator("body > .shad-select__content")).toHaveCount(0);
  await expect.poll(() => page.evaluate(() => shad.dismiss.depth)).toBe(0);
});

test("server theme switching updates preset and dark mode and reports both back", async ({ page }) => {
  const html = page.locator("html");
  await expect(page.getByTestId("theme-status")).toHaveText("preset=default; dark=false");

  await page.getByRole("button", { name: "Apply blue dark theme" }).click();

  await expect(html).toHaveAttribute("data-shad-theme", "blue");
  await expect(html).toHaveClass(/\bdark\b/);
  await expect(html).toHaveAttribute("data-bs-theme", "dark");
  await expect(page.getByTestId("theme-status")).toHaveText("preset=blue; dark=true");

  await page.getByRole("button", { name: "Reset theme" }).click();
  await expect(html).not.toHaveAttribute("data-shad-theme");
  await expect(html).not.toHaveClass(/\bdark\b/);
  await expect(page.getByTestId("theme-status")).toHaveText("preset=default; dark=false");
});

test("the fixture models usable vertical rhythm for stacked controls", async ({ page }) => {
  const gap = await page.locator("#readonly_rating").evaluate((rating) => {
    const button = document.getElementById("enable_quantity");
    return rating.getBoundingClientRect().top - button.getBoundingClientRect().bottom;
  });

  expect(gap).toBeGreaterThanOrEqual(12);
});

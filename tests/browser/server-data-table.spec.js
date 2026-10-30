import { test, expect } from "@playwright/test";
import AxeBuilder from "@axe-core/playwright";

const APP_URL = "http://127.0.0.1:4174";

test.skip(
  process.env.SHADSHINY_BROWSER_FIXTURE !== "server-data-table",
  "server-data-table fixture is selected explicitly for this focused suite",
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
  await expect(page.locator("#tbl .shad-data-table__summary")).toContainText("100000 rows");
  await expect(page.locator("#request_count")).toHaveText("1");
}

async function requestCount(page) {
  return Number((await page.locator("#request_count").textContent()).trim());
}

async function waitForNextRequest(page, previous) {
  await expect.poll(() => requestCount(page), { timeout: 10_000 }).toBe(previous + 1);
}

test.beforeEach(async ({ page }) => {
  await openFixture(page);
});

test("pages a 100,000-row source without rendering the full dataset", async ({ page }) => {
  const table = page.locator("#tbl");
  await expect(table.locator("table")).toHaveCount(1);
  await expect(table.locator("[role=grid]")).toHaveCount(0);
  await expect(table.locator("tbody tr[data-key]")).toHaveCount(10);
  await expect(table.locator(".shad-data-table__summary")).toContainText("1–10 of 100000 rows");
  await expect(table).toHaveAttribute("aria-busy", "false");
  await expect(table.locator('input[aria-label="Filter all columns"]')).toHaveCount(1);
  await expect(table.locator('input[aria-label="Filter Category"]')).toHaveCount(1);

  const before = await requestCount(page);
  const next = table.locator('[aria-label="Next page"]');
  await next.focus();
  await next.click();
  await waitForNextRequest(page, before);
  await expect(table.locator(".shad-data-table__summary")).toContainText("11–20 of 100000 rows");
  await expect.poll(() => page.evaluate(() => document.activeElement?.getAttribute("aria-label")))
    .toBe("Next page");

  const pageSize = table.locator("select");
  const afterPage = await requestCount(page);
  await pageSize.selectOption("25");
  await waitForNextRequest(page, afterPage);
  await expect(table.locator("tbody tr[data-key]")).toHaveCount(25);
  await expect(table.locator(".shad-data-table__summary")).toContainText("1–25 of 100000 rows");
});

test("delegates global and column filters and handles empty and retry states", async ({ page }) => {
  const table = page.locator("#tbl");
  let before = await requestCount(page);
  await table.locator('input[aria-label="Filter all columns"]').fill("Beta");
  await waitForNextRequest(page, before);
  await expect(table.locator(".shad-data-table__summary")).toContainText("of 25000 rows");

  before = await requestCount(page);
  await table.locator('input[aria-label="Filter all columns"]').fill("");
  await waitForNextRequest(page, before);
  before = await requestCount(page);
  await table.locator('input[aria-label="Filter Category"]').fill("Gamma");
  await waitForNextRequest(page, before);
  await expect(table.locator(".shad-data-table__summary")).toContainText("of 25000 rows");

  before = await requestCount(page);
  await table.locator('input[aria-label="Filter Category"]').fill("no-such-category");
  await waitForNextRequest(page, before);
  await expect(table.locator(".shad-data-table__empty")).toHaveText("No matching rows.");
  await expect(table.locator(".shad-data-table__summary")).toHaveText("0 rows");

  before = await requestCount(page);
  await table.locator('input[aria-label="Filter Category"]').fill("");
  await waitForNextRequest(page, before);
  before = await requestCount(page);
  await table.locator('input[aria-label="Filter all columns"]').fill("error");
  await waitForNextRequest(page, before);
  const alert = table.locator('[role="alert"]');
  await expect(alert).toContainText("Unable to load data");
  await expect(alert).not.toContainText("backend detail");
  await expect(table).toHaveAttribute("aria-busy", "false");

  before = await requestCount(page);
  await alert.getByRole("button", { name: "Try again" }).click();
  await waitForNextRequest(page, before);
  await expect(alert).toHaveCount(0);
  await expect(table.locator(".shad-data-table__summary")).toContainText("of 100000 rows");
});

test("supports multi-sort, stable selection, and lifecycle teardown", async ({ page }) => {
  const table = page.locator("#tbl");
  let before = await requestCount(page);
  await table.locator('[data-col="name"] .shad-data-table__sort').click();
  await waitForNextRequest(page, before);
  before = await requestCount(page);
  await table.locator('[data-col="category"] .shad-data-table__sort').click({ modifiers: ["Shift"] });
  await waitForNextRequest(page, before);
  await expect(table.locator('th[data-col="name"]')).toHaveAttribute("aria-sort", "ascending");
  await expect(table.locator('th[data-col="category"]')).toHaveAttribute("aria-sort", "ascending");

  const selectedRow = table.locator("tbody tr[data-key]").first();
  const selectedKey = await selectedRow.getAttribute("data-key");
  await selectedRow.locator('[role="checkbox"]').click();
  await expect(selectedRow).toHaveAttribute("data-state", "selected");

  before = await requestCount(page);
  await table.locator('[aria-label="Next page"]').click();
  await waitForNextRequest(page, before);
  before = await requestCount(page);
  await table.locator('[aria-label="Previous page"]').click();
  await waitForNextRequest(page, before);
  await expect(table.locator(`tr[data-key="${selectedKey}"]`)).toHaveAttribute("data-state", "selected");

  const removed = await page.evaluate(() => {
    window.__removedServerTable = document.getElementById("tbl");
    return Boolean(window.__removedServerTable);
  });
  expect(removed).toBe(true);
  await page.getByRole("button", { name: "Remove table" }).click();
  await expect(page.locator("#tbl")).toHaveCount(0);
  await expect.poll(() => page.evaluate(() => shad.get(window.__removedServerTable))).toBeNull();
});

test("has no serious or critical accessibility violations", async ({ page }) => {
  const report = await new AxeBuilder({ page }).include("#tbl").analyze();
  const blocking = report.violations.filter(
    (violation) => violation.impact === "serious" || violation.impact === "critical",
  );
  expect(blocking).toEqual([]);
});

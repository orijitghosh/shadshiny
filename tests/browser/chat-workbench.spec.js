import { test, expect } from "@playwright/test";
import AxeBuilder from "@axe-core/playwright";

const APP_URL = "http://127.0.0.1:4174";
test.skip(process.env.SHADSHINY_BROWSER_FIXTURE !== "chat-workbench-app", "selected explicitly");

test("structured workbench covers public events, upload metadata, versions, and axe", async ({ page }) => {
  await page.goto(APP_URL);
  await page.waitForFunction(() => window.Shiny && Shiny.shinyapp?.$socket?.readyState === WebSocket.OPEN);
  await page.locator('input[type="file"]').setInputFiles({
    name: "report.txt", mimeType: "text/plain", buffer: Buffer.from("offline")
  });
  await expect(page.getByText("Upload complete")).toBeVisible();
  await page.locator("textarea").fill("hello");
  await page.getByRole("button", { name: "Send" }).click();
  await expect(page.getByText("Echo: hello")).toBeVisible();
  await expect(page.locator(".shad-chat-source")).toHaveCount(2);
  await page.locator("details.shad-chat-source").first().click();
  await expect(page.getByRole("link", { name: "Documentation" })).toHaveAttribute("href", "https://example.org/docs");
  await expect(page.getByText("report.txt")).toBeVisible();
  await expect(page.locator('details.shad-chat-tool[data-status="success"]')).toBeVisible();
  await expect(page.getByText("Public summary only")).toBeVisible();
  await expect(page.locator("textarea")).toHaveValue("");
  await expect(page.locator("body")).not.toContainText("datapath");
  await expect(page.locator("body")).not.toContainText("private reasoning");

  await page.getByRole("button", { name: "Retry response" }).click();
  await expect(page.getByText("Retry: hello")).toBeVisible();
  await expect(page.getByText("Response 2 of 2")).toBeVisible();
  await page.getByRole("button", { name: "Previous response" }).click();
  await expect(page.getByText("Echo: hello")).toBeVisible();
  await expect(page.getByText("Response 1 of 2")).toBeVisible();

  const results = await new AxeBuilder({ page }).analyze();
  expect(results.violations.filter((violation) => ["serious", "critical"].includes(violation.impact))).toEqual([]);
});

test("structured workbench escapes hostile provider text and finalizes safe failures", async ({ page }) => {
  await page.goto(APP_URL);
  await page.waitForFunction(() => window.Shiny && Shiny.shinyapp?.$socket?.readyState === WebSocket.OPEN);
  await page.locator("textarea").fill("hostile");
  await page.getByRole("button", { name: "Send" }).click();
  await expect(page.locator(".shad-chat-workbench")).toContainText("hostile");
  await expect(page.locator(".shad-chat-workbench script")).toHaveCount(0);
  await expect(page.locator(".shad-chat-workbench img")).toHaveCount(0);

  await page.locator("textarea").fill("fail");
  await page.getByRole("button", { name: "Send" }).click();
  await expect(page.getByText("Something went wrong. Please try again.")).toBeVisible();
  await expect(page.locator("body")).not.toContainText("operator diagnostics");
});

test("structured workbench cancellation ignores late callback events", async ({ page }) => {
  await page.goto(APP_URL);
  await page.waitForFunction(() => window.Shiny && Shiny.shinyapp?.$socket?.readyState === WebSocket.OPEN);
  await page.locator("textarea").fill("cancel");
  await page.getByRole("button", { name: "Send" }).click();
  await expect(page.getByText("Started")).toBeVisible();
  await expect(page.getByRole("button", { name: "Cancel" })).toBeEnabled();
  await page.getByRole("button", { name: "Cancel" }).click();
  await expect(page.getByRole("button", { name: "Cancel" })).toBeDisabled();
  const afterCancel = await page.locator(".shad-chat-status").count();
  await page.waitForTimeout(150);
  await expect(page.locator(".shad-chat-status")).toHaveCount(afterCancel);
});

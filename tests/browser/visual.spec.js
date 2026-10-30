import { test, expect } from "@playwright/test";

test("button and dialog sections retain their light and dark appearance", async ({ page }) => {
  await page.goto("/inst/assets/demo/kitchen-sink.html");
  await page.waitForLoadState("networkidle");
  await page.waitForFunction(() => window.shad && window.shad.__runtime);
  await page.waitForFunction(() => document.fonts.status === "loaded");

  const buttonSection = page.locator("#c-button");
  const dialog = page.locator("#c-dialog [data-shad='dialog']");
  // The runtime portals open dialog content to document.body.
  const dialogContent = page.locator("body > .shad-dialog__content");

  await expect(buttonSection).toHaveScreenshot("button-light.png");
  await dialog.locator(".shad-dialog__trigger").dispatchEvent("click");
  await expect(dialogContent).toBeVisible();
  await expect(dialogContent).toHaveScreenshot("dialog-light.png");
  await dialogContent.locator("[data-shad-dialog-close]").first().dispatchEvent("click");
  await expect(dialogContent).toBeHidden();

  await page.locator("#dark-toggle").dispatchEvent("click");
  await page.waitForFunction(() => document.documentElement.classList.contains("dark"));

  await expect(buttonSection).toHaveScreenshot("button-dark.png");
  await dialog.locator(".shad-dialog__trigger").dispatchEvent("click");
  await expect(dialogContent).toBeVisible();
  await expect(dialogContent).toHaveScreenshot("dialog-dark.png");
});

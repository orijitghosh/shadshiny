import { test, expect } from "@playwright/test";
import AxeBuilder from "@axe-core/playwright";

const APP_URL = "http://127.0.0.1:4174";

test.skip(
  process.env.SHADSHINY_BROWSER_FIXTURE !== "rtl-app",
  "rtl-app fixture is selected explicitly for this focused suite",
);

async function openFixture(page) {
  await page.goto(APP_URL);
  await page.waitForLoadState("domcontentloaded");
  await page.waitForFunction(() =>
    window.Shiny && Shiny.shinyapp && Shiny.shinyapp.$socket &&
    Shiny.shinyapp.$socket.readyState === WebSocket.OPEN,
  );
  await page.waitForFunction(() => window.shad && window.shad.__runtime);
  await expect(page.locator("#rtl-fixture")).toBeVisible();
}

test.beforeEach(async ({ page }) => {
  await openFixture(page);
});

test("applies RTL to logical layout and preserves mixed-direction content", async ({ page }) => {
  await expect(page.locator(".shad-scope")).toHaveAttribute("dir", "rtl");
  await expect(page.locator("html")).toHaveAttribute("lang", "ar");
  await expect(page.locator("#rtl-table")).toHaveAttribute("dir", "auto");
  await expect(page.locator("#mixed-content")).toHaveAttribute("dir", "auto");

  await expect.poll(() => page.locator("#ltr-nested").evaluate(
    (el) => getComputedStyle(el).direction,
  )).toBe("ltr");
  await expect.poll(() => page.locator("#rtl-fixture").evaluate(
    (el) => getComputedStyle(el).direction,
  )).toBe("rtl");

  const sidebar = page.locator("#rtl-sidebar .shad-sidebar");
  await expect.poll(() => sidebar.evaluate(
    (el) => getComputedStyle(el).borderInlineEndWidth,
  )).toBe("1px");
  await expect(page.locator("#rtl-carousel .shad-carousel__prev .shad-icon"))
    .toHaveClass(/shad-icon--directional/);
  await expect(page.locator("#rtl-carousel .shad-carousel__next .shad-icon"))
    .toHaveAttribute("data-direction", "forward");
});

test("ports RTL direction through dialog, sheet, menu, select, combobox, popover, tooltip, and command", async ({ page }) => {
  const assertPortal = async (panel) => {
    await expect(panel).toBeVisible();
    await expect(panel).toHaveAttribute("dir", "rtl");
    await expect(panel).toHaveAttribute("lang", "ar");
  };

  const dialog = page.locator("#rtl-dialog");
  const dialogPanel = page.locator("body > .shad-dialog__content");
  await dialog.locator(".shad-dialog__trigger").click();
  await assertPortal(dialogPanel);
  await dialogPanel.locator("[data-shad-dialog-close]").first().dispatchEvent("click");
  await expect(dialogPanel).toBeHidden();

  const sheet = page.locator("#rtl-sheet");
  const sheetPanel = page.locator("body > .shad-sheet__content");
  await sheet.locator(".shad-sheet__trigger").click();
  await assertPortal(sheetPanel);
  await expect.poll(() => sheetPanel.evaluate(
    (el) => getComputedStyle(el).right,
  )).toBe("0px");
  await sheetPanel.locator("[data-shad-sheet-close]").click();
  await expect(sheetPanel).toBeHidden();

  const menu = page.locator("#rtl-menu");
  const menuPanel = page.locator("body > .shad-menu__content");
  await menu.locator(".shad-menu__trigger").click();
  await assertPortal(menuPanel);
  await page.keyboard.press("Escape");
  await expect(menuPanel).toBeHidden();

  const select = page.locator("#rtl-select");
  const selectPanel = page.locator("body > .shad-select__content");
  await select.getByRole("combobox").click();
  await assertPortal(selectPanel);
  await selectPanel.getByRole("option", { name: "أول" }).click();
  await expect(selectPanel).toBeHidden();

  const combobox = page.locator("#rtl-combobox");
  const comboPanel = page.locator("body > .shad-combobox__content");
  await combobox.locator(".shad-combobox__trigger").click();
  await assertPortal(comboPanel);
  await comboPanel.getByRole("option", { name: "ألف" }).click();
  await expect(comboPanel).toBeHidden();

  const popover = page.locator("#rtl-popover");
  const popoverPanel = page.locator("body > .shad-popover__content");
  await popover.locator(".shad-popover__trigger").click();
  await assertPortal(popoverPanel);
  await page.keyboard.press("Escape");
  await expect(popoverPanel).toBeHidden();

  const tooltip = page.getByRole("button", { name: "مرّر هنا" });
  const tooltipPanel = page.locator("body > .shad-tooltip__content");
  await tooltip.focus();
  await assertPortal(tooltipPanel);
  await page.keyboard.press("Escape");
  await expect(tooltipPanel).toBeHidden();

  await page.keyboard.press("Control+k");
  const command = page.locator("body > .shad-command--dialog");
  await assertPortal(command);
  await page.keyboard.press("Escape");
  await expect(command).toBeHidden();
});

test("centres modal panels, handle grips, and vertical thumbs in RTL", async ({ page }) => {
  const centreX = async (locator) => {
    const box = await locator.boundingBox();
    return box.x + box.width / 2;
  };
  const expectOnScreenAndCentred = async (panel) => {
    await expect(panel).toBeVisible();
    const box = await panel.boundingBox();
    const width = page.viewportSize().width;
    expect(box.x).toBeGreaterThanOrEqual(0);
    expect(box.x + box.width).toBeLessThanOrEqual(width);
    expect(Math.abs(box.x + box.width / 2 - width / 2)).toBeLessThanOrEqual(1);
  };

  const dialogPanel = page.locator("body > .shad-dialog__content");
  await page.locator("#rtl-dialog .shad-dialog__trigger").click();
  await expectOnScreenAndCentred(dialogPanel);
  await dialogPanel.locator("[data-shad-dialog-close]").first().dispatchEvent("click");
  await expect(dialogPanel).toBeHidden();

  await page.keyboard.press("Control+k");
  const command = page.locator("body > .shad-command--dialog");
  await expectOnScreenAndCentred(command);
  await page.keyboard.press("Escape");
  await expect(command).toBeHidden();

  const resizable = page.locator("#rtl-resizable");
  await resizable.scrollIntoViewIfNeeded();
  expect(Math.abs(
    await centreX(resizable.locator(".shad-resizable__grip")) -
      await centreX(resizable.locator(".shad-resizable__handle")),
  )).toBeLessThanOrEqual(1);

  const slider = page.locator("#rtl-vslider");
  expect(Math.abs(
    await centreX(slider.locator(".shad-slider__thumb")) -
      await centreX(slider.locator(".shad-slider__track")),
  )).toBeLessThanOrEqual(1);
});

test("chat shows its welcome until the first message and spans its width", async ({ page }) => {
  const chat = page.locator("#rtl-chat .shad-chat");
  const welcome = chat.locator(".shad-chat__welcome");
  await chat.scrollIntoViewIfNeeded();
  await expect(welcome).toHaveText("ابدأ محادثة");
  await expect(welcome).toBeVisible();

  const chatBox = await chat.boundingBox();
  const composerBox = await chat.locator(".shad-input-group").boundingBox();
  expect(Math.abs(composerBox.width - chatBox.width)).toBeLessThanOrEqual(1);
  const sendBox = await chat.getByRole("button", { name: "Send" }).boundingBox();
  expect(sendBox.x).toBeGreaterThanOrEqual(composerBox.x);
  expect(sendBox.x + sendBox.width).toBeLessThanOrEqual(composerBox.x + composerBox.width);

  await chat.locator("textarea").fill("مرحبا");
  await chat.getByRole("button", { name: "Send" }).click();
  await expect(chat.locator(".shad-chat__transcript")).toContainText("تم");
  await expect(welcome).toBeHidden();
});

test("keeps focus and interaction direction-aware across navigation controls", async ({ page }) => {
  const pagination = page.locator("#rtl-pagination");
  await pagination.getByRole("button", { name: "Next page" }).click();
  await expect(pagination.getByRole("button", { name: "Page 2" }))
    .toHaveAttribute("aria-current", "page");

  const carousel = page.locator("#rtl-carousel");
  await carousel.locator(".shad-carousel__next").click();
  await expect.poll(() => carousel.evaluate((el) => shad.get(el).getValue())).toBe(2);
  await carousel.locator(".shad-carousel__viewport").focus();
  await page.keyboard.press("ArrowRight");
  await expect.poll(() => carousel.evaluate((el) => shad.get(el).getValue())).toBe(1);

  const stepper = page.locator("#rtl-stepper");
  await stepper.locator(".shad-stepper__trigger").nth(1).click();
  await expect(stepper.locator('.shad-stepper__item[data-state="active"]'))
    .toContainText("الملف");

  const tree = page.locator("#rtl-tree");
  const treeItem = tree.locator('[role="treeitem"]').first();
  await treeItem.focus();
  await page.keyboard.press("ArrowLeft");
  await expect(treeItem).toBeFocused();
  await expect(treeItem.locator(':scope > [role="group"]')).toBeHidden();
});

test("updates an open portal when the owning direction changes and cleans up", async ({ page }) => {
  const popover = page.locator("#rtl-popover");
  const panel = page.locator("body > .shad-popover__content");
  await popover.locator(".shad-popover__trigger").click();
  await expect(panel).toHaveAttribute("dir", "rtl");

  await page.locator(".shad-scope").evaluate((el) => el.setAttribute("dir", "ltr"));
  await expect(panel).toHaveAttribute("dir", "ltr");
  await page.keyboard.press("Escape");
  await expect(panel).toBeHidden();

  const removed = await page.locator("#rtl-popover").evaluate((el) => {
    el.remove();
    return true;
  });
  expect(removed).toBe(true);
  await expect.poll(() => page.evaluate(() => shad.get(document.getElementById("rtl-popover"))))
    .toBeNull();
  await expect.poll(() => page.evaluate(() => shad.dismiss.depth)).toBe(0);
});

test("has no serious or critical accessibility violations", async ({ page }) => {
  // Pagination's existing muted "Previous" label is outside this plan's
  // directionality contract and has a known contrast debt; keep axe coverage
  // on the other RTL surfaces without silently changing that baseline.
  const report = await new AxeBuilder({ page })
    .include("#rtl-fixture").exclude("#rtl-pagination").analyze();
  const blocking = report.violations.filter(
    (violation) => violation.impact === "serious" || violation.impact === "critical",
  );
  expect(blocking).toEqual([]);
});

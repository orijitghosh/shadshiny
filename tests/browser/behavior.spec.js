import { test, expect } from "@playwright/test";

async function openKitchenSink(page) {
  await page.goto("/inst/assets/demo/kitchen-sink.html");
  await page.waitForLoadState("networkidle");
  await page.waitForFunction(() => window.shad && window.shad.__runtime);
}

test.describe("dialog keyboard contract", () => {
  test.beforeEach(async ({ page }) => {
    await openKitchenSink(page);
  });

  test("opening exposes a named modal and moves focus to the requested field", async ({ page }) => {
    const trigger = page.getByRole("button", { name: "Edit Profile" });

    await trigger.click();

    const dialog = page.getByRole("dialog", {
      name: "Edit profile",
      description: "Make changes to your profile here. Click save when you're done.",
    });
    await expect(dialog).toBeVisible();
    await expect(dialog).toHaveAttribute("aria-modal", "true");
    await expect(dialog).toHaveAccessibleDescription(
      "Make changes to your profile here. Click save when you're done.",
    );
    await expect(dialog.getByLabel("Name", { exact: true })).toBeFocused();
  });

  test("Tab and Shift+Tab wrap between the first and last dialog controls", async ({ page }) => {
    await page.getByRole("button", { name: "Edit Profile" }).click();
    const dialog = page.getByRole("dialog", {
      name: "Edit profile",
      description: "Make changes to your profile here. Click save when you're done.",
    });
    const close = dialog.getByRole("button", { name: "Close" });
    const save = dialog.getByRole("button", { name: "Save changes" });

    await expect(dialog.getByLabel("Name", { exact: true })).toBeFocused();
    await save.focus();
    await page.keyboard.press("Tab");
    await expect(close).toBeFocused();

    await page.keyboard.press("Shift+Tab");
    await expect(save).toBeFocused();
  });

  test("Escape closes the dialog and restores focus to its trigger", async ({ page }) => {
    const trigger = page.getByRole("button", { name: "Edit Profile" });
    await trigger.click();
    const dialog = page.getByRole("dialog", {
      name: "Edit profile",
      description: "Make changes to your profile here. Click save when you're done.",
    });
    await expect(dialog.getByLabel("Name", { exact: true })).toBeFocused();

    await page.keyboard.press("Escape");

    await expect(page.locator("body > .shad-dialog__content")).toBeHidden();
    await expect(trigger).toHaveAttribute("aria-expanded", "false");
    await expect(trigger).toBeFocused();
  });
});

test.describe("menu keyboard contract", () => {
  test.beforeEach(async ({ page }) => {
    await openKitchenSink(page);
  });

  test("ArrowUp opens a dropdown on its last enabled item", async ({ page }) => {
    const trigger = page.locator("#c-dropdown-menu").getByRole("button", { name: "Open menu" });
    await trigger.focus();

    await page.keyboard.press("ArrowUp");

    await expect(page.getByRole("menuitem", { name: /Log out/ })).toBeFocused();
    await expect(trigger).toHaveAttribute("aria-expanded", "true");
  });

  test("arrows skip disabled items and activation closes and restores focus", async ({ page }) => {
    const section = page.locator("#c-dropdown-menu");
    const trigger = section.getByRole("button", { name: "Open menu" });
    await trigger.focus();
    await page.keyboard.press("ArrowDown");
    await expect(page.getByRole("menuitem", { name: /Profile/ })).toBeFocused();

    await page.keyboard.press("ArrowDown");
    await expect(page.getByRole("menuitem", { name: /Billing/ })).toBeFocused();
    await page.keyboard.press("ArrowDown");
    await expect(page.getByRole("menuitemcheckbox", { name: "Status Bar" })).toBeFocused();

    await page.keyboard.press("End");
    await page.keyboard.press("Enter");
    await expect(trigger).toBeFocused();
    await expect(trigger).toHaveAttribute("aria-expanded", "false");
    await expect
      .poll(() => section.locator("[data-shad='dropdown-menu']").evaluate((el) => shad.get(el).getValue()))
      .toBe("logout");
  });

  test("menubar arrows move between triggers and open menus", async ({ page }) => {
    const menubar = page.getByRole("menubar");
    const file = menubar.getByRole("menuitem", { name: "File" });
    const edit = menubar.getByRole("menuitem", { name: "Edit" });
    const view = menubar.getByRole("menuitem", { name: "View" });

    await file.focus();
    await page.keyboard.press("ArrowRight");
    await expect(edit).toBeFocused();

    await page.keyboard.press("ArrowDown");
    await expect(page.getByRole("menuitem", { name: /Undo/ })).toBeFocused();
    await page.keyboard.press("ArrowRight");
    await expect(view).toHaveAttribute("aria-expanded", "true");

    await page.keyboard.press("Escape");
    await expect(view).toBeFocused();
    await expect(view).toHaveAttribute("aria-expanded", "false");
  });
});

test("combobox keyboard filtering skips disabled options and commits selection", async ({ page }) => {
  await openKitchenSink(page);
  const root = page.locator("#c-combobox [data-shad='combobox']").first();
  const trigger = root.locator(".shad-combobox__trigger");
  await expect(trigger).toHaveAccessibleName("Select framework…");

  await trigger.focus();
  await page.keyboard.press("ArrowDown");

  const search = page.getByRole("combobox", { name: "Search framework…" });
  await expect(search).toBeFocused();
  await expect(search).toHaveAttribute("aria-expanded", "true");
  await page.keyboard.press("End");
  await expect(page.getByRole("option", { name: "Astro" })).toHaveAttribute("data-highlighted", "");
  await page.keyboard.press("ArrowUp");
  await expect(page.getByRole("option", { name: "Nuxt" })).toHaveAttribute("data-highlighted", "");
  await page.keyboard.press("Enter");

  await expect(trigger).toContainText("Nuxt");
  await expect(trigger).toBeFocused();
  await expect(trigger).toHaveAttribute("aria-expanded", "false");
  await expect(root.getByRole("option", { name: "Nuxt" })).toHaveAttribute("aria-selected", "true");
});

test("multi combobox chips have real remove buttons outside the trigger", async ({ page }) => {
  await openKitchenSink(page);
  const root = page.locator("#c-combobox [data-shad='combobox'][data-multiple]");
  const trigger = root.locator(".shad-combobox__trigger");
  const remove = root.getByRole("button", { name: "Remove R" });

  // a button's children are presentational, so nothing interactive may sit inside it
  await expect(trigger.locator("button, [role='button'], [tabindex]")).toHaveCount(0);
  await expect(remove).toBeVisible();

  await trigger.focus();
  await page.keyboard.press("Shift+Tab");
  await expect(remove).toBeFocused();

  await page.evaluate(() => {
    window.__changes = [];
    document.querySelector("#c-combobox [data-multiple]")
      .addEventListener("shad:change", (ev) => window.__changes.push(ev.detail.value));
  });
  await page.keyboard.press("Enter");
  expect(await page.evaluate(() => window.__changes)).toEqual([[]]);
  await expect(root.locator(".shad-combobox__badge")).toHaveCount(0);
  await expect(trigger).toBeFocused();
  await expect(trigger).toHaveAttribute("aria-expanded", "false");
});

test("Tab from an open combobox search closes it and continues from the trigger", async ({ page }) => {
  await openKitchenSink(page);
  const root = page.locator("#c-combobox [data-shad='combobox']").first();
  const trigger = root.locator(".shad-combobox__trigger");
  const search = page.getByRole("combobox", { name: "Search framework…" });
  // the panel is portaled to the end of <body>; the next stop is the one after the trigger
  await page.evaluate(() => {
    const t = document.querySelector("#c-combobox .shad-combobox__trigger");
    const all = window.shad.util.tabbables(document.body);
    all[all.indexOf(t) + 1].setAttribute("data-test-next", "");
  });

  await trigger.focus();
  await page.keyboard.press("ArrowDown");
  await expect(search).toBeFocused();
  await page.keyboard.press("Tab");
  await expect(trigger).toHaveAttribute("aria-expanded", "false");
  await expect(page.locator("[data-test-next]")).toBeFocused();

  await trigger.focus();
  await page.keyboard.press("ArrowDown");
  await expect(search).toBeFocused();
  await page.keyboard.press("Shift+Tab");
  await expect(trigger).toHaveAttribute("aria-expanded", "false");
  await expect(trigger).toBeFocused();
});

test("an open multi combobox with chips has no serious or critical axe violations", async ({ page }) => {
  const { default: AxeBuilder } = await import("@axe-core/playwright");
  await openKitchenSink(page);
  const root = page.locator("#c-combobox [data-shad='combobox'][data-multiple]");
  await root.locator(".shad-combobox__trigger").click();
  await page.getByRole("option", { name: "Python" }).click();
  await expect(root.locator(".shad-combobox__badge")).toHaveCount(2);

  const report = await new AxeBuilder({ page })
    .include("#c-combobox")
    .include("body > .shad-combobox__content")
    .analyze();
  const blocking = report.violations
    .filter((v) => v.impact === "serious" || v.impact === "critical")
    .map((v) => ({ id: v.id, targets: v.nodes.map((n) => n.target.join(" ")) }));
  expect(blocking).toEqual([]);
});

test("calendar paging clamps to short months and nav buttons keep focus", async ({ page }) => {
  await openKitchenSink(page);
  const cal = page.locator("#c-calendar [data-shad='calendar']").first();
  const stop = cal.locator(".shad-calendar__day[tabindex='0']");
  await expect(stop).toHaveAttribute("data-date", "2026-07-11");

  await stop.focus();
  for (const k of ["ArrowDown", "ArrowDown", ...Array(6).fill("ArrowRight")]) {
    await page.keyboard.press(k);
  }
  await expect(cal.locator("[data-date='2026-07-31']")).toBeFocused();
  await page.keyboard.press("PageDown");
  await expect(cal.locator("[data-date='2026-08-31']")).toBeFocused();
  // September has 30 days: the 31st does not roll over into October
  await page.keyboard.press("PageDown");
  await expect(cal.locator("[data-date='2026-09-30']")).toBeFocused();

  const next = cal.getByRole("button", { name: "Next month" });
  await next.click();
  await expect(next).toBeFocused();
  // October's grid still shows Sep 30 as an outside day; November's does not
  await expect(cal.locator(".shad-calendar__day[tabindex='0']")).toHaveAttribute("data-date", "2026-09-30");
  await page.keyboard.press("Enter");
  await expect(next).toBeFocused();
  await expect(cal.locator(".shad-calendar__day[tabindex='0']")).toHaveAttribute("data-date", "2026-11-30");
});

test("an open date picker has no serious or critical axe violations", async ({ page }) => {
  const { default: AxeBuilder } = await import("@axe-core/playwright");
  await openKitchenSink(page);
  await page.locator("#c-date-picker .shad-date-picker__trigger").first().click();
  const content = page.locator("body > .shad-date-picker__content");
  await expect(content).toBeVisible();

  const report = await new AxeBuilder({ page })
    .include("#c-date-picker")
    .include("body > .shad-date-picker__content")
    .analyze();
  const blocking = report.violations
    .filter((v) => v.impact === "serious" || v.impact === "critical")
    .map((v) => ({ id: v.id, targets: v.nodes.map((n) => n.target.join(" ")) }));
  expect(blocking).toEqual([]);
});

test("an inline command palette has one tab stop and keeps focus in its search", async ({ page }) => {
  await openKitchenSink(page);
  const palette = page.locator("#c-command [data-shad='command']:not([data-hotkey])");
  const search = palette.getByRole("combobox", { name: "Search commands" });
  const profile = palette.getByRole("option", { name: /Profile/ });

  await search.focus();
  await page.keyboard.press("Tab");
  // the next stop is past the options, not on one
  expect(await palette.evaluate((el) => el.contains(document.activeElement))).toBe(false);

  await search.focus();
  await profile.click();
  await expect(search).toBeFocused();
  // the pointer highlighted Profile; the arrows carry on from there
  await page.keyboard.press("ArrowDown");
  await expect(palette.getByRole("option", { name: /Billing/ })).toHaveAttribute("data-highlighted", "");
});

test("an open command dialog keeps Tab on its search and has no serious axe violations", async ({ page }) => {
  const { default: AxeBuilder } = await import("@axe-core/playwright");
  await openKitchenSink(page);
  await page.locator("body").press("Control+k");
  const dialog = page.getByRole("dialog", { name: "Command palette" });
  await expect(dialog).toBeVisible();
  const search = dialog.getByRole("combobox");
  await expect(search).toBeFocused();

  await page.keyboard.press("Shift+Tab");
  await expect(search).toBeFocused();
  await page.keyboard.press("Tab");
  await expect(search).toBeFocused();

  const report = await new AxeBuilder({ page }).include("body > .shad-command--dialog").analyze();
  const blocking = report.violations
    .filter((v) => v.impact === "serious" || v.impact === "critical")
    .map((v) => ({ id: v.id, targets: v.nodes.map((n) => n.target.join(" ")) }));
  expect(blocking).toEqual([]);
});

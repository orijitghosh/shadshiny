import { test, expect } from "@playwright/test";

const APP_URL = "http://127.0.0.1:4174";

test.skip(
  process.env.SHADSHINY_BROWSER_FIXTURE !== "utility-elements",
  "utility-elements fixture is selected by the dedicated utility browser command",
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

test("escapes hostile code, isolates line numbers, and preserves exact copied text", async ({ page }) => {
  const block = page.locator(".fixture-code");
  const code = block.locator("code");
  const gutter = block.locator(".shad-code-block__gutter");

  await expect(code).toContainText('<script>alert("x")</script>');
  await expect(block.locator("script")).toHaveCount(0);
  await expect(gutter).toHaveAttribute("aria-hidden", "true");
  await expect(gutter).toContainText("1");
  await expect(gutter).toContainText("2");

  const copied = await page.evaluate(() => {
    const block = document.querySelector(".fixture-code");
    const code = block.querySelector("code");
    const expected = code.textContent;
    let actual = null;
    Object.defineProperty(navigator, "clipboard", {
      configurable: true,
      value: { writeText: (value) => { actual = value; return Promise.resolve(); } },
    });
    block.querySelector("[data-shad-copy-code]").focus();
    block.querySelector("[data-shad-copy-code]").click();
    return new Promise((resolve) => setTimeout(() => resolve({
      expected, actual, focused: document.activeElement === block.querySelector("button"),
      status: block.querySelector('[role="status"]').textContent,
    }), 0));
  });
  expect(copied.actual).toBe(copied.expected);
  expect(copied.focused).toBe(true);
  expect(copied.status).toBe("Copied");
});

test("reports deterministic clipboard failure and re-announces on repeat", async ({ page }) => {
  const block = page.locator(".failure-code");
  await page.evaluate(() => {
    Object.defineProperty(navigator, "clipboard", {
      configurable: true,
      value: { writeText: () => Promise.reject(new Error("denied")) },
    });
  });
  const button = block.getByRole("button", { name: "Copy code" });
  await button.focus();
  await button.click();
  await expect(block.locator('[role="status"]')).toHaveText("Copy failed");
  await button.click();
  await expect(block.locator('[role="status"]')).toHaveText("Copy failed");
  await expect(button).toBeFocused();
});

test("supports keyboard scrolling, focus-visible styling, RTL, and both-axis masks", async ({ page }) => {
  const vertical = page.getByTestId("vertical-fade");
  await vertical.focus();
  await expect(vertical).toBeFocused();
  const before = await vertical.evaluate((el) => el.scrollTop);
  await vertical.press("PageDown");
  await expect.poll(() => vertical.evaluate((el) => el.scrollTop)).toBeGreaterThan(before);

  const horizontal = page.getByTestId("horizontal-fade");
  const horizontalState = await horizontal.evaluate((el) => {
    const style = getComputedStyle(el);
    return {
      overflowX: style.overflowX,
      direction: style.direction,
      mask: style.maskImage || style.webkitMaskImage,
    };
  });
  expect(horizontalState.overflowX).toBe("auto");
  expect(horizontalState.mask).toContain("gradient");

  const both = page.getByTestId("both-fade");
  const bothState = await both.evaluate((el) => {
    const style = getComputedStyle(el);
    return {
      direction: style.direction,
      mask: style.maskImage || style.webkitMaskImage,
      parentDirection: getComputedStyle(el.parentElement).direction,
    };
  });
  expect(bothState.direction).toBe("rtl");
  expect(bothState.parentDirection).toBe("rtl");
  expect((bothState.mask.match(/gradient/g) || []).length).toBeGreaterThanOrEqual(2);

  const focusOutline = await vertical.evaluate((el) => getComputedStyle(el).outlineStyle);
  expect(focusOutline).toBe("solid");
});

test("keeps shimmer readable in reduced motion, forced colors, and dark mode", async ({ page }) => {
  await page.emulateMedia({ reducedMotion: "reduce" });
  const active = page.getByTestId("shimmer-active");
  const inactive = page.getByTestId("shimmer-inactive");
  await expect(active).toHaveText("Loading");
  await expect(inactive).toHaveText("Ready");
  expect(await active.evaluate((el) => getComputedStyle(el).animationName)).toBe("none");

  await page.getByRole("button", { name: "Toggle dark mode" }).click();
  await expect(page.locator("html")).toHaveClass(/dark/);

  await page.emulateMedia({ forcedColors: "active" });
  const forced = await active.evaluate((el) => {
    const style = getComputedStyle(el);
    return { color: style.color, animation: style.animationName };
  });
  expect(forced.animation).toBe("none");
  expect(forced.color).not.toBe("rgba(0, 0, 0, 0)");
});

test("utility fixture has no serious or critical axe violations", async ({ page }) => {
  const { AxeBuilder } = await import("@axe-core/playwright");
  const results = await new AxeBuilder({ page }).analyze();
  const serious = results.violations.filter((v) => ["serious", "critical"].includes(v.impact));
  expect(serious, JSON.stringify(serious, null, 2)).toEqual([]);
});

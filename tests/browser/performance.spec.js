import { test, expect } from "@playwright/test";
import { browserPerformanceBudgets } from "../../tools/performance-budgets.mjs";

const kitchenSinkUrl = "/inst/assets/demo/kitchen-sink.html";

function percentile95(values) {
  const ordered = [...values].sort((a, b) => a - b);
  return ordered[Math.ceil(ordered.length * 0.95) - 1];
}

function reportSamples(label, values, budget) {
  const p95 = percentile95(values);
  console.log(
    `[performance] ${label}: p95=${p95.toFixed(2)} ms; ` +
      `budget=${budget.toFixed(2)} ms; samples=${values.map((value) => value.toFixed(2)).join(",")}`,
  );
  return p95;
}

test("kitchen-sink initialization stays within its p95 budget", async ({ page }) => {
  test.setTimeout(60_000);

  await page.addInitScript(() => {
    const target = {};
    const proxy = new Proxy(target, {
      set(object, property, value) {
        if (property === "autoInit" && typeof value === "function") {
          object[property] = function (...args) {
            const start = performance.now();
            const result = value.apply(this, args);
            (window.__shadPerformance ||= { autoInit: [] }).autoInit.push(
              performance.now() - start,
            );
            return result;
          };
        } else {
          object[property] = value;
        }
        return true;
      },
    });

    Object.defineProperty(window, "shad", {
      configurable: true,
      get: () => proxy,
      set: (value) => {
        if (value && value !== proxy) Object.assign(target, value);
      },
    });
  });

  const samples = [];
  for (let run = 0; run < browserPerformanceBudgets.startupRuns; run += 1) {
    await page.goto(kitchenSinkUrl, { waitUntil: "load" });
    const result = await page.evaluate(() => ({
      duration: window.__shadPerformance?.autoInit?.[0],
      roots: document.querySelectorAll("[data-shad]").length,
      initialized: [...document.querySelectorAll("[data-shad]")].filter(
        (element) => element.__shadInstance,
      ).length,
    }));

    expect(result.roots).toBeGreaterThan(0);
    expect(result.initialized).toBe(result.roots);
    expect(Number.isFinite(result.duration)).toBe(true);
    samples.push(result.duration);
  }

  const measured = samples.slice(browserPerformanceBudgets.startupWarmups);
  const p95 = reportSamples(
    "kitchen-sink autoInit",
    measured,
    browserPerformanceBudgets.kitchenSinkP95Ms,
  );
  expect(p95).toBeLessThanOrEqual(browserPerformanceBudgets.kitchenSinkP95Ms);
});

test("dynamic initialization and teardown stay within their p95 budgets", async ({ page }) => {
  await page.goto(kitchenSinkUrl, { waitUntil: "load" });

  const measurements = await page.evaluate(async ({ rounds, batchSize }) => {
    const source = document.querySelector("[data-shad='select']");
    if (!source) throw new Error("Kitchen-sink select fixture is missing");

    const waitFor = (condition, label) =>
      new Promise((resolve, reject) => {
        const deadline = performance.now() + 1_000;
        const check = () => {
          if (condition()) return resolve();
          if (performance.now() > deadline) {
            return reject(new Error(`Timed out waiting for dynamic ${label}`));
          }
          setTimeout(check, 0);
        };
        check();
      });

    const insert = [];
    const teardown = [];
    for (let round = 0; round < rounds; round += 1) {
      const container = document.createElement("div");
      container.hidden = true;
      const roots = [];

      for (let index = 0; index < batchSize; index += 1) {
        const clone = source.cloneNode(true);
        if (clone.id) clone.removeAttribute("id");
        clone.querySelectorAll("[id]").forEach((element) => element.removeAttribute("id"));
        roots.push(clone);
        container.appendChild(clone);
      }

      const insertStart = performance.now();
      document.body.appendChild(container);
      await waitFor(
        () => roots.every((element) => element.__shadInstance),
        "initialization",
      );
      insert.push(performance.now() - insertStart);

      const teardownStart = performance.now();
      container.remove();
      await waitFor(
        () => roots.every((element) => !element.__shadInstance),
        "teardown",
      );
      teardown.push(performance.now() - teardownStart);
    }

    return { insert, teardown };
  }, {
    rounds: browserPerformanceBudgets.dynamicRuns,
    batchSize: browserPerformanceBudgets.dynamicBatchSize,
  });

  const insertSamples = measurements.insert.slice(browserPerformanceBudgets.dynamicWarmups);
  const teardownSamples = measurements.teardown.slice(browserPerformanceBudgets.dynamicWarmups);
  const insertP95 = reportSamples(
    `dynamic initialization (${browserPerformanceBudgets.dynamicBatchSize} selects)`,
    insertSamples,
    browserPerformanceBudgets.dynamicInitP95Ms,
  );
  const teardownP95 = reportSamples(
    `dynamic teardown (${browserPerformanceBudgets.dynamicBatchSize} selects)`,
    teardownSamples,
    browserPerformanceBudgets.dynamicTeardownP95Ms,
  );

  expect(insertP95).toBeLessThanOrEqual(browserPerformanceBudgets.dynamicInitP95Ms);
  expect(teardownP95).toBeLessThanOrEqual(browserPerformanceBudgets.dynamicTeardownP95Ms);
});

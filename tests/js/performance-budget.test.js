import { fileURLToPath } from "node:url";
import { dirname, join } from "node:path";
import { describe, expect, test } from "vitest";
import {
  browserPerformanceBudgets,
  bundlePerformanceBudgets,
  evaluateBundleBudgets,
  measureBundlePerformance,
  percentile95,
} from "../../tools/performance-budgets.mjs";

const repoRoot = join(dirname(fileURLToPath(import.meta.url)), "..", "..");

describe("compressed distribution budgets", () => {
  test("the committed CSS and JavaScript bundles stay within transfer budgets", () => {
    const result = measureBundlePerformance(repoRoot);

    expect(result.ok, result.violations.join("\n")).toBe(true);
    // Budgets as decided for 0.4.0: CSS rose from 22 to 23 KiB (and the
    // combined from 64 to 65 KiB) to ship five more full-ramp palettes.
    expect(bundlePerformanceBudgets.assets.css.gzipBytes).toBe(23 * 1024);
    expect(bundlePerformanceBudgets.assets.javascript.gzipBytes).toBe(42 * 1024);
    expect(bundlePerformanceBudgets.combinedGzipBytes).toBe(65 * 1024);
    expect(result.assets.css.gzipBytes).toBeLessThanOrEqual(23 * 1024);
    expect(result.assets.javascript.gzipBytes).toBeLessThanOrEqual(42 * 1024);
    expect(result.combinedGzipBytes).toBeLessThanOrEqual(65 * 1024);
    expect(result.assets.css.brotliBytes).toBeGreaterThan(0);
    expect(result.assets.javascript.brotliBytes).toBeGreaterThan(0);
  });

  test("approved moderate JavaScript growth remains inside the transfer envelope", () => {
    const result = evaluateBundleBudgets({
      css: { rawBytes: 150_000, gzipBytes: 21 * 1024, brotliBytes: 17_000 },
      javascript: { rawBytes: 155_000, gzipBytes: 41 * 1024, brotliBytes: 35_000 },
    });

    expect(result.ok, result.violations.join("\n")).toBe(true);
    expect(result.combinedGzipBytes).toBe(62 * 1024);
  });

  test("an over-budget asset reports the asset and exact excess", () => {
    const result = evaluateBundleBudgets(
      {
        css: { rawBytes: 30_000, gzipBytes: 24 * 1024, brotliBytes: 18_000 },
        javascript: { rawBytes: 1_000, gzipBytes: 1_000, brotliBytes: 900 },
      },
      bundlePerformanceBudgets,
    );

    expect(result.ok).toBe(false);
    expect(result.assets.css.gzipBytes).toBe(24 * 1024);
    expect(result.combinedGzipBytes).toBe(24 * 1024 + 1_000);
    expect(result.violations).toEqual([
      "CSS gzip 24.00 KiB exceeds its 23.00 KiB budget by 1.00 KiB",
    ]);
  });
});

describe("browser timing budgets", () => {
  test("p95 is the nearest-rank 95th percentile", () => {
    const samples = Array.from({ length: 20 }, (_, index) => index + 1);
    expect(percentile95(samples)).toBe(19);
    expect(percentile95([...samples].reverse())).toBe(19);
    expect(percentile95([5, 1, 3])).toBe(5);
  });

  test("each timing gate measures enough samples that one outlier cannot decide it", () => {
    const gates = {
      startup: browserPerformanceBudgets.startupRuns - browserPerformanceBudgets.startupWarmups,
      dynamic: browserPerformanceBudgets.dynamicRuns - browserPerformanceBudgets.dynamicWarmups,
    };
    for (const [gate, count] of Object.entries(gates)) {
      // Typical samples with one scheduler hiccup far over any budget.
      const samples = Array.from({ length: count }, () => 5);
      samples[Math.floor(count / 2)] = 1_000;
      expect(percentile95(samples), gate).toBe(5);
    }
  });
});

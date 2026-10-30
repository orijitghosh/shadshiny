import { fileURLToPath } from "node:url";
import { dirname, join } from "node:path";
import { describe, expect, test } from "vitest";
import {
  bundlePerformanceBudgets,
  evaluateBundleBudgets,
  measureBundlePerformance,
} from "../../tools/performance-budgets.mjs";

const repoRoot = join(dirname(fileURLToPath(import.meta.url)), "..", "..");

describe("compressed distribution budgets", () => {
  test("the committed CSS and JavaScript bundles stay within transfer budgets", () => {
    const result = measureBundlePerformance(repoRoot);

    expect(result.ok, result.violations.join("\n")).toBe(true);
    expect(result.assets.css.gzipBytes).toBeLessThanOrEqual(22 * 1024);
    expect(result.assets.javascript.gzipBytes).toBeLessThanOrEqual(42 * 1024);
    expect(result.combinedGzipBytes).toBeLessThanOrEqual(64 * 1024);
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
        css: { rawBytes: 30_000, gzipBytes: 23 * 1024, brotliBytes: 18_000 },
        javascript: { rawBytes: 1_000, gzipBytes: 1_000, brotliBytes: 900 },
      },
      bundlePerformanceBudgets,
    );

    expect(result.ok).toBe(false);
    expect(result.assets.css.gzipBytes).toBe(23 * 1024);
    expect(result.combinedGzipBytes).toBe(23 * 1024 + 1_000);
    expect(result.violations).toEqual([
      "CSS gzip 23.00 KiB exceeds its 22.00 KiB budget by 1.00 KiB",
    ]);
  });
});

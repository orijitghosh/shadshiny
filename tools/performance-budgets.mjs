import { readFileSync } from "node:fs";
import { join } from "node:path";
import {
  brotliCompressSync,
  constants as zlibConstants,
  gzipSync,
} from "node:zlib";

const kibibyte = 1024;

export const bundlePerformanceBudgets = Object.freeze({
  assets: Object.freeze({
    css: Object.freeze({
      label: "CSS",
      path: "inst/assets/dist/shadshiny.min.css",
      gzipBytes: 23 * kibibyte,
    }),
    javascript: Object.freeze({
      label: "JavaScript",
      path: "inst/assets/dist/shadshiny.min.js",
      gzipBytes: 42 * kibibyte,
    }),
  }),
  combinedGzipBytes: 65 * kibibyte,
});

// Each timing gate keeps 20 samples after its warmups, so p95 is the
// second-slowest sample and one scheduler hiccup cannot fail it alone.
export const browserPerformanceBudgets = Object.freeze({
  startupRuns: 21,
  startupWarmups: 1,
  kitchenSinkP95Ms: 125,
  dynamicRuns: 22,
  dynamicWarmups: 2,
  dynamicBatchSize: 20,
  dynamicInitP95Ms: 25,
  dynamicTeardownP95Ms: 25,
});

// The nearest-rank 95th percentile. With fewer than 20 samples it is the
// slowest sample, so a single scheduler hiccup decides the result.
export function percentile95(values) {
  const ordered = [...values].sort((a, b) => a - b);
  return ordered[Math.ceil(ordered.length * 0.95) - 1];
}

export function formatKibibytes(bytes) {
  return `${(bytes / kibibyte).toFixed(2)} KiB`;
}

export function measureCompressedBytes(buffer) {
  return {
    rawBytes: buffer.byteLength,
    gzipBytes: gzipSync(buffer, { level: 9 }).byteLength,
    brotliBytes: brotliCompressSync(buffer, {
      params: {
        [zlibConstants.BROTLI_PARAM_QUALITY]: 11,
      },
    }).byteLength,
  };
}

export function evaluateBundleBudgets(measurements, budgets = bundlePerformanceBudgets) {
  const assets = {};
  const violations = [];

  for (const [key, budget] of Object.entries(budgets.assets)) {
    const measured = measurements[key];
    if (!measured) throw new Error(`Missing performance measurement for ${key}`);

    assets[key] = {
      ...measured,
      label: budget.label,
      path: budget.path,
      gzipBudgetBytes: budget.gzipBytes,
    };
    if (measured.gzipBytes > budget.gzipBytes) {
      violations.push(
        `${budget.label} gzip ${formatKibibytes(measured.gzipBytes)} exceeds its ` +
          `${formatKibibytes(budget.gzipBytes)} budget by ` +
          `${formatKibibytes(measured.gzipBytes - budget.gzipBytes)}`,
      );
    }
  }

  const combinedGzipBytes = Object.values(assets).reduce(
    (total, asset) => total + asset.gzipBytes,
    0,
  );
  if (combinedGzipBytes > budgets.combinedGzipBytes) {
    violations.push(
      `Combined gzip ${formatKibibytes(combinedGzipBytes)} exceeds its ` +
        `${formatKibibytes(budgets.combinedGzipBytes)} budget by ` +
        `${formatKibibytes(combinedGzipBytes - budgets.combinedGzipBytes)}`,
    );
  }

  return {
    ok: violations.length === 0,
    assets,
    combinedGzipBytes,
    combinedGzipBudgetBytes: budgets.combinedGzipBytes,
    violations,
  };
}

export function measureBundlePerformance(repoRoot, budgets = bundlePerformanceBudgets) {
  const measurements = {};
  for (const [key, budget] of Object.entries(budgets.assets)) {
    measurements[key] = measureCompressedBytes(readFileSync(join(repoRoot, budget.path)));
  }
  return evaluateBundleBudgets(measurements, budgets);
}

export function formatBundlePerformanceReport(result) {
  const lines = ["Compressed bundle performance budgets"];
  for (const asset of Object.values(result.assets)) {
    lines.push(
      `${asset.label}: raw ${formatKibibytes(asset.rawBytes)}; ` +
        `gzip ${formatKibibytes(asset.gzipBytes)} / ` +
        `${formatKibibytes(asset.gzipBudgetBytes)} budget; ` +
        `brotli ${formatKibibytes(asset.brotliBytes)}`,
    );
  }
  lines.push(
    `Combined gzip: ${formatKibibytes(result.combinedGzipBytes)} / ` +
      `${formatKibibytes(result.combinedGzipBudgetBytes)} budget`,
  );
  lines.push(result.ok ? "Performance bundle budget: PASS" : "Performance bundle budget: FAIL");
  result.violations.forEach((violation) => lines.push(`- ${violation}`));
  return lines.join("\n");
}

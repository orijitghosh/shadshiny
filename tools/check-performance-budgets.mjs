import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import {
  formatBundlePerformanceReport,
  measureBundlePerformance,
} from "./performance-budgets.mjs";

const repoRoot = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const result = measureBundlePerformance(repoRoot);

console.log(formatBundlePerformanceReport(result));
if (!result.ok) process.exitCode = 1;

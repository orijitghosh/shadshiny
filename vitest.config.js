import { defineConfig } from "vitest/config";

export default defineConfig({
  test: {
    // Each file gets a fresh jsdom document; the runtime keeps module-level
    // state (the component registry, the dismiss stack), so tests must not
    // share a global.
    environment: "jsdom",
    include: ["tests/js/**/*.test.js"],
    restoreMocks: true
  }
});

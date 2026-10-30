import { describe, expect, test } from "vitest";

import {
  browserFixtureNames,
  resolveBrowserFixture,
} from "../../tools/browser-fixtures.mjs";

describe("browser fixture registry", () => {
  test("covers every fixture-gated browser suite", () => {
    expect(browserFixtureNames()).toEqual([
      "rtl",
      "questionnaire",
      "field-family",
      "chat-workbench",
      "server-data-table",
      "utility-elements",
    ]);
  });

  test.each([
    ["rtl", "rtl.spec.js", "rtl-app"],
    ["questionnaire", "questionnaire.spec.js", "questionnaire-app"],
    ["field-family", "field-family.spec.js", "field-family"],
    ["chat-workbench", "chat-workbench.spec.js", "chat-workbench-app"],
    ["server-data-table", "server-data-table.spec.js", "server-data-table"],
    ["utility-elements", "utility-elements.spec.js", "utility-elements"],
  ])("maps %s to its spec and Shiny app", (name, spec, app) => {
    expect(resolveBrowserFixture(name)).toEqual({ name, spec, app });
  });

  test("rejects unknown fixture names", () => {
    expect(() => resolveBrowserFixture("missing")).toThrow(
      "Unknown browser fixture: missing",
    );
  });
});

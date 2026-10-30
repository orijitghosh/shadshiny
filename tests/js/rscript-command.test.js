import { expect, test } from "vitest";

import { resolveRscript } from "../../tools/rscript-command.mjs";

test("uses PATH-selected Rscript by default", () => {
  expect(resolveRscript({})).toBe("Rscript");
  expect(resolveRscript({ SHADSHINY_RSCRIPT: "" })).toBe("Rscript");
});

test("honors an explicit Rscript override", () => {
  expect(resolveRscript({ SHADSHINY_RSCRIPT: "D:/R/bin/Rscript.exe" })).toBe(
    "D:/R/bin/Rscript.exe",
  );
});

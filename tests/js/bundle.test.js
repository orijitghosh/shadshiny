/* The committed bundle (inst/assets/dist) is what installed copies of the
   package actually load, so it needs the same smoke test the sources get:
   minification must not have broken the runtime or dropped a component. */
import { describe, it, expect, beforeEach } from "vitest";
import { readFileSync, existsSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { dirname, resolve } from "node:path";
import { loadAsset, mount } from "./helpers.js";

const here = dirname(fileURLToPath(import.meta.url));
const dist = resolve(here, "../../inst/assets/dist");
const built = existsSync(resolve(dist, "shadshiny.min.js"));

describe.skipIf(!built)("bundled assets", () => {
  beforeEach(() => {
    document.body.innerHTML = "";
    delete window.shad;
    loadAsset("dist/shadshiny.min.js");
  });

  it("exposes the runtime API", () => {
    expect(window.shad).toBeTruthy();
    for (const fn of ["register", "init", "get", "destroy", "autoInit"]) {
      expect(typeof window.shad[fn]).toBe("function");
    }
  });

  it("registers every component the sources register", () => {
    const sources = readFileSync(resolve(dist, "manifest.json"), "utf8");
    const componentJs = JSON.parse(sources).js.filter((p) => p.startsWith("components/"));
    // one shad.register() call per component file, and they all survived
    expect(componentJs.length).toBeGreaterThan(30);
    const min = readFileSync(resolve(dist, "shadshiny.min.js"), "utf8");
    for (const path of componentJs) {
      const name = path.split("/")[1];
      expect(min, `${name} missing from bundle`).toContain(`"${name}"`);
    }
  });

  it("still initialises a component", () => {
    const root = mount(`
      <div class="shad-accordion" data-shad="accordion">
        <div class="shad-accordion__item" data-state="closed">
          <h3><button class="shad-accordion__trigger" type="button">One</button></h3>
          <div class="shad-accordion__content"><p>Body</p></div>
        </div>
      </div>`);
    const trigger = root.querySelector(".shad-accordion__trigger");
    trigger.click();
    expect(root.querySelector(".shad-accordion__item").dataset.state).toBe("open");
  });

  it("ships the stylesheet with tokens first", () => {
    const css = readFileSync(resolve(dist, "shadshiny.min.css"), "utf8");
    expect(css).toContain("--shad-");
    expect(css.indexOf("--shad-space-4")).toBeLessThan(css.indexOf(".shad-accordion"));
  });
});

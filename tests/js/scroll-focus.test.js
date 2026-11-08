/* The scroll/focus contract.

   Two rules, both about a local interaction never becoming a page-level side
   effect:

     1. No component calls scrollIntoView(). It walks every scrollable ancestor,
        so a component in ordinary document flow drags the whole page to itself.
        shad.util.keepInView(container, item) scrolls one container.
     2. Pointer-driven focus() passes {preventScroll: true} – the user can
        already see what they clicked. Keyboard roving focus deliberately does
        not, because the user needs to see where focus landed. */
import { describe, test, expect, beforeEach, vi } from "vitest";
import { readFileSync, readdirSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { dirname, resolve, join } from "node:path";
import { loadRuntime, mount, rect, key } from "./helpers.js";

const ASSETS = resolve(dirname(fileURLToPath(import.meta.url)), "../../inst/assets");

function assetFiles() {
  const out = [join(ASSETS, "core/shad-runtime.js"),
               join(ASSETS, "shiny/shadshiny-shiny.js")];
  const comps = join(ASSETS, "components");
  for (const dir of readdirSync(comps)) {
    const js = join(comps, dir, `${dir}.js`);
    try { readFileSync(js); out.push(js); } catch { /* CSS-only component */ }
  }
  return out;
}

describe("no asset scrolls the page", () => {
  test("scrollIntoView / scrollIntoViewIfNeeded appear nowhere but in comments", () => {
    const offenders = [];
    for (const file of assetFiles()) {
      const lines = readFileSync(file, "utf8").split("\n");
      lines.forEach((line, i) => {
        const code = line.replace(/^\s*(\/\/|\*|\/\*).*/, "");
        if (/scrollIntoView(IfNeeded)?\s*\(/.test(code)) {
          offenders.push(`${file.replace(ASSETS, "")}:${i + 1}`);
        }
      });
    }
    expect(offenders).toEqual([]);
  });

  test("every focus() call is either preventScroll or keyboard roving focus", () => {
    // The exceptions are deliberate and few; if this list needs to grow, the
    // new case had better be keyboard navigation too.
    const allowed = [
      "/components/combobox/combobox.js",   // leave(), Tab out of the portaled search
      "/components/rating/rating.js",       // focusCurrent(), arrow keys
      "/components/tree/tree.js",           // arrow-key tree walk
      "/core/shad-runtime.js"               // focus trap Tab wrap-around
    ];
    const offenders = [];
    for (const file of assetFiles()) {
      const rel = file.replace(ASSETS, "").replace(/\\/g, "/");
      if (allowed.includes(rel)) continue;
      readFileSync(file, "utf8").split("\n").forEach((line, i) => {
        if (/\.focus\(\s*\)/.test(line)) offenders.push(`${rel}:${i + 1}`);
      });
    }
    expect(offenders).toEqual([]);
  });
});

describe("shad.util.keepInView", () => {
  let shad, list, item;
  beforeEach(() => {
    document.body.innerHTML = "";
    delete window.shad;
    shad = loadRuntime();
    mount('<div id="list"><div id="item"></div></div>');
    list = document.getElementById("list");
    item = document.getElementById("item");
    rect(list, { top: 100, bottom: 200, height: 100 });
    list.scrollTop = 40;
  });

  test("scrolls down just enough when the item is below the fold", () => {
    rect(item, { top: 230, bottom: 250, height: 20 });
    shad.util.keepInView(list, item);
    expect(list.scrollTop).toBe(90); // 40 + (250 - 200)
  });

  test("scrolls up just enough when the item is above it", () => {
    rect(item, { top: 70, bottom: 90, height: 20 });
    shad.util.keepInView(list, item);
    expect(list.scrollTop).toBe(10); // 40 - (100 - 70)
  });

  test("does nothing when the item is already visible", () => {
    rect(item, { top: 120, bottom: 140, height: 20 });
    shad.util.keepInView(list, item);
    expect(list.scrollTop).toBe(40);
  });

  test("never touches the window", () => {
    rect(item, { top: 230, bottom: 250, height: 20 });
    const scrollTo = vi.spyOn(window, "scrollTo").mockImplementation(() => {});
    shad.util.keepInView(list, item);
    expect(scrollTo).not.toHaveBeenCalled();
    expect(window.scrollY).toBe(0);
  });

  test("tolerates a missing container or item", () => {
    expect(() => shad.util.keepInView(null, item)).not.toThrow();
    expect(() => shad.util.keepInView(list, null)).not.toThrow();
  });
});

describe("select highlights without moving the page", () => {
  const MARKUP = `
    <div data-shad="select" id="sel">
      <button class="shad-select__trigger"><span class="shad-select__value"></span></button>
      <div class="shad-select__content" hidden>
        <div class="shad-select__viewport">
          <div class="shad-select__item" data-value="a">A</div>
          <div class="shad-select__item" data-value="b">B</div>
        </div>
      </div>
    </div>`;

  let shad, root;
  beforeEach(() => {
    document.body.innerHTML = "";
    delete window.shad;
    shad = loadRuntime("select");
    root = mount(MARKUP);
  });

  test("the viewport scrolls, the page does not", () => {
    const inst = shad.get(root);
    const viewport = root.querySelector(".shad-select__viewport");
    const b = root.querySelector('[data-value="b"]');
    rect(viewport, { top: 0, bottom: 40, height: 40 });
    rect(b, { top: 60, bottom: 80, height: 20 });
    viewport.scrollTop = 0;

    inst.open();
    key(root.querySelector(".shad-select__trigger"), "ArrowDown");

    expect(viewport.scrollTop).toBe(40);
    expect(window.scrollY).toBe(0);
  });

  test("selecting with the pointer refocuses the trigger without scrolling", () => {
    const inst = shad.get(root);
    const trigger = root.querySelector(".shad-select__trigger");
    const focus = vi.spyOn(trigger, "focus");

    inst.open();
    // the panel is portaled to <body> on open, so query the document
    document.querySelector('.shad-select__item[data-value="b"]').dispatchEvent(
      new window.MouseEvent("click", { bubbles: true }));

    expect(focus).toHaveBeenCalledWith({ preventScroll: true });
    expect(inst.getValue()).toBe("b");
  });
});

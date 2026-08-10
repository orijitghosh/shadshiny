/* Harness for the browser assets.
   -------------------------------------------------------------------------
   The assets are plain scripts that assign to window.shad — no modules and no
   build step, which is the whole point of the library. So the harness does what
   the browser does: read the file and run it in the current jsdom window.

   jsdom has no layout engine. getBoundingClientRect() is all zeros,
   scrollIntoView is a no-op stub, and offsetWidth is 0. Tests that care about
   geometry have to stub rects (see rect()); anything that genuinely depends on
   layout belongs in the shinytest2 suites, which drive real Chrome. */
import { readFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { dirname, resolve } from "node:path";
import { vi } from "vitest";

const here = dirname(fileURLToPath(import.meta.url));
const ASSETS = resolve(here, "../../inst/assets");

/** Run one asset file in the current window, the way a <script> tag would. */
export function loadAsset(relPath) {
  const code = readFileSync(resolve(ASSETS, relPath), "utf8");
  // indirect eval -> global scope, so `const shad = ...` inside the IIFE and
  // any window assignment behave exactly as in the browser.
  window.eval(code);
}

/** The runtime, plus any component files named (e.g. "command"). */
export function loadRuntime(...components) {
  loadAsset("core/shad-runtime.js");
  for (const name of components) {
    loadAsset(`components/${name}/${name}.js`);
  }
  return window.shad;
}

/** Put markup in the document body and wire it up. Returns the root element. */
export function mount(html, { init = true } = {}) {
  document.body.innerHTML = html;
  const root = document.body.firstElementChild;
  if (init) window.shad.init(document);
  return root;
}

/**
 * Give an element a fake bounding box. jsdom returns zeros for everything,
 * which makes "is this visible / does this overflow" logic untestable
 * otherwise.
 */
export function rect(el, box) {
  const full = {
    x: 0, y: 0, top: 0, left: 0, right: 0, bottom: 0, width: 0, height: 0,
    ...box
  };
  vi.spyOn(el, "getBoundingClientRect").mockReturnValue({
    ...full,
    toJSON: () => full
  });
  return el;
}

/** Collect events of `type` dispatched on (or through) `el`. */
export function record(el, type) {
  const seen = [];
  el.addEventListener(type, (ev) => seen.push(ev.detail ?? {}));
  return seen;
}

/**
 * A bubbling pointerdown. jsdom ships no PointerEvent constructor, and the
 * runtime only reads `target`, so a plain Event is a faithful stand-in.
 */
export function press(el) {
  el.dispatchEvent(new window.Event("pointerdown", { bubbles: true }));
}

/** A keydown that bubbles, the way a real one does. */
export function key(el, k, opts = {}) {
  const ev = new window.KeyboardEvent("keydown", {
    key: k, bubbles: true, cancelable: true, ...opts
  });
  el.dispatchEvent(ev);
  return ev;
}

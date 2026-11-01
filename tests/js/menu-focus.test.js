/* Contract: a menu that closes before its first frame keeps focus where the
   close put it. Opening highlights the first (or last) item one frame later,
   and a closing panel stays on screen for its exit animation, so without a
   check that frame would pull focus back into the panel (the menubar Escape
   flake in tests/browser/behavior.spec.js). */
import { describe, it, expect, beforeEach, afterEach, vi } from "vitest";
import { loadRuntime, mount, key } from "./helpers.js";

const menu = (name, items) => `<div data-shad-menubar-menu>
  <button type="button" class="shad-menubar__trigger">${name}</button>
  <div class="shad-menu__content shad-anim-pop" hidden>
    ${items.map((v) => `<button type="button" class="shad-menu__item" data-value="${v}">${v}</button>`).join("")}
  </div></div>`;
const menubar = `<div class="shad-menubar" data-shad="menubar">
  ${menu("File", ["new", "open"])}${menu("Edit", ["undo", "redo"])}${menu("View", ["reload"])}</div>`;
const dropdown = `<div data-shad="dropdown-menu">
  <button type="button" class="shad-menu__trigger">Open</button>
  <div class="shad-menu__content shad-anim-pop" hidden>
    <button type="button" class="shad-menu__item" data-value="a">A</button>
    <button type="button" class="shad-menu__item" data-value="b">B</button>
  </div></div>`;

let frames;
const flush = () => { const run = frames; frames = []; run.forEach((f) => f(0)); };

beforeEach(() => {
  document.body.innerHTML = "";
  delete window.shad;
  frames = [];
  vi.stubGlobal("requestAnimationFrame", (f) => { frames.push(f); return frames.length; });
  loadRuntime("dropdown-menu", "menubar");
});
afterEach(() => vi.unstubAllGlobals());

const trigger = (root, name) => Array.from(root.querySelectorAll(".shad-menubar__trigger"))
  .find((t) => t.textContent === name);

describe("menubar", () => {
  it("keeps focus on the trigger when Escape beats the first frame", () => {
    const root = mount(menubar);
    const edit = trigger(root, "Edit");
    edit.focus();
    key(edit, "ArrowDown");
    key(document.activeElement, "Escape");
    flush();
    expect(document.activeElement).toBe(edit);
    expect(root.querySelector("[data-highlighted]")).toBeNull();
  });

  it("highlights only the menu it switched to", () => {
    const root = mount(menubar);
    const edit = trigger(root, "Edit");
    edit.focus();
    key(edit, "ArrowDown");
    key(document.activeElement, "ArrowRight");
    flush();
    expect(document.activeElement.textContent).toBe("reload");
    expect(document.querySelectorAll("[data-highlighted]")).toHaveLength(1);
  });

  it("still highlights the first item when the menu stays open", () => {
    const root = mount(menubar);
    const file = trigger(root, "File");
    file.focus();
    key(file, "ArrowDown");
    flush();
    expect(document.activeElement.textContent).toBe("new");
  });
});

describe("dropdown menu", () => {
  it("keeps focus on the trigger when Escape beats the first frame", () => {
    const root = mount(dropdown);
    const btn = root.querySelector(".shad-menu__trigger");
    btn.focus();
    key(btn, "ArrowUp");
    key(document.activeElement, "Escape");
    flush();
    expect(document.activeElement).toBe(btn);
  });
});

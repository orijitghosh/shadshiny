/* Contract: the chips of a multiple combobox, and leaving its open panel by
   keyboard.

   1. Chips render in div.shad-combobox__chips just before the trigger. Nothing
      interactive sits inside the trigger: a button's children are
      presentational, so a control there can never be reached.
   2. Each chip has a real <button type="button"> named "Remove <label>".
      Labels and values stay text.
   3. Click, Delete or Backspace on a remove button drops that value and fires
      one shad:change. If the button had focus, focus moves to the next chip's
      button, else the previous one, else the trigger.
   4. With the panel open, removing a chip leaves the panel open and focus in
      the search input.
   5. While chips show, the trigger's value span carries their labels (visually
      hidden) so the trigger keeps a name; with none it shows the placeholder.
   6. A disabled combobox renders disabled remove buttons and ignores clicks on
      its chips.
   7. Clicking a chip's text toggles the panel, as the trigger does.
   8. destroy() and a fresh init reuse the chip container: no duplicates.
   9. Tab in the open search input closes the panel and moves focus to the next
      tabbable after the trigger (the trigger itself if there is none).
      Shift+Tab closes it and focuses the trigger. */
import { describe, it, expect, beforeEach } from "vitest";
import { loadRuntime, mount, record, key, rect } from "./helpers.js";

const HOSTILE = '<img src=x onerror="window.__pwned=1">';
const esc = (s) => s.replace(/&/g, "&amp;").replace(/</g, "&lt;")
  .replace(/>/g, "&gt;").replace(/"/g, "&quot;");

const OPTIONS = [
  { value: "r", label: "R", checked: true },
  { value: "py", label: "Python", checked: true },
  { value: "jl", label: "Julia", checked: true },
  { value: "x", label: HOSTILE }
];

const combobox = ({ multiple = true, disabled = false } = {}) => `
  <div class="shad-combobox" data-shad="combobox" id="langs"${multiple ? " data-multiple" : ""}>
    <button type="button" class="shad-combobox__trigger"${disabled ? " disabled" : ""}>
      <span class="shad-combobox__value" data-placeholder-text="Pick languages">Pick languages</span>
    </button>
    <div class="shad-combobox__content" hidden>
      <input class="shad-combobox__input" type="text">
      <div class="shad-combobox__list">
        ${OPTIONS.map((o) => `<div class="shad-combobox__item" data-value="${esc(o.value)}"` +
          ` data-state="${multiple && o.checked ? "checked" : "unchecked"}">${esc(o.label)}</div>`)
          .join("")}
      </div>
      <div class="shad-combobox__empty" hidden>No results.</div>
    </div>
  </div>
  <button type="button" id="after">After</button>`;

const parts = (root) => ({
  trigger: root.querySelector(".shad-combobox__trigger"),
  value: root.querySelector(".shad-combobox__value"),
  input: document.querySelector(".shad-combobox__input"),
  removes: () => Array.from(root.querySelectorAll(".shad-combobox__badge-x")),
  inst: window.shad.get(root)
});

beforeEach(() => loadRuntime("combobox"));

describe("combobox chips", () => {
  it("renders chips beside the trigger with real remove buttons (1, 2)", () => {
    const root = mount(combobox());
    const { trigger, removes } = parts(root);
    const box = root.querySelector(".shad-combobox__chips");
    expect(box.nextElementSibling).toBe(trigger);
    expect(trigger.querySelectorAll("button, [role='button'], [tabindex]").length).toBe(0);
    expect(removes().map((b) => [b.tagName, b.type, b.getAttribute("aria-label")])).toEqual([
      ["BUTTON", "button", "Remove R"],
      ["BUTTON", "button", "Remove Python"],
      ["BUTTON", "button", "Remove Julia"]
    ]);
  });

  it("keeps labels and values as text (2)", () => {
    const root = mount(combobox());
    parts(root).inst.setValue(["x"]);
    const [x] = parts(root).removes();
    expect(x.getAttribute("aria-label")).toBe("Remove " + HOSTILE);
    expect(x.getAttribute("data-remove")).toBe("x");
    expect(root.querySelector(".shad-combobox__badge img")).toBeNull();
    expect(window.__pwned).toBeUndefined();
  });

  it("removes a chip by click, Delete or Backspace, moving focus along (3)", () => {
    const root = mount(combobox());
    const { trigger, removes } = parts(root);
    const seen = record(root, "shad:change");

    removes()[1].focus();
    removes()[1].click();
    expect(seen.map((d) => d.value)).toEqual([["r", "jl"]]);
    expect(document.activeElement).toBe(removes()[1]);      // Julia, the next one

    key(removes()[1], "Delete");
    expect(seen.at(-1).value).toEqual(["r"]);
    expect(document.activeElement).toBe(removes()[0]);      // R, the previous one

    key(removes()[0], "Backspace");
    expect(seen.at(-1).value).toEqual([]);
    expect(seen.length).toBe(3);
    expect(document.activeElement).toBe(trigger);
  });

  it("leaves focus alone when the removed chip did not have it (3)", () => {
    const root = mount(combobox());
    const { removes } = parts(root);
    document.getElementById("after").focus();
    removes()[0].click();
    expect(document.activeElement.id).toBe("after");
  });

  it("keeps the panel open and focus in the search when removing while open (4)", () => {
    const root = mount(combobox());
    const { inst, input, removes } = parts(root);
    inst.open();
    expect(document.activeElement).toBe(input);
    removes()[0].click();
    expect(inst.isOpen).toBe(true);
    expect(document.activeElement).toBe(input);
    expect(inst.getValue()).toEqual(["py", "jl"]);
  });

  it("keeps the trigger named while chips show (5)", () => {
    const root = mount(combobox());
    const { trigger, value, inst } = parts(root);
    expect(value.textContent).toBe("R, Python, Julia");
    expect(value.classList.contains("shad-sr-only")).toBe(true);
    expect(trigger.hasAttribute("data-placeholder")).toBe(false);

    inst.setValue(null);
    expect(value.textContent).toBe("Pick languages");
    expect(value.classList.contains("shad-sr-only")).toBe(false);
    expect(trigger.hasAttribute("data-placeholder")).toBe(true);
  });

  it("disables the remove buttons of a disabled combobox (6)", () => {
    const root = mount(combobox({ disabled: true }));
    const { inst, removes } = parts(root);
    const seen = record(root, "shad:change");
    expect(removes().every((b) => b.disabled)).toBe(true);
    root.querySelector(".shad-combobox__badge").click();
    removes()[0].dispatchEvent(new window.MouseEvent("click", { bubbles: true }));
    expect(seen).toEqual([]);
    expect(inst.isOpen).toBe(false);
  });

  it("toggles the panel from a chip's text (7)", () => {
    const root = mount(combobox());
    const { inst } = parts(root);
    const chip = root.querySelector(".shad-combobox__badge");
    chip.click();
    expect(inst.isOpen).toBe(true);
    chip.click();
    expect(inst.isOpen).toBe(false);
    expect(inst.getValue()).toEqual(["r", "py", "jl"]);
  });

  it("reuses the chip container across destroy and init (8)", () => {
    const root = mount(combobox());
    window.shad.destroy(root);
    window.shad.init(document);
    expect(root.querySelectorAll(".shad-combobox__chips").length).toBe(1);
    expect(parts(root).removes().length).toBe(3);
  });
});

describe("leaving the open combobox panel by keyboard (9)", () => {
  for (const multiple of [false, true]) {
    const mode = multiple ? "multiple" : "single";

    it(`${mode}: Tab closes and moves to the next tabbable after the trigger`, () => {
      const root = mount(combobox({ multiple }));
      const { inst, input } = parts(root);
      const after = rect(document.getElementById("after"), { width: 40, height: 20 });
      inst.open();
      const ev = key(input, "Tab");
      expect(ev.defaultPrevented).toBe(true);
      expect(inst.isOpen).toBe(false);
      expect(document.activeElement).toBe(after);
    });

    it(`${mode}: Tab with nothing after the trigger focuses the trigger`, () => {
      const root = mount(combobox({ multiple }));
      const { inst, input, trigger } = parts(root);
      document.getElementById("after").remove();
      inst.open();
      key(input, "Tab");
      expect(inst.isOpen).toBe(false);
      expect(document.activeElement).toBe(trigger);
    });

    it(`${mode}: Shift+Tab closes and focuses the trigger`, () => {
      const root = mount(combobox({ multiple }));
      const { inst, input, trigger } = parts(root);
      rect(document.getElementById("after"), { width: 40, height: 20 });
      inst.open();
      const ev = key(input, "Tab", { shiftKey: true });
      expect(ev.defaultPrevented).toBe(true);
      expect(inst.isOpen).toBe(false);
      expect(document.activeElement).toBe(trigger);
    });
  }
});

/* Contract: command palette options, refresh, keyboard and hotkey.

   Options and refresh: the markup, and what update_shad_command() swaps in
   (the binding calls refresh() after it).
   1. Every item is an option: role=option, a unique id, and tabindex=-1, so
      the search input is the palette's only tab stop and the arrows move
      through the options. A disabled item also has aria-disabled="true".
   2. A group with a heading is role=group, named by that heading.
   3. refresh() re-reads the list: the replacement empty text, groups and
      separators follow the current query, and the first match is
      highlighted.
   4. aria-activedescendant names the highlighted option, and is removed when
      nothing is highlighted, so it never points at a hidden or removed item.

   Keyboard and pointer
   5. Keys pressed while an IME composition is in progress belong to the IME:
      Enter does not activate and the arrows do not move.
   6. Pressing an item with the pointer keeps focus in the search input; the
      click still activates it.

   Hotkey (data-hotkey)
   7. "+"-separated modifiers, then the key, in any case: mod (Ctrl or Cmd),
      ctrl, meta (cmd), alt (option), shift; "space" names the space bar.
      Every named modifier must be held and no other Ctrl, Cmd or Alt. Shift
      must match too, except for a symbol key such as "/" or "?", which some
      layouts type with Shift. When a letter key types a non-Latin character
      (another keyboard layout, or Option on a Mac), the physical key counts.
      A hotkey naming an unknown modifier never fires and console.warn says
      so.
   8. A hotkey without Ctrl, Cmd or Alt does not fire while focus is in an
      editable field (input, textarea, select, contenteditable), the palette's
      own search included, so typing that character still works.
   9. Keydown events without a key (browser autofill sends them), auto-repeats
      and IME compositions are ignored, and nothing throws.

   Lifecycle
   10. destroy() on an open dialog palette removes its overlay and releases
       the scroll lock. */
import { describe, it, expect, beforeEach, afterEach, vi } from "vitest";
import { loadRuntime, mount, key, record, rect } from "./helpers.js";

const ITEMS = `
  <div class="shad-command__empty">No results found.</div>
  <div class="shad-command__group">
    <div class="shad-command__group-heading">Go to</div>
    <button type="button" class="shad-command__item" data-value="calendar">Calendar</button>
    <button type="button" class="shad-command__item" data-value="off" data-disabled>Disabled</button>
  </div>
  <div class="shad-command__separator"></div>
  <div class="shad-command__group">
    <div class="shad-command__group-heading">Settings</div>
    <button type="button" class="shad-command__item" data-value="profile">Profile</button>
  </div>`;

const palette = (attrs = "") => `
  <div data-shad="command" id="cmd" ${attrs}>
    <div class="shad-command__header"><input class="shad-command__input" type="text"></div>
    <div class="shad-command__list">${ITEMS}</div>
  </div>
  <input id="field" type="text">
  <textarea id="notes"></textarea>
  <div id="editor" contenteditable="true"></div>`;

let root, input, list, inst, warn;
// a palette's hotkey listens on document: destroy each one, or it keeps
// answering keys in later tests
function teardown() {
  if (root) window.shad.destroy(root);
  root = null;
}
function setup(attrs) {
  teardown();
  root = mount(palette(attrs));
  input = root.querySelector(".shad-command__input");
  list = root.querySelector(".shad-command__list");
  inst = window.shad.get(root);
  return inst;
}
function type(text) {
  input.value = text;
  input.dispatchEvent(new window.Event("input", { bubbles: true }));
}
const options = () => Array.from(list.querySelectorAll(".shad-command__item"));
const highlighted = () => list.querySelector("[data-highlighted]");

beforeEach(() => {
  document.body.innerHTML = "";
  document.body.removeAttribute("style");   // a palette left open keeps its scroll lock
  delete window.shad;
  loadRuntime("command");
  warn = vi.spyOn(console, "warn").mockImplementation(() => {});
});
afterEach(() => {
  teardown();
  warn.mockRestore();
});

describe("options and refresh", () => {
  function expectOptions() {
    const ids = options().map((it) => it.id);
    expect(ids.every(Boolean)).toBe(true);
    expect(new Set(ids).size).toBe(ids.length);
    for (const it of options()) {
      expect(it.getAttribute("role")).toBe("option");
      expect(it.getAttribute("tabindex")).toBe("-1");
      expect(it.getAttribute("aria-disabled")).toBe(it.hasAttribute("data-disabled") ? "true" : null);
    }
    // jsdom has no layout, and tabbables() leaves out zero-size boxes
    for (const el of [input, ...options()]) rect(el, { width: 10, height: 10 });
    expect(window.shad.util.tabbables(root)).toEqual([input]);
  }
  function expectGroups() {
    for (const g of list.querySelectorAll(".shad-command__group")) {
      expect(g.getAttribute("role")).toBe("group");
      const heading = g.querySelector(".shad-command__group-heading");
      expect(heading.id).not.toBe("");
      expect(g.getAttribute("aria-labelledby")).toBe(heading.id);
    }
  }

  it("makes every item an option and the input the only tab stop (1, 2)", () => {
    setup();
    expectOptions();
    expectGroups();
  });

  it("does the same for items the server swaps in (1, 2, 3)", () => {
    setup();
    type("re");
    list.innerHTML = ITEMS.replace("No results found.", "Nothing recent")
      .replace("Profile", "Recent Q3").replace('"profile"', '"q3"');
    inst.refresh();
    expectOptions();
    expectGroups();
    // the query still applies
    expect(options().filter((it) => !it.hidden).map((it) => it.dataset.value)).toEqual(["q3"]);
    expect(highlighted().dataset.value).toBe("q3");

    type("zzz");
    const empty = list.querySelector(".shad-command__empty");
    expect(empty.hidden).toBe(false);
    expect(empty.textContent).toBe("Nothing recent");
    expect(list.querySelector(".shad-command__separator").hidden).toBe(true);
  });

  it("drops aria-activedescendant when nothing is highlighted (4)", () => {
    setup();
    expect(input.getAttribute("aria-activedescendant")).toBe(highlighted().id);
    type("zzz");
    expect(highlighted()).toBeNull();
    expect(input.hasAttribute("aria-activedescendant")).toBe(false);

    type("");
    list.innerHTML = '<div class="shad-command__empty">None</div>';
    inst.refresh();
    expect(input.hasAttribute("aria-activedescendant")).toBe(false);
  });
});

describe("keyboard and pointer", () => {
  it("leaves keys to an IME composition (5)", () => {
    setup();
    const seen = record(root, "shad:change");
    key(input, "ArrowDown", { isComposing: true });
    expect(highlighted().dataset.value).toBe("calendar");
    key(input, "Enter", { isComposing: true });
    expect(seen).toEqual([]);
    key(input, "Enter");
    expect(seen).toEqual([{ value: "calendar" }]);
  });

  it("keeps focus in the search when an item is pressed (6)", () => {
    setup();
    const item = list.querySelector('[data-value="profile"]');
    const down = new window.MouseEvent("mousedown", { bubbles: true, cancelable: true });
    item.dispatchEvent(down);
    expect(down.defaultPrevented).toBe(true);
    const seen = record(root, "shad:change");
    item.click();
    expect(seen).toEqual([{ value: "profile" }]);
  });
});

describe("hotkey", () => {
  const press = (target, k, opts) => key(target, k, opts);

  it("needs exactly the modifiers it names (7)", () => {
    const pal = setup('data-hotkey="mod+shift+p"');
    expect(press(document.body, "p", { ctrlKey: true }).defaultPrevented).toBe(false); // Print
    expect(pal.isOpen).toBe(false);
    press(document.body, "P", { ctrlKey: true, shiftKey: true, altKey: true });
    expect(pal.isOpen).toBe(false);
    press(document.body, "P", { ctrlKey: true, shiftKey: true });
    expect(pal.isOpen).toBe(true);
  });

  it("does not let mod+k fire on Ctrl+Shift+K (7)", () => {
    const pal = setup('data-hotkey="mod+k"');
    press(document.body, "K", { ctrlKey: true, shiftKey: true });
    expect(pal.isOpen).toBe(false);
    press(document.body, "k", { metaKey: true });
    expect(pal.isOpen).toBe(true);
  });

  it("reads ctrl, cmd and alt as modifiers, not as nothing (7)", () => {
    const pal = setup('data-hotkey="Ctrl+K"');
    press(document.body, "k");
    press(document.body, "k", { metaKey: true });
    expect(pal.isOpen).toBe(false);
    press(document.body, "k", { ctrlKey: true });
    expect(pal.isOpen).toBe(true);

    const other = setup('data-hotkey="cmd+alt+j"');
    press(document.body, "j", { metaKey: true });
    expect(other.isOpen).toBe(false);
    press(document.body, "j", { metaKey: true, altKey: true });
    expect(other.isOpen).toBe(true);
  });

  it("lets a symbol key come with Shift, and knows space (7)", () => {
    const pal = setup('data-hotkey="/"');
    press(document.body, "/", { shiftKey: true });           // Shift+7 on a German layout
    expect(pal.isOpen).toBe(true);

    const spaced = setup('data-hotkey="alt+space"');
    press(document.body, " ", { altKey: true });
    expect(spaced.isOpen).toBe(true);
  });

  it("uses the physical key when a letter types another script (7)", () => {
    const pal = setup('data-hotkey="mod+k"');
    press(document.body, "л", { ctrlKey: true, code: "KeyK" }); // Russian layout
    expect(pal.isOpen).toBe(true);
  });

  it("never fires a hotkey with an unknown modifier, and says so (7)", () => {
    const pal = setup('data-hotkey="hyper+k"');
    press(document.body, "k");
    press(document.body, "k", { ctrlKey: true });
    expect(pal.isOpen).toBe(false);
    expect(warn).toHaveBeenCalledTimes(1);
    expect(String(warn.mock.calls[0])).toContain("hyper+k");
  });

  it("leaves a plain hotkey to editable fields (8)", () => {
    const pal = setup('data-hotkey="/"');
    for (const id of ["field", "notes", "editor"]) {
      const ev = press(document.getElementById(id), "/");
      expect(pal.isOpen).toBe(false);
      expect(ev.defaultPrevented).toBe(false);
    }
    press(document.body, "/");
    expect(pal.isOpen).toBe(true);
    // typing "/" in the palette's own search does not close it
    press(input, "/");
    expect(pal.isOpen).toBe(true);
  });

  it("still fires a modifier hotkey from a text field (8)", () => {
    const pal = setup('data-hotkey="mod+k"');
    press(document.getElementById("field"), "k", { ctrlKey: true });
    expect(pal.isOpen).toBe(true);
  });

  it("ignores key-less events, repeats and compositions (9)", () => {
    const pal = setup('data-hotkey="mod+k"');
    const errors = [];
    const onError = (ev) => errors.push(ev.error);
    window.addEventListener("error", onError);
    try {
      document.body.dispatchEvent(new window.Event("keydown", { bubbles: true }));
      press(document.body, "k", { ctrlKey: true, repeat: true });
      press(document.body, "k", { ctrlKey: true, isComposing: true });
    } finally {
      window.removeEventListener("error", onError);
    }
    expect(errors).toEqual([]);
    expect(pal.isOpen).toBe(false);
  });
});

describe("lifecycle", () => {
  it("cleans up when destroyed while open (10)", () => {
    vi.useFakeTimers();
    try {
      const pal = setup('data-hotkey="mod+k"');
      pal.open();
      expect(document.querySelector(".shad-command__overlay")).not.toBeNull();
      expect(document.body.style.overflow).toBe("hidden");
      window.shad.destroy(root);
      vi.advanceTimersByTime(600);   // the exit-animation fallback
      expect(document.querySelector(".shad-command__overlay")).toBeNull();
      expect(document.body.style.overflow).toBe("");
    } finally {
      vi.useRealTimers();
    }
  });
});

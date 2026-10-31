/* Contract: what select and combobox do with a value set from the server
   (setValue, reached through update_shad_select() / update_shad_combobox()).

   1. Values compare as strings. Numbers and booleans are converted with
      String(); the R updaters already send as.character().
   2. null, undefined, "" and [] clear the input: placeholder shown, value null
      (single) or [] (multiple).
   3. Single mode takes a scalar or a one-element array. A longer array is
      ignored with a warning.
   4. A value that is not one of the options is ignored: the selection stays,
      no shad:change fires, and console.warn names the value once.
   5. Multiple mode drops duplicate and unknown entries (warning about the
      unknown ones) and keeps the rest in the order sent. If no entry is an
      option, the whole update is ignored.
   6. Setting the current value again fires nothing.
   7. The server may set a disabled option; disabled only stops the user.
   8. Values and labels are text. A value that looks like markup never becomes
      DOM in the trigger or in a chip. */
import { describe, it, expect, beforeEach, afterEach, vi } from "vitest";
import { loadRuntime, mount } from "./helpers.js";

const HOSTILE = '<img src=x onerror="window.__pwned=1">';
const esc = (s) => s.replace(/&/g, "&amp;").replace(/</g, "&lt;")
  .replace(/>/g, "&gt;").replace(/"/g, "&quot;");

const OPTIONS = [
  { value: "1", label: "One" },
  { value: "2", label: "Two" },
  { value: "3", label: "Three", disabled: true },
  { value: HOSTILE, label: HOSTILE }
];

const item = (cls, o) =>
  `<div class="${cls}" data-value="${esc(o.value)}" data-state="unchecked"` +
  `${o.disabled ? " data-disabled" : ""}>${esc(o.label)}</div>`;

const select = () => `
  <div class="shad-select" data-shad="select" id="pick">
    <button type="button" class="shad-select__trigger" data-placeholder>
      <span class="shad-select__value" data-placeholder-text="Pick one">Pick one</span>
    </button>
    <div class="shad-select__content" hidden>
      <div class="shad-select__viewport">
        ${OPTIONS.map((o) => item("shad-select__item", o)).join("")}
      </div>
    </div>
  </div>`;

const combobox = (multiple) => `
  <div class="shad-combobox" data-shad="combobox" id="pick"${multiple ? " data-multiple" : ""}>
    <button type="button" class="shad-combobox__trigger" data-placeholder>
      <span class="shad-combobox__value" data-placeholder-text="Pick one">Pick one</span>
    </button>
    <div class="shad-combobox__content" hidden>
      <input class="shad-combobox__input" type="text">
      <div class="shad-combobox__list">
        ${OPTIONS.map((o) => item("shad-combobox__item", o)).join("")}
      </div>
      <div class="shad-combobox__empty" hidden>No results.</div>
    </div>
  </div>`;

const record = (root) => {
  const seen = [];
  root.addEventListener("shad:change", (ev) => seen.push(ev.detail.value));
  return seen;
};

let warn;
beforeEach(() => {
  warn = vi.spyOn(console, "warn").mockImplementation(() => {});
});
afterEach(() => {
  warn.mockRestore();
  delete window.__pwned;
});

const warned = () => warn.mock.calls.map((args) => args.map(String).join(" "));

// Single-value behavior is the same contract for select and single combobox.
const SINGLE = [
  { name: "select", component: "select", markup: select, value: ".shad-select__value" },
  { name: "combobox (single)", component: "combobox", markup: () => combobox(false),
    value: ".shad-combobox__value" }
];

for (const kind of SINGLE) {
  describe(`${kind.name} server values`, () => {
    beforeEach(() => loadRuntime(kind.component));

    const setup = () => {
      const root = mount(kind.markup());
      return { root, inst: window.shad.get(root), changes: record(root) };
    };

    it("matches numbers against the string option values", () => {
      const { root, inst, changes } = setup();
      inst.setValue(2);
      expect(inst.getValue()).toBe("2");
      expect(root.querySelector(kind.value).textContent).toBe("Two");
      expect(changes).toEqual(["2"]);
    });

    it("ignores a value that is not an option, and warns once", () => {
      const { root, inst, changes } = setup();
      inst.setValue("1");
      changes.length = 0;
      inst.setValue("zzz");
      expect(inst.getValue()).toBe("1");
      expect(root.querySelector(kind.value).textContent).toBe("One");
      expect(changes).toEqual([]);
      expect(warn).toHaveBeenCalledTimes(1);
      expect(warned()[0]).toContain("zzz");
      expect(warned()[0]).toContain("pick");
    });

    it("clears on null, an empty string and an empty array", () => {
      const { root, inst } = setup();
      for (const empty of [null, "", []]) {
        inst.setValue("1");
        inst.setValue(empty);
        expect(inst.getValue()).toBe(null);
        expect(root.querySelector(kind.value).textContent).toBe("Pick one");
      }
      expect(warn).not.toHaveBeenCalled();
    });

    it("takes a one-element array and ignores a longer one", () => {
      const { inst, changes } = setup();
      inst.setValue(["2"]);
      expect(inst.getValue()).toBe("2");
      inst.setValue(["1", "2"]);
      expect(inst.getValue()).toBe("2");
      expect(changes).toEqual(["2"]);
      expect(warn).toHaveBeenCalledTimes(1);
    });

    it("fires nothing when the value is already set", () => {
      const { inst, changes } = setup();
      inst.setValue("1");
      inst.setValue("1");
      inst.setValue(1);
      expect(changes).toEqual(["1"]);
    });

    it("lets the server set a disabled option", () => {
      const { inst } = setup();
      inst.setValue("3");
      expect(inst.getValue()).toBe("3");
      expect(warn).not.toHaveBeenCalled();
    });

    it("renders a markup-looking value as text", () => {
      const { root, inst } = setup();
      inst.setValue(HOSTILE);
      expect(inst.getValue()).toBe(HOSTILE);
      expect(root.querySelector(kind.value).textContent).toBe(HOSTILE);
      expect(root.querySelector("img")).toBe(null);
      expect(window.__pwned).toBeUndefined();
    });
  });
}

describe("combobox (multiple) server values", () => {
  beforeEach(() => loadRuntime("combobox"));

  const setup = () => {
    const root = mount(combobox(true));
    return { root, inst: window.shad.get(root), changes: record(root) };
  };
  const chips = (root) => Array.from(root.querySelectorAll(".shad-combobox__badge"))
    .map((chip) => chip.textContent);

  it("converts numbers and drops duplicates, keeping the order sent", () => {
    const { inst, changes } = setup();
    inst.setValue([2, "1", 2]);
    expect(inst.getValue()).toEqual(["2", "1"]);
    expect(changes).toEqual([["2", "1"]]);
  });

  it("wraps a scalar and clears on null, an empty string and an empty array", () => {
    const { inst } = setup();
    for (const empty of [null, "", []]) {
      inst.setValue("1");
      expect(inst.getValue()).toEqual(["1"]);
      inst.setValue(empty);
      expect(inst.getValue()).toEqual([]);
    }
    expect(warn).not.toHaveBeenCalled();
  });

  it("drops unknown entries with one warning and keeps the rest", () => {
    const { root, inst, changes } = setup();
    inst.setValue(["2", "zzz", "1"]);
    expect(inst.getValue()).toEqual(["2", "1"]);
    expect(chips(root)).toEqual(["Two", "One"]);
    expect(changes).toEqual([["2", "1"]]);
    expect(warn).toHaveBeenCalledTimes(1);
    expect(warned()[0]).toContain("zzz");
  });

  it("ignores an update in which nothing is an option", () => {
    const { inst, changes } = setup();
    inst.setValue(["1"]);
    changes.length = 0;
    inst.setValue(["zzz", "yyy"]);
    expect(inst.getValue()).toEqual(["1"]);
    expect(changes).toEqual([]);
    expect(warn).toHaveBeenCalledTimes(1);
  });

  it("renders a markup-looking value as chip text", () => {
    const { root, inst } = setup();
    inst.setValue([HOSTILE]);
    expect(chips(root)).toEqual([HOSTILE]);
    expect(root.querySelector("img")).toBe(null);
    expect(window.__pwned).toBeUndefined();
  });
});

/* Inputs that can be cleared must be able to get back to their empty state,
   from the user and from the server, without leaving a stale label behind. */
import { describe, it, expect, beforeEach } from "vitest";
import { loadRuntime, mount } from "./helpers.js";

const record = (root) => {
  const seen = [];
  root.addEventListener("shad:change", (ev) => seen.push(ev.detail.value));
  return seen;
};

// The R constructors render the selected label into the value span, so the
// placeholder has to travel separately as data-placeholder-text.
const select = (selected) => `
  <div class="shad-select" data-shad="select">
    <button type="button" class="shad-select__trigger"${selected ? "" : " data-placeholder"}>
      <span class="shad-select__value" data-placeholder-text="Pick a fruit">${selected ? "Banana" : "Pick a fruit"}</span>
    </button>
    <div class="shad-select__content" hidden>
      <div class="shad-select__viewport">
        <div class="shad-select__item" data-value="apple" data-state="unchecked">Apple</div>
        <div class="shad-select__item" data-value="banana" data-state="${selected ? "checked" : "unchecked"}">Banana</div>
      </div>
    </div>
  </div>`;

const combobox = (selected) => `
  <div class="shad-combobox" data-shad="combobox" data-state="closed">
    <button type="button" class="shad-combobox__trigger"${selected ? "" : " data-placeholder"}>
      <span class="shad-combobox__value" data-placeholder-text="Pick a fruit">${selected ? "Apple" : "Pick a fruit"}</span>
    </button>
    <div class="shad-combobox__content" hidden>
      <input class="shad-combobox__input" type="text">
      <div class="shad-combobox__list">
        <div class="shad-combobox__item" data-value="apple" data-state="${selected ? "checked" : "unchecked"}">Apple</div>
        <div class="shad-combobox__item" data-value="pear" data-state="unchecked">Pear</div>
      </div>
      <div class="shad-combobox__empty" hidden>No results.</div>
    </div>
  </div>`;

describe("select", () => {
  beforeEach(() => loadRuntime("select"));

  it("shows the placeholder, not the initial label, after a server clear", () => {
    const root = mount(select(true));
    const trigger = root.querySelector(".shad-select__trigger");
    window.shad.get(root).setValue(null);
    expect(window.shad.get(root).getValue()).toBe(null);
    expect(root.querySelector(".shad-select__value").textContent).toBe("Pick a fruit");
    expect(trigger.hasAttribute("data-placeholder")).toBe(true);
  });

  it("names the listbox after the placeholder, not the initial label", () => {
    const root = mount(select(true));
    expect(root.querySelector(".shad-select__viewport").getAttribute("aria-label"))
      .toBe("Pick a fruit");
  });

  it("still reads the placeholder from hand-written markup", () => {
    const root = mount(select(false).replace(' data-placeholder-text="Pick a fruit"', ""));
    window.shad.get(root).setValue("apple");
    window.shad.get(root).setValue(null);
    expect(root.querySelector(".shad-select__value").textContent).toBe("Pick a fruit");
  });
});

describe("combobox (single)", () => {
  beforeEach(() => loadRuntime("combobox"));

  it("shows the placeholder, not the initial label, after a server clear", () => {
    const root = mount(combobox(true));
    window.shad.get(root).setValue(null);
    expect(root.querySelector(".shad-combobox__value").textContent).toBe("Pick a fruit");
    expect(root.querySelector(".shad-combobox__trigger").hasAttribute("data-placeholder")).toBe(true);
  });

  it("clears the value when the selected item is picked again", () => {
    const root = mount(combobox(true));
    const changes = record(root);
    const cbx = window.shad.get(root);
    cbx.open();
    document.querySelector('.shad-combobox__item[data-value="apple"]').click();
    expect(cbx.getValue()).toBe(null);
    expect(changes).toEqual([null]);
    expect(root.querySelector(".shad-combobox__value").textContent).toBe("Pick a fruit");
    expect(document.querySelector('.shad-combobox__item[data-value="apple"]')
      .getAttribute("aria-selected")).toBe("false");

    cbx.open();
    document.querySelector('.shad-combobox__item[data-value="apple"]').click();
    expect(cbx.getValue()).toBe("apple");
    expect(changes).toEqual([null, "apple"]);
  });
});

describe("calendar (single)", () => {
  beforeEach(() => loadRuntime("calendar"));
  const day = (iso) => document.querySelector(`.shad-calendar__day[data-date="${iso}"]`);

  it("clears the value when the selected day is picked again", () => {
    const root = mount('<div data-shad="calendar" class="shad-calendar" ' +
      'data-mode="single" data-value="2026-06-15"></div>');
    const changes = record(root);
    day("2026-06-15").click();
    expect(window.shad.get(root).getValue()).toBe(null);
    expect(day("2026-06-15").hasAttribute("data-selected")).toBe(false);
    day("2026-06-15").click();
    expect(window.shad.get(root).getValue()).toBe("2026-06-15");
    expect(changes).toEqual([null, "2026-06-15"]);
  });

  it("leaves range selection alone: the start day again closes a one-day range", () => {
    const root = mount('<div data-shad="calendar" class="shad-calendar" ' +
      'data-mode="range" data-value="2026-06-15"></div>');
    day("2026-06-15").click();
    expect(window.shad.get(root).getValue())
      .toEqual({ start: "2026-06-15", end: "2026-06-15" });
  });
});

describe("checkbox", () => {
  beforeEach(() => loadRuntime("checkbox"));
  const box = (attrs) =>
    mount(`<button type="button" data-shad="checkbox" class="shad-checkbox" ${attrs}></button>`);
  const states = (root, n) => Array.from({ length: n }, () => {
    root.click();
    return [root.getAttribute("data-state"), root.getAttribute("aria-checked")];
  });

  it("keeps the Radix two-state click cycle by default", () => {
    const root = box('data-state="indeterminate"');
    const changes = record(root);
    expect(states(root, 3)).toEqual([
      ["checked", "true"], ["unchecked", "false"], ["checked", "true"]
    ]);
    expect(changes).toEqual([true, false, true]);
  });

  it("cycles unchecked, checked, indeterminate with data-tristate", () => {
    const root = box('data-state="unchecked" data-tristate');
    const changes = record(root);
    expect(states(root, 4)).toEqual([
      ["checked", "true"], ["indeterminate", "mixed"],
      ["unchecked", "false"], ["checked", "true"]
    ]);
    expect(changes).toEqual([true, "indeterminate", false, true]);
  });

  it("does not cycle a disabled tri-state box", () => {
    const root = box('data-state="indeterminate" data-tristate data-disabled disabled');
    root.dispatchEvent(new MouseEvent("click", { bubbles: true }));
    expect(window.shad.get(root).getValue()).toBe("indeterminate");
  });
});

describe("number stepper", () => {
  beforeEach(() => loadRuntime("number-stepper"));

  it("ignores a null or non-numeric server value instead of showing NaN", () => {
    const root = mount(`
      <div class="shad-number-stepper" data-shad="number-stepper">
        <button type="button" data-action="decrement"></button>
        <input class="shad-number-stepper__input" value="4">
        <button type="button" data-action="increment"></button>
      </div>`);
    const changes = record(root);
    const stepper = window.shad.get(root);
    stepper.setValue(null);
    stepper.setValue("abc");
    expect(stepper.getValue()).toBe(4);
    expect(root.querySelector("input").value).toBe("4");
    expect(changes).toEqual([]);
  });
});

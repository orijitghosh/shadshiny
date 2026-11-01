/* Contract: a field's label, description and error reach the part of a
   component that takes focus. shad_form_field(), and every constructor given
   `label` or `description`, wraps the control; form-field.js wires it.
   1. A native input keeps its <label for>.
   2. A component root is a <div>, which a <label for> cannot name. The label
      names the part that takes focus instead, with aria-labelledby: a root
      with its own role (radio group, rating), else its first input, button
      or slider thumb (select, combobox and date picker triggers, OTP and
      number inputs).
   3. A trigger that is a plain button keeps its own text after the label, so
      the chosen value is still read ("Fruit Apple"), and so does each thumb
      of a range slider ("Price Minimum"). The select trigger is a combobox:
      the label alone names it, and its text is its value.
   4. The description, and an error once shown, describe that same part, and
      an error marks it aria-invalid as well as the root.
   5. A select trigger has role=combobox, so the aria-activedescendant it
      keeps while open is valid ARIA; with no field label its placeholder
      names it.
   (Names as Chromium computes them, and axe on each open state:
   tests/browser/shiny.spec.js.) */
import { describe, it, expect, beforeEach } from "vitest";
import { loadRuntime, mount } from "./helpers.js";

const chevron = '<svg aria-hidden="true"></svg>';
const field = (label, control, extra = "") => `<div class="shad-form-field" data-shad="form-field">
  <label class="shad-label">${label}</label>${control}${extra}
  <p class="shad-form-field__error" hidden></p></div>`;

// as shad_select() renders it
const select = (role = ' role="combobox"') => `<div class="shad-select" data-shad="select" id="sel">
  <button type="button" class="shad-select__trigger"${role}>
    <span class="shad-select__value" data-placeholder-text="Select...">Apple</span>${chevron}</button>
  <div class="shad-select__content shad-anim-pop" hidden>
    <div class="shad-select__viewport">
      <div class="shad-select__item" role="option" data-value="a" data-state="checked">Apple</div>
      <div class="shad-select__item" role="option" data-value="b" data-state="unchecked">Banana</div>
    </div></div></div>`;
const combobox = `<div class="shad-combobox" data-shad="combobox" id="cbx" data-state="closed">
  <button type="button" class="shad-combobox__trigger">
    <span class="shad-combobox__value" data-placeholder-text="Select...">Apple</span>${chevron}</button>
  <div class="shad-combobox__content shad-anim-pop" hidden>
    <div class="shad-combobox__search"><input class="shad-combobox__input" type="text" placeholder="Search..."/></div>
    <div class="shad-combobox__list">
      <div class="shad-combobox__item" role="option" data-value="a" data-state="checked">Apple</div>
    </div></div></div>`;
const datePicker = `<div class="shad-date-picker" data-shad="date-picker" id="dp">
  <button type="button" class="shad-date-picker__trigger">${chevron}<span class="shad-date-picker__value">Pick a date</span></button>
  <div class="shad-date-picker__content shad-anim-pop" hidden>
    <div class="shad-calendar" data-shad="calendar" data-mode="single" data-value="2026-10-14" data-week-start="0"></div>
  </div></div>`;
const radioGroup = `<div class="shad-radio-group" data-shad="radio-group" id="rad" role="radiogroup">
  <div class="shad-radio-row"><button type="button" class="shad-radio" role="radio" data-value="f" data-state="unchecked" id="rad-1"></button>
  <label class="shad-label" for="rad-1">Free</label></div></div>`;
const rating = '<div class="shad-rating" id="rate" data-shad="rating" role="radiogroup" data-value="3" data-max="5"></div>';
const slider = `<div class="shad-slider" data-shad="slider" id="sld" data-min="0" data-max="100" data-step="1" data-value="30">
  <div class="shad-slider__track"><div class="shad-slider__range"></div></div>
  <div class="shad-slider__thumb" role="slider" tabindex="0" aria-label="Value"></div></div>`;
const range = `<div class="shad-slider" data-shad="slider" id="rng" data-min="0" data-max="100" data-step="1" data-value="20" data-value2="80">
  <div class="shad-slider__track"><div class="shad-slider__range"></div></div>
  <div class="shad-slider__thumb" role="slider" tabindex="0" aria-label="Minimum"></div>
  <div class="shad-slider__thumb" role="slider" tabindex="0" aria-label="Maximum"></div></div>`;
const otp = `<div class="shad-otp" data-shad="input-otp" id="otp" data-length="4" data-pattern="\\d">
  <input class="shad-otp__input" type="text" inputmode="numeric" autocomplete="one-time-code" aria-label="One-time code"/>
  <div class="shad-otp__group"><div class="shad-otp__cell" aria-hidden="true"></div></div></div>`;

const labelOf = (root) => root.querySelector(".shad-form-field > .shad-label");

beforeEach(() => {
  document.body.innerHTML = "";
  delete window.shad;
  loadRuntime("form-field", "select", "combobox", "calendar", "date-picker",
    "radio-group", "rating", "slider", "input-otp");
});

describe("names", () => {
  it("keeps <label for> on a native input (1)", () => {
    const root = mount(field("Name", '<input id="txt" class="shad-input" type="text"/>'));
    expect(labelOf(root).htmlFor).toBe("txt");
  });

  it("names a select trigger, a combobox by the label alone (2, 3, 5)", () => {
    const root = mount(field("Fruit", select()));
    const trigger = root.querySelector(".shad-select__trigger");
    expect(trigger.getAttribute("role")).toBe("combobox");
    expect(trigger.getAttribute("aria-labelledby")).toBe(labelOf(root).id);
    expect(labelOf(root).id).not.toBe("");
  });

  it("names plain-button triggers by the label, then their own text (2, 3)", () => {
    for (const control of [combobox, datePicker]) {
      const root = mount(field("Fruit", control));
      const trigger = root.querySelector("[class$='__trigger']");
      expect(trigger.id).not.toBe("");
      expect(trigger.getAttribute("aria-labelledby")).toBe(labelOf(root).id + " " + trigger.id);
    }
  });

  it("names a root with its own role, a slider thumb, and an inner input (2)", () => {
    const cases = [
      [radioGroup, (root) => root.querySelector("[data-shad='radio-group']")],
      [rating, (root) => root.querySelector("[data-shad='rating']")],
      [slider, (root) => root.querySelector("[role='slider']")],
      [otp, (root) => root.querySelector("input")]
    ];
    for (const [control, part] of cases) {
      const root = mount(field("Plan", control));
      expect(part(root).getAttribute("aria-labelledby")).toBe(labelOf(root).id);
    }
  });

  it("names each thumb of a range slider by the label, then its own name (3)", () => {
    const root = mount(field("Price", range));
    const thumbs = root.querySelectorAll("[role='slider']");
    for (const thumb of thumbs) {
      expect(thumb.id).not.toBe("");
      expect(thumb.getAttribute("aria-labelledby")).toBe(labelOf(root).id + " " + thumb.id);
    }
  });
});

describe("description and error", () => {
  it("describe the trigger, and an error marks it invalid (4)", () => {
    const root = mount(field("Fruit", select(),
      '<p class="shad-form-field__description">Pick one</p>'));
    const trigger = root.querySelector(".shad-select__trigger");
    const desc = root.querySelector(".shad-form-field__description");
    expect(trigger.getAttribute("aria-describedby")).toBe(desc.id);

    shad.get(root).setError("Choose a fruit");
    const error = root.querySelector(".shad-form-field__error");
    expect(trigger.getAttribute("aria-describedby")).toBe(desc.id + " " + error.id);
    expect(trigger.getAttribute("aria-invalid")).toBe("true");
    expect(root.querySelector("[data-shad='select']").getAttribute("aria-invalid")).toBe("true");

    shad.get(root).setError(null);
    expect(trigger.getAttribute("aria-describedby")).toBe(desc.id);
    expect(trigger.hasAttribute("aria-invalid")).toBe(false);
  });
});

describe("select trigger", () => {
  it("is a combobox even when the markup leaves the role out (5)", () => {
    const root = mount(select(""));
    const trigger = root.querySelector(".shad-select__trigger");
    expect(trigger.getAttribute("role")).toBe("combobox");
  });

  it("takes its placeholder as a name when nothing labels it (5)", () => {
    const root = mount(select());
    expect(root.querySelector(".shad-select__trigger").getAttribute("aria-label")).toBe("Select...");
  });
});

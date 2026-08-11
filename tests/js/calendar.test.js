/* Calendar caption layouts. The default header only steps one month at a time,
   so anything that needs a year jump (a date of birth) depends on these. */
import { describe, it, expect, beforeEach } from "vitest";
import { loadRuntime, mount } from "./helpers.js";

const cal = (attrs) => `<div data-shad="calendar" class="shad-calendar" ${attrs}></div>`;
const dropdowns = (root) =>
  [...root.querySelectorAll(".shad-calendar__dropdown")].map((s) => s.getAttribute("data-caption"));
const label = (root) => root.querySelector(".shad-calendar__caption, .shad-calendar__label").textContent;

describe("calendar caption", () => {
  beforeEach(() => {
    document.body.innerHTML = "";
    loadRuntime("calendar");
  });

  it("defaults to a text label with no dropdowns", () => {
    const root = mount(cal('data-mode="single" data-value="1993-06-15"'));
    expect(dropdowns(root)).toEqual([]);
    expect(label(root)).toBe("June 1993");
  });

  it("renders month and year selects for data-caption-layout=dropdown", () => {
    const root = mount(cal('data-caption-layout="dropdown" data-value="1993-06-15"'));
    expect(dropdowns(root)).toEqual(["month", "year"]);
    const [month, year] = root.querySelectorAll(".shad-calendar__dropdown");
    expect(month.value).toBe("5");
    expect(year.value).toBe("1993");
    // each select carries its own decorative caret, appearance:none kills the UA one
    expect(root.querySelectorAll(".shad-calendar__dropdown-wrap > .shad-calendar__caret"))
      .toHaveLength(2);
  });

  it("renders one select for the -months and -years layouts", () => {
    expect(dropdowns(mount(cal('data-caption-layout="dropdown-months"')))).toEqual(["month"]);
    expect(dropdowns(mount(cal('data-caption-layout="dropdown-years"')))).toEqual(["year"]);
  });

  it("changing the year select moves the view without changing the value", () => {
    const root = mount(cal('data-caption-layout="dropdown" data-value="2026-06-15" ' +
      'data-from-year="1900" data-to-year="2026"'));
    const year = root.querySelector('[data-caption="year"]');
    year.value = "1993";
    year.dispatchEvent(new window.Event("change", { bubbles: true }));

    expect(root.querySelector('[data-caption="year"]').value).toBe("1993");
    expect(root.querySelector(".shad-calendar__day[data-date]").getAttribute("data-date"))
      .toMatch(/^1993-0[56]/);
    expect(window.shad.get(root).getValue()).toBe("2026-06-15");
  });

  it("honours data-from-year / data-to-year, and always includes the shown year", () => {
    const root = mount(cal('data-caption-layout="dropdown-years" data-value="1993-06-15" ' +
      'data-from-year="2000" data-to-year="2010"'));
    const years = [...root.querySelectorAll('[data-caption="year"] option')].map((o) => +o.value);
    expect(years[0]).toBe(1993);
    expect(years[years.length - 1]).toBe(2010);
  });

  it("derives the year range from data-min / data-max", () => {
    const root = mount(cal('data-caption-layout="dropdown-years" data-value="2020-06-15" ' +
      'data-min="2018-03-01" data-max="2022-09-30"'));
    const years = [...root.querySelectorAll('[data-caption="year"] option')].map((o) => +o.value);
    expect(years).toEqual([2018, 2019, 2020, 2021, 2022]);
  });

  it("disables months that min/max exclude entirely", () => {
    const root = mount(cal('data-caption-layout="dropdown" data-value="2020-06-15" ' +
      'data-min="2020-04-01" data-max="2020-08-31"'));
    const disabled = [...root.querySelectorAll('[data-caption="month"] option')]
      .filter((o) => o.disabled).map((o) => +o.value);
    expect(disabled).toEqual([0, 1, 2, 8, 9, 10, 11]);
  });

  it("data-month opens on that month without selecting anything", () => {
    const root = mount(cal('data-month="1993-06"'));
    expect(label(root)).toBe("June 1993");
    expect(window.shad.get(root).getValue()).toBe(null);
  });
});

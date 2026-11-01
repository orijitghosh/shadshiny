/* Contract: calendar and date picker values, bounds, keyboard and focus.

   Values: setValue() (reached through update_shad_calendar() and
   update_shad_date_picker()) and the data-value / data-min / data-max seeds.
   1. A date is an ISO "YYYY-MM-DD" string naming a real day. An impossible
      date such as "2026-02-31" is not a date: it never rolls over into the
      next month, in a server value or in markup.
   2. null, undefined and "" clear: null in single mode, {start: null,
      end: null} in range mode.
   3. A value that is not a date, or a date outside data-min / data-max, is
      ignored: the selection stays, no shad:change fires, and console.warn
      names it. In range mode one bad end rejects the whole update.
   4. Single mode takes one date string; an object or array is ignored with a
      warning.
   5. Range mode takes {start, end} (either may be null), [start, end], or one
      string, which sets the start and clears the end as the constructor does
      with one date; an end with no start is a start. A reversed range is put
      in order, as two clicks are.
   6. Setting the current value again, empty included, fires nothing.

   Keyboard and focus
   7. Arrow keys move by whole days, also across a daylight-saving change.
   8. PageUp / PageDown (Shift: a year) keep the day of the month, or take the
      last day of a shorter month; they never roll into the month after.
   9. The grid always has exactly one tab stop on a day it shows. When paging
      (nav buttons, caption selects) would leave it off the grid, it moves to
      the same day of the month shown, or that month's last day.
   10. Re-rendering (nav buttons, a server value, the range hover preview)
       keeps focus inside the calendar on the equivalent control instead of
       dropping it to <body>.
   11. A calendar with data-disabled renders its days, nav buttons and
       caption selects disabled, so no click or key changes it. The server
       can still set its value.

   Date picker
   12. A server value never opens, closes or moves focus; a user's pick still
       closes the panel and returns focus to the trigger.
   13. The picker root sees one shad:change per change.
   14. Range presets are cut to data-min / data-max; a preset wholly outside
       them is disabled. */
import { describe, it, expect, beforeAll, afterAll, beforeEach, afterEach, vi } from "vitest";
import { loadRuntime, mount, record, key } from "./helpers.js";

// rule 7 needs a zone with daylight saving; Node re-reads TZ when it is set
const systemTZ = process.env.TZ;
beforeAll(() => { process.env.TZ = "America/New_York"; });
afterAll(() => {
  if (systemTZ === undefined) delete process.env.TZ; else process.env.TZ = systemTZ;
});

const cal = (attrs = "") =>
  `<div data-shad="calendar" class="shad-calendar" id="when" ${attrs}></div>`;
const day = (iso) => document.querySelector(`.shad-calendar__day[data-date="${iso}"]`);
const stops = (root) => Array.from(root.querySelectorAll('.shad-calendar__day[tabindex="0"]'));
const shown = (root) => root.querySelector(".shad-calendar__label").textContent;

let warn;
beforeEach(() => {
  warn = vi.spyOn(console, "warn").mockImplementation(() => {});
});
afterEach(() => warn.mockRestore());
const warned = () => warn.mock.calls.map((args) => args.map(String).join(" "));

describe("calendar values", () => {
  beforeEach(() => loadRuntime("calendar"));

  it("never rolls an impossible date into the next month (1)", () => {
    const root = mount(cal('data-value="2026-02-31" data-month="2026-02"'));
    const inst = window.shad.get(root);
    expect(inst.getValue()).toBeNull();
    expect(root.querySelector("[data-selected]")).toBeNull();

    const seen = record(root, "shad:change");
    for (const bad of ["2026-02-31", "2026-13-01", "2026-00-10", "2026-2-3", "31/01/2026"]) {
      inst.setValue(bad);
    }
    expect(inst.getValue()).toBeNull();
    expect(seen).toEqual([]);
    expect(warned().filter((w) => w.includes("not a date"))).toHaveLength(5);
  });

  it("drops an impossible data-min or data-max instead of rolling it over (1)", () => {
    const root = mount(cal('data-min="2026-02-30" data-max="2026-04-31" data-month="2026-03"'));
    // rolled over these would be Mar 2 and May 1: Mar 1 and Apr 30 stay usable
    expect(day("2026-03-01").hasAttribute("data-disabled")).toBe(false);
    window.shad.get(root).goToMonth("2026-04");
    expect(day("2026-04-30").hasAttribute("data-disabled")).toBe(false);
  });

  it("clears with null, undefined and empty string (2)", () => {
    const single = mount(cal('data-value="2026-10-14"'));
    for (const empty of [null, undefined, ""]) {
      window.shad.get(single).setValue("2026-10-14");
      window.shad.get(single).setValue(empty);
      expect(window.shad.get(single).getValue()).toBeNull();
    }
    const range = mount(cal('data-mode="range" data-value="2026-10-01" data-value-end="2026-10-09"'));
    window.shad.get(range).setValue(null);
    expect(window.shad.get(range).getValue()).toEqual({ start: null, end: null });
  });

  it("ignores dates outside data-min / data-max with a warning (3)", () => {
    const root = mount(cal('data-value="2026-10-14" data-min="2026-10-05" data-max="2026-10-20"'));
    const inst = window.shad.get(root);
    const seen = record(root, "shad:change");
    inst.setValue("2026-10-04");
    inst.setValue("2026-10-21");
    expect(inst.getValue()).toBe("2026-10-14");
    expect(seen).toEqual([]);
    expect(warned().filter((w) => w.includes("min/max"))).toHaveLength(2);
    inst.setValue("2026-10-05");
    inst.setValue("2026-10-20");
    expect(seen.map((d) => d.value)).toEqual(["2026-10-05", "2026-10-20"]);
  });

  it("rejects a whole range when one end is bad (3)", () => {
    const root = mount(cal('data-mode="range" data-min="2026-10-05" data-max="2026-10-20"'));
    const inst = window.shad.get(root);
    inst.setValue({ start: "2026-10-06", end: "2026-10-09" });
    const seen = record(root, "shad:change");
    inst.setValue({ start: "2026-10-07", end: "2026-10-31" });
    inst.setValue({ start: "nope", end: "2026-10-08" });
    expect(inst.getValue()).toEqual({ start: "2026-10-06", end: "2026-10-09" });
    expect(seen).toEqual([]);
    expect(warn).toHaveBeenCalledTimes(2);
  });

  it("ignores an object or array in single mode (4)", () => {
    const root = mount(cal('data-value="2026-10-14"'));
    const inst = window.shad.get(root);
    const seen = record(root, "shad:change");
    inst.setValue({ start: "2026-10-01", end: "2026-10-02" });
    inst.setValue(["2026-10-01"]);
    expect(inst.getValue()).toBe("2026-10-14");
    expect(seen).toEqual([]);
    expect(warn).toHaveBeenCalledTimes(2);
  });

  it("accepts the range shapes and orders a reversed range (5)", () => {
    const root = mount(cal('data-mode="range"'));
    const inst = window.shad.get(root);
    inst.setValue(["2026-10-01", "2026-10-09"]);
    expect(inst.getValue()).toEqual({ start: "2026-10-01", end: "2026-10-09" });
    inst.setValue("2026-10-03");
    expect(inst.getValue()).toEqual({ start: "2026-10-03", end: null });
    inst.setValue({ start: "2026-10-20", end: "2026-10-12" });
    expect(inst.getValue()).toEqual({ start: "2026-10-12", end: "2026-10-20" });
    expect(day("2026-10-15").closest("td").hasAttribute("data-in-range")).toBe(true);
    // an R NA start arrives as null: the end alone is a start
    inst.setValue({ start: null, end: "2026-10-07" });
    expect(inst.getValue()).toEqual({ start: "2026-10-07", end: null });
    inst.setValue([null, "2026-10-08"]);
    expect(inst.getValue()).toEqual({ start: "2026-10-08", end: null });
    expect(warn).not.toHaveBeenCalled();
  });

  it("fires nothing when the value does not change, empty included (6)", () => {
    const single = mount(cal());
    const seen = record(single, "shad:change");
    window.shad.get(single).setValue(null);
    window.shad.get(single).setValue("");
    window.shad.get(single).setValue("2026-10-14");
    window.shad.get(single).setValue("2026-10-14");
    expect(seen.map((d) => d.value)).toEqual(["2026-10-14"]);

    const range = mount(cal('data-mode="range"'));
    const seenRange = record(range, "shad:change");
    window.shad.get(range).setValue({ start: null, end: null });
    window.shad.get(range).setValue(null);
    expect(seenRange).toEqual([]);
  });
});

describe("calendar keyboard and focus", () => {
  beforeEach(() => loadRuntime("calendar"));

  it("moves by whole days across a daylight-saving change (7)", () => {
    // New York leaves DST on 2026-11-01, a 25-hour day
    const root = mount(cal('data-value="2026-10-31"'));
    day("2026-10-31").focus();
    key(document.activeElement, "ArrowRight");
    key(document.activeElement, "ArrowRight");
    key(document.activeElement, "ArrowRight");
    expect(document.activeElement.getAttribute("data-date")).toBe("2026-11-03");
    key(document.activeElement, "ArrowUp");
    expect(document.activeElement.getAttribute("data-date")).toBe("2026-10-27");
    expect(stops(root)).toHaveLength(1);
  });

  it("keeps the day of the month on PageUp / PageDown, or takes the last day (8)", () => {
    mount(cal('data-value="2026-01-31"'));
    day("2026-01-31").focus();
    key(document.activeElement, "PageDown");
    expect(document.activeElement.getAttribute("data-date")).toBe("2026-02-28");
    key(document.activeElement, "PageUp");
    expect(document.activeElement.getAttribute("data-date")).toBe("2026-01-28");

    mount(cal('data-value="2028-02-29"'));
    day("2028-02-29").focus();
    key(document.activeElement, "PageDown", { shiftKey: true });
    expect(document.activeElement.getAttribute("data-date")).toBe("2029-02-28");
  });

  it("keeps one tab stop in the shown month after paging with the nav buttons (9, 10)", () => {
    const root = mount(cal('data-value="2026-10-31"'));
    const next = root.querySelector('[data-nav="1"]');
    next.focus();
    next.click();
    expect(shown(root)).toBe("November 2026");
    expect(document.activeElement).toBe(root.querySelector('[data-nav="1"]'));
    expect(stops(root).map((b) => b.getAttribute("data-date"))).toEqual(["2026-11-30"]);
    root.querySelector('[data-nav="-1"]').focus();
    root.querySelector('[data-nav="-1"]').click();
    root.querySelector('[data-nav="-1"]').click();
    expect(shown(root)).toBe("September 2026");
    expect(document.activeElement).toBe(root.querySelector('[data-nav="-1"]'));
    expect(stops(root).map((b) => b.getAttribute("data-date"))).toEqual(["2026-09-30"]);
  });

  it("keeps one tab stop after changing month with the caption select (9)", () => {
    const root = mount(cal('data-caption-layout="dropdown" data-value="2026-03-31"'));
    const month = root.querySelector('[data-caption="month"]');
    month.focus();
    month.value = "5";
    month.dispatchEvent(new window.Event("change", { bubbles: true }));
    expect(stops(root).map((b) => b.getAttribute("data-date"))).toEqual(["2026-06-30"]);
    expect(document.activeElement).toBe(root.querySelector('[data-caption="month"]'));
  });

  it("keeps focus in the calendar when a server value re-renders it (10)", () => {
    const root = mount(cal('data-value="2026-10-14"'));
    day("2026-10-14").focus();
    window.shad.get(root).setValue("2026-10-20");
    expect(document.activeElement).toBe(day("2026-10-20"));
  });

  it("keeps focus on the focused day while the range preview re-renders (10)", () => {
    mount(cal('data-mode="range" data-month="2026-10"'));
    day("2026-10-05").click();
    expect(document.activeElement).toBe(day("2026-10-05"));
    day("2026-10-09").dispatchEvent(new window.Event("pointerover", { bubbles: true }));
    expect(day("2026-10-07").closest("td").hasAttribute("data-in-range")).toBe(true);
    expect(document.activeElement).toBe(day("2026-10-05"));
  });

  it("disables every control of a data-disabled calendar (11)", () => {
    const root = mount(cal('data-disabled data-caption-layout="dropdown" data-value="2026-10-14"'));
    const seen = record(root, "shad:change");
    expect(root.querySelectorAll(".shad-calendar__day:not([disabled])")).toHaveLength(0);
    expect(root.querySelectorAll(".shad-calendar__nav:not([disabled])")).toHaveLength(0);
    expect(root.querySelectorAll(".shad-calendar__dropdown:not([disabled])")).toHaveLength(0);
    day("2026-10-20").click();
    key(day("2026-10-14"), "Enter");
    expect(seen).toEqual([]);

    window.shad.get(root).setValue("2026-10-20");
    expect(window.shad.get(root).getValue()).toBe("2026-10-20");
    expect(day("2026-10-20").disabled).toBe(true);
  });
});

const picker = ({ range = false, attrs = "", presets = "" } = {}) => `
  <div class="shad-date-picker" data-shad="date-picker" id="due">
    <button type="button" class="shad-date-picker__trigger" data-placeholder>
      <span class="shad-date-picker__value">Pick a date</span>
    </button>
    <div class="shad-date-picker__content" hidden>
      ${presets}
      <div class="shad-calendar" data-shad="calendar" data-mode="${range ? "range" : "single"}" ${attrs}></div>
    </div>
  </div>
  <button type="button" id="elsewhere">Elsewhere</button>`;

describe("date picker", () => {
  beforeEach(() => loadRuntime("calendar", "date-picker", "date-range-presets"));

  it("never opens, closes or moves focus on a server value (12)", () => {
    const root = mount(picker());
    const inst = window.shad.get(root);
    const elsewhere = document.getElementById("elsewhere");
    elsewhere.focus();
    inst.setValue("2026-10-14");
    expect(inst.getValue()).toBe("2026-10-14");
    expect(document.activeElement).toBe(elsewhere);
    expect(inst.isOpen).toBe(false);

    inst.open();
    inst.setValue("2026-10-15");
    expect(inst.isOpen).toBe(true);
  });

  it("still closes and refocuses the trigger after a user's pick (12)", () => {
    const root = mount(picker({ attrs: 'data-month="2026-10"' }));
    const inst = window.shad.get(root);
    inst.open();
    day("2026-10-14").click();
    expect(inst.isOpen).toBe(false);
    expect(document.activeElement).toBe(root.querySelector(".shad-date-picker__trigger"));
    expect(inst.getValue()).toBe("2026-10-14");
  });

  it("treats a preset click as a user's pick (12)", () => {
    const presets = `
      <div class="shad-date-range-presets" data-shad="date-range-presets">
        <button type="button" class="shad-date-range-presets__item" data-start="2026-10-05" data-end="2026-10-09">Week</button>
      </div>`;
    const root = mount(picker({ range: true, presets }));
    const inst = window.shad.get(root);
    const seen = record(root, "shad:change");
    inst.open();
    // open() portals the panel out of the root
    document.querySelector(".shad-date-range-presets__item").click();
    expect(inst.getValue()).toEqual({ start: "2026-10-05", end: "2026-10-09" });
    expect(inst.isOpen).toBe(false);
    expect(document.activeElement).toBe(root.querySelector(".shad-date-picker__trigger"));
    expect(seen.map((d) => d.value)).toEqual([{ start: "2026-10-05", end: "2026-10-09" }]);
  });

  it("emits one shad:change on its root per change (13)", () => {
    const root = mount(picker({ attrs: 'data-month="2026-10"' }));
    const seen = record(root, "shad:change");
    window.shad.get(root).setValue("2026-10-14");
    expect(seen.map((d) => d.value)).toEqual(["2026-10-14"]);
  });

  it("cuts presets to min/max and disables one wholly outside (14)", () => {
    vi.useFakeTimers({ toFake: ["Date"] });
    vi.setSystemTime(new Date(2026, 9, 31, 12));
    try {
      const presets = `
        <div class="shad-date-range-presets" data-shad="date-range-presets">
          <button type="button" class="shad-date-range-presets__item" data-days="30">Last 30 days</button>
          <button type="button" class="shad-date-range-presets__item" data-start="2025-01-01" data-end="2025-12-31">2025</button>
        </div>`;
      const root = mount(picker({ range: true, presets,
        attrs: 'data-min="2026-10-20" data-max="2026-10-31"' }));
      const [last30, y2025] = root.querySelectorAll(".shad-date-range-presets__item");
      expect(y2025.disabled).toBe(true);
      last30.click();
      expect(window.shad.get(root).getValue()).toEqual({ start: "2026-10-20", end: "2026-10-31" });
      expect(last30.getAttribute("data-state")).toBe("active");
      expect(warn).not.toHaveBeenCalled();
    } finally {
      vi.useRealTimers();
    }
  });
});

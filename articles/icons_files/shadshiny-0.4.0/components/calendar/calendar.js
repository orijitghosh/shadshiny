/* FILE: inst/assets/components/calendar/calendar.js */
/* shadshiny – calendar behavior (APG date-grid pattern).
   Markup (JS renders the grid; container is the whole API):
     <div data-shad="calendar" class="shad-calendar"
          [data-mode="single|range"] [data-value="YYYY-MM-DD"]
          [data-value-end="YYYY-MM-DD"] [data-min] [data-max]
          [data-week-start="0|1"] [data-month="YYYY-MM"]
          [data-caption-layout="label|dropdown|dropdown-months|dropdown-years"]
          [data-from-year] [data-to-year]></div>
   Value: single -> "YYYY-MM-DD"|null; range -> {start, end} (either null).
   Keyboard: arrows ±1day/±7days, PageUp/Down ±month (shift: ±year),
   Home/End week start/end, Enter/Space select. Focus roves one day cell.
   Server values: see the contract in tests/js/calendar-contract.test.js. */
(function () {
  "use strict";

  const DAY_MS = 86400000;
  const WEEKDAYS = ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"];
  const MONTHS = ["January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December"];

  function iso(d) {
    return String(d.getFullYear()).padStart(4, "0") + "-" +
      String(d.getMonth() + 1).padStart(2, "0") + "-" +
      String(d.getDate()).padStart(2, "0");
  }
  // local midnight of y-m-d, or null when that day does not exist: the Date
  // constructor would roll 2026-02-31 over to March 3
  function ymd(y, m, d) {
    const out = new Date(2000, 0, 1);
    out.setFullYear(y, m, d);
    return out.getFullYear() === y && out.getMonth() === m && out.getDate() === d
      ? out : null;
  }
  function parse(s) {
    const m = /^(\d{4})-(\d{2})-(\d{2})$/.exec(typeof s === "string" ? s : "");
    return m ? ymd(+m[1], +m[2] - 1, +m[3]) : null;
  }
  // the same day of the month n months on, or that month's last day
  function addMonths(d, n) {
    const last = new Date(d.getFullYear(), d.getMonth() + n + 1, 0).getDate();
    return new Date(d.getFullYear(), d.getMonth() + n, Math.min(d.getDate(), last));
  }
  function sameDay(a, b) { return a && b && iso(a) === iso(b); }
  function same(a, b) { return (!a && !b) || sameDay(a, b); }

  shad.register("calendar", function (root) {
    const mode = root.getAttribute("data-mode") === "range" ? "range" : "single";
    const weekStart = parseInt(root.getAttribute("data-week-start") || "0", 10);
    const minDate = parse(root.getAttribute("data-min"));
    const maxDate = parse(root.getAttribute("data-max"));
    // a date picker's calendar has no id of its own; warnings name the picker
    const who = ("calendar " + (root.id ||
      (root.closest('[data-shad="date-picker"]') || {}).id || "")).trim();
    const off = () => root.hasAttribute("data-disabled");

    const captionLayout = (function (v) {
      return ["dropdown", "dropdown-months", "dropdown-years"].indexOf(v) > -1 ? v : "label";
    })(root.getAttribute("data-caption-layout"));
    const monthsAsDropdown = captionLayout === "dropdown" || captionLayout === "dropdown-months";
    const yearsAsDropdown = captionLayout === "dropdown" || captionLayout === "dropdown-years";

    let selStart = parse(root.getAttribute("data-value"));
    let selEnd = mode === "range" ? parse(root.getAttribute("data-value-end")) : null;
    // data-month seeds the displayed month without seeding a selection.
    const seedMonth = /^(\d{4})-(\d{2})$/.exec(root.getAttribute("data-month") || "");
    let view = seedMonth ? new Date(+seedMonth[1], +seedMonth[2] - 1, 1) : (selStart || new Date());
    view = new Date(view.getFullYear(), view.getMonth(), 1);

    // Year bounds for the dropdown: explicit attrs, else min/max, else a
    // century back (birth dates) and a decade forward.
    const thisYear = new Date().getFullYear();
    function yearAttr(name, fallback) {
      const n = parseInt(root.getAttribute(name) || "", 10);
      return isNaN(n) ? fallback : n;
    }
    const fromYear = yearAttr("data-from-year",
      minDate ? minDate.getFullYear() : thisYear - 100);
    const toYear = yearAttr("data-to-year",
      maxDate ? maxDate.getFullYear() : thisYear + 10);
    let focusDate = selStart || new Date();
    let hoverDate = null; // range preview

    const CHEV_L = '<svg class="shad-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m15 18-6-6 6-6"/></svg>';
    const CHEV_D = '<svg class="shad-calendar__caret shad-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m6 9 6 6 6-6"/></svg>';
    const CHEV_R = '<svg class="shad-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m9 18 6-6-6-6"/></svg>';

    function disabled(d) {
      if (minDate && d < minDate && !sameDay(d, minDate)) return true;
      if (maxDate && d > maxDate && !sameDay(d, maxDate)) return true;
      return false;
    }
    function inRange(d) {
      if (mode !== "range" || !selStart) return false;
      const end = selEnd || (hoverDate && hoverDate > selStart ? hoverDate : null);
      if (!end) return false;
      return d > selStart && d < end;
    }

    // Month/year captions. Options outside [minDate, maxDate] are disabled
    // rather than dropped, so the list keeps a stable length and position.
    function monthSelect(y, m) {
      let opts = "";
      for (let i = 0; i < 12; i++) {
        const dis = (minDate && new Date(y, i + 1, 0) < minDate) ||
          (maxDate && new Date(y, i, 1) > maxDate);
        opts += '<option value="' + i + '"' + (i === m ? " selected" : "") +
          (dis ? " disabled" : "") + ">" + MONTHS[i] + "</option>";
      }
      return wrap('<select class="shad-calendar__dropdown" data-caption="month" aria-label="Month"' +
        (off() ? " disabled" : "") + ">" +
        opts + "</select>");
    }
    function yearSelect(y) {
      const lo = Math.min(fromYear, y), hi = Math.max(toYear, y);
      let opts = "";
      for (let i = lo; i <= hi; i++) {
        opts += '<option value="' + i + '"' + (i === y ? " selected" : "") + ">" + i + "</option>";
      }
      return wrap('<select class="shad-calendar__dropdown" data-caption="year" aria-label="Year"' +
        (off() ? " disabled" : "") + ">" +
        opts + "</select>");
    }
    // The caret is decorative and sits over the select's padding gutter, the
    // same trick native-select uses; appearance:none kills the UA arrow.
    function wrap(select) {
      return '<span class="shad-calendar__dropdown-wrap">' + select + CHEV_D + "</span>";
    }
    function caption(y, m) {
      if (captionLayout === "label") {
        return '<div class="shad-calendar__label" aria-live="polite" id="' + labelId + '">' +
          MONTHS[m] + " " + y + "</div>";
      }
      return '<div class="shad-calendar__caption" id="' + labelId + '">' +
        (monthsAsDropdown ? monthSelect(y, m)
          : '<span class="shad-calendar__label">' + MONTHS[m] + "</span>") +
        (yearsAsDropdown ? yearSelect(y)
          : '<span class="shad-calendar__label">' + y + "</span>") +
        "</div>";
    }

    function render() {
      const y = view.getFullYear(), m = view.getMonth();
      const today = new Date();
      const first = new Date(y, m, 1);
      let lead = (first.getDay() - weekStart + 7) % 7;
      const gridStart = new Date(y, m, 1 - lead);
      // the grid's one tab stop must be a day it shows: after paging, the same
      // day of the month shown (or its last day)
      if (iso(focusDate) < iso(gridStart) || iso(focusDate) > iso(new Date(y, m, 42 - lead))) {
        focusDate = addMonths(focusDate, (y - focusDate.getFullYear()) * 12 + m - focusDate.getMonth());
      }
      const dis = off() ? " disabled" : "";

      let html = '<div class="shad-calendar__header">' +
        '<button type="button" class="shad-calendar__nav" data-nav="-1" aria-label="Previous month"' + dis + ">" + CHEV_L + "</button>" +
        caption(y, m) +
        '<button type="button" class="shad-calendar__nav" data-nav="1" aria-label="Next month"' + dis + ">" + CHEV_R + "</button>" +
        "</div>";
      html += '<table class="shad-calendar__grid" role="grid" aria-labelledby="' + labelId + '"><thead><tr>';
      for (let i = 0; i < 7; i++) {
        html += '<th class="shad-calendar__weekday" scope="col">' +
          WEEKDAYS[(weekStart + i) % 7] + "</th>";
      }
      html += "</tr></thead><tbody>";
      for (let w = 0; w < 6; w++) {
        html += "<tr>";
        for (let i = 0; i < 7; i++) {
          const d = new Date(gridStart.getTime() + (w * 7 + i) * DAY_MS + 12 * 3600000);
          d.setHours(0, 0, 0, 0);
          const outside = d.getMonth() !== m;
          const isStart = mode === "range" ? sameDay(d, selStart)
            : sameDay(d, selStart);
          const isEnd = mode === "range" && sameDay(d, selEnd);
          const mid = inRange(d);
          const out = disabled(d);
          const isFocus = sameDay(d, focusDate);
          let cellAttrs = "";
          if (mid) cellAttrs += " data-in-range";
          if (mode === "range" && isStart && (selEnd || hoverDate)) cellAttrs += " data-range-start-cell";
          if (isEnd) cellAttrs += " data-range-end-cell";
          if (isStart || isEnd) cellAttrs += ' aria-selected="true"';
          let dayAttrs = "";
          if (outside) dayAttrs += " data-outside";
          if (sameDay(d, today)) dayAttrs += " data-today";
          if (mode === "single" && isStart) dayAttrs += " data-selected";
          if (mode === "range" && isStart) dayAttrs += " data-range-start";
          if (isEnd) dayAttrs += " data-range-end";
          if (out) dayAttrs += ' data-disabled aria-disabled="true"';
          dayAttrs += dis;
          html += '<td class="shad-calendar__cell" role="gridcell"' + cellAttrs + ">" +
            '<button type="button" class="shad-calendar__day" data-date="' + iso(d) + '"' +
            dayAttrs +
            ' tabindex="' + (isFocus ? "0" : "-1") + '"' +
            ' aria-label="' + d.toDateString() + '"' +
            ">" + d.getDate() + "</button></td>";
        }
        html += "</tr>";
      }
      html += "</tbody></table>";
      // replacing the markup would drop focus to <body>; put it back on the
      // matching control
      const f = root.contains(document.activeElement) ? document.activeElement : null;
      const again = !f ? null
        : f.hasAttribute("data-nav") ? '[data-nav="' + f.getAttribute("data-nav") + '"]'
          : f.hasAttribute("data-caption") ? '[data-caption="' + f.getAttribute("data-caption") + '"]'
            : '.shad-calendar__day[tabindex="0"]';
      root.innerHTML = html;
      const back = again && root.querySelector(again);
      if (back) back.focus({ preventScroll: true });
    }

    function emit() {
      const value = mode === "range"
        ? { start: selStart ? iso(selStart) : null, end: selEnd ? iso(selEnd) : null }
        : (selStart ? iso(selStart) : null);
      shad.util.emit(root, "shad:change", { value });
    }
    function pick(d) {
      if (disabled(d) || off()) return;
      if (mode === "single") {
        // picking the selected day again clears it (react-day-picker behavior)
        selStart = sameDay(d, selStart) ? null : d;
      } else {
        if (!selStart || (selStart && selEnd)) { selStart = d; selEnd = null; }
        else if (d < selStart) { selEnd = selStart; selStart = d; }
        else { selEnd = d; }
      }
      focusDate = d;
      render();
      focusCurrent();
      emit();
    }
    // whole calendar days, never 24-hour steps: a daylight-saving day is 23
    // or 25 hours long
    function moveFocus(days, months) {
      const d = months ? addMonths(focusDate, months)
        : new Date(focusDate.getFullYear(), focusDate.getMonth(), focusDate.getDate() + days);
      focusDate = d;
      if (d.getMonth() !== view.getMonth() || d.getFullYear() !== view.getFullYear()) {
        view = new Date(d.getFullYear(), d.getMonth(), 1);
      }
      render();
      focusCurrent();
    }
    function focusCurrent() {
      const btn = root.querySelector('.shad-calendar__day[tabindex="0"]');
      if (btn) btn.focus({ preventScroll: true });
    }

    function onClick(ev) {
      if (off()) return;
      const nav = ev.target.closest("[data-nav]");
      if (nav) {
        view.setMonth(view.getMonth() + parseInt(nav.getAttribute("data-nav"), 10));
        render();
        return;
      }
      const day = ev.target.closest(".shad-calendar__day");
      if (day && !day.hasAttribute("data-disabled")) pick(parse(day.getAttribute("data-date")));
    }
    function onChange(ev) {
      const sel = ev.target.closest(".shad-calendar__dropdown");
      if (!sel || off()) return;
      const which = sel.getAttribute("data-caption");
      const n = parseInt(sel.value, 10);
      // Clamp the day-of-month implicitly: view is always the 1st.
      if (which === "month") view = new Date(view.getFullYear(), n, 1);
      else view = new Date(n, view.getMonth(), 1);
      // A year change can land on a month that min/max excludes entirely.
      if (minDate && new Date(view.getFullYear(), view.getMonth() + 1, 0) < minDate) {
        view = new Date(minDate.getFullYear(), minDate.getMonth(), 1);
      } else if (maxDate && view > maxDate) {
        view = new Date(maxDate.getFullYear(), maxDate.getMonth(), 1);
      }
      render();
    }
    function onKeydown(ev) {
      if (!ev.target.closest(".shad-calendar__day") || off()) return;
      switch (ev.key) {
        case "ArrowRight": ev.preventDefault(); moveFocus(1); break;
        case "ArrowLeft": ev.preventDefault(); moveFocus(-1); break;
        case "ArrowDown": ev.preventDefault(); moveFocus(7); break;
        case "ArrowUp": ev.preventDefault(); moveFocus(-7); break;
        case "PageDown": ev.preventDefault(); moveFocus(0, ev.shiftKey ? 12 : 1); break;
        case "PageUp": ev.preventDefault(); moveFocus(0, ev.shiftKey ? -12 : -1); break;
        case "Home": {
          ev.preventDefault();
          const dow = (focusDate.getDay() - weekStart + 7) % 7;
          moveFocus(-dow); break;
        }
        case "End": {
          ev.preventDefault();
          const dow = (focusDate.getDay() - weekStart + 7) % 7;
          moveFocus(6 - dow); break;
        }
        case "Enter": case " ":
          ev.preventDefault(); pick(focusDate); break;
      }
    }
    function onPointerOver(ev) {
      if (mode !== "range" || !selStart || selEnd || off()) return;
      const day = ev.target.closest(".shad-calendar__day");
      if (!day) return;
      const d = parse(day.getAttribute("data-date"));
      if (!sameDay(d, hoverDate)) { hoverDate = d; render(); }
    }

    // A server value as {start, end} (end always null in single mode), or
    // undefined when it has to be ignored.
    function read(v) {
      const warn = (why) =>
        console.warn("[shadshiny] " + who + ": " + why + " " + JSON.stringify(v));
      let s = v, e = null;
      if (v != null && typeof v === "object") {
        if (mode !== "range") return warn("ignoring a value that is not one date");
        [s, e] = Array.isArray(v) ? v : [v.start, v.end];
      }
      const ds = parse(s), de = parse(e);
      if ((s != null && s !== "" && !ds) || (e != null && e !== "" && !de)) {
        return warn("ignoring a value that is not a date");
      }
      if ((ds && disabled(ds)) || (de && disabled(de))) {
        return warn("ignoring a date outside min/max");
      }
      if (!ds) return { start: de, end: null };
      return de && de < ds ? { start: de, end: ds } : { start: ds, end: de };
    }

    const labelId = shad.uid("cal-label");
    root.addEventListener("click", onClick);
    root.addEventListener("change", onChange);
    root.addEventListener("keydown", onKeydown);
    root.addEventListener("pointerover", onPointerOver);
    render();

    return {
      getValue() {
        return mode === "range"
          ? { start: selStart ? iso(selStart) : null, end: selEnd ? iso(selEnd) : null }
          : (selStart ? iso(selStart) : null);
      },
      setValue(v) {
        const next = read(v);
        if (!next || (same(next.start, selStart) && same(next.end, selEnd))) return;
        selStart = next.start;
        selEnd = next.end;
        if (selStart) {
          view = new Date(selStart.getFullYear(), selStart.getMonth(), 1);
          focusDate = selStart;
        }
        render();
        emit();
      },
      /** show a given month without changing selection: "YYYY-MM" */
      goToMonth(ym) {
        const m = /^(\d{4})-(\d{2})$/.exec(ym);
        if (m) { view = new Date(+m[1], +m[2] - 1, 1); render(); }
      },
      destroy() {
        root.removeEventListener("click", onClick);
        root.removeEventListener("change", onChange);
        root.removeEventListener("keydown", onKeydown);
        root.removeEventListener("pointerover", onPointerOver);
      }
    };
  });
})();

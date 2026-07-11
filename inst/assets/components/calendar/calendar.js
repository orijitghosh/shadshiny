/* FILE: inst/assets/components/calendar/calendar.js */
/* shadshiny — calendar behavior (APG date-grid pattern).
   Markup (JS renders the grid; container is the whole API):
     <div data-shad="calendar" class="shad-calendar"
          [data-mode="single|range"] [data-value="YYYY-MM-DD"]
          [data-value-end="YYYY-MM-DD"] [data-min] [data-max]
          [data-week-start="0|1"]></div>
   Value: single -> "YYYY-MM-DD"|null; range -> {start, end} (either null).
   Keyboard: arrows ±1day/±7days, PageUp/Down ±month (shift: ±year),
   Home/End week start/end, Enter/Space select. Focus roves one day cell. */
(function () {
  "use strict";

  const DAY_MS = 86400000;
  const WEEKDAYS = ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"];
  const MONTHS = ["January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December"];

  function iso(d) {
    return d.getFullYear() + "-" +
      String(d.getMonth() + 1).padStart(2, "0") + "-" +
      String(d.getDate()).padStart(2, "0");
  }
  function parse(s) {
    if (!s) return null;
    const m = /^(\d{4})-(\d{2})-(\d{2})$/.exec(s);
    return m ? new Date(+m[1], +m[2] - 1, +m[3]) : null;
  }
  function sameDay(a, b) { return a && b && iso(a) === iso(b); }

  shad.register("calendar", function (root) {
    const mode = root.getAttribute("data-mode") === "range" ? "range" : "single";
    const weekStart = parseInt(root.getAttribute("data-week-start") || "0", 10);
    const minDate = parse(root.getAttribute("data-min"));
    const maxDate = parse(root.getAttribute("data-max"));

    let selStart = parse(root.getAttribute("data-value"));
    let selEnd = mode === "range" ? parse(root.getAttribute("data-value-end")) : null;
    let view = selStart || new Date();
    view = new Date(view.getFullYear(), view.getMonth(), 1);
    let focusDate = selStart || new Date();
    let hoverDate = null; // range preview

    const CHEV_L = '<svg class="shad-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m15 18-6-6 6-6"/></svg>';
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

    function render() {
      const y = view.getFullYear(), m = view.getMonth();
      const today = new Date();
      const first = new Date(y, m, 1);
      let lead = (first.getDay() - weekStart + 7) % 7;
      const gridStart = new Date(y, m, 1 - lead);

      let html = '<div class="shad-calendar__header">' +
        '<button type="button" class="shad-calendar__nav" data-nav="-1" aria-label="Previous month">' + CHEV_L + "</button>" +
        '<div class="shad-calendar__label" aria-live="polite" id="' + labelId + '">' +
        MONTHS[m] + " " + y + "</div>" +
        '<button type="button" class="shad-calendar__nav" data-nav="1" aria-label="Next month">' + CHEV_R + "</button>" +
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
          const dis = disabled(d);
          const isFocus = sameDay(d, focusDate);
          let cellAttrs = "";
          if (mid) cellAttrs += " data-in-range";
          if (mode === "range" && isStart && (selEnd || hoverDate)) cellAttrs += " data-range-start-cell";
          if (isEnd) cellAttrs += " data-range-end-cell";
          let dayAttrs = "";
          if (outside) dayAttrs += " data-outside";
          if (sameDay(d, today)) dayAttrs += " data-today";
          if (mode === "single" && isStart) dayAttrs += " data-selected";
          if (mode === "range" && isStart) dayAttrs += " data-range-start";
          if (isEnd) dayAttrs += " data-range-end";
          if (dis) dayAttrs += ' data-disabled aria-disabled="true"';
          html += '<td class="shad-calendar__cell" role="gridcell"' + cellAttrs + ">" +
            '<button type="button" class="shad-calendar__day" data-date="' + iso(d) + '"' +
            dayAttrs +
            ' tabindex="' + (isFocus ? "0" : "-1") + '"' +
            ' aria-label="' + d.toDateString() + '"' +
            (isStart || isEnd ? ' aria-selected="true"' : "") +
            ">" + d.getDate() + "</button></td>";
        }
        html += "</tr>";
      }
      html += "</tbody></table>";
      root.innerHTML = html;
    }

    function emit() {
      const value = mode === "range"
        ? { start: selStart ? iso(selStart) : null, end: selEnd ? iso(selEnd) : null }
        : (selStart ? iso(selStart) : null);
      shad.util.emit(root, "shad:change", { value });
    }
    function pick(d) {
      if (disabled(d)) return;
      if (mode === "single") {
        selStart = d;
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
    function moveFocus(days, months, years) {
      let d = new Date(focusDate);
      if (days) d = new Date(d.getTime() + days * DAY_MS);
      if (months) d.setMonth(d.getMonth() + months);
      if (years) d.setFullYear(d.getFullYear() + years);
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
      const nav = ev.target.closest("[data-nav]");
      if (nav) {
        view.setMonth(view.getMonth() + parseInt(nav.getAttribute("data-nav"), 10));
        render();
        return;
      }
      const day = ev.target.closest(".shad-calendar__day");
      if (day && !day.hasAttribute("data-disabled")) pick(parse(day.getAttribute("data-date")));
    }
    function onKeydown(ev) {
      if (!ev.target.closest(".shad-calendar__day")) return;
      switch (ev.key) {
        case "ArrowRight": ev.preventDefault(); moveFocus(1); break;
        case "ArrowLeft": ev.preventDefault(); moveFocus(-1); break;
        case "ArrowDown": ev.preventDefault(); moveFocus(7); break;
        case "ArrowUp": ev.preventDefault(); moveFocus(-7); break;
        case "PageDown": ev.preventDefault(); moveFocus(0, ev.shiftKey ? 0 : 1, ev.shiftKey ? 1 : 0); break;
        case "PageUp": ev.preventDefault(); moveFocus(0, ev.shiftKey ? 0 : -1, ev.shiftKey ? -1 : 0); break;
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
      if (mode !== "range" || !selStart || selEnd) return;
      const day = ev.target.closest(".shad-calendar__day");
      if (!day) return;
      const d = parse(day.getAttribute("data-date"));
      if (!sameDay(d, hoverDate)) { hoverDate = d; render(); }
    }

    const labelId = shad.uid("cal-label");
    root.addEventListener("click", onClick);
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
        if (mode === "range") {
          const ns = parse(v && v.start), ne = parse(v && v.end);
          if (sameDay(ns, selStart) && sameDay(ne, selEnd)) return;
          selStart = ns; selEnd = ne;
        } else {
          const nd = parse(v);
          if (sameDay(nd, selStart)) return;
          selStart = nd;
        }
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
        root.removeEventListener("keydown", onKeydown);
        root.removeEventListener("pointerover", onPointerOver);
      }
    };
  });
})();

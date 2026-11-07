/* FILE: inst/assets/components/date-range-presets/date-range-presets.js */
/* shadshiny — date-range-presets behavior (tiny). Slots inside a range-mode
   date-picker's __content; clicking a preset writes {start,end} into the
   picker's calendar, as a pick. Load AFTER date-picker.js.
   Markup (inside .shad-date-picker__content, BEFORE the calendar):
     <div class="shad-date-range-presets" data-shad="date-range-presets" role="group" aria-label="Quick ranges">
       <button type="button" class="shad-date-range-presets__item" data-days="7">Last 7 days</button>
       <button type="button" class="shad-date-range-presets__item" data-days="30">Last 30 days</button>
       <button type="button" class="shad-date-range-presets__item" data-preset="this-month">This month</button>
       <button type="button" class="shad-date-range-presets__item" data-start="2026-01-01" data-end="2026-03-31">Q1</button>
       <div class="shad-date-range-presets__separator" role="separator"></div>
       …
     </div>
   Range sources (first match wins): data-start+data-end (ISO) |
   data-preset (today, yesterday, this-week, this-month, last-month,
   this-year) | data-days=N (last N days, ending today). The range is cut
   to the calendar's data-min/data-max; a preset wholly outside is disabled. */
(function () {
  "use strict";
  function iso(d) {
    return d.getFullYear() + "-" +
      String(d.getMonth() + 1).padStart(2, "0") + "-" +
      String(d.getDate()).padStart(2, "0");
  }
  function computeRange(btn) {
    if (btn.hasAttribute("data-start") && btn.hasAttribute("data-end")) {
      return { start: btn.getAttribute("data-start"), end: btn.getAttribute("data-end") };
    }
    var now = new Date();
    var p = btn.getAttribute("data-preset");
    if (p) {
      var s, e;
      switch (p) {
        case "today": s = e = now; break;
        case "yesterday":
          s = e = new Date(now.getFullYear(), now.getMonth(), now.getDate() - 1); break;
        case "this-week": { // Monday start
          var dow = (now.getDay() + 6) % 7;
          s = new Date(now.getFullYear(), now.getMonth(), now.getDate() - dow);
          e = now; break;
        }
        case "this-month":
          s = new Date(now.getFullYear(), now.getMonth(), 1); e = now; break;
        case "last-month":
          s = new Date(now.getFullYear(), now.getMonth() - 1, 1);
          e = new Date(now.getFullYear(), now.getMonth(), 0); break;
        case "this-year":
          s = new Date(now.getFullYear(), 0, 1); e = now; break;
        default: return null;
      }
      return { start: iso(s), end: iso(e) };
    }
    if (btn.hasAttribute("data-days")) {
      var n = parseInt(btn.getAttribute("data-days"), 10);
      var s2 = new Date(now.getFullYear(), now.getMonth(), now.getDate() - (n - 1));
      return { start: iso(s2), end: iso(now) };
    }
    return null;
  }

  shad.register("date-range-presets", function (root) {
    var pickerEl = root.closest('[data-shad="date-picker"]');
    var items = Array.from(root.querySelectorAll(".shad-date-range-presets__item"));
    var calEl = pickerEl && pickerEl.querySelector('[data-shad="calendar"]');
    var min = calEl && calEl.getAttribute("data-min");
    var max = calEl && calEl.getAttribute("data-max");

    // ISO dates compare as strings
    function rangeOf(btn) {
      var r = computeRange(btn);
      if (!r) return null;
      if (min && r.start < min) r.start = min;
      if (max && r.end > max) r.end = max;
      return r.start <= r.end ? r : null;
    }

    function picker() { return pickerEl ? shad.get(pickerEl) : null; }
    function markActive() {
      var pk = picker();
      var v = pk && pk.getValue ? pk.getValue() : null;
      items.forEach(function (b) {
        var r = rangeOf(b);
        b.disabled = !r;
        var on = r && v && v.start === r.start && v.end === r.end;
        if (on) b.setAttribute("data-state", "active");
        else b.removeAttribute("data-state");
      });
    }

    function onClick(ev) {
      var btn = ev.target.closest(".shad-date-range-presets__item");
      if (!btn || !root.contains(btn)) return;
      var r = rangeOf(btn);
      if (!r) return;
      // through the calendar, as a pick: the picker's own setValue() is the
      // server's path and would leave the panel open
      var c = calEl ? shad.get(calEl) : null;
      if (c && c.setValue) c.setValue(r);
      markActive();
      shad.util.emit(root, "shad:change", { value: r });
    }
    root.addEventListener("click", onClick);
    if (pickerEl) pickerEl.addEventListener("shad:change", markActive);
    markActive();

    return {
      getValue: function () {
        var b = root.querySelector('[data-state="active"]');
        return b ? rangeOf(b) : null;
      },
      setValue: function () {}, // presets derive from the picker's value
      destroy: function () {
        root.removeEventListener("click", onClick);
        if (pickerEl) pickerEl.removeEventListener("shad:change", markActive);
      }
    };
  });
})();

/* FILE: inst/assets/components/rating/rating.js */
/* shadshiny — rating behavior.
   Markup: <div data-shad="rating" class="shad-rating" [data-value="3.5"]
                [data-max="5"] [data-half] [data-readonly] [data-size=sm|lg]
                [aria-label="Rating"]></div>
   JS builds the stars. Events: shad:change {value}. */
(function () {
  "use strict";
  var STAR = "M12 2l2.9 6.26 6.86.63-5.18 4.55 1.53 6.72L12 16.67 5.89 20.16l1.53-6.72L2.24 8.89l6.86-.63z";
  function starSvg() {
    var s = document.createElementNS("http://www.w3.org/2000/svg", "svg");
    s.setAttribute("viewBox", "0 0 24 24");
    s.setAttribute("aria-hidden", "true");
    var p = document.createElementNS("http://www.w3.org/2000/svg", "path");
    p.setAttribute("d", STAR);
    s.appendChild(p);
    return s;
  }
  shad.register("rating", function (root) {
    var max = parseInt(root.getAttribute("data-max") || "5", 10);
    var half = root.hasAttribute("data-half");
    var readonly = root.hasAttribute("data-readonly");
    var value = parseFloat(root.getAttribute("data-value") || "0");
    var step = half ? 0.5 : 1;

    root.setAttribute("role", readonly ? "img" : "radiogroup");
    if (!root.hasAttribute("aria-label")) root.setAttribute("aria-label", "Rating");

    var items = [];
    for (var i = 1; i <= max; i++) {
      var b = document.createElement("button");
      b.type = "button";
      b.className = "shad-rating__item";
      b.setAttribute("data-index", String(i));
      if (readonly) { b.disabled = true; b.setAttribute("tabindex", "-1"); }
      else {
        b.setAttribute("role", "radio");
        b.setAttribute("aria-label", i + (i === 1 ? " star" : " stars"));
      }
      b.appendChild(starSvg());
      var h = document.createElement("span");
      h.className = "shad-rating__half";
      h.setAttribute("aria-hidden", "true");
      h.appendChild(starSvg());
      b.appendChild(h);
      root.appendChild(b);
      items.push(b);
    }

    function render(previewVal) {
      var v = previewVal != null ? previewVal : value;
      items.forEach(function (b, idx) {
        var i = idx + 1;
        var state = v >= i ? "on" : (half && v >= i - 0.5) ? "half" : "off";
        b.setAttribute("data-state", state);
        if (previewVal != null) {
          if (v >= i - (half ? 0.5 : 0)) b.setAttribute("data-active", "");
          else b.removeAttribute("data-active");
        } else b.removeAttribute("data-active");
        if (!readonly) {
          var checked = value >= i && value < i + 1;
          b.setAttribute("aria-checked", String(checked));
          b.setAttribute("tabindex", checked || (value === 0 && i === 1) ? "0" : "-1");
        }
      });
      if (readonly) root.setAttribute("aria-label", value + " out of " + max + " stars");
      root.setAttribute("data-value", String(value));
    }

    function set(v, emitEvt) {
      var nv = shad.util.clamp(Math.round(v / step) * step, 0, max);
      if (nv === value) { render(); return; }
      value = nv;
      render();
      if (emitEvt !== false) shad.util.emit(root, "shad:change", { value: value });
    }

    function valueFromEvent(b, ev) {
      var i = parseInt(b.getAttribute("data-index"), 10);
      if (!half) return i;
      var r = b.getBoundingClientRect();
      var isRtl = getComputedStyle(root).direction === "rtl";
      var frac = (ev.clientX - r.left) / r.width;
      if (isRtl) frac = 1 - frac;
      return frac < 0.5 ? i - 0.5 : i;
    }

    var handlers = [];
    function on(el, type, fn) { el.addEventListener(type, fn); handlers.push([el, type, fn]); }

    if (!readonly) {
      items.forEach(function (b) {
        on(b, "click", function (ev) {
          var v = valueFromEvent(b, ev);
          set(v === value ? 0 : v); // click current value clears
          b.focus({ preventScroll: true });
        });
        on(b, "mousemove", function (ev) {
          root.setAttribute("data-preview", "");
          render(valueFromEvent(b, ev));
        });
      });
      on(root, "mouseleave", function () {
        root.removeAttribute("data-preview");
        render();
      });
      on(root, "keydown", function (ev) {
        var k = ev.key, delta = 0;
        var isRtl = getComputedStyle(root).direction === "rtl";
        if (k === "ArrowRight" || k === "ArrowUp") delta = isRtl && k === "ArrowRight" ? -step : step;
        else if (k === "ArrowLeft" || k === "ArrowDown") delta = isRtl && k === "ArrowLeft" ? step : -step;
        else if (k === "Home") { ev.preventDefault(); set(step); focusCurrent(); return; }
        else if (k === "End") { ev.preventDefault(); set(max); focusCurrent(); return; }
        else return;
        ev.preventDefault();
        set(shad.util.clamp(value + delta, step, max));
        focusCurrent();
      });
    }
    /* Keyboard roving focus: no preventScroll here on purpose. The user is
       navigating by keyboard and needs to see where they landed. */
    function focusCurrent() {
      var i = Math.max(1, Math.ceil(value));
      var b = items[i - 1];
      if (b) b.focus();
    }

    render();

    return {
      getValue: function () { return value; },
      setValue: function (v) { set(parseFloat(v)); },
      destroy: function () {
        handlers.forEach(function (h) { h[0].removeEventListener(h[1], h[2]); });
        items.forEach(function (b) { b.remove(); });
      }
    };
  });
})();

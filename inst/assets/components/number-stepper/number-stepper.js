/* FILE: inst/assets/components/number-stepper/number-stepper.js */
/* shadshiny — number-stepper behavior.
   Markup (composes input-group; group owns chrome):
     <div data-shad="number-stepper" class="shad-input-group shad-number-stepper"
          [data-min] [data-max] [data-step="1"] [data-precision]>
       <input class="shad-input" type="text" inputmode="decimal" role="spinbutton" value="0">
       <button type="button" class="shad-number-stepper__btn shad-number-stepper__btn--dec" aria-label="Decrease">−svg</button>
       <button type="button" class="shad-number-stepper__btn shad-number-stepper__btn--inc" aria-label="Increase">+svg</button>
     </div>
   Hold-to-repeat on the buttons (500ms delay, then 60ms). Events: shad:change {value}. */
(function () {
  "use strict";
  shad.register("number-stepper", function (root) {
    var input = root.querySelector("input");
    var dec = root.querySelector(".shad-number-stepper__btn--dec");
    var inc = root.querySelector(".shad-number-stepper__btn--inc");
    var min = root.hasAttribute("data-min") ? parseFloat(root.getAttribute("data-min")) : -Infinity;
    var max = root.hasAttribute("data-max") ? parseFloat(root.getAttribute("data-max")) : Infinity;
    var step = parseFloat(root.getAttribute("data-step") || "1");
    var precision = root.hasAttribute("data-precision")
      ? parseInt(root.getAttribute("data-precision"), 10)
      : (String(step).split(".")[1] || "").length;
    var value = parseFloat(input.value || "0") || 0;

    input.setAttribute("role", "spinbutton");
    if (isFinite(min)) input.setAttribute("aria-valuemin", String(min));
    if (isFinite(max)) input.setAttribute("aria-valuemax", String(max));

    function fmt(v) { return precision > 0 ? v.toFixed(precision) : String(Math.round(v)); }
    function render() {
      var disabled = root.hasAttribute("data-disabled");
      input.disabled = disabled;
      input.value = fmt(value);
      input.setAttribute("aria-valuenow", String(value));
      if (dec) dec.disabled = disabled || value <= min;
      if (inc) inc.disabled = disabled || value >= max;
    }
    function set(v, emitEvt) {
      var nv = shad.util.clamp(v, min, max);
      nv = parseFloat(nv.toFixed(Math.max(precision, 6))); // kill FP drift
      if (nv === value) { render(); return; }
      value = nv;
      render();
      if (emitEvt !== false) shad.util.emit(root, "shad:change", { value: value });
    }
    function nudge(dir, factor) { set(value + dir * step * (factor || 1)); }

    /* hold-to-repeat */
    var holdT = null, repeatT = null;
    function startHold(dir) {
      nudge(dir);
      holdT = setTimeout(function tick() {
        repeatT = setInterval(function () { nudge(dir); }, 60);
      }, 500);
    }
    function stopHold() {
      clearTimeout(holdT); clearInterval(repeatT);
      holdT = repeatT = null;
    }

    var handlers = [];
    function on(el, type, fn, opts) { el.addEventListener(type, fn, opts); handlers.push([el, type, fn, opts]); }

    [[dec, -1], [inc, 1]].forEach(function (pair) {
      var btn = pair[0], dir = pair[1];
      if (!btn) return;
      on(btn, "pointerdown", function (ev) { ev.preventDefault(); startHold(dir); });
      on(btn, "pointerup", stopHold);
      on(btn, "pointerleave", stopHold);
      on(btn, "keydown", function (ev) {
        if (ev.key === "Enter" || ev.key === " ") { ev.preventDefault(); nudge(dir); }
      });
    });

    on(input, "keydown", function (ev) {
      if (ev.key === "ArrowUp") { ev.preventDefault(); nudge(1, ev.shiftKey ? 10 : 1); }
      else if (ev.key === "ArrowDown") { ev.preventDefault(); nudge(-1, ev.shiftKey ? 10 : 1); }
      else if (ev.key === "Home" && isFinite(min)) { ev.preventDefault(); set(min); }
      else if (ev.key === "End" && isFinite(max)) { ev.preventDefault(); set(max); }
      else if (ev.key === "Enter") { commitTyped(); }
    });
    function commitTyped() {
      var v = parseFloat(input.value.replace(",", "."));
      if (isNaN(v)) { render(); return; } // revert junk
      set(v);
    }
    on(input, "blur", commitTyped);

    render();

    return {
      getValue: function () { return value; },
      setValue: function (v) {
        var n = parseFloat(v);
        if (isNaN(n)) { render(); return; } // same rule as typed junk
        set(n);
      },
      setDisabled: function (v) {
        root.toggleAttribute("data-disabled", !!v);
        render();
      },
      destroy: function () {
        stopHold();
        handlers.forEach(function (h) { h[0].removeEventListener(h[1], h[2], h[3]); });
      }
    };
  });
})();

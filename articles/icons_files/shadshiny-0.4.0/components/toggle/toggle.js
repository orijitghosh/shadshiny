/* FILE: inst/assets/components/toggle/toggle.js */
/* shadshiny – toggle behavior (two-state pressed button).
   Markup: <button data-shad="toggle" class="shad-toggle" aria-pressed> */
(function () {
  "use strict";
  shad.register("toggle", function (el) {
    let value = el.getAttribute("data-state") === "on";

    function render() {
      el.setAttribute("data-state", value ? "on" : "off");
      el.setAttribute("aria-pressed", String(value));
    }
    function set(v, emit) {
      v = !!v;
      if (v === value) return;
      value = v;
      render();
      if (emit !== false) shad.util.emit(el, "shad:change", { value });
    }
    function onClick() {
      if (el.hasAttribute("data-disabled") || el.disabled) return;
      set(!value);
    }

    render();
    el.addEventListener("click", onClick);

    return {
      getValue() { return value; },
      setValue(v) { set(v); },
      destroy() { el.removeEventListener("click", onClick); }
    };
  });
})();

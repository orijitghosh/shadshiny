/* FILE: inst/assets/components/switch/switch.js */
/* shadshiny – switch behavior (APG switch pattern).
   Markup: <button data-shad="switch" class="shad-switch" role="switch"> */
(function () {
  "use strict";
  shad.register("switch", function (el) {
    let value = el.getAttribute("data-state") === "checked";

    function render() {
      el.setAttribute("data-state", value ? "checked" : "unchecked");
      el.setAttribute("aria-checked", String(value));
    }
    function set(v, emit) {
      v = !!v;
      if (v === value) return;
      value = v;
      render();
      if (emit !== false) shad.util.emit(el, "shad:change", { value });
    }
    function onClick(ev) {
      ev.preventDefault();
      if (el.hasAttribute("data-disabled") || el.disabled) return;
      set(!value);
    }
    function onKeydown(ev) {
      if (ev.key === "Enter") { ev.preventDefault(); onClick(ev); } // APG: Enter also toggles
    }

    if (!el.hasAttribute("role")) el.setAttribute("role", "switch");
    render();
    el.addEventListener("click", onClick);
    el.addEventListener("keydown", onKeydown);

    return {
      getValue() { return value; },
      setValue(v) { set(v); },
      destroy() {
        el.removeEventListener("click", onClick);
        el.removeEventListener("keydown", onKeydown);
      }
    };
  });
})();

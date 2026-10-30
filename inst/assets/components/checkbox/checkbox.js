/* FILE: inst/assets/components/checkbox/checkbox.js */
/* shadshiny — checkbox behavior.
   Markup: <button data-shad="checkbox" class="shad-checkbox" role="checkbox">
   Value model: true | false | "indeterminate".
   Clicking an indeterminate box checks it (Radix behavior). With
   [data-tristate], clicks cycle unchecked -> checked -> indeterminate. */
(function () {
  "use strict";

  function stateOf(v) {
    return v === "indeterminate" ? "indeterminate" : (v ? "checked" : "unchecked");
  }

  shad.register("checkbox", function (el) {
    let value = el.getAttribute("data-state") === "checked" ? true
      : el.getAttribute("data-state") === "indeterminate" ? "indeterminate"
      : false;

    function render() {
      const s = stateOf(value);
      el.setAttribute("data-state", s);
      el.setAttribute("aria-checked", s === "indeterminate" ? "mixed" : String(s === "checked"));
    }
    function set(v, emit) {
      if (v === value) return;
      value = v;
      render();
      if (emit !== false) shad.util.emit(el, "shad:change", { value });
    }
    function toggle() {
      if (el.hasAttribute("data-disabled") || el.disabled) return;
      if (el.hasAttribute("data-tristate")) {
        set(value === true ? "indeterminate" : value !== "indeterminate");
      } else {
        set(value === "indeterminate" ? true : !value);
      }
    }
    function onClick(ev) { ev.preventDefault(); toggle(); }
    function onKeydown(ev) {
      // buttons fire click on Space natively; Enter should NOT toggle (APG)
      if (ev.key === "Enter") ev.preventDefault();
    }

    if (!el.hasAttribute("role")) el.setAttribute("role", "checkbox");
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

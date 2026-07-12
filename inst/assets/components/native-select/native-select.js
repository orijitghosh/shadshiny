/* FILE: inst/assets/components/native-select/native-select.js */
/* shadshiny — native-select behavior.
   Markup: <div data-shad="native-select" class="shad-native-select">
             <select class="shad-native-select__select">…</select>
             <svg class="shad-icon shad-native-select__chevron" aria-hidden="true">…</svg>
           </div>
   The <select> keeps full native behavior; this binding only bridges its
   value to the shad instance contract (getValue/setValue/shad:change). */
(function () {
  "use strict";
  shad.register("native-select", function (el) {
    const select = el.querySelector("select");
    if (!select) return {};

    /* mirror aria-invalid → data-invalid on the root so CSS/R can use either */
    function syncInvalid() {
      el.toggleAttribute("data-invalid", select.getAttribute("aria-invalid") === "true");
    }

    function onChange() {
      shad.util.emit(el, "shad:change", { value: select.value });
    }

    syncInvalid();
    select.addEventListener("change", onChange);

    return {
      getValue() { return select.value; },
      setValue(v) {
        v = String(v);
        if (v === select.value) return;
        select.value = v;
        shad.util.emit(el, "shad:change", { value: select.value });
      },
      destroy() { select.removeEventListener("change", onChange); }
    };
  });
})();

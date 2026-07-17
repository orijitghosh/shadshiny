/* FILE: inst/assets/components/textarea/textarea.js */
/* shadshiny — textarea autosize behavior.
   Markup: <textarea class="shad-textarea" data-shad="textarea" data-autosize>
   JS fallback for browsers without field-sizing:content. */
(function () {
  "use strict";
  shad.register("textarea", function (el) {
    const autosize = el.hasAttribute("data-autosize");
    const supportsNative = CSS.supports && CSS.supports("field-sizing", "content");

    function resize() {
      if (!autosize || supportsNative) return;
      el.style.height = "auto";
      el.style.height = el.scrollHeight + 2 + "px"; // +2 for borders
    }
    function onInput() {
      resize();
      shad.util.emit(el, "shad:change", { value: el.value });
    }
    el.addEventListener("input", onInput);
    resize();

    return {
      getValue() { return el.value; },
      setValue(v) {
        if (el.value === String(v)) return;
        el.value = v;
        resize();
        shad.util.emit(el, "shad:change", { value: el.value });
      },
      destroy() { el.removeEventListener("input", onInput); }
    };
  });
})();

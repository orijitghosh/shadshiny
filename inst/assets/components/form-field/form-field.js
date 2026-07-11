/* FILE: inst/assets/components/form-field/form-field.js */
/* shadshiny — form-field wiring.
   Markup:
     <div data-shad="form-field">
       <label class="shad-label">…</label>
       <input class="shad-input"> (or any shad control)
       <p class="shad-form-field__description">…</p>
       <p class="shad-form-field__error" hidden></p>
     </div>
   Auto-wires ids + aria-describedby; setError(msg|null) drives invalid state.
   getValue/setValue proxy to the inner control (shad instance or native). */
(function () {
  "use strict";
  shad.register("form-field", function (el) {
    const label = el.querySelector(".shad-label");
    const desc = el.querySelector(".shad-form-field__description");
    const error = el.querySelector(".shad-form-field__error");
    const control = el.querySelector(
      ".shad-input, .shad-textarea, [data-shad]:not([data-shad='form-field'])");

    // id plumbing
    if (control && !control.id) control.id = shad.uid("field");
    if (label && control && !label.htmlFor) label.htmlFor = control.id;
    if (desc && !desc.id) desc.id = shad.uid("desc");
    if (error && !error.id) error.id = shad.uid("err");

    function syncDescribedBy() {
      if (!control) return;
      const ids = [];
      if (desc) ids.push(desc.id);
      if (error && !error.hidden) ids.push(error.id);
      if (ids.length) control.setAttribute("aria-describedby", ids.join(" "));
      else control.removeAttribute("aria-describedby");
    }
    syncDescribedBy();
    if (error && !error.hidden && error.textContent.trim()) {
      el.setAttribute("data-invalid", "");
      if (control) control.setAttribute("aria-invalid", "true");
    }

    function inner() {
      // late-bound: inner shad component may init after us
      return control ? shad.get(control) : null;
    }

    return {
      setError(msg) {
        if (!error) return;
        if (msg) {
          error.textContent = msg;
          error.hidden = false;
          el.setAttribute("data-invalid", "");
          if (control) control.setAttribute("aria-invalid", "true");
        } else {
          error.hidden = true;
          el.removeAttribute("data-invalid");
          if (control) control.removeAttribute("aria-invalid");
        }
        syncDescribedBy();
      },
      getValue() {
        const i = inner();
        if (i && i.getValue) return i.getValue();
        return control ? control.value : undefined;
      },
      setValue(v) {
        const i = inner();
        if (i && i.setValue) { i.setValue(v); return; }
        if (control) {
          control.value = v;
          shad.util.emit(el, "shad:change", { value: v });
        }
      },
      destroy() {}
    };
  });
})();

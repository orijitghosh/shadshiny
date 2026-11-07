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
   A component root is not labelable, so the label, description and error go
   to the part that takes focus (contract: tests/js/field-label.test.js).
   getValue/setValue proxy to the inner control (shad instance or native). */
(function () {
  "use strict";
  shad.register("form-field", function (el) {
    const label = el.querySelector(".shad-label");
    const desc = el.querySelector(".shad-form-field__description");
    const error = el.querySelector(".shad-form-field__error");
    const control = el.querySelector(
      ".shad-input, .shad-textarea, [data-shad]:not([data-shad='form-field'])");

    // The part that takes focus: a labelable control (input, button, ...)
    // or a root with its own role, else its slider thumbs or first input or
    // button.
    const labelable = control && control.labels;
    let parts = [];
    if (control) {
      const thumbs = control.querySelectorAll("[role='slider']");
      parts = labelable || control.hasAttribute("role") ? [control]
        : thumbs.length ? Array.from(thumbs)
          : [control.querySelector("input, button")].filter(Boolean);
    }

    // id plumbing
    if (control && !control.id) control.id = shad.uid("field");
    if (label && labelable) {
      if (!label.htmlFor) label.htmlFor = control.id;
    } else if (label) {
      if (!label.id) label.id = shad.uid("label");
      parts.forEach((p) => {
        // a plain button shows the value, a range slider thumb which end it
        // is: keep that after the label
        const own = parts.length > 1 || p.matches("button:not([role])");
        if (own && !p.id) p.id = shad.uid("part");
        p.setAttribute("aria-labelledby", own ? label.id + " " + p.id : label.id);
      });
    }
    if (desc && !desc.id) desc.id = shad.uid("desc");
    if (error && !error.id) error.id = shad.uid("err");

    function invalid(on) {
      new Set([control, ...parts]).forEach((p) => {
        if (!p) return;
        if (on) p.setAttribute("aria-invalid", "true");
        else p.removeAttribute("aria-invalid");
      });
    }
    function syncDescribedBy() {
      const ids = [];
      if (desc) ids.push(desc.id);
      if (error && !error.hidden) ids.push(error.id);
      parts.forEach((p) => {
        if (ids.length) p.setAttribute("aria-describedby", ids.join(" "));
        else p.removeAttribute("aria-describedby");
      });
    }
    syncDescribedBy();
    if (error && !error.hidden && error.textContent.trim()) {
      el.setAttribute("data-invalid", "");
      invalid(true);
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
          invalid(true);
        } else {
          error.hidden = true;
          el.removeAttribute("data-invalid");
          invalid(false);
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

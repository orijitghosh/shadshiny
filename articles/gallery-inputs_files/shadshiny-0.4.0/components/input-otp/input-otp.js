/* FILE: inst/assets/components/input-otp/input-otp.js */
/* shadshiny — input-otp behavior (input-otp library pattern).
   One REAL <input> overlays the whole control (opacity 0); cells are a pure
   rendering of its value + caret position. Paste splits automatically;
   typing auto-advances (native, since it's one input).
   Markup:
     <div data-shad="input-otp" class="shad-otp" data-length="6" [data-pattern="\\d*"]>
       <input class="shad-otp__input" inputmode="numeric" autocomplete="one-time-code">
       <div class="shad-otp__group"> <div class="shad-otp__cell"></div>×3 </div>
       <div class="shad-otp__separator">–</div>
       <div class="shad-otp__group"> …×3 </div>
     </div>
   Cell count must equal data-length. */
(function () {
  "use strict";
  shad.register("input-otp", function (root) {
    const input = root.querySelector(".shad-otp__input");
    const cells = Array.from(root.querySelectorAll(".shad-otp__cell"));
    const length = parseInt(root.getAttribute("data-length") || String(cells.length), 10);
    const pattern = root.getAttribute("data-pattern"); // e.g. "\\d*"
    const re = pattern ? new RegExp("^" + pattern + "$") : null;
    let lastEmitted = null;

    input.maxLength = length;
    input.setAttribute("aria-label", input.getAttribute("aria-label") || "One-time code");

    function sanitize(v) {
      let out = "";
      for (const ch of v) {
        if (!re || re.test(ch)) out += ch;
        if (out.length >= length) break;
      }
      return out;
    }
    function render() {
      const v = input.value;
      const focused = document.activeElement === input;
      const caret = Math.min(v.length, length - 1);
      cells.forEach((cell, i) => {
        cell.textContent = v[i] || "";
        cell.removeAttribute("data-active");
        const caretEl = cell.querySelector(".shad-otp__caret");
        if (caretEl) caretEl.remove();
        if (focused && i === caret && !v[i]) {
          cell.setAttribute("data-active", "");
          const c = document.createElement("span");
          c.className = "shad-otp__caret";
          cell.appendChild(c);
        } else if (focused && (i === caret || (v.length === length && i === length - 1))) {
          cell.setAttribute("data-active", "");
        }
      });
    }
    function maybeEmit() {
      const v = input.value;
      if (v === lastEmitted) return;
      lastEmitted = v;
      shad.util.emit(root, "shad:change", { value: v, complete: v.length === length });
    }
    function onInput() {
      const clean = sanitize(input.value);
      if (clean !== input.value) input.value = clean;
      render();
      maybeEmit();
    }
    function onPaste(ev) {
      ev.preventDefault();
      const text = (ev.clipboardData || window.clipboardData).getData("text") || "";
      input.value = sanitize(text.trim());
      render();
      maybeEmit();
    }
    function onFocusBlur() { render(); }
    function onCellsClick() { input.focus({ preventScroll: true }); }

    input.addEventListener("input", onInput);
    input.addEventListener("paste", onPaste);
    input.addEventListener("focus", onFocusBlur);
    input.addEventListener("blur", onFocusBlur);
    root.addEventListener("click", onCellsClick);
    render();

    return {
      getValue() { return input.value; },
      setValue(v) {
        const clean = sanitize(String(v || ""));
        if (clean === input.value) return;
        input.value = clean;
        render();
        maybeEmit();
      },
      destroy() {
        input.removeEventListener("input", onInput);
        input.removeEventListener("paste", onPaste);
        input.removeEventListener("focus", onFocusBlur);
        input.removeEventListener("blur", onFocusBlur);
        root.removeEventListener("click", onCellsClick);
      }
    };
  });
})();

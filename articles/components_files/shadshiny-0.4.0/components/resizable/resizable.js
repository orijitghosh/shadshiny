/* FILE: inst/assets/components/resizable/resizable.js */
/* shadshiny — resizable behavior (APG window splitter).
   Panels declare data-size (percent; normalized on init) and optional
   data-min (percent, default 10). Handles between panels drag with pointer
   and step with arrows (1%, Shift=10%), Home/End collapse/expand to min/max.
   getValue() -> array of panel sizes (percent, 1dp). */
(function () {
  "use strict";
  shad.register("resizable", function (root) {
    const orientation = root.getAttribute("data-orientation") || "horizontal";
    const horizontal = orientation === "horizontal";
    root.setAttribute("data-orientation", orientation);
    const panels = Array.from(root.querySelectorAll(":scope > .shad-resizable__panel"));
    const handles = Array.from(root.querySelectorAll(":scope > .shad-resizable__handle"));
    let sizes = panels.map((p) => parseFloat(p.dataset.size || "0") || 0);
    const mins = panels.map((p) => parseFloat(p.dataset.min || "10"));

    // normalize sizes to 100
    const total = sizes.reduce((a, b) => a + b, 0);
    sizes = total > 0 ? sizes.map((s) => (s / total) * 100)
                      : panels.map(() => 100 / panels.length);

    function apply(fire) {
      panels.forEach((p, i) => {
        p.style.flexBasis = sizes[i] + "%";
      });
      handles.forEach((h, i) => {
        h.setAttribute("aria-valuenow", String(Math.round(sizes[i])));
      });
      if (fire) {
        shad.util.emit(root, "shad:change", {
          value: sizes.map((s) => Math.round(s * 10) / 10)
        });
      }
    }
    /** move boundary after panel i by delta (percent) */
    function moveBoundary(i, delta, fire) {
      const a = i, b = i + 1;
      const clampedDelta = shad.util.clamp(delta,
        -(sizes[a] - mins[a]), sizes[b] - mins[b]);
      sizes[a] += clampedDelta;
      sizes[b] -= clampedDelta;
      apply(fire);
    }

    handles.forEach((handle, i) => {
      handle.setAttribute("role", "separator");
      handle.setAttribute("tabindex", "0");
      handle.setAttribute("aria-orientation", horizontal ? "vertical" : "horizontal");
      handle.setAttribute("aria-valuemin", String(mins[i]));
      handle.setAttribute("aria-valuemax", "100");
      handle.setAttribute("aria-label", "Resize panel");

      let drag = null;
      handle.addEventListener("pointerdown", (ev) => {
        ev.preventDefault();
        const rect = root.getBoundingClientRect();
        drag = {
          startPos: horizontal ? ev.clientX : ev.clientY,
          startSizes: sizes.slice(),
          groupSize: horizontal ? rect.width : rect.height
        };
        handle.setAttribute("data-dragging", "");
        handle.setPointerCapture(ev.pointerId);
      });
      handle.addEventListener("pointermove", (ev) => {
        if (!drag) return;
        const pos = horizontal ? ev.clientX : ev.clientY;
        const deltaPct = ((pos - drag.startPos) / drag.groupSize) * 100;
        sizes = drag.startSizes.slice();
        moveBoundary(i, deltaPct, false);
      });
      const end = (ev) => {
        if (!drag) return;
        drag = null;
        handle.removeAttribute("data-dragging");
        try { handle.releasePointerCapture(ev.pointerId); } catch (e) {}
        apply(true); // fire once on release
      };
      handle.addEventListener("pointerup", end);
      handle.addEventListener("pointercancel", end);

      handle.addEventListener("keydown", (ev) => {
        const step = ev.shiftKey ? 10 : 1;
        let handled = true;
        switch (ev.key) {
          case "ArrowLeft": if (horizontal) moveBoundary(i, -step, true); else handled = false; break;
          case "ArrowRight": if (horizontal) moveBoundary(i, step, true); else handled = false; break;
          case "ArrowUp": if (!horizontal) moveBoundary(i, -step, true); else handled = false; break;
          case "ArrowDown": if (!horizontal) moveBoundary(i, step, true); else handled = false; break;
          case "Home": moveBoundary(i, -100, true); break;
          case "End": moveBoundary(i, 100, true); break;
          default: handled = false;
        }
        if (handled) ev.preventDefault();
      });
    });

    apply(false);

    return {
      getValue() { return sizes.map((s) => Math.round(s * 10) / 10); },
      setValue(v) {
        if (Array.isArray(v) && v.length === sizes.length) {
          const t = v.reduce((a, b) => a + b, 0);
          sizes = v.map((s) => (s / t) * 100);
          apply(true);
        }
      },
      destroy() {}
    };
  });
})();

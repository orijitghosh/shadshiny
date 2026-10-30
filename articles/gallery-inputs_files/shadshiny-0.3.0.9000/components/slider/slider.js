/* FILE: inst/assets/components/slider/slider.js */
/* shadshiny — slider behavior (APG slider pattern).
   Markup:
     <div data-shad="slider" class="shad-slider"
          data-min="0" data-max="100" data-step="1" data-value="50"
          [data-value2="80"]  <- presence makes it a RANGE slider
          [data-marks="0,25,50,75,100"] [data-marks-labels]>
       <div class="shad-slider__track">
         <div class="shad-slider__range"></div>
       </div>
       <div class="shad-slider__thumb" role="slider" tabindex="0"></div>
       [second thumb for range]
     </div>
   Value: single -> number; range -> [lo, hi].
   Keyboard: arrows ±step, PageUp/Down ±10*step, Home/End min/max. */
(function () {
  "use strict";
  shad.register("slider", function (root) {
    const track = root.querySelector(".shad-slider__track");
    const range = root.querySelector(".shad-slider__range");
    const thumbs = Array.from(root.querySelectorAll(".shad-slider__thumb"));
    const vertical = root.getAttribute("data-orientation") === "vertical";
    const min = parseFloat(root.getAttribute("data-min") || "0");
    const max = parseFloat(root.getAttribute("data-max") || "100");
    const step = parseFloat(root.getAttribute("data-step") || "1");
    const isRange = thumbs.length > 1;

    let values = [parseFloat(root.getAttribute("data-value") || String(min))];
    if (isRange) values.push(parseFloat(root.getAttribute("data-value2") || String(max)));

    function snap(v) {
      v = shad.util.clamp(v, min, max);
      const snapped = min + Math.round((v - min) / step) * step;
      // avoid float drift
      return parseFloat(snapped.toFixed(10));
    }
    function pct(v) { return ((v - min) / (max - min)) * 100; }

    function render() {
      values = values.map(snap);
      if (isRange && values[0] > values[1]) values.sort((a, b) => a - b);
      thumbs.forEach((t, i) => {
        const p = pct(values[i]);
        if (vertical) t.style.bottom = p + "%";
        else t.style.left = p + "%";
        t.setAttribute("aria-valuemin", String(min));
        t.setAttribute("aria-valuemax", String(max));
        t.setAttribute("aria-valuenow", String(values[i]));
        t.setAttribute("aria-orientation", vertical ? "vertical" : "horizontal");
      });
      const lo = isRange ? pct(values[0]) : 0;
      const hi = pct(values[isRange ? 1 : 0]);
      if (vertical) {
        range.style.bottom = lo + "%";
        range.style.top = (100 - hi) + "%";
      } else {
        range.style.left = lo + "%";
        range.style.width = (hi - lo) + "%";
      }
    }
    function emit() {
      shad.util.emit(root, "shad:change", { value: isRange ? values.slice() : values[0] });
    }
    function setIndex(i, v, doEmit) {
      v = snap(v);
      // range: clamp against sibling
      if (isRange) {
        if (i === 0) v = Math.min(v, values[1]);
        else v = Math.max(v, values[0]);
      }
      if (values[i] === v) return;
      values[i] = v;
      render();
      if (doEmit !== false) emit();
    }

    /* pointer */
    let dragIndex = -1;
    function valueFromPointer(ev) {
      const r = track.getBoundingClientRect();
      const frac = vertical
        ? 1 - (ev.clientY - r.top) / r.height
        : (ev.clientX - r.left) / r.width;
      return min + shad.util.clamp(frac, 0, 1) * (max - min);
    }
    function nearestThumb(v) {
      if (!isRange) return 0;
      return Math.abs(v - values[0]) <= Math.abs(v - values[1]) ? 0 : 1;
    }
    function onPointerDown(ev) {
      if (root.hasAttribute("data-disabled")) return;
      ev.preventDefault();
      const v = valueFromPointer(ev);
      const ti = ev.target.closest(".shad-slider__thumb")
        ? thumbs.indexOf(ev.target.closest(".shad-slider__thumb"))
        : nearestThumb(v);
      dragIndex = ti;
      if (!ev.target.closest(".shad-slider__thumb")) setIndex(ti, v);
      thumbs[ti].focus({ preventScroll: true });
      root.setPointerCapture && root.setPointerCapture(ev.pointerId);
      root.addEventListener("pointermove", onPointerMove);
      root.addEventListener("pointerup", onPointerUp);
      root.addEventListener("pointercancel", onPointerUp);
    }
    function onPointerMove(ev) {
      if (dragIndex === -1) return;
      setIndex(dragIndex, valueFromPointer(ev));
    }
    function onPointerUp(ev) {
      dragIndex = -1;
      root.releasePointerCapture && root.releasePointerCapture(ev.pointerId);
      root.removeEventListener("pointermove", onPointerMove);
      root.removeEventListener("pointerup", onPointerUp);
      root.removeEventListener("pointercancel", onPointerUp);
    }

    /* keyboard */
    function onKeydown(ev) {
      const i = thumbs.indexOf(ev.target);
      if (i === -1) return;
      let delta = 0;
      switch (ev.key) {
        case "ArrowRight": case "ArrowUp": delta = step; break;
        case "ArrowLeft": case "ArrowDown": delta = -step; break;
        case "PageUp": delta = step * 10; break;
        case "PageDown": delta = -step * 10; break;
        case "Home": ev.preventDefault(); setIndex(i, min); return;
        case "End": ev.preventDefault(); setIndex(i, max); return;
        default: return;
      }
      ev.preventDefault();
      setIndex(i, values[i] + delta);
    }

    /* marks (optional) */
    const marksAttr = root.getAttribute("data-marks");
    let marksEl = null;
    if (marksAttr) {
      marksEl = document.createElement("div");
      marksEl.className = "shad-slider__marks";
      marksEl.setAttribute("aria-hidden", "true");
      const withLabels = root.hasAttribute("data-marks-labels");
      marksAttr.split(",").map((s) => parseFloat(s.trim())).forEach((mv) => {
        const dot = document.createElement("span");
        dot.className = "shad-slider__mark";
        dot.style[vertical ? "bottom" : "left"] = pct(snap(mv)) + "%";
        marksEl.appendChild(dot);
        if (withLabels) {
          const lab = document.createElement("span");
          lab.className = "shad-slider__mark-label";
          lab.style[vertical ? "bottom" : "left"] = pct(snap(mv)) + "%";
          lab.textContent = String(mv);
          marksEl.appendChild(lab);
        }
      });
      track.parentNode.insertBefore(marksEl, track.nextSibling);
    }

    thumbs.forEach((t) => {
      if (!t.hasAttribute("role")) t.setAttribute("role", "slider");
      if (!t.hasAttribute("tabindex")) t.setAttribute("tabindex", "0");
    });
    root.addEventListener("pointerdown", onPointerDown);
    root.addEventListener("keydown", onKeydown);
    render();

    return {
      getValue() { return isRange ? values.slice() : values[0]; },
      setValue(v) {
        const next = isRange ? v.slice() : [v];
        const same = next.every((x, i) => snap(x) === values[i]);
        if (same) return;
        values = next;
        render();
        emit();
      },
      destroy() {
        root.removeEventListener("pointerdown", onPointerDown);
        root.removeEventListener("keydown", onKeydown);
        if (marksEl) marksEl.remove();
      }
    };
  });
})();

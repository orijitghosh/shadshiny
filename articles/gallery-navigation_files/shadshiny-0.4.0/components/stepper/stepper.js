/* FILE: inst/assets/components/stepper/stepper.js */
/* shadshiny – stepper behavior.
   Markup:
     <div data-shad="stepper" class="shad-stepper" data-orientation="horizontal"
          [data-linear] [data-clickable] [data-active="0"]>
       <ol class="shad-stepper__list">
         <li class="shad-stepper__item" [data-state=...]>
           <button type="button" class="shad-stepper__trigger">
             <span class="shad-stepper__indicator">
               <span class="shad-stepper__number">1</span>
               <svg class="shad-stepper__check">…</svg><svg class="shad-stepper__x">…</svg>
             </span>
             <span class="shad-stepper__meta">
               <span class="shad-stepper__label">…</span>
               [<span class="shad-stepper__description">…</span>]
             </span>
           </button>
           <span class="shad-stepper__connector" aria-hidden="true"></span>
         </li>…
       </ol>
       [<div class="shad-stepper__panels">
          <div class="shad-stepper__panel">…</div> (one per step, in order)
        </div>]
     </div>
   data-linear: steps only reachable sequentially (click capped at first
   incomplete step). data-clickable: triggers are interactive.
   An initial data-state="error" on an item is preserved until that step is
   revisited. Events: shad:change {value: stepIndex}. */
(function () {
  "use strict";
  shad.register("stepper", function (root) {
    var items = Array.from(root.querySelectorAll(".shad-stepper__item"));
    var triggers = items.map(function (it) { return it.querySelector(".shad-stepper__trigger"); });
    var panels = Array.from(root.querySelectorAll(".shad-stepper__panel"));
    var clickable = root.hasAttribute("data-clickable");
    var linear = root.hasAttribute("data-linear");
    var active = parseInt(root.getAttribute("data-active") || "0", 10);
    var errors = {};
    items.forEach(function (it, i) { if (it.getAttribute("data-state") === "error") errors[i] = true; });
    if (clickable) root.classList.add("shad-stepper--clickable");

    if (!root.getAttribute("data-orientation")) root.setAttribute("data-orientation", "horizontal");

    function maxReachable() {
      return linear ? Math.min(active + 1, items.length - 1) : items.length - 1;
    }
    function render() {
      items.forEach(function (it, i) {
        var state = errors[i] ? "error"
          : i < active ? "complete"
          : i === active ? "active" : "inactive";
        it.setAttribute("data-state", state);
        var t = triggers[i];
        if (t) {
          if (i === active) t.setAttribute("aria-current", "step");
          else t.removeAttribute("aria-current");
          var reachable = clickable && i <= maxReachable();
          t.disabled = clickable ? !reachable : true;
          if (!clickable) t.removeAttribute("disabled"); // display-only: keep natural
          if (!clickable) t.setAttribute("tabindex", "-1");
        }
      });
      panels.forEach(function (p, i) {
        if (i === active) {
          p.hidden = false;
          p.setAttribute("data-state", "open");
        } else {
          p.setAttribute("data-state", "closed");
          p.hidden = true;
        }
      });
    }
    function goTo(i, emitEvt) {
      var n = Math.max(0, Math.min(i, items.length - 1));
      if (linear && n > maxReachable()) n = maxReachable();
      if (n === active) { render(); return; }
      delete errors[n]; // revisiting an errored step clears it
      active = n;
      render();
      if (emitEvt !== false) shad.util.emit(root, "shad:change", { value: active });
    }

    var onClicks = [];
    triggers.forEach(function (t, i) {
      if (!t) return;
      var fn = function () { if (clickable) goTo(i); };
      t.addEventListener("click", fn);
      onClicks.push([t, fn]);
    });

    render();

    return {
      getValue: function () { return active; },
      setValue: function (v) { goTo(parseInt(v, 10)); },
      next: function () { goTo(active + 1); },
      prev: function () { goTo(active - 1); },
      goTo: function (i) { goTo(i); },
      setError: function (i, on) {
        if (on === false) delete errors[i]; else errors[i] = true;
        render();
      },
      destroy: function () {
        onClicks.forEach(function (p) { p[0].removeEventListener("click", p[1]); });
      }
    };
  });
})();

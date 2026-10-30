/* FILE: inst/assets/components/tabs/tabs.js */
/* shadshiny — tabs behavior (APG tabs, automatic activation).
   Markup:
     <div data-shad="tabs" data-value="account">
       <div class="shad-tabs__list">
         <div class="shad-tabs__indicator"></div>
         <button class="shad-tabs__trigger" data-value="account">Account</button>
         …
       </div>
       <div class="shad-tabs__content" data-value="account">…</div>
       …
     </div> */
(function () {
  "use strict";
  shad.register("tabs", function (root) {
    const list = root.querySelector(".shad-tabs__list");
    const indicator = list.querySelector(".shad-tabs__indicator");
    const triggers = Array.from(list.querySelectorAll(".shad-tabs__trigger"));
    const panels = Array.from(root.querySelectorAll(".shad-tabs__content"));
    let value = root.getAttribute("data-value") ||
      (triggers[0] && triggers[0].dataset.value);

    list.setAttribute("role", "tablist");
    triggers.forEach((t) => {
      t.setAttribute("role", "tab");
      t.id = t.id || shad.uid("tab");
    });
    panels.forEach((p) => {
      p.setAttribute("role", "tabpanel");
      p.setAttribute("tabindex", "0");
      p.id = p.id || shad.uid("tabpanel");
      const t = triggers.find((x) => x.dataset.value === p.dataset.value);
      if (t) {
        p.setAttribute("aria-labelledby", t.id);
        t.setAttribute("aria-controls", p.id);
      }
    });

    function positionIndicator() {
      const active = triggers.find((t) => t.dataset.value === value);
      if (!active || !indicator) return;
      indicator.style.width = active.offsetWidth + "px";
      indicator.style.transform = "translateX(" + active.offsetLeft + "px)";
    }
    function apply(fireEvent) {
      triggers.forEach((t) => {
        const on = t.dataset.value === value;
        t.setAttribute("data-state", on ? "active" : "inactive");
        t.setAttribute("aria-selected", on ? "true" : "false");
        t.setAttribute("tabindex", on ? "0" : "-1");
      });
      panels.forEach((p) => {
        p.setAttribute("data-state", p.dataset.value === value ? "active" : "inactive");
      });
      positionIndicator();
      if (fireEvent) shad.util.emit(root, "shad:change", { value });
    }
    function select(v, fire) {
      if (v === value) return;
      value = v;
      root.setAttribute("data-value", v);
      apply(fire !== false);
    }

    triggers.forEach((t) => {
      t.addEventListener("click", () => {
        if (!t.hasAttribute("data-disabled")) select(t.dataset.value);
      });
    });
    // automatic activation: arrow focus selects
    const rove = shad.roving(list, {
      selector: ".shad-tabs__trigger",
      orientation: root.getAttribute("data-orientation") === "vertical" ? "vertical" : "horizontal",
      focusItem(el) {
        el.focus({ preventScroll: true });
        select(el.dataset.value);
      }
    });

    // fonts/layout can shift after load; keep the indicator honest
    const onResize = () => positionIndicator();
    window.addEventListener("resize", onResize, { passive: true });
    if (document.fonts && document.fonts.ready) {
      document.fonts.ready.then(positionIndicator);
    }
    apply(false);

    return {
      getValue() { return value; },
      setValue(v) { select(v, true); },
      destroy() {
        rove.destroy();
        window.removeEventListener("resize", onResize);
      }
    };
  });
})();

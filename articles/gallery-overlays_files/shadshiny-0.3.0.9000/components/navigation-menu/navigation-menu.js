/* FILE: inst/assets/components/navigation-menu/navigation-menu.js */
/* shadshiny — navigation-menu behavior.
   One shared viewport under the trigger row; opening a different trigger
   cross-fades panels while the viewport animates width/height between
   panel sizes. Hover opens (150ms intent delay), click toggles, Esc closes.
   Panels stay in place (no portal — nav sits at page level). */
(function () {
  "use strict";
  shad.register("navigation-menu", function (root) {
    const viewport = root.querySelector(".shad-nav-menu__viewport");
    const entries = []; // {trigger, panel}
    let activeIndex = -1;
    let openTimer = null, closeTimer = null;
    let disposeDismiss = null;

    viewport.hidden = true;

    root.querySelectorAll("[data-shad-nav-item]").forEach((wrap) => {
      const trigger = wrap.querySelector(".shad-nav-menu__trigger");
      const panel = wrap.querySelector(".shad-nav-menu__panel");
      if (!trigger || !panel) return; // plain link item
      panel.hidden = true;
      panel.setAttribute("data-state", "closed");
      panel.id = panel.id || shad.uid("nav-panel");
      trigger.setAttribute("aria-expanded", "false");
      trigger.setAttribute("aria-controls", panel.id);
      viewport.appendChild(panel); // panels live inside the shared viewport
      entries.push({ trigger, panel });
    });

    function sizeViewportTo(panel) {
      // measure the panel offscreen-safe: it's inside the viewport already
      panel.hidden = false;
      const w = panel.offsetWidth, h = panel.offsetHeight;
      viewport.style.setProperty("--shad-nav-viewport-width", w + "px");
      viewport.style.setProperty("--shad-nav-viewport-height", h + "px");
    }
    function openAt(i) {
      clearTimeout(closeTimer); closeTimer = null;
      if (activeIndex === i) return;
      const prev = activeIndex !== -1 ? entries[activeIndex] : null;
      const next = entries[i];
      activeIndex = i;

      if (viewport.hidden) {
        viewport.hidden = false;
        sizeViewportTo(next.panel);
        shad.presence.show(next.panel);
        // align viewport's left edge under the active trigger
        positionViewport(next.trigger);
        disposeDismiss = shad.dismiss.push({
          el: root,
          onDismiss: () => closeAll(true)
        });
        shad.util.emit(root, "shad:open", {});
      } else {
        if (prev) {
          prev.trigger.setAttribute("data-state", "closed");
          prev.trigger.setAttribute("aria-expanded", "false");
          shad.presence.hide(prev.panel);
        }
        sizeViewportTo(next.panel);
        shad.presence.show(next.panel);
        positionViewport(next.trigger);
      }
      next.trigger.setAttribute("data-state", "open");
      next.trigger.setAttribute("aria-expanded", "true");
    }
    function positionViewport(trigger) {
      const rootRect = root.getBoundingClientRect();
      const tRect = trigger.getBoundingClientRect();
      const vw = viewport.offsetWidth || 0;
      let left = tRect.left - rootRect.left;
      // clamp so the viewport doesn't spill past the nav's right edge
      left = Math.max(0, Math.min(left, rootRect.width - vw));
      viewport.style.left = Math.round(left) + "px";
    }
    function closeAll(instant) {
      clearTimeout(openTimer); openTimer = null;
      clearTimeout(closeTimer); closeTimer = null;
      if (activeIndex === -1) return;
      const cur = entries[activeIndex];
      cur.trigger.setAttribute("data-state", "closed");
      cur.trigger.setAttribute("aria-expanded", "false");
      activeIndex = -1;
      if (disposeDismiss) { disposeDismiss(); disposeDismiss = null; }
      shad.presence.hide(cur.panel, () => {
        if (activeIndex === -1) viewport.hidden = true;
      });
      shad.util.emit(root, "shad:close", {});
    }
    function scheduleClose() {
      clearTimeout(closeTimer);
      closeTimer = setTimeout(() => closeAll(false), 200);
    }

    entries.forEach((e, i) => {
      e.trigger.addEventListener("click", () => {
        activeIndex === i ? closeAll(false) : openAt(i);
      });
      e.trigger.addEventListener("pointerenter", (ev) => {
        if (shad.util.isTouchPointer(ev)) return;
        clearTimeout(openTimer);
        openTimer = setTimeout(() => openAt(i), 150); // hover intent
      });
      e.trigger.addEventListener("pointerleave", () => {
        clearTimeout(openTimer); openTimer = null;
        scheduleClose();
      });
      e.trigger.addEventListener("keydown", (ev) => {
        if (ev.key === "ArrowDown" && activeIndex === i) {
          ev.preventDefault();
          const first = shad.util.tabbables(e.panel)[0];
          if (first) first.focus({ preventScroll: true });
        }
      });
    });
    viewport.addEventListener("pointerenter", () => {
      clearTimeout(closeTimer); closeTimer = null;
    });
    viewport.addEventListener("pointerleave", scheduleClose);

    const rove = shad.roving(root.querySelector(".shad-nav-menu__list"), {
      selector: ".shad-nav-menu__trigger, .shad-nav-menu__link",
      orientation: "horizontal"
    });

    return {
      getValue() { return activeIndex; },
      setValue(i) { typeof i === "number" && i >= 0 ? openAt(i) : closeAll(false); },
      open() { openAt(0); },
      close() { closeAll(false); },
      get isOpen() { return activeIndex !== -1; },
      destroy() { closeAll(false); rove.destroy(); }
    };
  });
})();

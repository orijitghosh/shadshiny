/* FILE: inst/assets/components/tooltip/tooltip.js */
/* shadshiny — tooltip behavior (APG tooltip pattern).
   Delay group (module-level): first open waits 700ms; if a tooltip closed
   within the last 1.5s, the next opens after 300ms (feels like one group).
   Skipped entirely for touch pointers. Opens on focus-visible immediately.
   Never traps focus; Esc closes; pointerleave/blur close instantly. */
(function () {
  "use strict";
  const group = { lastClose: 0 }; // shared across all tooltip instances

  shad.register("tooltip", function (root) {
    const trigger = root.querySelector(".shad-tooltip__trigger");
    const content = root.querySelector(".shad-tooltip__content");
    const arrow = content.querySelector(".shad-tooltip__arrow");
    const side = root.getAttribute("data-side") || "top";
    const align = root.getAttribute("data-align") || "center";

    let open = false;
    let openTimer = null;
    let untrack = null, restore = null;

    content.hidden = true;
    content.setAttribute("data-state", "closed");
    content.setAttribute("role", "tooltip");
    content.id = content.id || shad.uid("tooltip");
    trigger.setAttribute("aria-describedby", content.id);

    function doOpen() {
      if (open) return;
      open = true;
      restore = shad.portal(content);
      shad.presence.show(content);
      untrack = shad.floating.track(trigger, content, {
        side, align, offset: 6, arrow: arrow || undefined
      });
      shad.util.emit(root, "shad:open", {});
    }
    function doClose() {
      clearTimeout(openTimer); openTimer = null;
      if (!open) return;
      open = false;
      group.lastClose = Date.now();
      if (untrack) { untrack(); untrack = null; }
      shad.presence.hide(content, () => {
        if (restore) { restore(); restore = null; }
      });
      shad.util.emit(root, "shad:close", {});
    }
    function scheduleOpen() {
      if (open || openTimer) return;
      const withinGroup = Date.now() - group.lastClose < 1500;
      openTimer = setTimeout(() => { openTimer = null; doOpen(); },
        withinGroup ? 300 : 700);
    }

    function onPointerEnter(ev) {
      if (shad.util.isTouchPointer(ev)) return; // skip touch
      scheduleOpen();
    }
    function onPointerLeave() { doClose(); }
    function onPointerDown() { doClose(); } // pressing the trigger hides it
    function onFocus(ev) {
      // only keyboard focus shows the tooltip (matches Radix focus-visible)
      if (trigger.matches(":focus-visible")) doOpen();
    }
    function onBlur() { doClose(); }
    function onKeydown(ev) { if (ev.key === "Escape" && open) doClose(); }

    trigger.addEventListener("pointerenter", onPointerEnter);
    trigger.addEventListener("pointerleave", onPointerLeave);
    trigger.addEventListener("pointerdown", onPointerDown);
    trigger.addEventListener("focus", onFocus);
    trigger.addEventListener("blur", onBlur);
    document.addEventListener("keydown", onKeydown, true);

    return {
      getValue() { return open; },
      setValue(v) { v ? doOpen() : doClose(); },
      open: doOpen, close: doClose,
      get isOpen() { return open; },
      destroy() {
        doClose();
        trigger.removeEventListener("pointerenter", onPointerEnter);
        trigger.removeEventListener("pointerleave", onPointerLeave);
        trigger.removeEventListener("pointerdown", onPointerDown);
        trigger.removeEventListener("focus", onFocus);
        trigger.removeEventListener("blur", onBlur);
        document.removeEventListener("keydown", onKeydown, true);
      }
    };
  });
})();

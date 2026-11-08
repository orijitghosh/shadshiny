/* FILE: inst/assets/components/hover-card/hover-card.js */
/* shadshiny – hover-card behavior.
   Pointer-only supplementary preview: open after 700ms hover, close after
   300ms once the pointer leaves BOTH trigger and panel. Also opens on
   keyboard focus (immediate) and closes on blur/Esc. Not a tooltip role –
   content is rich; screen readers reach it via the trigger link itself. */
(function () {
  "use strict";
  shad.register("hover-card", function (root) {
    const trigger = root.querySelector(".shad-hover-card__trigger");
    const content = root.querySelector(".shad-hover-card__content");
    const side = root.getAttribute("data-side") || "bottom";
    const align = root.getAttribute("data-align") || "center";

    let open = false;
    let openTimer = null, closeTimer = null;
    let untrack = null, restore = null;

    content.hidden = true;
    content.setAttribute("data-state", "closed");

    function doOpen() {
      clearTimeout(closeTimer); closeTimer = null;
      if (open) return;
      open = true;
      restore = shad.portal(content);
      shad.presence.show(content);
      untrack = shad.floating.track(trigger, content, { side, align, offset: 6 });
      shad.util.emit(root, "shad:open", {});
    }
    function doClose() {
      clearTimeout(openTimer); openTimer = null;
      clearTimeout(closeTimer); closeTimer = null;
      if (!open) return;
      open = false;
      if (untrack) { untrack(); untrack = null; }
      shad.presence.hide(content, () => {
        if (restore) { restore(); restore = null; }
      });
      shad.util.emit(root, "shad:close", {});
    }
    function scheduleOpen(delay) {
      clearTimeout(closeTimer); closeTimer = null;
      if (open || openTimer) return;
      openTimer = setTimeout(() => { openTimer = null; doOpen(); }, delay);
    }
    function scheduleClose() {
      clearTimeout(openTimer); openTimer = null;
      if (!open || closeTimer) return;
      closeTimer = setTimeout(() => { closeTimer = null; doClose(); }, 300);
    }

    function onTriggerEnter(ev) {
      if (shad.util.isTouchPointer(ev)) return;
      scheduleOpen(700);
    }
    function onLeave() { scheduleClose(); }
    function onContentEnter() { clearTimeout(closeTimer); closeTimer = null; }
    function onFocus() { if (trigger.matches(":focus-visible")) doOpen(); }
    function onBlur() { scheduleClose(); }
    function onKeydown(ev) { if (ev.key === "Escape" && open) doClose(); }

    trigger.addEventListener("pointerenter", onTriggerEnter);
    trigger.addEventListener("pointerleave", onLeave);
    content.addEventListener("pointerenter", onContentEnter);
    content.addEventListener("pointerleave", onLeave);
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
        trigger.removeEventListener("pointerenter", onTriggerEnter);
        trigger.removeEventListener("pointerleave", onLeave);
        content.removeEventListener("pointerenter", onContentEnter);
        content.removeEventListener("pointerleave", onLeave);
        trigger.removeEventListener("focus", onFocus);
        trigger.removeEventListener("blur", onBlur);
        document.removeEventListener("keydown", onKeydown, true);
      }
    };
  });
})();

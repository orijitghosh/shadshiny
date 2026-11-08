/* FILE: inst/assets/components/popover/popover.js */
/* shadshiny — popover behavior (non-modal; APG disclosure-ish + dismiss).
   Focus moves into the panel on open (first tabbable / autofocus / panel),
   NOT trapped (Tab past the end leaves + closes). Esc / outside press close.
   Trigger toggles. Focus returns to trigger on close-by-keyboard. */
(function () {
  "use strict";
  shad.register("popover", function (root) {
    const trigger = root.querySelector(".shad-popover__trigger");
    const content = root.querySelector(".shad-popover__content");
    const arrow = content.querySelector(".shad-popover__arrow");
    const side = root.getAttribute("data-side") || "bottom";
    const align = root.getAttribute("data-align") || "center";

    let open = false;
    let untrack = null, restore = null, disposeDismiss = null;

    content.hidden = true;
    content.setAttribute("data-state", "closed");
    content.setAttribute("tabindex", "-1");
    content.id = content.id || shad.uid("popover");
    trigger.setAttribute("aria-haspopup", "dialog");
    trigger.setAttribute("aria-expanded", "false");
    trigger.setAttribute("aria-controls", content.id);

    function doOpen() {
      if (open) return;
      open = true;
      restore = shad.portal(content);
      shad.presence.show(content);
      untrack = shad.floating.track(trigger, content, {
        side, align, offset: 6, arrow: arrow || undefined
      });
      disposeDismiss = shad.dismiss.push({
        el: content,
        extraElements: [trigger], // clicking the trigger is handled by toggle
        onDismiss(reason) {
          doClose();
          if (reason === "escape") trigger.focus({ preventScroll: true });
        }
      });
      trigger.setAttribute("aria-expanded", "true");
      const auto = content.querySelector("[data-shad-autofocus]") ||
        shad.util.tabbables(content)[0] || content;
      requestAnimationFrame(() => auto.focus({ preventScroll: true }));
      shad.util.emit(root, "shad:open", {});
      shad.util.emit(root, "shad:change", { value: true });
    }
    function doClose() {
      if (!open) return;
      open = false;
      if (disposeDismiss) { disposeDismiss(); disposeDismiss = null; }
      if (untrack) { untrack(); untrack = null; }
      trigger.setAttribute("aria-expanded", "false");
      shad.presence.hide(content, () => {
        if (restore) { restore(); restore = null; }
      });
      shad.util.emit(root, "shad:close", {});
      shad.util.emit(root, "shad:change", { value: false });
    }

    function onTriggerClick() { open ? doClose() : doOpen(); }
    // Tab out of the panel closes it (non-modal)
    function onFocusOut(ev) {
      if (open && ev.relatedTarget &&
          !content.contains(ev.relatedTarget) && ev.relatedTarget !== trigger) {
        doClose();
      }
    }
    trigger.addEventListener("click", onTriggerClick);
    content.addEventListener("focusout", onFocusOut);

    return {
      getValue() { return open; },
      setValue(v) { v ? doOpen() : doClose(); },
      open: doOpen, close: doClose,
      get isOpen() { return open; },
      destroy() {
        doClose();
        trigger.removeEventListener("click", onTriggerClick);
        content.removeEventListener("focusout", onFocusOut);
      }
    };
  });
})();

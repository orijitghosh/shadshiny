/* FILE: inst/assets/components/sheet/sheet.js */
/* shadshiny — sheet behavior. Dialog machinery + side slide.
   Markup:
     <div data-shad="sheet" data-side="right|left|top|bottom">
       <button class="shad-sheet__trigger">…</button>
       <div class="shad-sheet__overlay shad-anim-overlay" hidden></div>
       <div class="shad-sheet__content shad-anim-sheet" hidden>
         … [data-shad-sheet-close] closes …
       </div>
     </div> */
(function () {
  "use strict";
  shad.register("sheet", function (root) {
    const trigger = root.querySelector(".shad-sheet__trigger");
    const overlay = root.querySelector(".shad-sheet__overlay");
    const content = root.querySelector(".shad-sheet__content");
    const side = root.getAttribute("data-side") || "right";

    let open = false;
    let releaseTrap = null, disposeDismiss = null;
    let restoreOverlay = null, restoreContent = null;

    overlay.hidden = true;
    content.hidden = true;
    overlay.setAttribute("data-state", "closed");
    content.setAttribute("data-state", "closed");
    content.setAttribute("data-side", side);
    content.setAttribute("role", "dialog");
    content.setAttribute("aria-modal", "true");
    const title = content.querySelector(".shad-sheet__title");
    if (title) {
      title.id = title.id || shad.uid("sheet-title");
      content.setAttribute("aria-labelledby", title.id);
    }

    function doOpen() {
      if (open) return;
      open = true;
      restoreOverlay = shad.portal(overlay);
      restoreContent = shad.portal(content);
      shad.scrollLock.lock();
      shad.presence.show(overlay);
      shad.presence.show(content);
      releaseTrap = shad.focusTrap(content);
      disposeDismiss = shad.dismiss.push({ el: content, onDismiss: doClose });
      shad.util.emit(root, "shad:open", {});
      shad.util.emit(root, "shad:change", { value: true });
    }
    function doClose() {
      if (!open) return;
      open = false;
      if (disposeDismiss) { disposeDismiss(); disposeDismiss = null; }
      if (releaseTrap) { releaseTrap(); releaseTrap = null; }
      shad.presence.hide(overlay, () => {
        if (restoreOverlay) { restoreOverlay(); restoreOverlay = null; }
      });
      shad.presence.hide(content, () => {
        shad.scrollLock.unlock();
        if (restoreContent) { restoreContent(); restoreContent = null; }
      });
      shad.util.emit(root, "shad:close", {});
      shad.util.emit(root, "shad:change", { value: false });
    }
    function onTriggerClick() { doOpen(); }
    function onContentClick(ev) {
      if (ev.target.closest("[data-shad-sheet-close]")) doClose();
    }
    if (trigger) trigger.addEventListener("click", onTriggerClick);
    content.addEventListener("click", onContentClick);

    return {
      getValue() { return open; },
      setValue(v) { v ? doOpen() : doClose(); },
      open: doOpen, close: doClose,
      get isOpen() { return open; },
      destroy() {
        doClose();
        if (trigger) trigger.removeEventListener("click", onTriggerClick);
        content.removeEventListener("click", onContentClick);
      }
    };
  });
})();

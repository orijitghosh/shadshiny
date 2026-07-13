/* FILE: inst/assets/components/dialog/dialog.js */
/* shadshiny — dialog behavior (APG modal dialog).
   Also registers "alert-dialog": identical machinery, but no outside-press
   dismiss, no Esc dismiss unless data-escape-close, no __close button req.
   Markup:
     <div data-shad="dialog" class="shad-dialog">
       <button class="shad-dialog__trigger">…</button>   (any el w/ class)
       <div class="shad-dialog__overlay shad-anim-overlay" hidden></div>
       <div class="shad-dialog__content shad-anim-dialog" hidden role="dialog">
         … [data-shad-dialog-close] on any button closes …
       </div>
     </div>
   getValue() -> isOpen (boolean); setValue(true/false) opens/closes. */
(function () {
  "use strict";

  function makeDialog(kind) {
    return function (root) {
      const trigger = root.querySelector(".shad-dialog__trigger");
      const overlay = root.querySelector(".shad-dialog__overlay");
      const content = root.querySelector(".shad-dialog__content");
      const isAlert = kind === "alert-dialog";

      let open = false;
      let releaseTrap = null, disposeDismiss = null;
      let restoreOverlay = null, restoreContent = null;

      overlay.hidden = true;
      content.hidden = true;
      overlay.setAttribute("data-state", "closed");
      content.setAttribute("data-state", "closed");
      content.setAttribute("role", isAlert ? "alertdialog" : "dialog");
      content.setAttribute("aria-modal", "true");
      const title = content.querySelector(".shad-dialog__title");
      if (title) {
        title.id = title.id || shad.uid("dlg-title");
        content.setAttribute("aria-labelledby", title.id);
      }
      const desc = content.querySelector(".shad-dialog__description");
      if (desc) {
        desc.id = desc.id || shad.uid("dlg-desc");
        content.setAttribute("aria-describedby", desc.id);
      }
      if (trigger) {
        trigger.setAttribute("aria-haspopup", "dialog");
        trigger.setAttribute("aria-expanded", "false");
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
        disposeDismiss = shad.dismiss.push({
          el: content,
          closeOnEscape: !isAlert || root.hasAttribute("data-escape-close"),
          closeOnOutside: !isAlert,
          onDismiss: doClose
        });
        if (trigger) trigger.setAttribute("aria-expanded", "true");
        shad.util.emit(root, "shad:open", {});
        shad.util.emit(root, "shad:change", { value: true });
      }
      function doClose() {
        if (!open) return;
        open = false;
        if (disposeDismiss) { disposeDismiss(); disposeDismiss = null; }
        if (releaseTrap) { releaseTrap(); releaseTrap = null; }
        if (trigger) trigger.setAttribute("aria-expanded", "false");
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
        const closer = ev.target.closest("[data-shad-dialog-close]");
        if (closer) doClose();
      }

      if (trigger) trigger.addEventListener("click", onTriggerClick);
      content.addEventListener("click", onContentClick);

      return {
        getValue() { return open; },
        setValue(v) { v ? doOpen() : doClose(); },
        open: doOpen,
        close: doClose,
        get isOpen() { return open; },
        destroy() {
          doClose();
          if (trigger) trigger.removeEventListener("click", onTriggerClick);
          content.removeEventListener("click", onContentClick);
        }
      };
    };
  }

  shad.register("dialog", makeDialog("dialog"));
  shad.register("alert-dialog", makeDialog("alert-dialog"));
  window.__shadDialogLoaded = true; // probed by alert-dialog/alert-dialog.js
})();

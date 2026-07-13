/* FILE: inst/assets/components/drawer/drawer.js */
/* shadshiny — drawer behavior (bottom sheet w/ drag-to-dismiss).
   Drag physics (DECISION): dismiss when release velocity > 0.5 px/ms downward
   OR travel > 50% of panel height; otherwise spring back (CSS transition).
   Upward drag is resisted (rubber-band /3). Overlay opacity tracks progress. */
(function () {
  "use strict";
  shad.register("drawer", function (root) {
    const trigger = root.querySelector(".shad-drawer__trigger");
    const overlay = root.querySelector(".shad-drawer__overlay");
    const content = root.querySelector(".shad-drawer__content");

    let open = false;
    let releaseTrap = null, disposeDismiss = null;
    let restoreOverlay = null, restoreContent = null;

    overlay.hidden = true;
    content.hidden = true;
    overlay.setAttribute("data-state", "closed");
    content.setAttribute("data-state", "closed");
    content.setAttribute("data-side", "bottom"); // reuse sheet slide keyframes
    content.setAttribute("role", "dialog");
    content.setAttribute("aria-modal", "true");
    const title = content.querySelector(".shad-drawer__title");
    if (title) {
      title.id = title.id || shad.uid("drawer-title");
      content.setAttribute("aria-labelledby", title.id);
    }

    function doOpen() {
      if (open) return;
      open = true;
      restoreOverlay = shad.portal(overlay);
      restoreContent = shad.portal(content);
      shad.scrollLock.lock();
      content.style.transform = "";
      overlay.style.opacity = "";
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
        overlay.style.opacity = "";
        if (restoreOverlay) { restoreOverlay(); restoreOverlay = null; }
      });
      shad.presence.hide(content, () => {
        shad.scrollLock.unlock();
        content.style.transform = "";
        if (restoreContent) { restoreContent(); restoreContent = null; }
      });
      shad.util.emit(root, "shad:close", {});
      shad.util.emit(root, "shad:change", { value: false });
    }

    /* ---- drag-to-dismiss ------------------------------------------- */
    let drag = null; // {startY, lastY, lastT, velocity, height}
    function onPointerDown(ev) {
      if (!open) return;
      // drag from handle, header, or any non-scrollable area of the panel
      const scroller = ev.target.closest(".shad-drawer__body");
      if (scroller && scroller.scrollTop > 0) return; // let inner scroll win
      drag = {
        startY: ev.clientY, lastY: ev.clientY,
        lastT: ev.timeStamp, velocity: 0,
        height: content.offsetHeight
      };
      content.setAttribute("data-dragging", "");
      content.setPointerCapture(ev.pointerId);
    }
    function onPointerMove(ev) {
      if (!drag) return;
      const dt = ev.timeStamp - drag.lastT || 1;
      drag.velocity = (ev.clientY - drag.lastY) / dt;
      drag.lastY = ev.clientY;
      drag.lastT = ev.timeStamp;
      let dy = ev.clientY - drag.startY;
      if (dy < 0) dy = dy / 3; // rubber-band above rest position
      content.style.transform = "translateY(" + Math.round(dy) + "px)";
      const progress = shad.util.clamp(dy / drag.height, 0, 1);
      overlay.style.opacity = String(1 - progress);
    }
    function onPointerUp(ev) {
      if (!drag) return;
      const dy = drag.lastY - drag.startY;
      const shouldDismiss = drag.velocity > 0.5 || dy > drag.height * 0.5;
      content.removeAttribute("data-dragging");
      try { content.releasePointerCapture(ev.pointerId); } catch (e) {}
      drag = null;
      if (shouldDismiss) {
        // let the exit animation take over from the dragged position
        doClose();
      } else {
        content.style.transform = "";  // spring back (CSS transition)
        overlay.style.opacity = "";
      }
    }

    function onTriggerClick() { doOpen(); }
    function onContentClick(ev) {
      if (ev.target.closest("[data-shad-drawer-close]")) doClose();
    }
    if (trigger) trigger.addEventListener("click", onTriggerClick);
    content.addEventListener("click", onContentClick);
    content.addEventListener("pointerdown", onPointerDown);
    content.addEventListener("pointermove", onPointerMove);
    content.addEventListener("pointerup", onPointerUp);
    content.addEventListener("pointercancel", onPointerUp);

    return {
      getValue() { return open; },
      setValue(v) { v ? doOpen() : doClose(); },
      open: doOpen, close: doClose,
      get isOpen() { return open; },
      destroy() {
        doClose();
        if (trigger) trigger.removeEventListener("click", onTriggerClick);
        content.removeEventListener("click", onContentClick);
        content.removeEventListener("pointerdown", onPointerDown);
        content.removeEventListener("pointermove", onPointerMove);
        content.removeEventListener("pointerup", onPointerUp);
        content.removeEventListener("pointercancel", onPointerUp);
      }
    };
  });
})();

/* FILE: inst/assets/components/date-picker/date-picker.js */
/* shadshiny — date-picker: composes calendar inside a floating panel.
   Markup:
     <div data-shad="date-picker" class="shad-date-picker" [data-format="..."]>
       <button class="shad-date-picker__trigger" data-placeholder>
         <svg calendar icon> <span class="shad-date-picker__value">Pick a date</span>
       </button>
       <div class="shad-date-picker__content shad-anim-pop" hidden>
         <div class="shad-calendar" data-shad="calendar" data-mode="single" …></div>
       </div>
     </div>
   Value mirrors the inner calendar. Single mode closes on pick; range mode
   closes when the range completes. A server value only updates the value: it
   never opens, closes or moves focus. */
(function () {
  "use strict";

  function fmt(isoStr) {
    if (!isoStr) return null;
    const m = /^(\d{4})-(\d{2})-(\d{2})$/.exec(isoStr);
    if (!m) return isoStr;
    const d = new Date(+m[1], +m[2] - 1, +m[3]);
    return d.toLocaleDateString(undefined, { year: "numeric", month: "long", day: "numeric" });
  }

  shad.register("date-picker", function (root) {
    const trigger = root.querySelector(".shad-date-picker__trigger");
    const valueEl = trigger.querySelector(".shad-date-picker__value");
    const content = root.querySelector(".shad-date-picker__content");
    const calEl = content.querySelector('[data-shad="calendar"]');
    const isRange = calEl.getAttribute("data-mode") === "range";
    const placeholder = valueEl.textContent;

    let open = false;
    let syncing = false; // inside setValue(): the change is the server's
    let disposeDismiss = null, disposeFloat = null, restorePortal = null;

    content.hidden = true;
    content.setAttribute("data-state", "closed");
    trigger.setAttribute("aria-haspopup", "dialog");
    trigger.setAttribute("aria-expanded", "false");

    function cal() { return shad.get(calEl); } // late-bound instance

    function renderValue() {
      const c = cal();
      const v = c ? c.getValue() : null;
      let text = null;
      if (isRange && v && v.start) {
        text = fmt(v.start) + (v.end ? " – " + fmt(v.end) : " – …");
      } else if (!isRange && v) {
        text = fmt(v);
      }
      if (text) {
        valueEl.textContent = text;
        trigger.removeAttribute("data-placeholder");
      } else {
        valueEl.textContent = placeholder;
        trigger.setAttribute("data-placeholder", "");
      }
    }

    function doOpen() {
      if (open) return;
      open = true;
      restorePortal = shad.portal(content);
      shad.presence.show(content);
      disposeFloat = shad.floating.track(trigger, content, {
        side: "bottom", align: "start", offset: 4
      });
      disposeDismiss = shad.dismiss.push({
        el: content,
        extraElements: [trigger],
        onDismiss: () => { doClose(); trigger.focus({ preventScroll: true }); }
      });
      trigger.setAttribute("aria-expanded", "true");
      const day = content.querySelector('.shad-calendar__day[tabindex="0"]');
      if (day) day.focus({ preventScroll: true });
      shad.util.emit(root, "shad:open", {});
    }
    function doClose() {
      if (!open) return;
      open = false;
      if (disposeDismiss) { disposeDismiss(); disposeDismiss = null; }
      trigger.setAttribute("aria-expanded", "false");
      shad.presence.hide(content, () => {
        if (disposeFloat) { disposeFloat(); disposeFloat = null; }
        if (restorePortal) { restorePortal(); restorePortal = null; }
      });
      shad.util.emit(root, "shad:close", {});
    }

    function onTriggerClick() { open ? doClose() : doOpen(); }
    function onCalChange(ev) {
      if (ev.target !== calEl) return;
      // re-emit from the picker root with the same value, once: while closed
      // the calendar's own event would bubble through the root as well
      ev.stopPropagation();
      renderValue();
      shad.util.emit(root, "shad:change", { value: ev.detail.value });
      const v = ev.detail.value;
      const complete = isRange ? (v && v.start && v.end) : !!v;
      if (complete && open && !syncing) { doClose(); trigger.focus({ preventScroll: true }); }
    }

    trigger.addEventListener("click", onTriggerClick);
    calEl.addEventListener("shad:change", onCalChange);
    // calendar may init after us in the same shad.init pass
    requestAnimationFrame(renderValue);

    return {
      getValue() { const c = cal(); return c ? c.getValue() : null; },
      setValue(v) {
        const c = cal();
        if (!c) return;
        syncing = true;
        try { c.setValue(v); } finally { syncing = false; }
        renderValue();
      },
      open: doOpen,
      close: doClose,
      get isOpen() { return open; },
      destroy() {
        doClose();
        trigger.removeEventListener("click", onTriggerClick);
        calEl.removeEventListener("shad:change", onCalChange);
      }
    };
  });
})();

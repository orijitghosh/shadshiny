/* FILE: inst/assets/components/select/select.js */
/* shadshiny – select behavior (APG listbox popup pattern).
   Markup:
     <div data-shad="select" class="shad-select">
       <button class="shad-select__trigger" role="combobox" [data-placeholder]>
         <span class="shad-select__value">…</span> <svg chevron>
       </button>
       <div class="shad-select__content shad-anim-pop" hidden>
         <button class="shad-select__scroll-btn" data-dir="up" hidden>…</button>
         <div class="shad-select__viewport">
           [<div class="shad-select__group" role="group">
              <div class="shad-select__group-label">…</div> …items…]
           <div class="shad-select__item" role="option" data-value="x">
             <svg class="shad-select__item-check">✓</svg> Label
           </div>
         </div>
         <button class="shad-select__scroll-btn" data-dir="down" hidden>…</button>
       </div>
     </div>
   Keyboard: closed trigger ArrowDown/Up/Enter/Space opens; open: arrows move
   highlight, typeahead, Enter/Space selects, Esc closes, Home/End. */
(function () {
  "use strict";
  shad.register("select", function (root) {
    const trigger = root.querySelector(".shad-select__trigger");
    const content = root.querySelector(".shad-select__content");
    const viewport = content.querySelector(".shad-select__viewport");
    const valueEl = trigger.querySelector(".shad-select__value");
    const scrollUp = content.querySelector('.shad-select__scroll-btn[data-dir="up"]');
    const scrollDown = content.querySelector('.shad-select__scroll-btn[data-dir="down"]');
    // The R constructor renders the selected label into the value span, so
    // the placeholder travels separately; hand-written markup may omit it.
    const placeholder = valueEl.getAttribute("data-placeholder-text") ?? valueEl.textContent;

    let value = null;
    let open = false;
    let highlighted = null;
    let disposeDismiss = null, disposeFloat = null, restorePortal = null;
    let typeBuffer = "", typeTimer = null;
    let scrollRAF = null;

    // ids + roles
    const listboxId = content.id || (content.id = shad.uid("select-list"));
    // a combobox, so aria-activedescendant is allowed on it; its text is the
    // value, so a field label (form-field.js) or the placeholder names it
    trigger.setAttribute("role", "combobox");
    if (!trigger.hasAttribute("aria-labelledby") && !trigger.hasAttribute("aria-label")) {
      trigger.setAttribute("aria-label", placeholder);
    }
    trigger.setAttribute("aria-haspopup", "listbox");
    trigger.setAttribute("aria-expanded", "false");
    trigger.setAttribute("aria-controls", listboxId);
    viewport.setAttribute("role", "listbox");
    viewport.setAttribute(
      "aria-label",
      viewport.getAttribute("aria-label") || trigger.getAttribute("aria-label") || placeholder
    );
    content.hidden = true;
    content.setAttribute("data-state", "closed");

    // seed initial value from markup
    const initial = content.querySelector('.shad-select__item[data-state="checked"]');
    if (initial) { value = initial.getAttribute("data-value"); }

    function items() {
      return Array.from(content.querySelectorAll(".shad-select__item"));
    }
    function enabledItems() {
      return items().filter((it) => !it.hasAttribute("data-disabled"));
    }
    function labelOf(item) { return (item.textContent || "").trim(); }

    function renderValue() {
      const sel = items().find((it) => it.getAttribute("data-value") === value);
      if (sel) {
        valueEl.textContent = labelOf(sel);
        trigger.removeAttribute("data-placeholder");
      } else {
        valueEl.textContent = placeholder;
        trigger.setAttribute("data-placeholder", "");
      }
      items().forEach((it) => {
        const checked = it.getAttribute("data-value") === value;
        it.setAttribute("data-state", checked ? "checked" : "unchecked");
        it.setAttribute("aria-selected", String(checked));
      });
    }
    function highlight(item, scroll) {
      items().forEach((it) => it.removeAttribute("data-highlighted"));
      highlighted = item || null;
      if (item) {
        item.setAttribute("data-highlighted", "");
        trigger.setAttribute("aria-activedescendant",
          item.id || (item.id = shad.uid("opt")));
        // scrolls the listbox viewport only; scrollIntoView() would also walk
        // out to the document and move the page behind the open panel
        if (scroll !== false) shad.util.keepInView(viewport, item);
      } else {
        trigger.removeAttribute("aria-activedescendant");
      }
      updateScrollButtons();
    }
    function moveHighlight(delta) {
      const list = enabledItems();
      if (!list.length) return;
      let i = list.indexOf(highlighted);
      i = i === -1 ? (delta > 0 ? 0 : list.length - 1)
        : shad.util.clamp(i + delta, 0, list.length - 1);
      highlight(list[i]);
    }
    function select(item) {
      const v = item.getAttribute("data-value");
      const changed = v !== value;
      value = v;
      renderValue();
      doClose();
      if (changed) shad.util.emit(root, "shad:change", { value });
    }

    /* scroll buttons: shown when viewport can scroll that direction */
    function updateScrollButtons() {
      if (!scrollUp && !scrollDown) return;
      const canUp = viewport.scrollTop > 0;
      const canDown = viewport.scrollTop + viewport.clientHeight < viewport.scrollHeight - 1;
      if (scrollUp) scrollUp.hidden = !canUp;
      if (scrollDown) scrollDown.hidden = !canDown;
    }
    function startAutoScroll(dir) {
      stopAutoScroll();
      const step = () => {
        viewport.scrollTop += dir * 4;
        updateScrollButtons();
        scrollRAF = requestAnimationFrame(step);
      };
      scrollRAF = requestAnimationFrame(step);
    }
    function stopAutoScroll() {
      if (scrollRAF) { cancelAnimationFrame(scrollRAF); scrollRAF = null; }
    }

    function doOpen() {
      if (open) return;
      open = true;
      restorePortal = shad.portal(content);
      shad.presence.show(content);
      // panel min-width matches trigger
      content.style.minWidth = trigger.offsetWidth + "px";
      disposeFloat = shad.floating.track(trigger, content, {
        side: "bottom", align: "start", offset: 4
      });
      disposeDismiss = shad.dismiss.push({
        el: content,
        extraElements: [trigger],
        onDismiss: () => { doClose(); trigger.focus({ preventScroll: true }); }
      });
      trigger.setAttribute("aria-expanded", "true");
      const target = items().find((it) => it.getAttribute("data-value") === value)
        || enabledItems()[0];
      highlight(target || null);
      updateScrollButtons();
      shad.util.emit(root, "shad:open", {});
    }
    function doClose() {
      if (!open) return;
      open = false;
      stopAutoScroll();
      if (disposeDismiss) { disposeDismiss(); disposeDismiss = null; }
      trigger.setAttribute("aria-expanded", "false");
      trigger.removeAttribute("aria-activedescendant");
      shad.presence.hide(content, () => {
        if (disposeFloat) { disposeFloat(); disposeFloat = null; }
        if (restorePortal) { restorePortal(); restorePortal = null; }
      });
      shad.util.emit(root, "shad:close", {});
    }

    /* typeahead within open list */
    function typeahead(ch) {
      typeBuffer += ch.toLowerCase();
      clearTimeout(typeTimer);
      typeTimer = setTimeout(() => { typeBuffer = ""; }, 1000);
      const list = enabledItems();
      const start = (list.indexOf(highlighted) + 1) % (list.length || 1);
      const rotated = list.slice(start).concat(list.slice(0, start));
      const hit = rotated.find((it) => labelOf(it).toLowerCase().startsWith(typeBuffer));
      if (hit) highlight(hit);
    }

    function onTriggerClick() {
      if (trigger.disabled || trigger.hasAttribute("data-disabled")) return;
      open ? doClose() : doOpen();
    }
    function onTriggerKeydown(ev) {
      if (trigger.disabled) return;
      if (!open) {
        if (["ArrowDown", "ArrowUp", "Enter", " "].includes(ev.key)) {
          ev.preventDefault(); doOpen();
        } else if (ev.key.length === 1 && !ev.ctrlKey && !ev.metaKey) {
          doOpen(); typeahead(ev.key);
        }
        return;
      }
      switch (ev.key) {
        case "ArrowDown": ev.preventDefault(); moveHighlight(1); break;
        case "ArrowUp": ev.preventDefault(); moveHighlight(-1); break;
        case "Home": ev.preventDefault(); highlight(enabledItems()[0]); break;
        case "End": { ev.preventDefault(); const l = enabledItems(); highlight(l[l.length - 1]); break; }
        case "Enter": case " ":
          ev.preventDefault();
          if (highlighted) select(highlighted);
          break;
        case "Tab": doClose(); break;
        default:
          if (ev.key.length === 1 && !ev.ctrlKey && !ev.metaKey) typeahead(ev.key);
      }
    }
    /* pointermove highlights (shadcn detail: not :hover) */
    function onPointerMove(ev) {
      const item = ev.target.closest(".shad-select__item");
      if (item && !item.hasAttribute("data-disabled") && item !== highlighted) {
        highlight(item, false);
      }
    }
    function onContentClick(ev) {
      const item = ev.target.closest(".shad-select__item");
      if (item && !item.hasAttribute("data-disabled")) {
        select(item); trigger.focus({ preventScroll: true });
      }
    }

    trigger.addEventListener("click", onTriggerClick);
    trigger.addEventListener("keydown", onTriggerKeydown);
    content.addEventListener("pointermove", onPointerMove);
    content.addEventListener("click", onContentClick);
    viewport.addEventListener("scroll", updateScrollButtons, { passive: true });
    if (scrollUp) {
      scrollUp.addEventListener("pointerenter", () => startAutoScroll(-1));
      scrollUp.addEventListener("pointerleave", stopAutoScroll);
    }
    if (scrollDown) {
      scrollDown.addEventListener("pointerenter", () => startAutoScroll(1));
      scrollDown.addEventListener("pointerleave", stopAutoScroll);
    }

    renderValue();

    return {
      getValue() { return value; },
      setValue(v) {
        const next = shad.util.choiceValue(
          v, items().map((it) => it.getAttribute("data-value")), false,
          "select " + root.id);
        if (next === undefined || next === value) return;
        value = next;
        renderValue();
        shad.util.emit(root, "shad:change", { value });
      },
      open: doOpen,
      close: doClose,
      get isOpen() { return open; },
      destroy() {
        doClose();
        trigger.removeEventListener("click", onTriggerClick);
        trigger.removeEventListener("keydown", onTriggerKeydown);
        content.removeEventListener("pointermove", onPointerMove);
        content.removeEventListener("click", onContentClick);
        viewport.removeEventListener("scroll", updateScrollButtons);
        clearTimeout(typeTimer);
        stopAutoScroll();
      }
    };
  });
})();

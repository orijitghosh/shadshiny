/* FILE: inst/assets/components/combobox/combobox.js */
/* shadshiny — combobox behavior (APG combobox w/ listbox popup).
   Modes: data-multiple absent -> single (string|null); present -> string[].
   Filtering: case-insensitive substring on item text.
   Markup: see combobox.html. Value chips (multi) rendered by JS into the
   trigger before the chevrons. */
(function () {
  "use strict";

  const X_ICON = '<svg class="shad-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M18 6 6 18"/><path d="m6 6 12 12"/></svg>';

  shad.register("combobox", function (root) {
    const trigger = root.querySelector(".shad-combobox__trigger");
    const valueEl = trigger.querySelector(".shad-combobox__value");
    const content = root.querySelector(".shad-combobox__content");
    const input = content.querySelector(".shad-combobox__input");
    const list = content.querySelector(".shad-combobox__list");
    const empty = content.querySelector(".shad-combobox__empty");
    const multiple = root.hasAttribute("data-multiple");
    const placeholder = valueEl ? valueEl.textContent : "";

    let value = multiple ? [] : null;
    let open = false;
    let highlighted = null;
    let disposeDismiss = null, disposeFloat = null, restorePortal = null;

    const listId = list.id || (list.id = shad.uid("cbx-list"));
    trigger.setAttribute("aria-haspopup", "listbox");
    trigger.setAttribute("aria-expanded", "false");
    list.setAttribute("role", "listbox");
    if (multiple) list.setAttribute("aria-multiselectable", "true");
    input.setAttribute("role", "combobox");
    input.setAttribute("aria-controls", listId);
    input.setAttribute("aria-expanded", "true");
    input.setAttribute("aria-autocomplete", "list");
    content.hidden = true;
    content.setAttribute("data-state", "closed");

    items().forEach((it) => it.setAttribute("role", "option"));

    // seed from markup
    items().forEach((it) => {
      if (it.getAttribute("data-state") === "checked") {
        const v = it.getAttribute("data-value");
        if (multiple) value.push(v); else if (value == null) value = v;
      }
    });

    function items() {
      return Array.from(list.querySelectorAll(".shad-combobox__item"));
    }
    function visibleItems() {
      return items().filter((it) => !it.hidden && !it.hasAttribute("data-disabled"));
    }
    function labelOf(it) { return (it.textContent || "").trim(); }
    function isSel(v) { return multiple ? value.includes(v) : value === v; }

    function renderItems() {
      items().forEach((it) => {
        const checked = isSel(it.getAttribute("data-value"));
        it.setAttribute("data-state", checked ? "checked" : "unchecked");
        it.setAttribute("aria-selected", String(checked));
      });
    }
    function renderTrigger() {
      // remove existing chips
      trigger.querySelectorAll(".shad-combobox__badge").forEach((b) => b.remove());
      if (multiple) {
        if (value.length === 0) {
          valueEl.hidden = false;
          valueEl.textContent = placeholder;
          trigger.setAttribute("data-placeholder", "");
        } else {
          valueEl.hidden = true;
          trigger.removeAttribute("data-placeholder");
          value.forEach((v) => {
            const it = items().find((x) => x.getAttribute("data-value") === v);
            const chip = document.createElement("span");
            chip.className = "shad-combobox__badge";
            chip.appendChild(document.createTextNode(it ? labelOf(it) : v));
            const x = document.createElement("span");
            x.className = "shad-combobox__badge-x";
            x.setAttribute("role", "button");
            x.setAttribute("aria-label", "Remove " + (it ? labelOf(it) : v));
            x.setAttribute("data-remove", v);
            x.innerHTML = X_ICON;
            chip.appendChild(x);
            trigger.insertBefore(chip, valueEl);
          });
        }
      } else {
        const it = items().find((x) => x.getAttribute("data-value") === value);
        if (it) {
          valueEl.textContent = labelOf(it);
          trigger.removeAttribute("data-placeholder");
        } else {
          valueEl.textContent = placeholder;
          trigger.setAttribute("data-placeholder", "");
        }
      }
    }
    function emit() {
      shad.util.emit(root, "shad:change", { value: multiple ? value.slice() : value });
    }
    function highlight(item, scroll) {
      items().forEach((it) => it.removeAttribute("data-highlighted"));
      highlighted = item || null;
      if (item) {
        item.setAttribute("data-highlighted", "");
        input.setAttribute("aria-activedescendant", item.id || (item.id = shad.uid("opt")));
        // list only -- see shad.util.keepInView; scrollIntoView() would also
        // scroll the page behind the open panel
        if (scroll !== false) shad.util.keepInView(list, item);
      } else {
        input.removeAttribute("aria-activedescendant");
      }
    }
    function filter() {
      const q = input.value.trim().toLowerCase();
      let any = false;
      items().forEach((it) => {
        const hit = !q || labelOf(it).toLowerCase().includes(q);
        it.hidden = !hit;
        if (hit) any = true;
      });
      // hide group labels with no visible items
      list.querySelectorAll("[role='group']").forEach((g) => {
        g.hidden = !g.querySelector(".shad-combobox__item:not([hidden])");
      });
      if (empty) empty.hidden = any;
      highlight(visibleItems()[0] || null);
    }
    function toggleItem(it) {
      const v = it.getAttribute("data-value");
      if (multiple) {
        value = value.includes(v) ? value.filter((x) => x !== v) : value.concat(v);
        renderItems(); renderTrigger(); emit();
        // stay open in multi mode (shadcn multi-combobox behavior)
      } else {
        const changed = v !== value;
        value = v;
        renderItems(); renderTrigger();
        doClose(); trigger.focus({ preventScroll: true });
        if (changed) emit();
      }
    }

    function doOpen() {
      if (open) return;
      open = true;
      root.setAttribute("data-state", "open");
      restorePortal = shad.portal(content);
      shad.presence.show(content);
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
      input.value = "";
      filter();
      input.focus({ preventScroll: true });
      shad.util.emit(root, "shad:open", {});
    }
    function doClose() {
      if (!open) return;
      open = false;
      root.setAttribute("data-state", "closed");
      if (disposeDismiss) { disposeDismiss(); disposeDismiss = null; }
      trigger.setAttribute("aria-expanded", "false");
      shad.presence.hide(content, () => {
        if (disposeFloat) { disposeFloat(); disposeFloat = null; }
        if (restorePortal) { restorePortal(); restorePortal = null; }
      });
      shad.util.emit(root, "shad:close", {});
    }

    function onTriggerClick(ev) {
      const removeChip = ev.target.closest("[data-remove]");
      if (removeChip) {
        ev.stopPropagation();
        const v = removeChip.getAttribute("data-remove");
        value = value.filter((x) => x !== v);
        renderItems(); renderTrigger(); emit();
        return;
      }
      open ? doClose() : doOpen();
    }
    function onTriggerKeydown(ev) {
      if (["ArrowDown", "ArrowUp", "Enter", " "].includes(ev.key) && !open) {
        ev.preventDefault(); doOpen();
      }
    }
    function onInputKeydown(ev) {
      switch (ev.key) {
        case "ArrowDown": case "ArrowUp": {
          ev.preventDefault();
          const vis = visibleItems();
          if (!vis.length) return;
          let i = vis.indexOf(highlighted);
          i = ev.key === "ArrowDown"
            ? (i + 1) % vis.length
            : (i - 1 + vis.length) % vis.length;
          highlight(vis[i]);
          break;
        }
        case "Home": ev.preventDefault(); highlight(visibleItems()[0]); break;
        case "End": { ev.preventDefault(); const v = visibleItems(); highlight(v[v.length - 1]); break; }
        case "Enter":
          ev.preventDefault();
          if (highlighted) toggleItem(highlighted);
          break;
        case "Escape": break; // DismissLayer handles
        case "Tab": doClose(); break;
        case "Backspace":
          if (multiple && input.value === "" && value.length) {
            value = value.slice(0, -1);
            renderItems(); renderTrigger(); emit();
          }
          break;
      }
    }
    function onPointerMove(ev) {
      const it = ev.target.closest(".shad-combobox__item");
      if (it && !it.hasAttribute("data-disabled") && it !== highlighted) highlight(it, false);
    }
    function onListClick(ev) {
      const it = ev.target.closest(".shad-combobox__item");
      if (it && !it.hasAttribute("data-disabled")) toggleItem(it);
    }

    trigger.addEventListener("click", onTriggerClick);
    trigger.addEventListener("keydown", onTriggerKeydown);
    input.addEventListener("input", filter);
    input.addEventListener("keydown", onInputKeydown);
    list.addEventListener("pointermove", onPointerMove);
    list.addEventListener("click", onListClick);

    renderItems();
    renderTrigger();

    return {
      getValue() { return multiple ? value.slice() : value; },
      setValue(v) {
        const next = multiple ? (Array.isArray(v) ? v.slice() : [v].filter(Boolean)) : v;
        const same = multiple
          ? next.length === value.length && next.every((x) => value.includes(x))
          : next === value;
        if (same) return;
        value = next;
        renderItems(); renderTrigger(); emit();
      },
      open: doOpen,
      close: doClose,
      get isOpen() { return open; },
      destroy() {
        doClose();
        trigger.removeEventListener("click", onTriggerClick);
        trigger.removeEventListener("keydown", onTriggerKeydown);
        input.removeEventListener("input", filter);
        input.removeEventListener("keydown", onInputKeydown);
        list.removeEventListener("pointermove", onPointerMove);
        list.removeEventListener("click", onListClick);
      }
    };
  });
})();

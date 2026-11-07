/* FILE: inst/assets/components/dropdown-menu/dropdown-menu.js */
/* shadshiny — dropdown-menu (APG menu-button). Registers a shared menu core
   on shad.__menuCore reused by context-menu and menubar.
   Markup:
     <div data-shad="dropdown-menu">
       <button class="shad-menu__trigger">…</button>
       <div class="shad-menu__content shad-anim-pop" hidden>
         <div class="shad-menu__label">…</div>
         <button class="shad-menu__item" data-value="v">…
           <span class="shad-menu__shortcut">⌘S</span></button>
         <button class="shad-menu__item" data-type="checkbox" data-state="checked" data-value="v">
           <span class="shad-menu__indicator">✓svg</span>Label</button>
         <button class="shad-menu__item" data-type="radio" data-group="g" data-state="unchecked" …>
         <div class="shad-menu__separator"></div>
         <div data-shad-submenu>
           <button class="shad-menu__item" data-shad-submenu-trigger>More…<svg chevron></button>
           <div class="shad-menu__content shad-anim-pop" hidden> …items… </div>
         </div>
       </div>
     </div>
   Value semantics: getValue() -> last activated item's data-value; checkbox
   items toggle data-state; radio items check within data-group.
   shad:change detail: {value, type:"item"|"checkbox"|"radio", checked?}. */
(function () {
  "use strict";
  const ITEM_SEL = ".shad-menu__item:not([data-shad-submenu-trigger])," +
                   ".shad-menu__item[data-shad-submenu-trigger]";

  /* ---- shared menu-panel core (open/close/keyboard/submenus) ---- */
  function menuPanel(panel, opts) {
    // opts: {anchor(), side, align, onActivate(item), onRequestClose(reason)}
    let open = false, untrack = null, restore = null, disposeDismiss = null;
    let subPanels = []; // open submenu closers
    panel.hidden = true;
    panel.setAttribute("data-state", "closed");
    panel.setAttribute("role", "menu");
    panel.setAttribute("tabindex", "-1");
    panel.querySelectorAll(".shad-menu__item").forEach((it) => {
      it.setAttribute("role",
        it.dataset.type === "checkbox" ? "menuitemcheckbox" :
        it.dataset.type === "radio" ? "menuitemradio" : "menuitem");
      it.setAttribute("tabindex", "-1");
      if (it.dataset.type) {
        it.setAttribute("aria-checked", it.dataset.state === "checked" ? "true" : "false");
      }
    });

    function items() {
      // only DIRECT items of this panel (not submenu panels' items)
      return Array.from(panel.querySelectorAll(".shad-menu__item")).filter((it) =>
        it.closest(".shad-menu__content") === panel &&
        !it.hasAttribute("data-disabled") && it.getAttribute("aria-disabled") !== "true");
    }
    function highlight(item) {
      items().forEach((it) => {
        if (it === item) { it.setAttribute("data-highlighted", ""); it.focus({ preventScroll: true }); }
        else it.removeAttribute("data-highlighted");
      });
    }
    function highlighted() { return panel.querySelector(":scope > .shad-menu__item[data-highlighted], .shad-menu__item[data-highlighted]"); }
    function move(delta) {
      const all = items();
      if (!all.length) return;
      let i = all.findIndex((it) => it.hasAttribute("data-highlighted"));
      i = i === -1 ? (delta > 0 ? 0 : all.length - 1) : (i + delta + all.length) % all.length;
      highlight(all[i]);
    }
    let typeBuf = "", typeTimer = null;

    function closeSubmenus() {
      subPanels.forEach((c) => c());
      subPanels = [];
    }
    function openSubmenu(triggerItem) {
      const wrap = triggerItem.closest("[data-shad-submenu]");
      const sub = wrap && wrap.querySelector(":scope > .shad-menu__content");
      if (!sub || !sub.hidden) return null;
      const subCtl = menuPanel(sub, {
        anchor: () => triggerItem,
        side: "right", align: "start",
        onActivate: opts.onActivate,
        onRequestClose: (reason) => {
          subCtl.close();
          if (reason === "left-arrow" || reason === "escape") {
            triggerItem.focus({ preventScroll: true });
          } else if (reason !== "internal") {
            opts.onRequestClose(reason); // activation bubbles: close whole tree
          }
        }
      });
      subCtl.show();
      triggerItem.setAttribute("data-state", "open");
      triggerItem.setAttribute("aria-expanded", "true");
      const closer = () => {
        subCtl.close();
        triggerItem.setAttribute("data-state", "closed");
        triggerItem.setAttribute("aria-expanded", "false");
      };
      subPanels.push(closer);
      return subCtl;
    }

    function onKeydown(ev) {
      let handled = true;
      const rtl = shad.util.direction(panel) === "rtl";
      switch (ev.key) {
        case "ArrowDown": move(1); break;
        case "ArrowUp": move(-1); break;
        case "Home": highlight(items()[0]); break;
        case "End": highlight(items()[items().length - 1]); break;
        case "ArrowRight": case "ArrowLeft": {
          const opensSubmenu = rtl ? ev.key === "ArrowLeft" : ev.key === "ArrowRight";
          const h = highlighted();
          if (opensSubmenu && h && h.hasAttribute("data-shad-submenu-trigger")) {
            const sub = openSubmenu(h);
            if (sub) sub.highlightFirst();
          } else if (opensSubmenu) handled = false;
          else opts.onRequestClose("left-arrow");
          break;
        }
        case "Enter": case " ": {
          const h = highlighted();
          if (h) activate(h);
          break;
        }
        case "Tab":
          opts.onRequestClose("tab");
          handled = false; // let focus move naturally
          break;
        default:
          handled = false;
          if (ev.key.length === 1 && !ev.ctrlKey && !ev.metaKey && !ev.altKey) {
            typeBuf += ev.key.toLowerCase();
            clearTimeout(typeTimer);
            typeTimer = setTimeout(() => { typeBuf = ""; }, 1000);
            const hit = items().find((it) =>
              (it.textContent || "").trim().toLowerCase().startsWith(typeBuf));
            if (hit) { highlight(hit); handled = true; }
          }
      }
      if (handled) { ev.preventDefault(); ev.stopPropagation(); }
    }
    function activate(item) {
      if (item.hasAttribute("data-shad-submenu-trigger")) {
        const sub = openSubmenu(item);
        if (sub) sub.highlightFirst();
        return;
      }
      opts.onActivate(item);
      opts.onRequestClose("activate");
    }
    /* pointermove (not hover) drives highlight — shadcn detail */
    function onPointerMove(ev) {
      const item = ev.target.closest(".shad-menu__item");
      if (!item || item.closest(".shad-menu__content") !== panel) return;
      if (item.hasAttribute("data-disabled")) return;
      if (!item.hasAttribute("data-highlighted")) {
        highlight(item);
        // hovering a submenu trigger opens it after 100ms; hovering a
        // plain item closes any open sibling submenu
        clearTimeout(panel.__shadSubTimer);
        panel.__shadSubTimer = setTimeout(() => {
          if (item.hasAttribute("data-shad-submenu-trigger")) openSubmenu(item);
          else closeSubmenus();
        }, 100);
      }
    }
    function onClick(ev) {
      const item = ev.target.closest(".shad-menu__item");
      if (!item || item.closest(".shad-menu__content") !== panel) return;
      if (item.hasAttribute("data-disabled")) return;
      ev.preventDefault();
      activate(item);
    }

    return {
      show() {
        if (open) return;
        open = true;
        restore = shad.portal(panel);
        shad.presence.show(panel);
        untrack = shad.floating.track(opts.anchor(), panel, {
          side: opts.side, align: opts.align, offset: opts.offset != null ? opts.offset : 4
        });
        disposeDismiss = shad.dismiss.push({
          el: panel,
          extraElements: opts.extraElements || [],
          onDismiss: (reason) => opts.onRequestClose(reason)
        });
        panel.addEventListener("keydown", onKeydown);
        panel.addEventListener("pointermove", onPointerMove);
        panel.addEventListener("click", onClick);
        panel.focus({ preventScroll: true });
      },
      close() {
        if (!open) return;
        open = false;
        closeSubmenus();
        if (disposeDismiss) { disposeDismiss(); disposeDismiss = null; }
        if (untrack) { untrack(); untrack = null; }
        panel.removeEventListener("keydown", onKeydown);
        panel.removeEventListener("pointermove", onPointerMove);
        panel.removeEventListener("click", onClick);
        items().forEach((it) => it.removeAttribute("data-highlighted"));
        shad.presence.hide(panel, () => {
          if (restore) { restore(); restore = null; }
        });
      },
      // One frame late, so the panel is placed first. A panel closed in
      // between is still on screen for its exit animation: leave focus be.
      highlightFirst() { requestAnimationFrame(() => { if (open) highlight(items()[0]); }); },
      highlightLast() {
        requestAnimationFrame(() => {
          if (!open) return;
          const all = items();
          highlight(all[all.length - 1]);
        });
      },
      get isOpen() { return open; }
    };
  }

  /* expose core for context-menu / menubar */
  shad.__menuCore = { menuPanel: menuPanel };

  /* value handling shared by dropdown/context/menubar */
  function handleActivate(root, item, state) {
    const type = item.dataset.type || "item";
    const value = item.dataset.value != null ? item.dataset.value :
      (item.textContent || "").trim();
    if (type === "checkbox") {
      const next = item.dataset.state === "checked" ? "unchecked" : "checked";
      item.dataset.state = next;
      item.setAttribute("aria-checked", next === "checked" ? "true" : "false");
      state.value = value;
      shad.util.emit(root, "shad:change", { value, type, checked: next === "checked" });
    } else if (type === "radio") {
      const grp = item.dataset.group;
      root.querySelectorAll('.shad-menu__item[data-type="radio"][data-group="' + grp + '"]')
        .forEach((r) => {
          const on = r === item;
          r.dataset.state = on ? "checked" : "unchecked";
          r.setAttribute("aria-checked", on ? "true" : "false");
        });
      state.value = value;
      shad.util.emit(root, "shad:change", { value, type });
    } else {
      state.value = value;
      shad.util.emit(root, "shad:change", { value, type });
    }
  }
  shad.__menuCore.handleActivate = handleActivate;

  shad.register("dropdown-menu", function (root) {
    const trigger = root.querySelector(".shad-menu__trigger");
    const panel = root.querySelector(":scope > .shad-menu__content, .shad-menu__content");
    const side = root.getAttribute("data-side") || "bottom";
    const align = root.getAttribute("data-align") || "start";
    const state = { value: null };

    trigger.setAttribute("aria-haspopup", "menu");
    trigger.setAttribute("aria-expanded", "false");

    const ctl = menuPanel(panel, {
      anchor: () => trigger,
      side, align,
      extraElements: [trigger],
      onActivate: (item) => handleActivate(root, item, state),
      onRequestClose(reason) {
        close_();
        if (reason === "escape" || reason === "left-arrow" || reason === "activate") {
          trigger.focus({ preventScroll: true });
        }
      }
    });

    function open_(focusLast) {
      if (ctl.isOpen) return;
      ctl.show();
      trigger.setAttribute("aria-expanded", "true");
      if (focusLast) ctl.highlightLast(); else ctl.highlightFirst();
      shad.util.emit(root, "shad:open", {});
    }
    function close_() {
      if (!ctl.isOpen) return;
      ctl.close();
      trigger.setAttribute("aria-expanded", "false");
      shad.util.emit(root, "shad:close", {});
    }
    function onTriggerClick() { ctl.isOpen ? close_() : open_(); }
    function onTriggerKeydown(ev) {
      if (ev.key === "ArrowDown" || ev.key === "ArrowUp") {
        ev.preventDefault();
        open_(ev.key === "ArrowUp");
      }
    }
    trigger.addEventListener("click", onTriggerClick);
    trigger.addEventListener("keydown", onTriggerKeydown);

    return {
      getValue() { return state.value; },
      setValue(v) { state.value = v; },
      open: open_, close: close_,
      get isOpen() { return ctl.isOpen; },
      destroy() {
        close_();
        trigger.removeEventListener("click", onTriggerClick);
        trigger.removeEventListener("keydown", onTriggerKeydown);
      }
    };
  });
})();

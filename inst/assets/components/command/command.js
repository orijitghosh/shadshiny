/* FILE: inst/assets/components/command/command.js */
/* shadshiny — command palette behavior (cmdk-style).
   Two modes:
     inline:  <div data-shad="command"> (always visible, filters as you type)
     dialog:  root also has data-hotkey="mod+k" → hidden until hotkey/open();
              root gets .shad-command--dialog + sibling overlay created by JS.
   Filtering (DECISION): case-insensitive substring on item text +
   data-keywords; groups hide when all their items hide; __empty shows when
   nothing matches. No fuzzy scoring — predictable and fast.
   getValue() -> data-value of last activated item. */
(function () {
  "use strict";
  shad.register("command", function (root) {
    const input = root.querySelector(".shad-command__input");
    const list = root.querySelector(".shad-command__list");
    const empty = root.querySelector(".shad-command__empty");
    const hotkey = root.getAttribute("data-hotkey"); // e.g. "mod+k"
    const isDialog = !!hotkey || root.hasAttribute("data-dialog");
    const state = { value: null };

    let open = !isDialog;
    let overlay = null, disposeDismiss = null, releaseTrap = null, restore = null;

    list.id = list.id || shad.uid("cmd-list");
    input.setAttribute("role", "combobox");
    input.setAttribute("aria-expanded", "true");
    input.setAttribute("aria-controls", list.id);
    input.setAttribute("aria-autocomplete", "list");
    input.setAttribute("autocomplete", "off");
    input.setAttribute("spellcheck", "false");
    list.setAttribute("role", "listbox");
    if (empty) empty.hidden = true;

    function items() {
      return Array.from(list.querySelectorAll(".shad-command__item"))
        .filter((it) => !it.hidden && !it.hasAttribute("data-disabled"));
    }
    function allItems() {
      return Array.from(list.querySelectorAll(".shad-command__item"));
    }
    allItems().forEach((it) => {
      it.setAttribute("role", "option");
      it.id = it.id || shad.uid("cmd-item");
    });

    function highlight(item) {
      allItems().forEach((it) => {
        if (it === item) {
          it.setAttribute("data-highlighted", "");
          it.setAttribute("aria-selected", "true");
          input.setAttribute("aria-activedescendant", it.id);
          // scrolls the list only — never the page (see shad.util.keepInView)
          shad.util.keepInView(list, it);
        } else {
          it.removeAttribute("data-highlighted");
          it.removeAttribute("aria-selected");
        }
      });
    }
    function highlighted() { return list.querySelector(".shad-command__item[data-highlighted]"); }
    function move(delta) {
      const all = items();
      if (!all.length) return;
      let i = all.indexOf(highlighted());
      i = i === -1 ? (delta > 0 ? 0 : all.length - 1) : shad.util.clamp(i + delta, 0, all.length - 1);
      highlight(all[i]);
    }

    function filter() {
      const q = input.value.trim().toLowerCase();
      let any = false;
      allItems().forEach((it) => {
        const text = ((it.textContent || "") + " " + (it.dataset.keywords || "")).toLowerCase();
        const match = q === "" || text.includes(q);
        it.hidden = !match;
        if (match) any = true;
      });
      root.querySelectorAll(".shad-command__group").forEach((g) => {
        g.hidden = !g.querySelector(".shad-command__item:not([hidden])");
      });
      root.querySelectorAll(".shad-command__separator").forEach((s) => { s.hidden = !any; });
      if (empty) empty.hidden = any;
      highlight(items()[0] || null);
    }

    function activate(item) {
      if (!item) return;
      state.value = item.dataset.value != null ? item.dataset.value :
        (item.textContent || "").trim();
      shad.util.emit(root, "shad:change", { value: state.value });
      if (isDialog) doClose();
    }

    /* ---- dialog mode plumbing ---- */
    function ensureOverlay() {
      if (overlay) return;
      overlay = document.createElement("div");
      overlay.className = "shad-command__overlay shad-anim-overlay";
      overlay.hidden = true;
      overlay.setAttribute("data-state", "closed");
    }
    function doOpen() {
      if (open) return;
      open = true;
      ensureOverlay();
      document.body.appendChild(overlay);
      restore = shad.portal(root);
      shad.scrollLock.lock();
      shad.presence.show(overlay);
      shad.presence.show(root);
      releaseTrap = shad.focusTrap(root);
      disposeDismiss = shad.dismiss.push({ el: root, onDismiss: doClose });
      input.value = "";
      filter();
      requestAnimationFrame(() => input.focus({ preventScroll: true }));
      shad.util.emit(root, "shad:open", {});
    }
    function doClose() {
      if (!open || !isDialog) return;
      open = false;
      if (disposeDismiss) { disposeDismiss(); disposeDismiss = null; }
      if (releaseTrap) { releaseTrap(); releaseTrap = null; }
      shad.presence.hide(overlay, () => { if (overlay.parentNode) overlay.remove(); });
      shad.presence.hide(root, () => {
        shad.scrollLock.unlock();
        if (restore) { restore(); restore = null; }
      });
      shad.util.emit(root, "shad:close", {});
    }
    if (isDialog) {
      root.classList.add("shad-command--dialog");
      root.hidden = true;
      root.setAttribute("data-state", "closed");
      root.setAttribute("role", "dialog");
      root.setAttribute("aria-modal", "true");
      root.setAttribute("aria-label", root.getAttribute("aria-label") || "Command palette");
    }

    /* hotkey: "mod+k" → ⌘K on mac, Ctrl+K elsewhere */
    function onHotkey(ev) {
      if (!hotkey) return;
      const parts = hotkey.toLowerCase().split("+");
      const key = parts[parts.length - 1];
      const needMod = parts.includes("mod");
      const mod = ev.metaKey || ev.ctrlKey;
      if (ev.key.toLowerCase() === key && (!needMod || mod)) {
        ev.preventDefault();
        open ? doClose() : doOpen();
      }
    }
    if (hotkey) document.addEventListener("keydown", onHotkey);

    function onInput() { filter(); }
    function onKeydown(ev) {
      switch (ev.key) {
        case "ArrowDown": ev.preventDefault(); move(1); break;
        case "ArrowUp": ev.preventDefault(); move(-1); break;
        case "Home": ev.preventDefault(); highlight(items()[0]); break;
        case "End": ev.preventDefault(); highlight(items()[items().length - 1]); break;
        case "Enter": ev.preventDefault(); activate(highlighted()); break;
      }
    }
    function onPointerMove(ev) {
      const item = ev.target.closest(".shad-command__item");
      if (item && !item.hasAttribute("data-highlighted") && !item.hasAttribute("data-disabled")) {
        highlight(item);
      }
    }
    function onClick(ev) {
      const item = ev.target.closest(".shad-command__item");
      if (item && !item.hasAttribute("data-disabled")) { ev.preventDefault(); activate(item); }
    }
    input.addEventListener("input", onInput);
    input.addEventListener("keydown", onKeydown);
    list.addEventListener("pointermove", onPointerMove);
    list.addEventListener("click", onClick);

    filter(); // initial highlight

    return {
      getValue() { return state.value; },
      setValue(v) { state.value = v; },
      open: isDialog ? doOpen : function () {},
      close: isDialog ? doClose : function () {},
      get isOpen() { return open; },
      /** re-run the filter after Shiny swaps items */
      refresh: filter,
      destroy() {
        doClose();
        if (hotkey) document.removeEventListener("keydown", onHotkey);
        input.removeEventListener("input", onInput);
        input.removeEventListener("keydown", onKeydown);
        list.removeEventListener("pointermove", onPointerMove);
        list.removeEventListener("click", onClick);
      }
    };
  });

  /* Any element with data-shad-command-open="<id>" opens that palette.
     Delegated from the document so a trigger rendered later (a navbar button,
     a Shiny-inserted fragment) works without re-wiring. */
  document.addEventListener("click", function (ev) {
    const trigger = ev.target.closest && ev.target.closest("[data-shad-command-open]");
    if (!trigger) return;
    const root = document.getElementById(trigger.getAttribute("data-shad-command-open"));
    const inst = root && shad.get(root);
    if (!inst || typeof inst.open !== "function") return;
    ev.preventDefault();
    inst.open();
  });
})();

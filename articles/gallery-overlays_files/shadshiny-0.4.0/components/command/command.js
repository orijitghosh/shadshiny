/* FILE: inst/assets/components/command/command.js */
/* shadshiny — command palette behavior (cmdk-style).
   Two modes:
     inline:  <div data-shad="command"> (always visible, filters as you type)
     dialog:  root also has data-hotkey="mod+k" → hidden until hotkey/open();
              root gets .shad-command--dialog + sibling overlay created by JS.
   Filtering (DECISION): case-insensitive substring on item text +
   data-keywords; groups hide when all their items hide; __empty shows when
   nothing matches. No fuzzy scoring — predictable and fast.
   getValue() -> data-value of last activated item.
   Hotkey: "+"-separated modifiers (mod = Ctrl or Cmd, ctrl, meta/cmd,
   alt/option, shift) then the key. Contract:
   tests/js/command-contract.test.js. */
(function () {
  "use strict";
  shad.register("command", function (root) {
    const input = root.querySelector(".shad-command__input");
    const list = root.querySelector(".shad-command__list");
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

    // update_shad_command() replaces the list's contents, so look these up
    // each time rather than once
    function empty() { return list.querySelector(".shad-command__empty"); }
    function items() {
      return Array.from(list.querySelectorAll(".shad-command__item"))
        .filter((it) => !it.hidden && !it.hasAttribute("data-disabled"));
    }
    function allItems() {
      return Array.from(list.querySelectorAll(".shad-command__item"));
    }
    // Options are reached with the arrows through aria-activedescendant, so
    // the search input stays the only tab stop. Runs again on refresh().
    function prepare() {
      allItems().forEach((it) => {
        it.setAttribute("role", "option");
        it.id = it.id || shad.uid("cmd-item");
        it.setAttribute("tabindex", "-1");
        if (it.hasAttribute("data-disabled")) it.setAttribute("aria-disabled", "true");
        else it.removeAttribute("aria-disabled");
      });
      list.querySelectorAll(".shad-command__group").forEach((g) => {
        const heading = g.querySelector(".shad-command__group-heading");
        if (!heading) return;
        heading.id = heading.id || shad.uid("cmd-group");
        g.setAttribute("role", "group");
        g.setAttribute("aria-labelledby", heading.id);
      });
    }
    prepare();

    function highlight(item) {
      if (!item) input.removeAttribute("aria-activedescendant");
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
      const e = empty();
      if (e) e.hidden = any;
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
    const combo = hotkey ? parseHotkey(hotkey) : null;
    if (hotkey && !combo) {
      console.warn("[shadshiny] command " + root.id + ": ignoring hotkey " + JSON.stringify(hotkey));
    }
    function onHotkey(ev) {
      // autofill sends keydown without a key; the IME owns keys mid-composition
      if (typeof ev.key !== "string" || ev.repeat || ev.isComposing) return;
      if (!matches(combo, ev)) return;
      // a plain key ("/") is typing while focus is in a field
      if (!combo.mod && !combo.ctrl && !combo.meta && !combo.alt && editable(ev.target)) return;
      ev.preventDefault();
      open ? doClose() : doOpen();
    }
    if (combo) document.addEventListener("keydown", onHotkey);

    function onInput() { filter(); }
    function onKeydown(ev) {
      if (ev.isComposing) return;
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
    // keep focus in the search: the arrows only work from there
    function onMouseDown(ev) {
      if (ev.target.closest(".shad-command__item")) ev.preventDefault();
    }
    input.addEventListener("input", onInput);
    input.addEventListener("keydown", onKeydown);
    list.addEventListener("pointermove", onPointerMove);
    list.addEventListener("click", onClick);
    list.addEventListener("mousedown", onMouseDown);

    filter(); // initial highlight

    return {
      getValue() { return state.value; },
      setValue(v) { state.value = v; },
      open: isDialog ? doOpen : function () {},
      close: isDialog ? doClose : function () {},
      get isOpen() { return open; },
      /** re-read the items after Shiny swaps them, then re-run the filter */
      refresh() { prepare(); filter(); },
      destroy() {
        doClose();
        if (combo) document.removeEventListener("keydown", onHotkey);
        input.removeEventListener("input", onInput);
        input.removeEventListener("keydown", onKeydown);
        list.removeEventListener("pointermove", onPointerMove);
        list.removeEventListener("click", onClick);
        list.removeEventListener("mousedown", onMouseDown);
      }
    };
  });

  const MODIFIERS = { mod: "mod", ctrl: "ctrl", control: "ctrl", meta: "meta", cmd: "meta",
    command: "meta", alt: "alt", option: "alt", shift: "shift" };

  // "mod+shift+p" -> {key, mod, ctrl, meta, alt, shift}; null when it names
  // an unknown modifier or no key. A trailing "+" is the plus key.
  function parseHotkey(s) {
    const parts = String(s).toLowerCase().split(/\+(?=.)/);
    let key = parts.pop();
    if (key === "space") key = " ";
    const combo = { key, mod: false, ctrl: false, meta: false, alt: false, shift: false };
    for (const p of parts) {
      if (!MODIFIERS[p]) return null;
      combo[MODIFIERS[p]] = true;
    }
    return key ? combo : null;
  }

  function matches(combo, ev) {
    const k = ev.key.toLowerCase();
    // a letter key that types another script (a Russian layout, Option on a
    // Mac) still names its physical key
    const physical = /^[^\x00-\x7f]$/.test(k) && /^[a-z0-9]$/.test(combo.key) &&
      ev.code === (/\d/.test(combo.key) ? "Digit" : "Key") + combo.key.toUpperCase();
    if (k !== combo.key && !physical) return false;
    if (combo.mod ? !(ev.ctrlKey || ev.metaKey)
      : !!ev.ctrlKey !== combo.ctrl || !!ev.metaKey !== combo.meta) return false;
    if (!!ev.altKey !== combo.alt) return false;
    // "/" or "?" may need Shift on some layouts; letters and named keys do not
    const symbol = combo.key.length === 1 && !/[a-z0-9 ]/.test(combo.key);
    return symbol ? !combo.shift || !!ev.shiftKey : !!ev.shiftKey === combo.shift;
  }

  // somewhere a plain key types: a text field, a select, or contenteditable
  function editable(el) {
    if (!el || el.nodeType !== 1) return false;
    if (el.tagName === "INPUT") {
      return !/^(button|checkbox|radio|submit|reset|image|file|range|color)$/i.test(el.type);
    }
    if (/^(textarea|select)$/i.test(el.tagName)) return true;
    const ce = el.closest("[contenteditable]");
    return !!ce && ce.getAttribute("contenteditable") !== "false";
  }

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

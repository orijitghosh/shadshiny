/* FILE: inst/assets/core/shad-runtime.js */
/* ==========================================================================
   shadshiny — shared runtime
   --------------------------------------------------------------------------
   Single global: window.shad. No modules, no build step. ES2020.

   Component contract (uniform across the kit — Shiny InputBindings are built
   purely on this):
     - Markup is declarative: root element carries data-shad="<name>".
     - shad.init(root?) scans and wires; idempotent (instances cached on the
       element as el.__shadInstance; re-init is a no-op).
     - shad.get(el) -> instance | null (el may be the root or any descendant).
     - Every stateful instance implements: getValue(), setValue(v),
       destroy(); overlays add open(), close(), plus isOpen.
     - Value changes dispatch bubbling CustomEvent('shad:change',
       {detail:{value}}) on the ROOT element; overlays dispatch 'shad:open' /
       'shad:close'. Events are NOT fired by setValue() re-entrantly with the
       same value (guarded by equality check in each component).
     - Component JS files self-register: shad.register(name, factory) where
       factory(rootEl) -> instance. This file must load FIRST.
   ========================================================================== */
(function () {
  "use strict";
  if (window.shad && window.shad.__runtime) return; // idempotent script load

  const shad = window.shad || {};
  shad.__runtime = true;
  window.shad = shad;

  /* ================================================================
     uid
     ================================================================ */
  let uidCounter = 0;
  shad.uid = function (prefix) {
    uidCounter += 1;
    return (prefix || "shad") + "-" + uidCounter.toString(36) + "-" +
      Math.random().toString(36).slice(2, 6);
  };

  /* small helpers shared by components */
  shad.util = {
    /** dispatch a bubbling, composed CustomEvent */
    emit(el, type, detail) {
      el.dispatchEvent(new CustomEvent(type, { bubbles: true, detail: detail || {} }));
    },
    /** all tabbable elements within container, in DOM order */
    tabbables(container) {
      const sel = [
        "a[href]", "button:not([disabled])", "input:not([disabled]):not([type=hidden])",
        "select:not([disabled])", "textarea:not([disabled])",
        "[tabindex]:not([tabindex='-1'])", "audio[controls]", "video[controls]",
        "[contenteditable]:not([contenteditable='false'])"
      ].join(",");
      return Array.from(container.querySelectorAll(sel)).filter((el) => {
        if (el.closest("[hidden]") || el.getAttribute("aria-hidden") === "true") return false;
        const r = el.getBoundingClientRect();
        return r.width > 0 || r.height > 0 || el === document.activeElement;
      });
    },
    /** true if event target is on a touch-driven pointer */
    isTouchPointer(ev) {
      return ev.pointerType === "touch" || ev.pointerType === "pen";
    },
    /** Resolve the nearest explicit text direction for keyboard/layout logic. */
    direction(el) {
      let node = el;
      while (node && node.nodeType === 1) {
        const value = node.getAttribute("dir");
        if (value && value.toLowerCase() !== "auto") {
          return value.toLowerCase() === "rtl" ? "rtl" : "ltr";
        }
        node = node.parentElement;
      }
      const documentDirection = document.documentElement.getAttribute("dir");
      if (documentDirection && documentDirection.toLowerCase() !== "auto") {
        return documentDirection.toLowerCase() === "rtl" ? "rtl" : "ltr";
      }
      return getComputedStyle(el || document.documentElement).direction === "rtl"
        ? "rtl" : "ltr";
    },
    /**
     * Scroll `container` just enough to reveal `item`, and scroll NOTHING else.
     *
     * This is the reason not to use scrollIntoView(): that walks every
     * scrollable ancestor up to the document, so highlighting an item inside a
     * component that sits in ordinary document flow drags the whole page to it.
     * An inline command palette used to jump the page to itself on load and on
     * every keystroke exactly this way.
     *
     * Honours the container's scroll-padding-block-start, so an item does not
     * come to rest under a sticky header inside the list.
     */
    keepInView(container, item) {
      if (!container || !item) return;
      const pad = parseFloat(
        getComputedStyle(container).scrollPaddingBlockStart) || 0;
      const c = container.getBoundingClientRect();
      const i = item.getBoundingClientRect();
      if (i.top < c.top + pad) container.scrollTop -= c.top + pad - i.top;
      else if (i.bottom > c.bottom - pad) container.scrollTop += i.bottom - c.bottom + pad;
    },
    clamp(v, min, max) { return Math.min(max, Math.max(min, v)); },
    /**
     * Normalise a value the server sent to a choice input (select, combobox)
     * against the option values it has. Values compare as strings; null, ""
     * and [] mean empty. Unknown entries are dropped with one warning, and an
     * update that names no option at all is ignored, as is more than one value
     * for a single choice. Returns a string or null (single), an array
     * (multiple), or undefined to leave the input as it is.
     */
    choiceValue(v, options, multiple, who) {
      const sent = [];
      (v == null ? [] : [].concat(v)).forEach((x) => {
        const s = x == null ? "" : String(x);
        if (s !== "" && sent.indexOf(s) === -1) sent.push(s);
      });
      const warn = (why, list) =>
        console.warn("[shadshiny] " + who + ": " + why + " " + JSON.stringify(list));
      if (!multiple && sent.length > 1) {
        warn("ignoring several values for a single choice", sent);
        return undefined;
      }
      const known = sent.filter((s) => options.indexOf(s) !== -1);
      if (known.length < sent.length) {
        warn("ignoring values that are not options",
          sent.filter((s) => known.indexOf(s) === -1));
        if (!known.length) return undefined;
      }
      return multiple ? known : (known.length ? known[0] : null);
    }
  };

  /* Delegated code copy: one document handler, safe for dynamic Shiny DOM. */
  function wireCodeCopy() {
    if (document.__shadCodeCopyHandler) return;

    function announceCopy(button, message) {
      const root = button.closest("[data-shad-code-block]");
      const status = root && root.querySelector("[data-shad-copy-status], [role=status]");
      if (!root || !status || !root.isConnected || !button.isConnected) return;
      if (root.__shadCopyStatusTimer) clearTimeout(root.__shadCopyStatusTimer);
      status.textContent = "";
      status.textContent = message;
      const timer = setTimeout(() => {
        if (root.isConnected && status.isConnected && root.__shadCopyStatusTimer === timer) {
          status.textContent = "";
          delete root.__shadCopyStatusTimer;
        }
      }, 2000);
      root.__shadCopyStatusTimer = timer;
    }

    async function copyCode(button) {
      const root = button.closest("[data-shad-code-block]");
      const code = root && root.querySelector("code");
      if (!root || !code) return;
      const request = (root.__shadCopyRequest || 0) + 1;
      root.__shadCopyRequest = request;
      let message = "Copied";
      try {
        await navigator.clipboard.writeText(code.textContent || "");
      } catch (_error) {
        message = "Copy failed";
      }
      if (!root.isConnected || !button.isConnected || root.__shadCopyRequest !== request) return;
      announceCopy(button, message);
    }

    const handler = (event) => {
      const target = event.target;
      const button = target && target.closest
        ? target.closest("[data-shad-copy-code]") : null;
      if (button) void copyCode(button);
    };
    document.addEventListener("click", handler);
    document.__shadCodeCopyHandler = handler;
  }
  wireCodeCopy();

  /* ================================================================
     FloatingEngine — popover/menu/tooltip positioning
     ----------------------------------------------------------------
     position:fixed math (viewport coords == fixed coords). Supports:
       side: top|right|bottom|left      (preferred)
       align: start|center|end
       offset: px gap between anchor and panel (default 4)
       flip: swap to opposite side when preferred side overflows
       shift: clamp along the alignment axis to stay in viewport (8px pad)
       arrow: optional element, centered on the anchor, clamped to panel
     Writes data-side/data-align back onto the panel (CSS motion reads them).
     One shared passive scroll/resize listener drives all trackers, batched
     through a single requestAnimationFrame.
     ================================================================ */
  const Floating = (function () {
    const PAD = 8; // viewport collision padding
    const tracked = new Set();
    let rafPending = false;
    let listening = false;

    function scheduleAll() {
      if (rafPending) return;
      rafPending = true;
      requestAnimationFrame(() => {
        rafPending = false;
        tracked.forEach((t) => position(t));
      });
    }
    function ensureListeners() {
      if (listening) return;
      listening = true;
      // capture:true catches scrolls of any ancestor scroller, not just window
      window.addEventListener("scroll", scheduleAll, { capture: true, passive: true });
      window.addEventListener("resize", scheduleAll, { passive: true });
    }

    function mainAxisCoord(side, a, p, offset) {
      switch (side) {
        case "top": return a.top - p.height - offset;
        case "bottom": return a.bottom + offset;
        case "left": return a.left - p.width - offset;
        case "right": return a.right + offset;
      }
    }
    function crossAxisCoord(side, align, a, p) {
      const horizontal = side === "top" || side === "bottom";
      const aStart = horizontal ? a.left : a.top;
      const aSize = horizontal ? a.width : a.height;
      const pSize = horizontal ? p.width : p.height;
      switch (align) {
        case "start": return aStart;
        case "end": return aStart + aSize - pSize;
        default: return aStart + aSize / 2 - pSize / 2; // center
      }
    }

    function position(t) {
      const { anchor, panel, opts } = t;
      if (!panel.isConnected || panel.hidden) return;
      const a = anchor.getBoundingClientRect();
      // measure without previous position affecting layout size
      const p = { width: panel.offsetWidth, height: panel.offsetHeight };
      const vw = document.documentElement.clientWidth;
      const vh = document.documentElement.clientHeight;
      const offset = opts.offset != null ? opts.offset : 4;

      let side = opts.side || "bottom";
      const align = opts.align || "center";

      // flip: if preferred side overflows and opposite fits better, swap
      if (opts.flip !== false) {
        const fits = (s) => {
          const m = mainAxisCoord(s, a, p, offset);
          if (s === "top" || s === "bottom") return m >= PAD && m + p.height <= vh - PAD;
          return m >= PAD && m + p.width <= vw - PAD;
        };
        if (!fits(side)) {
          const opposite = { top: "bottom", bottom: "top", left: "right", right: "left" }[side];
          if (fits(opposite)) side = opposite;
        }
      }

      const horizontal = side === "top" || side === "bottom";
      let main = mainAxisCoord(side, a, p, offset);
      let cross = crossAxisCoord(side, align, a, p);

      // shift: clamp cross axis into viewport
      if (opts.shift !== false) {
        const max = (horizontal ? vw - p.width : vh - p.height) - PAD;
        cross = shad.util.clamp(cross, PAD, Math.max(PAD, max));
      }

      const top = horizontal ? main : cross;
      const left = horizontal ? cross : main;
      panel.style.position = "fixed";
      panel.style.top = Math.round(top) + "px";
      panel.style.left = Math.round(left) + "px";
      panel.style.margin = "0";
      panel.setAttribute("data-side", side);
      panel.setAttribute("data-align", align);

      // available-height hint for scrollable listboxes (select/combobox)
      const avail = side === "top" ? a.top - offset - PAD : vh - a.bottom - offset - PAD;
      panel.style.setProperty("--shad-available-height", Math.max(80, Math.floor(avail)) + "px");

      // arrow: centered on anchor along cross axis, clamped inside the panel
      if (opts.arrow) {
        const arrow = opts.arrow;
        const half = (horizontal ? arrow.offsetWidth : arrow.offsetHeight) / 2 || 5;
        if (horizontal) {
          const cx = shad.util.clamp(a.left + a.width / 2 - left, half + 4, p.width - half - 4);
          arrow.style.left = Math.round(cx - half) + "px";
          arrow.style.top = side === "bottom" ? -half + "px" : "";
          arrow.style.bottom = side === "top" ? -half + "px" : "";
        } else {
          const cy = shad.util.clamp(a.top + a.height / 2 - top, half + 4, p.height - half - 4);
          arrow.style.top = Math.round(cy - half) + "px";
          arrow.style.left = side === "right" ? -half + "px" : "";
          arrow.style.right = side === "left" ? -half + "px" : "";
        }
        arrow.setAttribute("data-side", side);
      }
    }

    return {
      /**
       * Track panel against anchor. Returns an untrack() disposer.
       * opts: {side, align, offset, flip, shift, arrow}
       */
      track(anchor, panel, opts) {
        ensureListeners();
        const t = { anchor, panel, opts: opts || {} };
        tracked.add(t);
        position(t); // immediate first position
        return () => tracked.delete(t);
      },
      /** one-shot reposition (e.g. after content change) */
      positionNow(anchor, panel, opts) {
        position({ anchor, panel, opts: opts || {} });
      }
    };
  })();
  shad.floating = Floating;

  /* ================================================================
     DismissLayer — global overlay stack
     ----------------------------------------------------------------
     push({el, onDismiss, closeOnEscape=true, closeOnOutside=true,
           extraElements=[]}) -> disposer.
     - Escape dismisses ONLY the topmost layer.
     - pointerdown outside dismisses the topmost layer IFF the target is
       not inside that layer's el/extraElements AND not inside any layer
       ABOVE it (there are none, it's topmost) — nested case works because
       an inner layer (menu in dialog) is pushed later, so it is topmost
       and receives the dismissal first; the click that closed it does not
       also close the dialog (we stop after topmost).
     ================================================================ */
  const Dismiss = (function () {
    const stack = [];
    let wired = false;

    function topmost() { return stack[stack.length - 1] || null; }

    function onKeydown(ev) {
      if (ev.key !== "Escape") return;
      const layer = topmost();
      if (!layer || layer.closeOnEscape === false) return;
      ev.preventDefault();
      ev.stopPropagation();
      layer.onDismiss("escape");
    }
    function inLayer(layer, target) {
      if (layer.el.contains(target)) return true;
      return (layer.extraElements || []).some((x) => x && x.contains(target));
    }
    function onPointerDown(ev) {
      const layer = topmost();
      if (!layer || layer.closeOnOutside === false) return;
      if (inLayer(layer, ev.target)) return;
      // if the press landed inside a LOWER layer or plain page, dismiss top.
      layer.onDismiss("outside");
    }
    function wire() {
      if (wired) return;
      wired = true;
      document.addEventListener("keydown", onKeydown, true);
      document.addEventListener("pointerdown", onPointerDown, true);
    }

    return {
      push(layer) {
        wire();
        stack.push(layer);
        return () => {
          const i = stack.indexOf(layer);
          if (i !== -1) stack.splice(i, 1);
        };
      },
      /** true if el belongs to the topmost layer (used by menus) */
      isTopmost(el) {
        const layer = topmost();
        return !!layer && inLayer(layer, el);
      },
      get depth() { return stack.length; }
    };
  })();
  shad.dismiss = Dismiss;

  /* ================================================================
     FocusTrap — modal focus containment
     ----------------------------------------------------------------
     trap(container) -> release(). Saves document.activeElement, moves
     focus to [data-shad-autofocus] || first tabbable || container, keeps
     Tab/Shift-Tab cycling inside, restores focus on release.
     ================================================================ */
  shad.focusTrap = function (container) {
    const previouslyFocused = document.activeElement;

    function initialFocus() {
      const auto = container.querySelector("[data-shad-autofocus]");
      const target = auto || shad.util.tabbables(container)[0] || container;
      if (target === container) container.setAttribute("tabindex", "-1");
      target.focus({ preventScroll: true });
    }
    function onKeydown(ev) {
      if (ev.key !== "Tab") return;
      const items = shad.util.tabbables(container);
      if (items.length === 0) { ev.preventDefault(); return; }
      const first = items[0], last = items[items.length - 1];
      const active = document.activeElement;
      // Tab wrap-around scrolls by design: the panel may be taller than its
      // viewport, and the newly focused control has to be visible.
      if (ev.shiftKey && (active === first || !container.contains(active))) {
        ev.preventDefault(); last.focus();
      } else if (!ev.shiftKey && (active === last || !container.contains(active))) {
        ev.preventDefault(); first.focus();
      }
    }
    // recapture focus that escapes (e.g. via click on document)
    function onFocusIn(ev) {
      if (!container.contains(ev.target)) {
        const items = shad.util.tabbables(container);
        (items[0] || container).focus({ preventScroll: true });
      }
    }

    container.addEventListener("keydown", onKeydown);
    document.addEventListener("focusin", onFocusIn);
    // defer initial focus one frame so enter animation/layout settles
    requestAnimationFrame(initialFocus);

    return function release() {
      container.removeEventListener("keydown", onKeydown);
      document.removeEventListener("focusin", onFocusIn);
      if (previouslyFocused && previouslyFocused.focus &&
          document.contains(previouslyFocused)) {
        previouslyFocused.focus({ preventScroll: true });
      }
    };
  };

  /* ================================================================
     RovingTabindex — arrow-key item navigation
     ----------------------------------------------------------------
     roving(container, {
       selector,                  // item selector (required)
       orientation: "vertical"|"horizontal"|"both" (default vertical)
       loop: true,                // wrap at ends
       typeahead: false,          // 1s buffered first-letter matching
       focusItem(el),             // override focus behavior
       onActivate(el, ev)         // Enter/Space handler (optional)
     }) -> {destroy, setActive(el), items(), active}
     Items: tabindex=0 on active, -1 on the rest. Skips [data-disabled],
     [aria-disabled=true], [hidden].
     ================================================================ */
  shad.roving = function (container, opts) {
    const o = Object.assign({ orientation: "vertical", loop: true }, opts);
    let active = null;
    let buffer = "";
    let bufferTimer = null;

    function items() {
      return Array.from(container.querySelectorAll(o.selector)).filter((el) =>
        !el.hasAttribute("data-disabled") &&
        el.getAttribute("aria-disabled") !== "true" &&
        !el.hidden && !el.closest("[hidden]"));
    }
    function setActive(el, focus) {
      const all = items();
      if (!el) el = all[0];
      if (!el) return;
      all.forEach((it) => it.setAttribute("tabindex", it === el ? "0" : "-1"));
      active = el;
      if (focus !== false) {
        if (o.focusItem) o.focusItem(el); else el.focus({ preventScroll: true });
      }
    }
    function move(delta) {
      const all = items();
      if (all.length === 0) return;
      let i = all.indexOf(document.activeElement);
      if (i === -1) i = all.indexOf(active);
      let next = i + delta;
      if (o.loop) next = (next + all.length) % all.length;
      else next = shad.util.clamp(next, 0, all.length - 1);
      setActive(all[next]);
    }
    function onKeydown(ev) {
      const horiz = o.orientation === "horizontal" || o.orientation === "both";
      const vert = o.orientation === "vertical" || o.orientation === "both";
      const rtl = horiz && shad.util.direction(container) === "rtl";
      let handled = true;
      switch (ev.key) {
        case "ArrowDown": if (vert) move(1); else handled = false; break;
        case "ArrowUp": if (vert) move(-1); else handled = false; break;
        case "ArrowRight": if (horiz) move(rtl ? -1 : 1); else handled = false; break;
        case "ArrowLeft": if (horiz) move(rtl ? 1 : -1); else handled = false; break;
        case "Home": setActive(items()[0]); break;
        case "End": setActive(items()[items().length - 1]); break;
        case "Enter": case " ":
          if (o.onActivate && items().includes(document.activeElement)) {
            o.onActivate(document.activeElement, ev);
          } else handled = false;
          break;
        default:
          handled = false;
          if (o.typeahead && ev.key.length === 1 && !ev.ctrlKey && !ev.metaKey && !ev.altKey) {
            buffer += ev.key.toLowerCase();
            clearTimeout(bufferTimer);
            bufferTimer = setTimeout(() => { buffer = ""; }, 1000);
            const all = items();
            const start = (all.indexOf(document.activeElement) + 1) % (all.length || 1);
            const rotated = all.slice(start).concat(all.slice(0, start));
            const hit = rotated.find((el) =>
              (el.textContent || "").trim().toLowerCase().startsWith(buffer));
            if (hit) { setActive(hit); handled = true; }
          }
      }
      if (handled) { ev.preventDefault(); ev.stopPropagation(); }
    }

    container.addEventListener("keydown", onKeydown);
    // initialize tabindexes lazily (first item focusable)
    setActive(items()[0], false);

    return {
      destroy() { container.removeEventListener("keydown", onKeydown); clearTimeout(bufferTimer); },
      setActive,
      items,
      get active() { return active; }
    };
  };

  /* ================================================================
     Presence — animated unmount
     ----------------------------------------------------------------
     show(el): removes [hidden], forces reflow, sets data-state="open".
     hide(el, done?): sets data-state="closed"; when the exit animation
     ends (or 500ms fallback), applies [hidden] and calls done().
     Never display:none an open overlay directly.
     ================================================================ */
  shad.presence = {
    show(el) {
      if (el.__shadHideCleanup) { el.__shadHideCleanup(); }
      el.hidden = false;
      // force reflow so the enter animation restarts from frame 0
      void el.offsetWidth;
      el.setAttribute("data-state", "open");
    },
    hide(el, done) {
      if (el.hidden) { if (done) done(); return; }
      let finished = false;
      const finish = () => {
        if (finished) return;
        finished = true;
        el.removeEventListener("animationend", onEnd);
        el.removeEventListener("transitionend", onEnd);
        clearTimeout(timer);
        delete el.__shadHideCleanup;
        el.hidden = true;
        if (done) done();
      };
      const onEnd = (ev) => { if (ev.target === el) finish(); };
      el.setAttribute("data-state", "closed");
      el.addEventListener("animationend", onEnd);
      el.addEventListener("transitionend", onEnd);
      const timer = setTimeout(finish, 500); // fallback: reduced-motion / no anim
      el.__shadHideCleanup = finish;
    }
  };

  /* ================================================================
     ScrollLock — reference-counted body scroll lock
     ----------------------------------------------------------------
     Compensates for scrollbar width so layout doesn't shift.
     ================================================================ */
  const ScrollLock = (function () {
    let count = 0;
    let saved = null;
    return {
      lock() {
        count += 1;
        if (count > 1) return;
        const body = document.body;
        const scrollbar = window.innerWidth - document.documentElement.clientWidth;
        saved = { overflow: body.style.overflow, paddingRight: body.style.paddingRight };
        body.style.overflow = "hidden";
        if (scrollbar > 0) {
          const current = parseFloat(getComputedStyle(body).paddingRight) || 0;
          body.style.paddingRight = (current + scrollbar) + "px";
        }
      },
      unlock() {
        count = Math.max(0, count - 1);
        if (count > 0 || !saved) return;
        document.body.style.overflow = saved.overflow;
        document.body.style.paddingRight = saved.paddingRight;
        saved = null;
      }
    };
  })();
  shad.scrollLock = ScrollLock;

  /* ================================================================
     Portal — move panel to document.body, restore on close
     ----------------------------------------------------------------
     portal(el) -> restore(). A comment node marks the original slot so
     the element returns to the exact position (Shiny fragments keep
     working). Idempotent: portaling twice returns the same restorer.
     ================================================================ */
  function inheritedAttribute(source, name) {
    let node = source;
    while (node && node.nodeType === 1) {
      const value = node.getAttribute(name);
      if (value) return value;
      node = node.parentElement;
    }
    return document.documentElement.getAttribute(name) || null;
  }

  /** Copy the logical owner's direction/language onto a body portal. */
  shad.syncPortalDirection = function (source, portal) {
    if (!source || !portal) return;
    const dir = inheritedAttribute(source, "dir") || "ltr";
    const lang = inheritedAttribute(source, "lang");
    portal.setAttribute("dir", dir);
    if (lang) portal.setAttribute("lang", lang);
    else portal.removeAttribute("lang");
  };

  shad.portal = function (el) {
    if (el.__shadPortalRestore) return el.__shadPortalRestore;
    const componentRoot = el.closest && el.closest("[data-shad]");
    // A component that portals its own root (the command dialog) would lose
    // the scope direction if the root itself were used after it moves.
    const source = componentRoot && componentRoot.getAttribute("dir")
      ? componentRoot
      : (componentRoot?.parentElement || el.parentElement || el);
    const previousDir = el.getAttribute("dir");
    const previousLang = el.getAttribute("lang");
    const marker = document.createComment("shad-portal");
    shad.syncPortalDirection(source || document.documentElement, el);
    el.parentNode.insertBefore(marker, el);
    document.body.appendChild(el);
    const directionObserver = typeof MutationObserver === "function"
      ? new MutationObserver((mutations) => {
        if (mutations.some((m) => m.target !== el && (m.target === source ||
            m.target.contains?.(source)))) {
          shad.syncPortalDirection(source || document.documentElement, el);
        }
      })
      : null;
    if (directionObserver) {
      directionObserver.observe(document.documentElement, {
        attributes: true, attributeFilter: ["dir", "lang"], subtree: true
      });
    }
    let restored = false;
    const restore = () => {
      if (restored) return;
      restored = true;
      if (directionObserver) directionObserver.disconnect();
      if (marker.parentNode) marker.parentNode.replaceChild(el, marker);
      if (previousDir == null) el.removeAttribute("dir");
      else el.setAttribute("dir", previousDir);
      if (previousLang == null) el.removeAttribute("lang");
      else el.setAttribute("lang", previousLang);
      delete el.__shadPortalRestore;
    };
    el.__shadPortalRestore = restore;
    return restore;
  };

  /* ================================================================
     Component registry + lifecycle
     ================================================================ */
  const registry = new Map(); // name -> factory(rootEl) -> instance

  shad.register = function (name, factory) {
    registry.set(name, factory);
  };

  /* Two init-time attributes, used by server-created overlays
     (shad_show_dialog() and friends). They live here rather than in each
     overlay's file so dialog / alert-dialog / sheet / drawer / popover all get
     them from one place.

       data-shad-open       open as soon as the instance exists
       data-shad-transient  after it closes, unbind, destroy and remove it

     Transient is what makes a server-created overlay disposable: the R side
     inserts the markup and never has to reach back in to clean it up. */
  function autoOpen(el, instance) {
    if (!el.hasAttribute("data-shad-open")) return;
    if (typeof instance.open !== "function") return;
    // Defer past the end of the current task, for two reasons:
    //   - Shiny appends the fragment and binds it in one task. Overlays portal
    //     their panel to <body> on open, so opening before Shiny::bindAll gets
    //     there would move the inputs out from under it and leave them unbound.
    //   - the element needs to be laid out before the enter animation runs.
    // setTimeout, not requestAnimationFrame: a backgrounded tab paints no
    // frames, and an overlay that only appears once you look at the tab is a
    // bug you cannot reproduce on demand.
    setTimeout(function () { instance.open(); }, 0);
  }

  function autoRemove(el) {
    if (!el.hasAttribute("data-shad-transient") || el.__shadTransient) return;
    el.__shadTransient = true;
    el.addEventListener("shad:close", function () {
      // shad:close fires when the close STARTS; Presence is still animating the
      // element out and only then applies [hidden]. Its own fallback timer caps
      // that at 500ms, so waiting past it needs no per-component knowledge —
      // and the element is invisible for the whole wait either way.
      setTimeout(function () {
        if (window.Shiny && Shiny.unbindAll) Shiny.unbindAll(el);
        shad.destroy(el);
        if (el.parentNode) el.parentNode.removeChild(el);
      }, 550);
    });
  }

  /**
   * Scan `root` (default document) for [data-shad] elements and wire them.
   * Idempotent: elements that already carry an instance are skipped.
   */
  shad.init = function (root) {
    root = root || document;
    const nodes = [];
    if (root.nodeType === 1 && root.matches("[data-shad]")) nodes.push(root);
    root.querySelectorAll("[data-shad]").forEach((el) => nodes.push(el));
    nodes.forEach((el) => {
      if (el.__shadInstance) return;
      const name = el.getAttribute("data-shad");
      const factory = registry.get(name);
      if (!factory) return; // component JS not loaded — silently skip
      try {
        const instance = factory(el) || {};
        instance.el = el;
        instance.name = name;
        el.__shadInstance = instance;
        autoOpen(el, instance);
        autoRemove(el);
      } catch (err) {
        console.error("[shad] failed to init <" + name + ">", el, err);
      }
    });
  };

  /** Instance for el (root or descendant), or null. */
  shad.get = function (el) {
    const root = el && el.closest ? el.closest("[data-shad]") : null;
    return root ? root.__shadInstance || null : null;
  };

  /** Tear down the instance on el (root or descendant). */
  shad.destroy = function (el) {
    const inst = shad.get(el);
    if (inst) {
      if (typeof inst.destroy === "function") inst.destroy();
      delete inst.el.__shadInstance;
    }
  };

  /**
   * Watch the DOM and auto-init shad components in inserted fragments,
   * auto-destroy in removed ones. Call once; returns a stop().
   * Recommended for Shiny: shad.autoInit() right after scripts load.
   */
  let observer = null;
  shad.autoInit = function () {
    // Initialise whatever exists right now. Safe to call repeatedly —
    // shad.init caches instances on the element, so this is idempotent.
    shad.init(document);

    // Then watch for dynamically inserted / removed components (Shiny
    // renderUI, insertUI, dynamic tabs). The bundle's scripts run in <head>,
    // so document.body can still be null here; defer the observer to DOM ready
    // rather than throwing (a throw here previously aborted init entirely).
    function startObserver() {
      if (observer || !document.body) return;
      observer = new MutationObserver((mutations) => {
        for (const m of mutations) {
          m.addedNodes.forEach((n) => { if (n.nodeType === 1) shad.init(n); });
          m.removedNodes.forEach((n) => {
            if (n.nodeType !== 1) return;
            const roots = [];
            if (n.matches && n.matches("[data-shad]")) roots.push(n);
            if (n.querySelectorAll) n.querySelectorAll("[data-shad]").forEach((e) => roots.push(e));
            roots.forEach((e) => {
              // A move is a removal plus an insertion, and shad.portal() moves
              // panels (and, for a command dialog, the root itself) to <body>
              // on open. Tearing those down here would destroy the component
              // mid-open. Anything still in the document was moved, not removed.
              if (e.isConnected) return;
              const inst = e.__shadInstance;
              if (inst && typeof inst.destroy === "function") inst.destroy();
              delete e.__shadInstance;
            });
          });
        }
      });
      observer.observe(document.body, { childList: true, subtree: true });
    }

    if (document.body) {
      startObserver();
    } else {
      document.addEventListener("DOMContentLoaded", startObserver, { once: true });
    }
    return function stop() { if (observer) { observer.disconnect(); observer = null; } };
  };

  /* auto-init on DOM ready for static pages */
  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", () => shad.init(document));
  } else {
    // scripts loaded late (Shiny): init what exists now
    shad.init(document);
  }
})();

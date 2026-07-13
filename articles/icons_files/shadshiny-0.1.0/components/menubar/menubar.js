/* FILE: inst/assets/components/menubar/menubar.js */
/* shadshiny — menubar (APG menubar). Requires dropdown-menu.js.
   Roving focus across triggers (←/→); click opens; once any menu is open,
   hovering another trigger switches to it; ←/→ inside an open menu move
   between adjacent menus (unless → opens a submenu). */
(function () {
  "use strict";
  shad.register("menubar", function (root) {
    if (!shad.__menuCore) {
      console.error("[shad] menubar requires components/dropdown-menu/dropdown-menu.js");
      return {};
    }
    const state = { value: null };
    const menus = []; // {trigger, panel, ctl}
    let openIndex = -1;

    root.setAttribute("role", "menubar");

    function closeAll(refocus) {
      if (openIndex === -1) return;
      const m = menus[openIndex];
      m.ctl.close();
      m.trigger.setAttribute("data-state", "closed");
      m.trigger.setAttribute("aria-expanded", "false");
      const wasOpen = openIndex;
      openIndex = -1;
      shad.util.emit(root, "shad:close", {});
      if (refocus) menus[wasOpen].trigger.focus({ preventScroll: true });
    }
    function openAt(i) {
      if (openIndex === i) return;
      if (openIndex !== -1) {
        const prev = menus[openIndex];
        prev.ctl.close();
        prev.trigger.setAttribute("data-state", "closed");
        prev.trigger.setAttribute("aria-expanded", "false");
        openIndex = -1;
      }
      const m = menus[i];
      m.ctl.show();
      m.ctl.highlightFirst();
      m.trigger.setAttribute("data-state", "open");
      m.trigger.setAttribute("aria-expanded", "true");
      openIndex = i;
      shad.util.emit(root, "shad:open", { menu: m.trigger.textContent.trim() });
    }
    function moveMenu(delta) {
      if (openIndex === -1) return;
      openAt((openIndex + delta + menus.length) % menus.length);
    }

    root.querySelectorAll(":scope > [data-shad-menubar-menu]").forEach((wrap, i) => {
      const trigger = wrap.querySelector(".shad-menubar__trigger");
      const panel = wrap.querySelector(".shad-menu__content");
      trigger.setAttribute("role", "menuitem");
      trigger.setAttribute("aria-haspopup", "menu");
      trigger.setAttribute("aria-expanded", "false");
      trigger.setAttribute("data-state", "closed");

      const ctl = shad.__menuCore.menuPanel(panel, {
        anchor: () => trigger,
        side: "bottom", align: "start",
        extraElements: [trigger],
        onActivate: (item) => shad.__menuCore.handleActivate(root, item, state),
        onRequestClose(reason) {
          if (reason === "left-arrow") {
            // ← at menu top level: previous menubar menu
            moveMenu(-1);
          } else {
            closeAll(reason === "escape" || reason === "activate");
          }
        }
      });
      menus.push({ trigger, panel, ctl });

      trigger.addEventListener("click", () => {
        openIndex === i ? closeAll(true) : openAt(i);
      });
      trigger.addEventListener("pointerenter", () => {
        if (openIndex !== -1 && openIndex !== i) openAt(i); // hover-switch
      });
      trigger.addEventListener("keydown", (ev) => {
        if (ev.key === "ArrowDown" || ev.key === "Enter" || ev.key === " ") {
          ev.preventDefault(); openAt(i);
        }
      });
    });

    /* → inside an open menu (when not on a submenu trigger) = next menu.
       menuPanel handles → for submenus and stops propagation; anything that
       reaches here means "next menubar menu". Listen on document because
       panels are portaled to body while open. */
    function onDocKeydown(ev) {
      if (openIndex === -1 || ev.key !== "ArrowRight") return;
      const panel = menus[openIndex].panel;
      if (panel.contains(document.activeElement)) {
        ev.preventDefault();
        moveMenu(1);
      }
    }
    document.addEventListener("keydown", onDocKeydown);

    /* roving tabindex across closed-state triggers */
    const rove = shad.roving(root, {
      selector: ".shad-menubar__trigger",
      orientation: "horizontal"
    });

    return {
      getValue() { return state.value; },
      setValue(v) { state.value = v; },
      open() { openAt(0); },
      close() { closeAll(false); },
      get isOpen() { return openIndex !== -1; },
      destroy() {
        closeAll(false);
        rove.destroy();
        document.removeEventListener("keydown", onDocKeydown);
      }
    };
  });
})();

/* FILE: inst/assets/components/context-menu/context-menu.js */
/* shadshiny — context-menu. Requires dropdown-menu.js (shad.__menuCore).
   Opens at pointer coords via a virtual anchor rect; contextmenu event is
   prevented inside the zone. Same items/submenus/keyboard as dropdown-menu. */
(function () {
  "use strict";
  shad.register("context-menu", function (root) {
    if (!shad.__menuCore) {
      console.error("[shad] context-menu requires components/dropdown-menu/dropdown-menu.js");
      return {};
    }
    const zone = root.querySelector(".shad-context-menu__zone");
    const panel = root.querySelector(".shad-menu__content");
    const state = { value: null };

    // virtual anchor: 1x1 rect at last right-click point
    let point = { x: 0, y: 0 };
    const virtualAnchor = {
      getBoundingClientRect() {
        return { top: point.y, bottom: point.y + 1, left: point.x, right: point.x + 1,
                 width: 1, height: 1, x: point.x, y: point.y };
      }
    };

    const ctl = shad.__menuCore.menuPanel(panel, {
      anchor: () => virtualAnchor,
      side: "bottom", align: "start", offset: 0,
      onActivate: (item) => shad.__menuCore.handleActivate(root, item, state),
      onRequestClose(reason) {
        close_();
        if (reason === "escape") zone.focus({ preventScroll: true });
      }
    });

    function open_(x, y) {
      point = { x, y };
      if (ctl.isOpen) {
        // reposition on a second right-click while open
        shad.floating.positionNow(virtualAnchor, panel, { side: "bottom", align: "start", offset: 0 });
        return;
      }
      ctl.show();
      ctl.highlightFirst();
      shad.util.emit(root, "shad:open", {});
    }
    function close_() {
      if (!ctl.isOpen) return;
      ctl.close();
      shad.util.emit(root, "shad:close", {});
    }
    function onContextMenu(ev) {
      ev.preventDefault();
      open_(ev.clientX, ev.clientY);
    }
    // keyboard access: Shift+F10 / ContextMenu key opens at zone center
    function onKeydown(ev) {
      if ((ev.key === "F10" && ev.shiftKey) || ev.key === "ContextMenu") {
        ev.preventDefault();
        const r = zone.getBoundingClientRect();
        open_(r.left + r.width / 2, r.top + r.height / 2);
      }
    }
    zone.setAttribute("tabindex", zone.getAttribute("tabindex") || "0");
    zone.addEventListener("contextmenu", onContextMenu);
    zone.addEventListener("keydown", onKeydown);

    return {
      getValue() { return state.value; },
      setValue(v) { state.value = v; },
      open() { const r = zone.getBoundingClientRect(); open_(r.left + r.width / 2, r.top + r.height / 2); },
      close: close_,
      get isOpen() { return ctl.isOpen; },
      destroy() {
        close_();
        zone.removeEventListener("contextmenu", onContextMenu);
        zone.removeEventListener("keydown", onKeydown);
      }
    };
  });
})();

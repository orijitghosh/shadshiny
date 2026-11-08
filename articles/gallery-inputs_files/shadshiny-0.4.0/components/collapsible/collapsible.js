/* FILE: inst/assets/components/collapsible/collapsible.js */
/* shadshiny – collapsible behavior (APG disclosure). */
(function () {
  "use strict";
  shad.register("collapsible", function (root) {
    const trigger = root.querySelector(".shad-collapsible__trigger");
    const content = root.querySelector(".shad-collapsible__content");
    let open = root.hasAttribute("data-open");

    content.id = content.id || shad.uid("collapsible");
    trigger.setAttribute("aria-controls", content.id);
    trigger.setAttribute("aria-expanded", open ? "true" : "false");
    root.setAttribute("data-state", open ? "open" : "closed");
    content.setAttribute("data-state", open ? "open" : "closed");
    content.hidden = !open;

    function setHeightVar() {
      content.style.setProperty("--shad-collapsible-height",
        content.scrollHeight + "px");
    }
    function doOpen() {
      if (open) return;
      open = true;
      root.setAttribute("data-state", "open");
      trigger.setAttribute("aria-expanded", "true");
      content.hidden = false;
      setHeightVar();
      shad.presence.show(content);
      shad.util.emit(root, "shad:open", {});
      shad.util.emit(root, "shad:change", { value: true });
    }
    function doClose() {
      if (!open) return;
      open = false;
      root.setAttribute("data-state", "closed");
      trigger.setAttribute("aria-expanded", "false");
      setHeightVar();
      shad.presence.hide(content);
      shad.util.emit(root, "shad:close", {});
      shad.util.emit(root, "shad:change", { value: false });
    }
    function onClick() { open ? doClose() : doOpen(); }
    trigger.addEventListener("click", onClick);

    return {
      getValue() { return open; },
      setValue(v) { v ? doOpen() : doClose(); },
      open: doOpen, close: doClose,
      get isOpen() { return open; },
      destroy() { trigger.removeEventListener("click", onClick); }
    };
  });
})();

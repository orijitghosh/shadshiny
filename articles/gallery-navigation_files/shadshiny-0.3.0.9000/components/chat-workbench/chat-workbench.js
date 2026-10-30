/* FILE: inst/assets/components/chat-workbench/chat-workbench.js */
(function () {
  "use strict";
  shad.register("chat-workbench", function (el) {
    function onVersion(event) {
      if (!window.Shiny || !el.id || !event.detail) return;
      window.Shiny.setInputValue(el.id.replace(/-root$/, "-version"), event.detail, { priority: "event" });
    }
    el.addEventListener("shad:chat-version", onVersion);
    return { destroy() { el.removeEventListener("shad:chat-version", onVersion); } };
  });
})();

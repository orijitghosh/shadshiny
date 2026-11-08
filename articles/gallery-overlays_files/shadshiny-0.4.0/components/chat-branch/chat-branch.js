/* FILE: inst/assets/components/chat-branch/chat-branch.js */
(function () {
  "use strict";
  shad.register("chat-branch", function (el) {
    function onClick(event) {
      const control = event.target.closest("[data-chat-branch]");
      if (!control || !el.contains(control)) return;
      if (control.disabled || control.getAttribute("aria-disabled") === "true") return;
      const current = Number(el.dataset.version || 1);
      const version = control.dataset.chatBranch === "previous" ? current - 1 : current + 1;
      el.dispatchEvent(new CustomEvent("shad:chat-version", {
        bubbles: true, detail: { messageId: el.dataset.messageId, version }
      }));
    }
    el.addEventListener("click", onClick);
    return { destroy() { el.removeEventListener("click", onClick); } };
  });
})();

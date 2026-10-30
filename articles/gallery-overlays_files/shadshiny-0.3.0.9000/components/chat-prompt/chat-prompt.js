/* FILE: inst/assets/components/chat-prompt/chat-prompt.js */
(function () {
  "use strict";
  shad.register("chat-prompt", function (el) {
    const textarea = el.querySelector("textarea");
    const button = el.querySelector("button");
    function onKeydown(event) {
      if (event.key !== "Enter" || event.shiftKey || event.isComposing ||
          !button || button.disabled || (textarea && textarea.disabled)) return;
      event.preventDefault();
      button.click();
    }
    if (textarea) textarea.addEventListener("keydown", onKeydown);
    return { destroy() { if (textarea) textarea.removeEventListener("keydown", onKeydown); } };
  });
})();

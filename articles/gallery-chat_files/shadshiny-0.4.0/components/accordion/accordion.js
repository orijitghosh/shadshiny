/* FILE: inst/assets/components/accordion/accordion.js */
/* shadshiny – accordion behavior (APG accordion).
   data-type="single" (default; data-collapsible allows closing the open one)
   or data-type="multiple". Height animation: measure scrollHeight into
   --shad-collapsible-height, run keyframes, then let Presence hide.
   getValue() -> single: value|null; multiple: array of open values. */
(function () {
  "use strict";
  shad.register("accordion", function (root) {
    const multiple = root.getAttribute("data-type") === "multiple";
    const collapsible = multiple || root.hasAttribute("data-collapsible");
    const items = Array.from(root.querySelectorAll(".shad-accordion__item"));
    const map = []; // {value, trigger, content}

    items.forEach((item) => {
      const trigger = item.querySelector(".shad-accordion__trigger");
      const content = item.querySelector(".shad-accordion__content");
      const value = item.dataset.value ||
        (item.dataset.value = shad.uid("acc"));
      content.id = content.id || shad.uid("acc-content");
      trigger.id = trigger.id || shad.uid("acc-trigger");
      trigger.setAttribute("aria-controls", content.id);
      content.setAttribute("role", "region");
      content.setAttribute("aria-labelledby", trigger.id);
      const initiallyOpen = item.hasAttribute("data-open");
      trigger.setAttribute("aria-expanded", initiallyOpen ? "true" : "false");
      trigger.setAttribute("data-state", initiallyOpen ? "open" : "closed");
      content.setAttribute("data-state", initiallyOpen ? "open" : "closed");
      content.hidden = !initiallyOpen;
      map.push({ value, item, trigger, content });
    });

    function openValues() {
      return map.filter((m) => m.trigger.getAttribute("data-state") === "open")
        .map((m) => m.value);
    }
    function setHeightVar(content) {
      content.style.setProperty("--shad-collapsible-height",
        content.scrollHeight + "px");
    }
    function openItem(m) {
      if (m.trigger.getAttribute("data-state") === "open") return;
      m.trigger.setAttribute("data-state", "open");
      m.trigger.setAttribute("aria-expanded", "true");
      m.item.setAttribute("data-state", "open");
      m.content.hidden = false;
      setHeightVar(m.content);
      shad.presence.show(m.content);
    }
    function closeItem(m) {
      if (m.trigger.getAttribute("data-state") === "closed") return;
      m.trigger.setAttribute("data-state", "closed");
      m.trigger.setAttribute("aria-expanded", "false");
      m.item.setAttribute("data-state", "closed");
      setHeightVar(m.content);
      shad.presence.hide(m.content);
    }
    function toggle(m) {
      const isOpen = m.trigger.getAttribute("data-state") === "open";
      if (isOpen) {
        if (collapsible) closeItem(m);
      } else {
        if (!multiple) map.forEach((x) => { if (x !== m) closeItem(x); });
        openItem(m);
      }
      shad.util.emit(root, "shad:change", {
        value: multiple ? openValues() : (openValues()[0] || null)
      });
    }

    map.forEach((m) => {
      m.trigger.addEventListener("click", () => toggle(m));
    });
    const rove = shad.roving(root, {
      selector: ".shad-accordion__trigger",
      orientation: "vertical",
      loop: false
    });

    return {
      getValue() { return multiple ? openValues() : (openValues()[0] || null); },
      setValue(v) {
        const wanted = multiple ? (Array.isArray(v) ? v : [v]) : [v];
        map.forEach((m) => {
          wanted.includes(m.value) ? openItem(m) : closeItem(m);
        });
        shad.util.emit(root, "shad:change", {
          value: multiple ? openValues() : (openValues()[0] || null)
        });
      },
      destroy() { rove.destroy(); }
    };
  });
})();

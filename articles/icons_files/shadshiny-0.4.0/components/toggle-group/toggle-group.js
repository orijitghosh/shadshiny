/* FILE: inst/assets/components/toggle-group/toggle-group.js */
/* shadshiny — toggle group behavior.
   Markup: <div data-shad="toggle-group" data-type="single|multiple">
             <button class="shad-toggle" data-value="a">…
   Value: single -> string|null; multiple -> array of strings.
   Roving tabindex, horizontal arrows. */
(function () {
  "use strict";
  shad.register("toggle-group", function (el) {
    const ITEM = ".shad-toggle";
    const multiple = el.getAttribute("data-type") === "multiple";
    let value = multiple ? [] : null;

    // seed from markup
    el.querySelectorAll(ITEM + '[data-state="on"]').forEach((it) => {
      const v = it.getAttribute("data-value");
      if (multiple) value.push(v); else if (value == null) value = v;
    });

    function items() { return Array.from(el.querySelectorAll(ITEM)); }
    function isOn(v) { return multiple ? value.includes(v) : value === v; }
    function render() {
      items().forEach((it) => {
        const on = isOn(it.getAttribute("data-value"));
        it.setAttribute("data-state", on ? "on" : "off");
        it.setAttribute("aria-pressed", String(on));
      });
    }
    function emit() {
      shad.util.emit(el, "shad:change", { value: multiple ? value.slice() : value });
    }
    function toggleItem(v) {
      if (multiple) {
        value = value.includes(v) ? value.filter((x) => x !== v) : value.concat(v);
      } else {
        value = value === v ? null : v;
      }
      render();
      emit();
    }
    function onClick(ev) {
      const item = ev.target.closest(ITEM);
      if (!item || !el.contains(item)) return;
      if (item.hasAttribute("data-disabled") || item.disabled) return;
      toggleItem(item.getAttribute("data-value"));
    }

    if (!el.hasAttribute("role")) el.setAttribute("role", "group");
    render();
    el.addEventListener("click", onClick);
    const rover = shad.roving(el, {
      selector: ITEM + ":not([data-disabled]):not(:disabled)",
      orientation: el.getAttribute("data-orientation") === "vertical" ? "vertical" : "horizontal",
      loop: true
    });

    return {
      getValue() { return multiple ? value.slice() : value; },
      setValue(v) {
        const next = multiple ? (Array.isArray(v) ? v.slice() : [v].filter(Boolean)) : v;
        const same = multiple
          ? next.length === value.length && next.every((x) => value.includes(x))
          : next === value;
        if (same) return;
        value = next;
        render();
        emit();
      },
      destroy() {
        el.removeEventListener("click", onClick);
        rover.destroy();
      }
    };
  });
})();

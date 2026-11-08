/* FILE: inst/assets/components/radio-group/radio-group.js */
/* shadshiny – radio group behavior (APG radio pattern).
   Markup: <div data-shad="radio-group" role="radiogroup">
             <button class="shad-radio" role="radio" data-value="a">…
   Arrow keys move AND select (APG). Roving tabindex. */
(function () {
  "use strict";
  shad.register("radio-group", function (el) {
    const ITEM = ".shad-radio";
    let value = null;

    // initial value: item with data-state=checked
    const initial = el.querySelector(ITEM + '[data-state="checked"]');
    if (initial) value = initial.getAttribute("data-value");

    function items() { return Array.from(el.querySelectorAll(ITEM)); }
    function render() {
      items().forEach((it) => {
        const checked = it.getAttribute("data-value") === value && value != null;
        it.setAttribute("data-state", checked ? "checked" : "unchecked");
        it.setAttribute("aria-checked", String(checked));
      });
    }
    function set(v, emit) {
      if (v === value) return;
      value = v;
      render();
      if (emit !== false) shad.util.emit(el, "shad:change", { value });
    }

    if (!el.hasAttribute("role")) el.setAttribute("role", "radiogroup");
    items().forEach((it) => { if (!it.hasAttribute("role")) it.setAttribute("role", "radio"); });
    render();

    const orientation = el.getAttribute("data-orientation") === "horizontal"
      ? "horizontal" : "vertical";
    // APG: arrows both move focus AND select
    const rover = shad.roving(el, {
      selector: ITEM + ':not([data-disabled]):not(:disabled)',
      orientation: "both",  // shadcn allows both axes regardless of layout
      loop: true,
      onActivate(item) { set(item.getAttribute("data-value")); }
    });
    function onFocusIn(ev) {
      const item = ev.target.closest(ITEM);
      if (item && ev.target.matches(":focus-visible") === false) return;
      // select on arrow-move focus (but not on initial Tab-in to checked item)
    }
    function onKeydownSelect(ev) {
      // after roving moved focus with arrows, select the focused item
      if (["ArrowUp", "ArrowDown", "ArrowLeft", "ArrowRight"].includes(ev.key)) {
        const active = document.activeElement;
        if (active && active.matches && active.matches(ITEM)) {
          set(active.getAttribute("data-value"));
        }
      }
    }
    function onClick(ev) {
      const item = ev.target.closest(ITEM);
      if (!item || item.hasAttribute("data-disabled") || item.disabled) return;
      ev.preventDefault();
      set(item.getAttribute("data-value"));
      rover.setActive(item);
    }
    el.addEventListener("click", onClick);
    // keyup, so roving's keydown focus-move has already happened
    el.addEventListener("keyup", onKeydownSelect);
    el.addEventListener("focusin", onFocusIn);

    // ensure checked item is the tab stop
    const checkedEl = el.querySelector(ITEM + '[data-state="checked"]');
    if (checkedEl) rover.setActive(checkedEl, false);

    return {
      getValue() { return value; },
      setValue(v) {
        set(v);
        const it = el.querySelector(ITEM + '[data-value="' + CSS.escape(String(v)) + '"]');
        if (it) rover.setActive(it, false);
      },
      destroy() {
        rover.destroy();
        el.removeEventListener("click", onClick);
        el.removeEventListener("keyup", onKeydownSelect);
        el.removeEventListener("focusin", onFocusIn);
      }
    };
  });
})();

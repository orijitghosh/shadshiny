/* FILE: inst/assets/components/scroll-area/scroll-area.js */
/* shadshiny — scroll-area behavior. Syncs custom thumbs to native scroll;
   thumb drag scrolls; scrollbars fade in on hover/scroll, out after 800ms. */
(function () {
  "use strict";
  shad.register("scroll-area", function (root) {
    const viewport = root.querySelector(".shad-scroll-area__viewport");
    const bars = Array.from(root.querySelectorAll(".shad-scroll-area__scrollbar"));
    let hideTimer = null;
    let ro = null;

    function syncBar(bar) {
      const vertical = bar.getAttribute("data-orientation") !== "horizontal";
      const thumb = bar.querySelector(".shad-scroll-area__thumb");
      const scrollSize = vertical ? viewport.scrollHeight : viewport.scrollWidth;
      const clientSize = vertical ? viewport.clientHeight : viewport.clientWidth;
      if (scrollSize <= clientSize + 1) { bar.style.display = "none"; return; }
      bar.style.display = "";
      const trackSize = vertical ? bar.clientHeight : bar.clientWidth;
      const thumbSize = Math.max(24, (clientSize / scrollSize) * trackSize);
      const maxScroll = scrollSize - clientSize;
      const scrollPos = vertical ? viewport.scrollTop : viewport.scrollLeft;
      const maxThumb = trackSize - thumbSize;
      const pos = maxScroll > 0 ? (scrollPos / maxScroll) * maxThumb : 0;
      if (vertical) {
        thumb.style.height = Math.round(thumbSize) + "px";
        thumb.style.transform = "translateY(" + Math.round(pos) + "px)";
        thumb.style.flex = "none";
      } else {
        thumb.style.width = Math.round(thumbSize) + "px";
        thumb.style.transform = "translateX(" + Math.round(pos) + "px)";
        thumb.style.flex = "none";
      }
    }
    function syncAll() { bars.forEach(syncBar); }
    function flash() {
      bars.forEach((b) => b.setAttribute("data-state", "visible"));
      clearTimeout(hideTimer);
      hideTimer = setTimeout(() => {
        bars.forEach((b) => b.removeAttribute("data-state"));
      }, 800);
    }
    function onScroll() { syncAll(); flash(); }

    /* thumb drag */
    bars.forEach((bar) => {
      const vertical = bar.getAttribute("data-orientation") !== "horizontal";
      const thumb = bar.querySelector(".shad-scroll-area__thumb");
      let drag = null;
      thumb.addEventListener("pointerdown", (ev) => {
        ev.preventDefault();
        drag = {
          start: vertical ? ev.clientY : ev.clientX,
          scrollStart: vertical ? viewport.scrollTop : viewport.scrollLeft
        };
        bar.setAttribute("data-dragging", "");
        thumb.setPointerCapture(ev.pointerId);
      });
      thumb.addEventListener("pointermove", (ev) => {
        if (!drag) return;
        const delta = (vertical ? ev.clientY : ev.clientX) - drag.start;
        const scrollSize = vertical ? viewport.scrollHeight : viewport.scrollWidth;
        const clientSize = vertical ? viewport.clientHeight : viewport.clientWidth;
        const trackSize = vertical ? bar.clientHeight : bar.clientWidth;
        const ratio = scrollSize / trackSize;
        if (vertical) viewport.scrollTop = drag.scrollStart + delta * ratio;
        else viewport.scrollLeft = drag.scrollStart + delta * ratio;
      });
      const end = (ev) => {
        if (!drag) return;
        drag = null;
        bar.removeAttribute("data-dragging");
        try { thumb.releasePointerCapture(ev.pointerId); } catch (e) {}
      };
      thumb.addEventListener("pointerup", end);
      thumb.addEventListener("pointercancel", end);
      // click on track jumps a page
      bar.addEventListener("pointerdown", (ev) => {
        if (ev.target !== bar) return;
        const rect = bar.getBoundingClientRect();
        const clickPos = vertical ? ev.clientY - rect.top : ev.clientX - rect.left;
        const thumbRect = thumb.getBoundingClientRect();
        const thumbPos = vertical ? thumbRect.top - rect.top : thumbRect.left - rect.left;
        const dir = clickPos < thumbPos ? -1 : 1;
        const clientSize = vertical ? viewport.clientHeight : viewport.clientWidth;
        if (vertical) viewport.scrollTop += dir * clientSize;
        else viewport.scrollLeft += dir * clientSize;
      });
    });

    viewport.addEventListener("scroll", onScroll, { passive: true });
    ro = new ResizeObserver(syncAll);
    ro.observe(viewport);
    Array.from(viewport.children).forEach((c) => ro.observe(c));
    syncAll();

    return {
      getValue() { return { top: viewport.scrollTop, left: viewport.scrollLeft }; },
      setValue(v) {
        if (v && typeof v === "object") {
          if (v.top != null) viewport.scrollTop = v.top;
          if (v.left != null) viewport.scrollLeft = v.left;
        }
      },
      refresh: syncAll,
      destroy() {
        viewport.removeEventListener("scroll", onScroll);
        clearTimeout(hideTimer);
        if (ro) ro.disconnect();
      }
    };
  });
})();

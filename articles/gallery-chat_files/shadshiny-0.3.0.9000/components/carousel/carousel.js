/* FILE: inst/assets/components/carousel/carousel.js */
/* shadshiny — carousel behavior. Scroll-snap native scrolling; JS adds
   prev/next paging, generated dots, index tracking via scroll position,
   and arrow-key support. getValue()/setValue() and the shad:change payload
   are 1-based slide numbers (the R contract); `index` is 0-based internally. */
(function () {
  "use strict";
  shad.register("carousel", function (root) {
    const viewport = root.querySelector(".shad-carousel__viewport");
    const track = root.querySelector(".shad-carousel__track");
    const prev = root.querySelector(".shad-carousel__prev");
    const next = root.querySelector(".shad-carousel__next");
    const dotsWrap = root.querySelector(".shad-carousel__dots");
    let index = 0;
    let dots = [];
    let programmatic = false; // suppress the settle-emit after goTo() self-reports

    root.setAttribute("aria-roledescription", "carousel");
    function slides() {
      return Array.from(track.querySelectorAll(":scope > .shad-carousel__slide"));
    }
    slides().forEach((s, i, arr) => {
      s.setAttribute("role", "group");
      s.setAttribute("aria-roledescription", "slide");
      s.setAttribute("aria-label", (i + 1) + " of " + arr.length);
    });

    function buildDots() {
      if (!dotsWrap) return;
      dotsWrap.innerHTML = "";
      dots = slides().map((_, i) => {
        const b = document.createElement("button");
        b.type = "button";
        b.className = "shad-carousel__dot";
        b.setAttribute("aria-label", "Go to slide " + (i + 1));
        b.addEventListener("click", () => goTo(i));
        dotsWrap.appendChild(b);
        return b;
      });
    }
    function currentIndex() {
      const all = slides();
      if (!all.length) return 0;
      const x = viewport.scrollLeft;
      let best = 0, bestDist = Infinity;
      all.forEach((s, i) => {
        const d = Math.abs(s.offsetLeft - x);
        if (d < bestDist) { bestDist = d; best = i; }
      });
      return best;
    }
    function sync(fire) {
      const all = slides();
      const newIndex = currentIndex();
      const changed = newIndex !== index;
      index = newIndex;
      const maxScroll = viewport.scrollWidth - viewport.clientWidth;
      if (prev) prev.toggleAttribute("data-disabled", viewport.scrollLeft <= 1);
      if (next) next.toggleAttribute("data-disabled", viewport.scrollLeft >= maxScroll - 1);
      dots.forEach((d, i) => {
        d.setAttribute("data-state", i === index ? "active" : "inactive");
      });
      if (fire && changed) shad.util.emit(root, "shad:change", { value: index + 1 });
    }
    function goTo(i) {
      const all = slides();
      if (!all.length) return;
      i = shad.util.clamp(i, 0, all.length - 1);
      const changed = i !== index;
      index = i;
      dots.forEach((d, j) => {
        d.setAttribute("data-state", j === index ? "active" : "inactive");
      });
      // Report immediately: the smooth scroll settles asynchronously, but the
      // value is already known — this keeps server-driven navigation and tests
      // deterministic instead of waiting on the scroll animation.
      programmatic = true;
      viewport.scrollTo({ left: all[i].offsetLeft, behavior: "smooth" });
      if (changed) shad.util.emit(root, "shad:change", { value: index + 1 });
    }

    let scrollTimer = null;
    function onScroll() {
      clearTimeout(scrollTimer);
      scrollTimer = setTimeout(() => {
        // A programmatic goTo() already emitted; just reconcile dots/disabled.
        if (programmatic) { programmatic = false; sync(false); } else sync(true);
      }, 80); // settle after snap
    }
    function onPrev() { goTo(index - 1); }
    function onNext() { goTo(index + 1); }
    function onKeydown(ev) {
      const rtl = shad.util.direction(root) === "rtl";
      if (ev.key === "ArrowLeft") {
        ev.preventDefault(); rtl ? onNext() : onPrev();
      }
      if (ev.key === "ArrowRight") {
        ev.preventDefault(); rtl ? onPrev() : onNext();
      }
    }

    viewport.addEventListener("scroll", onScroll, { passive: true });
    viewport.setAttribute("tabindex", "0");
    viewport.addEventListener("keydown", onKeydown);
    if (prev) prev.addEventListener("click", onPrev);
    if (next) next.addEventListener("click", onNext);
    buildDots();
    sync(false);

    return {
      getValue() { return index + 1; },
      setValue(i) { goTo(parseInt(i, 10) - 1); },
      next: onNext, prev: onPrev,
      refresh() { buildDots(); sync(false); },
      destroy() {
        viewport.removeEventListener("scroll", onScroll);
        viewport.removeEventListener("keydown", onKeydown);
        if (prev) prev.removeEventListener("click", onPrev);
        if (next) next.removeEventListener("click", onNext);
        clearTimeout(scrollTimer);
      }
    };
  });
})();

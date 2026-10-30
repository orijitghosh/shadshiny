/* FILE: inst/assets/components/message-scroller/message-scroller.js */
/* shadshiny — message-scroller behavior.
   Markup:
     <div data-shad="message-scroller" class="shad-message-scroller"
          data-auto-scroll data-default-position="end">
       <div class="shad-message-scroller__viewport" aria-live="polite">
         <div class="shad-message-scroller__content">
           <div class="shad-message-scroller__item" [data-anchor]>…</div>
         </div>
       </div>
       <button class="shad-message-scroller__button">…</button>
     </div>
   Behavior:
   - Follows the bottom ONLY while the user is at the bottom; scrolling up,
     selecting text, or keyboard scrolling detaches.
   - New content while detached never moves the viewport; the jump button
     appears instead.
   - Prepended history preserves the scroll anchor (no visual shift).
   Options (data-attributes on the root):
   - data-auto-scroll="false"  — never auto-follow (default true)
   - data-default-position="start|end|last-anchor" (default "end")
   - data-anchor on items marks turn boundaries for "last-anchor". */
(function () {
  "use strict";

  const BOTTOM_THRESHOLD = 32; // px slack that still counts as "at bottom"

  shad.register("message-scroller", function (el) {
    const viewport = el.querySelector(".shad-message-scroller__viewport");
    const content = el.querySelector(".shad-message-scroller__content");
    const button = el.querySelector(".shad-message-scroller__button");
    if (!viewport || !content) return {};

    const autoScroll = el.getAttribute("data-auto-scroll") !== "false";
    const defaultPosition = el.getAttribute("data-default-position") || "end";
    const reducedMotion = window.matchMedia("(prefers-reduced-motion: reduce)");

    let following = autoScroll && defaultPosition === "end";
    let programmatic = false;       // ignore scroll events we caused ourselves
    let lastScrollHeight = 0;
    let knownFirst = content.firstElementChild;

    function atBottom() {
      return viewport.scrollHeight - viewport.scrollTop - viewport.clientHeight
        <= BOTTOM_THRESHOLD;
    }

    function update() {
      el.setAttribute("data-state", following ? "following" : "detached");
      if (button) button.toggleAttribute("data-visible", !following && !atBottom());
    }

    function jump(smooth) {
      programmatic = true;
      viewport.scrollTo({
        top: viewport.scrollHeight,
        behavior: smooth && !reducedMotion.matches ? "smooth" : "auto"
      });
    }

    function scrollToBottom(smooth) {
      following = true; // explicit jump always re-attaches
      jump(smooth !== false);
      update();
    }

    /* ---- user scrolling ---- */
    function onScroll() {
      if (programmatic) {
        // smooth programmatic scrolls fire many events; release the guard
        // once the bottom is reached
        if (atBottom()) programmatic = false;
        lastScrollHeight = viewport.scrollHeight;
        return;
      }
      following = atBottom();
      lastScrollHeight = viewport.scrollHeight;
      update();
    }
    /* explicit user intent detaches immediately (before scroll settles) */
    function onWheel(ev) { if (ev.deltaY < 0) { following = false; update(); } }
    function onKeydown(ev) {
      if (["ArrowUp", "PageUp", "Home"].includes(ev.key)) { following = false; update(); }
      if (ev.key === "End" && ev.target === viewport) { scrollToBottom(false); }
    }
    function onSelect() {
      const sel = document.getSelection();
      if (sel && !sel.isCollapsed && viewport.contains(sel.anchorNode)) {
        following = false; update();
      }
    }

    /* ---- content growth / shrink ---- */
    function onContentResize() {
      if (following && autoScroll) {
        jump(false);
      } else if (button) {
        update(); // content changed while detached → surface the button
      }
      lastScrollHeight = viewport.scrollHeight;
    }

    /* prepended history: keep the previously-visible content in place */
    function onMutations() {
      const first = content.firstElementChild;
      const prepended = first && first !== knownFirst &&
        knownFirst && knownFirst.isConnected;
      if (prepended && !following) {
        const delta = viewport.scrollHeight - lastScrollHeight;
        if (delta > 0) {
          programmatic = true;
          viewport.scrollTop += delta;
          requestAnimationFrame(() => { programmatic = false; });
        }
      }
      knownFirst = first;
      lastScrollHeight = viewport.scrollHeight;
    }

    const resizeObserver = new ResizeObserver(onContentResize);
    resizeObserver.observe(content);
    const mutationObserver = new MutationObserver(onMutations);
    mutationObserver.observe(content, { childList: true });

    viewport.addEventListener("scroll", onScroll, { passive: true });
    viewport.addEventListener("wheel", onWheel, { passive: true });
    viewport.addEventListener("keydown", onKeydown);
    document.addEventListener("selectionchange", onSelect);
    if (button) button.addEventListener("click", () => scrollToBottom(true));

    /* ---- initial position ---- */
    requestAnimationFrame(() => {
      if (defaultPosition === "end") {
        jump(false);
      } else if (defaultPosition === "last-anchor") {
        const anchors = content.querySelectorAll("[data-anchor]");
        const target = anchors[anchors.length - 1];
        if (target) {
          programmatic = true;
          viewport.scrollTop = target.offsetTop - content.offsetTop;
          requestAnimationFrame(() => { programmatic = false; });
        }
        following = false;
      } else {
        following = false; // "start": stay at the top
      }
      lastScrollHeight = viewport.scrollHeight;
      update();
    });

    return {
      /* position state — consumed by the Shiny binding as the input value */
      getValue() {
        return {
          following: following,
          atBottom: atBottom(),
          scrollTop: viewport.scrollTop
        };
      },
      /* setValue("end") re-attaches + scrolls; setValue("start") detaches
         + scrolls to top. Exposed for shadshiny:invoke symmetry. */
      setValue(v) {
        if (v === "end") scrollToBottom(false);
        else if (v === "start") {
          following = false;
          programmatic = true;
          viewport.scrollTop = 0;
          requestAnimationFrame(() => { programmatic = false; });
          update();
        }
      },
      /* callable through the shadshiny:invoke channel */
      scrollToBottom(smooth) { scrollToBottom(smooth); },
      destroy() {
        resizeObserver.disconnect();
        mutationObserver.disconnect();
        viewport.removeEventListener("scroll", onScroll);
        viewport.removeEventListener("wheel", onWheel);
        viewport.removeEventListener("keydown", onKeydown);
        document.removeEventListener("selectionchange", onSelect);
      }
    };
  });
})();

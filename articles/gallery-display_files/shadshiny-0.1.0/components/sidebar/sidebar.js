/* FILE: inst/assets/components/sidebar/sidebar.js */
/* shadshiny — sidebar behavior.
   Desktop (≥768px): trigger toggles data-collapsed (icon rail).
   Mobile (<768px): trigger opens off-canvas sheet (data-mobile-open) with
   overlay + dismiss layer + focus trap.
   getValue() -> {collapsed, mobileOpen, active}. Active item tracked from
   clicks on .shad-sidebar__item[data-value]. */
(function () {
  "use strict";
  const MOBILE_QUERY = "(max-width: 767.98px)";

  shad.register("sidebar", function (root) {
    // root = layout wrapper (data-shad="sidebar" on .shad-sidebar-layout)
    const sidebar = root.querySelector(".shad-sidebar");
    const overlay = root.querySelector(".shad-sidebar__overlay");
    const triggers = Array.from(root.querySelectorAll(".shad-sidebar__trigger"));
    const mql = window.matchMedia(MOBILE_QUERY);

    let collapsed = sidebar.hasAttribute("data-collapsed");
    let mobileOpen = false;
    let active = null;
    let disposeDismiss = null, releaseTrap = null;

    if (overlay) overlay.hidden = true;
    const initActive = sidebar.querySelector('.shad-sidebar__item[data-state="active"]');
    if (initActive) active = initActive.dataset.value || null;

    function setCollapsed(v, fire) {
      collapsed = !!v;
      sidebar.toggleAttribute("data-collapsed", collapsed);
      triggers.forEach((t) => t.setAttribute("aria-expanded", collapsed ? "false" : "true"));
      if (fire !== false) emit();
    }
    function openMobile() {
      if (mobileOpen) return;
      mobileOpen = true;
      sidebar.setAttribute("data-mobile-open", "");
      if (overlay) {
        overlay.hidden = false;
        void overlay.offsetWidth;
        overlay.setAttribute("data-state", "open");
      }
      shad.scrollLock.lock();
      releaseTrap = shad.focusTrap(sidebar);
      disposeDismiss = shad.dismiss.push({ el: sidebar, onDismiss: closeMobile });
      shad.util.emit(root, "shad:open", {});
      emit();
    }
    function closeMobile() {
      if (!mobileOpen) return;
      mobileOpen = false;
      sidebar.removeAttribute("data-mobile-open");
      if (disposeDismiss) { disposeDismiss(); disposeDismiss = null; }
      if (releaseTrap) { releaseTrap(); releaseTrap = null; }
      shad.scrollLock.unlock();
      if (overlay) {
        overlay.setAttribute("data-state", "closed");
        setTimeout(() => { if (!mobileOpen) overlay.hidden = true; }, 300);
      }
      shad.util.emit(root, "shad:close", {});
      emit();
    }
    function toggle() {
      if (mql.matches) mobileOpen ? closeMobile() : openMobile();
      else setCollapsed(!collapsed);
    }
    function emit() {
      shad.util.emit(root, "shad:change", {
        value: { collapsed, mobileOpen, active }
      });
    }

    triggers.forEach((t) => {
      t.setAttribute("aria-label", t.getAttribute("aria-label") || "Toggle sidebar");
      t.setAttribute("aria-expanded", collapsed ? "false" : "true");
      t.addEventListener("click", toggle);
    });

    // active item tracking
    function onItemClick(ev) {
      const item = ev.target.closest(".shad-sidebar__item");
      if (!item || !sidebar.contains(item)) return;
      sidebar.querySelectorAll(".shad-sidebar__item").forEach((it) => {
        it.setAttribute("data-state", it === item ? "active" : "inactive");
      });
      active = item.dataset.value || (item.textContent || "").trim();
      if (mql.matches) closeMobile();
      emit();
    }
    sidebar.addEventListener("click", onItemClick);

    // leaving mobile width closes the sheet cleanly
    function onMql() { if (!mql.matches) closeMobile(); }
    mql.addEventListener("change", onMql);

    // keyboard shortcut: Ctrl/Cmd+B toggles (shadcn sidebar default)
    function onKeydown(ev) {
      if ((ev.metaKey || ev.ctrlKey) && ev.key.toLowerCase() === "b") {
        ev.preventDefault();
        toggle();
      }
    }
    document.addEventListener("keydown", onKeydown);

    return {
      getValue() { return { collapsed, mobileOpen, active }; },
      setValue(v) {
        if (v && typeof v === "object") {
          if (v.collapsed != null) setCollapsed(v.collapsed);
          if (v.mobileOpen != null) (v.mobileOpen ? openMobile() : closeMobile());
        }
      },
      open: openMobile, close: closeMobile,
      get isOpen() { return mobileOpen; },
      toggleCollapsed() { setCollapsed(!collapsed); },
      destroy() {
        closeMobile();
        triggers.forEach((t) => t.removeEventListener("click", toggle));
        sidebar.removeEventListener("click", onItemClick);
        mql.removeEventListener("change", onMql);
        document.removeEventListener("keydown", onKeydown);
      }
    };
  });
})();

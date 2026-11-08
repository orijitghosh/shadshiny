/* FILE: inst/assets/components/toast/toast.js */
/* shadshiny – toast system (sonner-style), IMPERATIVE API (no data-shad).
   API:
     shad.toast(message | {title, description, variant, duration, action:{label,onClick}})
       -> id
     shad.toast.success/error/warning/loading(message, opts?) -> id
     shad.toast.update(id, opts)      // e.g. flip loading -> success
     shad.toast.dismiss(id?)          // no id = dismiss all
     shad.toast.promise(p, {loading, success, error}) -> p
   Decisions: max 3 visible collapsed (rest hidden in stack, still queued);
   default duration 5000ms (loading: none until updated); hover pauses ALL
   timers + fans the stack; swipe right > 80px or velocity > 0.3 px/ms
   dismisses. Container is created lazily, bottom-right. */
(function () {
  "use strict";
  const DEFAULT_DURATION = 5000;
  const MAX_VISIBLE = 3;
  const ICONS = {
    success: '<svg class="shad-toast__icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="12" cy="12" r="10"/><path d="m9 12 2 2 4-4"/></svg>',
    error: '<svg class="shad-toast__icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="12" cy="12" r="10"/><path d="m15 9-6 6"/><path d="m9 9 6 6"/></svg>',
    warning: '<svg class="shad-toast__icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m21.73 18-8-14a2 2 0 0 0-3.48 0l-8 14A2 2 0 0 0 4 21h16a2 2 0 0 0 1.73-3"/><path d="M12 9v4"/><path d="M12 17h.01"/></svg>',
    loading: '<svg class="shad-toast__icon shad-animate-spin" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M21 12a9 9 0 1 1-6.219-8.56"/></svg>'
  };

  let container = null;
  const toasts = new Map(); // id -> {el, timer, remaining, startedAt, duration}

  function ensureContainer() {
    if (container && container.isConnected) return container;
    container = document.createElement("div");
    container.className = "shad-toaster";
    container.setAttribute("aria-live", "polite");
    container.setAttribute("aria-label", "Notifications");
    container.addEventListener("pointerenter", () => {
      container.setAttribute("data-expanded", "");
      pauseAll();
      layout();
    });
    container.addEventListener("pointerleave", () => {
      container.removeAttribute("data-expanded");
      resumeAll();
      layout();
    });
    document.body.appendChild(container);
    return container;
  }

  /* stack layout: front toast (newest) is index 0. Collapsed: transforms via
     --shad-toast-index. Expanded: per-toast Y offset so cards fan upward. */
  function layout() {
    const list = Array.from(container.querySelectorAll(".shad-toast"))
      .filter((el) => el.getAttribute("data-state") !== "closed")
      .reverse(); // newest first
    const expanded = container.hasAttribute("data-expanded");
    const frontH = list.length ? list[0].offsetHeight : 0;
    container.style.height = expanded
      ? list.reduce((s, el) => s + el.offsetHeight + 8, 0) + "px"
      : (frontH + (Math.min(list.length, MAX_VISIBLE) - 1) * 12) + "px";
    let offset = 0;
    list.forEach((el, i) => {
      el.setAttribute("data-stacked", "");
      el.style.setProperty("--shad-toast-index", String(Math.min(i, MAX_VISIBLE - 1)));
      if (i >= MAX_VISIBLE && !expanded) el.setAttribute("data-hidden-in-stack", "");
      else el.removeAttribute("data-hidden-in-stack");
      el.style.setProperty("--shad-toast-offset", "-" + offset + "px");
      offset += el.offsetHeight + 8;
    });
  }

  function startTimer(id) {
    const t = toasts.get(id);
    if (!t || t.duration == null) return;
    clearTimeout(t.timer);
    t.startedAt = Date.now();
    t.timer = setTimeout(() => dismiss(id), t.remaining);
  }
  function pauseAll() {
    toasts.forEach((t) => {
      if (t.timer) {
        clearTimeout(t.timer);
        t.timer = null;
        t.remaining -= Date.now() - t.startedAt;
      }
    });
  }
  function resumeAll() {
    toasts.forEach((t, id) => {
      if (t.duration != null && !t.timer) startTimer(id);
    });
  }

  function normalize(msg, extra) {
    const o = typeof msg === "string" ? { title: msg } : Object.assign({}, msg);
    return Object.assign(o, extra || {});
  }

  function render(el, o) {
    el.className = "shad-toast" + (o.variant && o.variant !== "default"
      ? " shad-toast--" + o.variant : "");
    let html = "";
    if (o.variant && ICONS[o.variant]) html += ICONS[o.variant];
    html += '<div class="shad-toast__body">';
    if (o.title) html += '<div class="shad-toast__title"></div>';
    if (o.description) html += '<div class="shad-toast__description"></div>';
    html += "</div>";
    if (o.action) html += '<button type="button" class="shad-toast__action"></button>';
    html += '<button type="button" class="shad-toast__close" aria-label="Dismiss">' +
      '<svg class="shad-icon shad-icon--sm" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M18 6 6 18"/><path d="m6 6 12 12"/></svg></button>';
    el.innerHTML = html;
    // text via textContent (never trust message strings as HTML)
    if (o.title) el.querySelector(".shad-toast__title").textContent = o.title;
    if (o.description) el.querySelector(".shad-toast__description").textContent = o.description;
    if (o.action) {
      const btn = el.querySelector(".shad-toast__action");
      btn.textContent = o.action.label;
      btn.addEventListener("click", () => {
        if (o.action.onClick) o.action.onClick();
        dismiss(el.__shadToastId);
      });
    }
    el.querySelector(".shad-toast__close")
      .addEventListener("click", () => dismiss(el.__shadToastId));
  }

  function attachSwipe(el, id) {
    let drag = null;
    el.addEventListener("pointerdown", (ev) => {
      if (ev.target.closest("button")) return;
      drag = { startX: ev.clientX, lastX: ev.clientX, lastT: ev.timeStamp, v: 0 };
      el.setAttribute("data-swiping", "");
      el.setPointerCapture(ev.pointerId);
    });
    el.addEventListener("pointermove", (ev) => {
      if (!drag) return;
      const dt = ev.timeStamp - drag.lastT || 1;
      drag.v = (ev.clientX - drag.lastX) / dt;
      drag.lastX = ev.clientX;
      drag.lastT = ev.timeStamp;
      let dx = ev.clientX - drag.startX;
      if (dx < 0) dx = dx / 4; // resist left
      el.style.translate = dx + "px 0";
      el.style.opacity = String(1 - Math.max(0, dx) / 300);
    });
    const end = (ev) => {
      if (!drag) return;
      const dx = drag.lastX - drag.startX;
      const go = dx > 80 || drag.v > 0.3;
      el.removeAttribute("data-swiping");
      try { el.releasePointerCapture(ev.pointerId); } catch (e) {}
      drag = null;
      if (go) dismiss(id);
      else { el.style.translate = ""; el.style.opacity = ""; }
    };
    el.addEventListener("pointerup", end);
    el.addEventListener("pointercancel", end);
  }

  function toast(msg, extra) {
    const o = normalize(msg, extra);
    const id = shad.uid("toast");
    ensureContainer();
    const el = document.createElement("div");
    el.__shadToastId = id;
    el.setAttribute("role", o.variant === "error" ? "alert" : "status");
    render(el, o);
    container.appendChild(el);
    attachSwipe(el, id);
    shad.presence.show(el);
    const duration = o.duration !== undefined ? o.duration :
      (o.variant === "loading" ? null : DEFAULT_DURATION);
    toasts.set(id, {
      el, timer: null, duration,
      remaining: duration == null ? Infinity : duration,
      startedAt: Date.now(), opts: o
    });
    if (duration != null && !container.hasAttribute("data-expanded")) startTimer(id);
    layout();
    return id;
  }

  function update(id, opts) {
    const t = toasts.get(id);
    if (!t) return;
    t.opts = normalize(t.opts, opts);
    render(t.el, t.opts);
    // re-arm timer with new duration semantics
    clearTimeout(t.timer); t.timer = null;
    t.duration = opts.duration !== undefined ? opts.duration :
      (t.opts.variant === "loading" ? null : DEFAULT_DURATION);
    t.remaining = t.duration == null ? Infinity : t.duration;
    if (t.duration != null && !container.hasAttribute("data-expanded")) startTimer(id);
    layout();
  }

  function dismiss(id) {
    if (id == null) { Array.from(toasts.keys()).forEach(dismiss); return; }
    const t = toasts.get(id);
    if (!t) return;
    clearTimeout(t.timer);
    toasts.delete(id);
    t.el.removeAttribute("data-stacked"); // exit in place
    shad.presence.hide(t.el, () => {
      t.el.remove();
      layout();
    });
    layout();
  }

  toast.success = (m, o) => toast(normalize(m, o), { variant: "success" });
  toast.error = (m, o) => toast(normalize(m, o), { variant: "error" });
  toast.warning = (m, o) => toast(normalize(m, o), { variant: "warning" });
  toast.loading = (m, o) => toast(normalize(m, o), { variant: "loading" });
  toast.update = update;
  toast.dismiss = dismiss;
  toast.promise = function (p, msgs) {
    const id = toast(normalize(msgs.loading || "Loading…"), { variant: "loading" });
    Promise.resolve(p).then(
      (val) => update(id, normalize(
        typeof msgs.success === "function" ? msgs.success(val) : (msgs.success || "Done"),
        { variant: "success" })),
      (err) => update(id, normalize(
        typeof msgs.error === "function" ? msgs.error(err) : (msgs.error || "Error"),
        { variant: "error" }))
    );
    return p;
  };

  shad.toast = toast;
})();

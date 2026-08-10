/* FILE: inst/assets/shiny/shadshiny-shiny.js */
/* ==========================================================================
   shadshiny — Shiny input bindings + custom message handlers
   --------------------------------------------------------------------------
   Loads LAST (after core/shad-runtime.js and every component JS). Builds one
   generic InputBinding per stateful component on top of the uniform contract:
     shad.get(el) -> {getValue, setValue, [open/close/isOpen], destroy}
     root dispatches 'shad:change' {detail:{value}}, plus 'shad:open'/'shad:close'.

   No-value components (tooltip, hover-card, scroll-area) and the imperative
   toast system get no binding. input/textarea use Shiny's native text bindings
   (the assets render real <input>/<textarea> elements), so they are excluded
   here too.
   ========================================================================== */
(function () {
  "use strict";

  var hasShiny = typeof window !== "undefined" && window.Shiny && Shiny.InputBinding;

  /* ----------------------------------------------------------------------
     Custom message handlers work with or without a rendered binding, so wire
     them whenever Shiny is present.
     ---------------------------------------------------------------------- */
  if (hasShiny && Shiny.addCustomMessageHandler) {
    Shiny.addCustomMessageHandler("shadshiny:invoke", function (msg) {
      var el = document.getElementById(msg.id);
      var inst = el && window.shad && shad.get(el);
      if (!inst) { console.warn("[shadshiny] invoke: no instance for", msg.id); return; }
      var fn = inst[msg.method];
      if (typeof fn !== "function") { console.warn("[shadshiny] invoke: no method", msg.method); return; }
      fn.apply(inst, msg.args || []);
    });

    Shiny.addCustomMessageHandler("shadshiny:update", function (msg) {
      var el = document.getElementById(msg.id);
      var inst = el && window.shad && shad.get(el);
      if (!inst || typeof inst.setValue !== "function") {
        console.warn("[shadshiny] update: no settable instance for", msg.id); return;
      }
      inst.setValue(msg.value);
    });

    Shiny.addCustomMessageHandler("shadshiny:attr", function (msg) {
      var el = document.getElementById(msg.id);
      if (!el) { console.warn("[shadshiny] attr: no element", msg.id); return; }
      if (msg.value === null || typeof msg.value === "undefined") {
        el.removeAttribute(msg.attr);
      } else if (msg.value === true) {
        el.setAttribute(msg.attr, "");
      } else if (msg.value === false) {
        el.removeAttribute(msg.attr);
      } else {
        el.setAttribute(msg.attr, msg.value);
      }
      // keep the native `disabled` property in sync for form controls
      if (msg.attr === "disabled" && "disabled" in el) {
        el.disabled = !(msg.value === null || msg.value === false);
      }
    });

    Shiny.addCustomMessageHandler("shadshiny:text", function (msg) {
      var el = document.getElementById(msg.id);
      if (!el) { console.warn("[shadshiny] text: no element", msg.id); return; }
      var target = msg.selector ? el.querySelector(msg.selector) : el;
      if (target) target.textContent = msg.text;
    });

    // Set a single inline style property, optionally on a descendant. Used by
    // update_shad_progress (no bound instance) to move the indicator bar.
    // Replace a component's markup (or a region of it) with server-rendered
    // HTML. Goes through Shiny.renderContent so dependencies are registered and
    // any inputs/outputs inside are bound, then gives the component a chance to
    // re-read what changed.
    Shiny.addCustomMessageHandler("shadshiny:html", function (msg) {
      var el = document.getElementById(msg.id);
      if (!el) { console.warn("[shadshiny] html: no element", msg.id); return; }
      var target = msg.selector ? el.querySelector(msg.selector) : el;
      if (!target) { console.warn("[shadshiny] html: no match", msg.selector); return; }
      Shiny.renderContent(target, { html: msg.html, deps: msg.deps || [] });
      var inst = window.shad && shad.get(el);
      if (inst && typeof inst.refresh === "function") inst.refresh();
    });

    Shiny.addCustomMessageHandler("shadshiny:style", function (msg) {
      var el = document.getElementById(msg.id);
      if (!el) { console.warn("[shadshiny] style: no element", msg.id); return; }
      var target = msg.selector ? el.querySelector(msg.selector) : el;
      if (target && msg.prop) target.style.setProperty(msg.prop, msg.value);
    });

    // form-field validation: set/clear an error on the field wrapping a control.
    Shiny.addCustomMessageHandler("shadshiny:formField", function (msg) {
      var control = document.getElementById(msg.id);
      if (!control) { console.warn("[shadshiny] formField: no control", msg.id); return; }
      var field = (control.closest && control.closest(".shad-form-field")) || control.parentElement;
      var msgId = msg.id + "-error";
      if (msg.error) {
        control.setAttribute("aria-invalid", "true");
        control.setAttribute("aria-describedby", msgId);
        if (field) field.setAttribute("data-invalid", "");
        var el = document.getElementById(msgId);
        if (!el) {
          el = document.createElement("div");
          el.id = msgId;
          el.className = "shad-form-message shad-form-message--error";
          (field || control.parentElement).appendChild(el);
        }
        el.textContent = msg.error;
        el.hidden = false;
      } else {
        control.removeAttribute("aria-invalid");
        if (field) field.removeAttribute("data-invalid");
        var old = document.getElementById(msgId);
        if (old) old.parentNode.removeChild(old);
      }
    });

    Shiny.addCustomMessageHandler("shadshiny:theme", function (msg) {
      var root = document.documentElement;
      if (typeof msg.preset !== "undefined" && msg.preset !== null) {
        if (msg.preset === "default") root.removeAttribute("data-shad-theme");
        else root.setAttribute("data-shad-theme", msg.preset);
      }
      if (typeof msg.dark !== "undefined" && msg.dark !== null) {
        if (msg.dark) {
          root.classList.add("dark");
          root.setAttribute("data-bs-theme", "dark");
        } else {
          root.classList.remove("dark");
          root.setAttribute("data-bs-theme", "light");
        }
      }
      // custom theme: write tokens into a managed <style> element.
      if (typeof msg.css !== "undefined" && msg.css !== null) {
        var styleEl = document.getElementById("shad-custom-theme");
        if (!styleEl) {
          styleEl = document.createElement("style");
          styleEl.id = "shad-custom-theme";
          document.head.appendChild(styleEl);
        }
        styleEl.textContent = msg.css;
      }
    });

    // Toast bridge. R can't read shad.toast()'s return id synchronously, so the
    // caller supplies its own id which we map to the internal toast id.
    var toastMap = {};
    Shiny.addCustomMessageHandler("shadshiny:toast", function (msg) {
      if (!window.shad || typeof shad.toast !== "function") {
        console.warn("[shadshiny] toast runtime missing"); return;
      }
      var kind = msg.kind || "default";
      var opts = msg.opts || {};
      // attach the action onClick (functions can't cross sendCustomMessage)
      if (opts.action && opts.action.input) {
        var inputId = opts.action.input;
        opts.action = { label: opts.action.label, onClick: function () {
          if (window.Shiny) Shiny.setInputValue(inputId, Date.now(), { priority: "event" });
        } };
      }
      if (kind === "dismiss") {
        var internal = msg.id ? toastMap[msg.id] : undefined;
        shad.toast.dismiss(typeof internal !== "undefined" ? internal : undefined);
        if (msg.id) delete toastMap[msg.id];
        return;
      }
      if (kind === "update") {
        var tid = msg.id ? toastMap[msg.id] : undefined;
        if (typeof tid !== "undefined") shad.toast.update(tid, opts);
        return;
      }
      var fn = (kind !== "default" && typeof shad.toast[kind] === "function")
        ? shad.toast[kind] : shad.toast;
      var returnedId = (kind !== "default" && shad.toast[kind])
        ? shad.toast[kind](opts.message || opts.title || "", opts)
        : shad.toast(opts);
      if (msg.id) toastMap[msg.id] = returnedId;
    });
  }

  if (!hasShiny) {
    // Static page (kitchen-sink via file://): just make sure components init.
    if (window.shad && typeof shad.autoInit === "function") shad.autoInit();
    return;
  }

  /* ----------------------------------------------------------------------
     Generic binding factory
     ---------------------------------------------------------------------- */
  function makeShadBinding(name, opts) {
    opts = opts || {};
    var binding = new Shiny.InputBinding();

    binding.find = function (scope) {
      return $(scope).find('[data-shad="' + name + '"]');
    };
    binding.getId = function (el) { return el.id; };
    binding.getType = function () { return opts.type || false; };

    function instance(el) {
      if (!window.shad) return null;
      var inst = shad.get(el);
      if (!inst) {                 // race / dynamic insert: init on demand
        shad.init(el);
        inst = shad.get(el);
      }
      return inst || null;
    }

    binding.getValue = function (el) {
      var inst = instance(el);
      return inst && typeof inst.getValue === "function" ? inst.getValue() : null;
    };
    binding.setValue = function (el, value) {
      var inst = instance(el);
      if (inst && typeof inst.setValue === "function") inst.setValue(value);
    };
    binding.subscribe = function (el, callback) {
      el.__shadCb = function () { callback(!!opts.debounce); };
      el.addEventListener("shad:change", el.__shadCb);
      if (opts.alsoOpenClose) {
        el.addEventListener("shad:open", el.__shadCb);
        el.addEventListener("shad:close", el.__shadCb);
      }
    };
    binding.unsubscribe = function (el) {
      if (!el.__shadCb) return;
      el.removeEventListener("shad:change", el.__shadCb);
      el.removeEventListener("shad:open", el.__shadCb);
      el.removeEventListener("shad:close", el.__shadCb);
      delete el.__shadCb;
    };
    binding.receiveMessage = function (el, data) {
      var inst = instance(el);
      if (!inst) return;
      if (data && "value" in data && typeof inst.setValue === "function") {
        inst.setValue(data.value);
      }
      if (data && data.method && typeof inst[data.method] === "function") {
        inst[data.method].apply(inst, data.args || []);
      }
    };
    binding.getRatePolicy = function () {
      return opts.debounce ? { policy: "debounce", delay: 250 } : null;
    };
    if (opts.overrides) {
      for (var k in opts.overrides) binding[k] = opts.overrides[k];
    }

    Shiny.inputBindings.register(binding, "shadshiny." + name);
    return binding;
  }

  /* ----------------------------------------------------------------------
     Registrations. Order does not matter (find() is per-name).
     ---------------------------------------------------------------------- */
  // Tier 2 form controls
  makeShadBinding("checkbox");
  makeShadBinding("radio-group");
  makeShadBinding("switch");
  makeShadBinding("slider", { debounce: true });
  makeShadBinding("toggle");
  makeShadBinding("toggle-group");
  makeShadBinding("select");
  makeShadBinding("native-select");
  makeShadBinding("combobox");
  makeShadBinding("input-otp");
  makeShadBinding("calendar", { type: "shadshiny.date" });
  makeShadBinding("date-picker", { type: "shadshiny.date" });
  makeShadBinding("form-field");

  // Tier 3 overlays (value = open boolean; also react to open/close)
  makeShadBinding("dialog", { alsoOpenClose: true });
  makeShadBinding("alert-dialog", { alsoOpenClose: true });
  makeShadBinding("sheet", { alsoOpenClose: true });
  makeShadBinding("drawer", { alsoOpenClose: true });
  makeShadBinding("popover", { alsoOpenClose: true });
  makeShadBinding("collapsible", { alsoOpenClose: true });

  // Tier 3 menus / navigation / structure
  makeShadBinding("dropdown-menu");
  makeShadBinding("context-menu");
  makeShadBinding("menubar");
  makeShadBinding("navigation-menu");
  makeShadBinding("command");
  makeShadBinding("tabs");
  makeShadBinding("accordion");
  makeShadBinding("pagination");
  makeShadBinding("resizable");
  makeShadBinding("sidebar");
  makeShadBinding("carousel");

  /* ----------------------------------------------------------------------
     V2 stateful components
     ---------------------------------------------------------------------- */
  // data-table: compound value {selected, sort, filter, page, pageSize}.
  makeShadBinding("data-table", { type: "shadshiny.dataTable", debounce: true });
  makeShadBinding("stepper", { type: "shadshiny.step1" });
  makeShadBinding("rating");
  makeShadBinding("number-stepper");
  // tree: value = selected keys. Lazy expand is forwarded separately below.
  makeShadBinding("tree");

  /* command: forward every activation to `input$<id>_event` as an event.
     input$<id> holds the selected value, and Shiny drops a repeat of the same
     value — fine for a filter, wrong for navigation, where picking "Settings"
     twice has to run twice. Delegated so palettes inserted later work too. */
  document.addEventListener("shad:change", function (ev) {
    var root = ev.target;
    if (!root || !root.matches || !root.matches('[data-shad="command"]')) return;
    if (!root.id) return;
    Shiny.setInputValue(root.id + "_event", {
      value: ev.detail ? ev.detail.value : null,
      nonce: Date.now()
    }, { priority: "event" });
  }, true);

  /* tree lazy-load: forward shad:expand to `input$<id>_expanded` as an event so
     the server can answer with update_shad_tree(children=). Also exposes the
     current expanded-key set. Delegated so dynamically inserted trees work. */
  document.addEventListener("shad:expand", function (ev) {
    var root = ev.target;
    if (!root || !root.matches || !root.matches('[data-shad="tree"]')) return;
    if (!root.id) return;
    Shiny.setInputValue(root.id + "_expanded", {
      key: ev.detail ? ev.detail.key : null,
      expanded: ev.detail ? ev.detail.expanded : null,
      nonce: Date.now()
    }, { priority: "event" });
  }, true);

  /* ----------------------------------------------------------------------
     dropzone → Shiny native file upload bridge
     --------------------------------------------------------------------------
     The dropzone asset emits `shad:files` with raw File objects but performs no
     transfer. We forward those Files into a visually-hidden real
     shiny::fileInput (rendered by shad_dropzone with id = <inputId>__file) via a
     DataTransfer + synthetic change event, so Shiny's own fileInputBinding
     uploads them and `input$<inputId>` becomes the standard files data.frame.
     ---------------------------------------------------------------------- */
  document.addEventListener("shad:files", function (ev) {
    var root = ev.target;
    if (!root || !root.matches || !root.matches('[data-shad="dropzone"]')) return;
    var targetId = root.getAttribute("data-upload-target");
    if (!targetId) return;
    var fileInput = document.getElementById(targetId);
    if (!fileInput) { console.warn("[shadshiny] dropzone: no upload target", targetId); return; }
    var detail = ev.detail || {};
    var files = (detail.files || []).map(function (f) { return f.file; }).filter(Boolean);
    if (!files.length) return;
    try {
      var dt = new DataTransfer();
      files.forEach(function (f) { dt.items.add(f); });
      fileInput.files = dt.files;
      fileInput.dispatchEvent(new Event("change", { bubbles: true }));
    } catch (e) {
      console.warn("[shadshiny] dropzone: DataTransfer unsupported", e);
    }
  }, true);

  /* ----------------------------------------------------------------------
     Report the active theme (preset + dark) as `input$.shad_theme` so
     server-side chart code (shad_current_theme()) re-runs on theme changes.
     ---------------------------------------------------------------------- */
  if (hasShiny) (function themeReporter() {
    var rootEl = document.documentElement;

    // This file loads in <head>, so on the first pass neither `document.body`
    // nor `Shiny.setInputValue` exists yet. Both reads must be guarded: an
    // unguarded one throws and aborts the rest of this IIFE, taking
    // shad.autoInit() -- and `input$.shad_theme` itself -- down with it.
    function report() {
      if (!Shiny.setInputValue) return;
      var body = document.body;
      var dark = rootEl.classList.contains("dark") ||
        rootEl.getAttribute("data-bs-theme") === "dark" ||
        (!!body && body.getAttribute("data-bs-theme") === "dark");
      Shiny.setInputValue(".shad_theme", {
        preset: rootEl.getAttribute("data-shad-theme") || "default",
        dark: !!dark
      });
    }

    var mo = new MutationObserver(report);
    mo.observe(rootEl, { attributes: true,
      attributeFilter: ["class", "data-shad-theme", "data-bs-theme"] });

    function onReady() {
      mo.observe(document.body, { attributes: true, attributeFilter: ["data-bs-theme"] });
      report();
    }
    if (document.body) onReady();
    else document.addEventListener("DOMContentLoaded", onReady, { once: true });

    // setInputValue only exists once Shiny has initialised; seed the value then.
    $(document).on("shiny:connected", report);
  })();

  /* ----------------------------------------------------------------------
     Init after registration. shad.autoInit installs the MutationObserver for
     Shiny's dynamic UI and initializes everything currently in the document.
     ---------------------------------------------------------------------- */
  if (window.shad && typeof shad.autoInit === "function") {
    shad.autoInit();
  }
})();

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
    Shiny.addCustomMessageHandler("shadshiny:style", function (msg) {
      var el = document.getElementById(msg.id);
      if (!el) { console.warn("[shadshiny] style: no element", msg.id); return; }
      var target = msg.selector ? el.querySelector(msg.selector) : el;
      if (target && msg.prop) target.style.setProperty(msg.prop, msg.value);
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
     Init after registration. shad.autoInit installs the MutationObserver for
     Shiny's dynamic UI and initializes everything currently in the document.
     ---------------------------------------------------------------------- */
  if (window.shad && typeof shad.autoInit === "function") {
    shad.autoInit();
  }
})();

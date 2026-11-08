/* FILE: inst/assets/components/dropzone/dropzone.js */
/* shadshiny – dropzone behavior. NO upload – emits shad:files; the host
   (Shiny binding / FileReader) does the transfer and drives per-file state
   via setState(). File list rows compose attachment/ markup.
   Markup:
     <div data-shad="dropzone" class="shad-dropzone"
          [data-multiple] [data-accept=".csv,image/*"] [data-max-size="1048576"] [data-disabled]>
       <div class="shad-dropzone__zone" tabindex="0" role="button" aria-label="…">
         <span class="shad-dropzone__icon">svg</span>
         <div class="shad-dropzone__hint"><strong>Click to browse</strong> or drag files here</div>
         [<div class="shad-dropzone__meta">CSV up to 1 MB</div>]
       </div>
       <input type="file" class="shad-dropzone__input" [multiple] [accept]>
       <div class="shad-dropzone__files"></div>
     </div> */
(function () {
  "use strict";
  function fmtSize(b) {
    if (b < 1024) return b + " B";
    if (b < 1048576) return (b / 1024).toFixed(1) + " KB";
    return (b / 1048576).toFixed(1) + " MB";
  }
  function fileIcon() {
    var s = document.createElementNS("http://www.w3.org/2000/svg", "svg");
    s.setAttribute("viewBox", "0 0 24 24"); s.setAttribute("fill", "none");
    s.setAttribute("stroke", "currentColor"); s.setAttribute("stroke-width", "2");
    s.setAttribute("stroke-linecap", "round"); s.setAttribute("stroke-linejoin", "round");
    s.setAttribute("aria-hidden", "true");
    ["M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z", "M14 2v6h6"].forEach(function (d) {
      var p = document.createElementNS("http://www.w3.org/2000/svg", "path");
      p.setAttribute("d", d); s.appendChild(p);
    });
    return s;
  }
  shad.register("dropzone", function (root) {
    var zone = root.querySelector(".shad-dropzone__zone");
    var input = root.querySelector(".shad-dropzone__input");
    var list = root.querySelector(".shad-dropzone__files");
    var multiple = root.hasAttribute("data-multiple");
    var accept = (root.getAttribute("data-accept") || input.getAttribute("accept") || "").trim();
    var maxSize = root.hasAttribute("data-max-size") ? parseInt(root.getAttribute("data-max-size"), 10) : Infinity;
    var accepted = []; // [{name, file, row}]
    var dragDepth = 0;

    if (multiple) input.multiple = true;
    if (accept && !input.getAttribute("accept")) input.setAttribute("accept", accept);

    function matchesAccept(file) {
      if (!accept) return true;
      return accept.split(",").some(function (tok) {
        tok = tok.trim().toLowerCase();
        if (!tok) return false;
        if (tok.charAt(0) === ".") return file.name.toLowerCase().endsWith(tok);
        if (tok.endsWith("/*")) return (file.type || "").toLowerCase().indexOf(tok.slice(0, -1)) === 0;
        return (file.type || "").toLowerCase() === tok;
      });
    }

    function makeRow(file, state, desc) {
      var row = document.createElement("div");
      row.className = "shad-attachment shad-attachment--sm";
      row.setAttribute("data-name", file.name);
      if (state) row.setAttribute("data-state", state);
      var media = document.createElement("span");
      media.className = "shad-attachment__media shad-attachment__media--icon";
      media.appendChild(fileIcon());
      row.appendChild(media);
      var content = document.createElement("span");
      content.className = "shad-attachment__content";
      var title = document.createElement("span");
      title.className = "shad-attachment__title";
      title.textContent = file.name;
      content.appendChild(title);
      var d = document.createElement("span");
      d.className = "shad-attachment__description";
      d.textContent = desc || fmtSize(file.size);
      content.appendChild(d);
      row.appendChild(content);
      var actions = document.createElement("span");
      actions.className = "shad-attachment__actions";
      var rm = document.createElement("button");
      rm.type = "button";
      rm.className = "shad-attachment__action";
      rm.setAttribute("aria-label", "Remove " + file.name);
      var x = document.createElementNS("http://www.w3.org/2000/svg", "svg");
      x.setAttribute("viewBox", "0 0 24 24"); x.setAttribute("fill", "none");
      x.setAttribute("stroke", "currentColor"); x.setAttribute("stroke-width", "2");
      x.setAttribute("stroke-linecap", "round"); x.setAttribute("aria-hidden", "true");
      var xp = document.createElementNS("http://www.w3.org/2000/svg", "path");
      xp.setAttribute("d", "M6 6l12 12M18 6L6 18");
      x.appendChild(xp);
      rm.appendChild(x);
      rm.addEventListener("click", function () { removeFile(file.name); });
      actions.appendChild(rm);
      row.appendChild(actions);
      return row;
    }

    function removeFile(name) {
      var i = accepted.findIndex(function (f) { return f.name === name; });
      if (i !== -1) { accepted[i].row.remove(); accepted.splice(i, 1); }
      else {
        var r = list.querySelector('[data-name="' + CSS.escape(name) + '"]');
        if (r) r.remove(); // rejected row
      }
      emitChange();
    }

    function addFiles(fileList) {
      if (root.hasAttribute("data-disabled")) return;
      var files = Array.from(fileList);
      if (!multiple) {
        files = files.slice(0, 1);
        accepted.forEach(function (f) { f.row.remove(); });
        accepted = [];
        list.querySelectorAll('[data-state="error"]').forEach(function (r) { r.remove(); });
      }
      var ok = [], rejected = [];
      files.forEach(function (file) {
        var reason = null;
        if (!matchesAccept(file)) reason = "File type not accepted";
        else if (file.size > maxSize) reason = "Too large (max " + fmtSize(maxSize) + ")";
        else if (accepted.some(function (f) { return f.name === file.name; })) reason = "Duplicate file";
        if (reason) {
          rejected.push({ name: file.name, size: file.size, type: file.type, reason: reason });
          list.appendChild(makeRow(file, "error", reason));
        } else {
          var row = makeRow(file);
          list.appendChild(row);
          accepted.push({ name: file.name, file: file, row: row });
          ok.push({ name: file.name, size: file.size, type: file.type, file: file });
        }
      });
      shad.util.emit(root, "shad:files", { files: ok, rejected: rejected });
      emitChange();
    }
    function emitChange() {
      shad.util.emit(root, "shad:change", {
        value: accepted.map(function (f) { return f.name; })
      });
    }

    /* wiring */
    var handlers = [];
    function on(el, type, fn) { el.addEventListener(type, fn); handlers.push([el, type, fn]); }

    on(zone, "click", function () { input.click(); });
    on(zone, "keydown", function (ev) {
      if (ev.key === "Enter" || ev.key === " ") { ev.preventDefault(); input.click(); }
    });
    on(input, "change", function () {
      if (input.files.length) addFiles(input.files);
      input.value = "";
    });
    on(root, "dragenter", function (ev) {
      ev.preventDefault();
      if (root.hasAttribute("data-disabled")) return;
      dragDepth++;
      root.setAttribute("data-drag", "");
    });
    on(root, "dragover", function (ev) { ev.preventDefault(); });
    on(root, "dragleave", function () {
      if (--dragDepth <= 0) { dragDepth = 0; root.removeAttribute("data-drag"); }
    });
    on(root, "drop", function (ev) {
      ev.preventDefault();
      dragDepth = 0;
      root.removeAttribute("data-drag");
      if (ev.dataTransfer && ev.dataTransfer.files.length) addFiles(ev.dataTransfer.files);
    });

    return {
      getValue: function () { return accepted.map(function (f) { return f.name; }); },
      getFiles: function () { return accepted.map(function (f) { return f.file; }); },
      setValue: function () {}, // files can't be set programmatically
      setState: function (name, state, desc) { // drive upload lifecycle per file
        var r = list.querySelector('[data-name="' + CSS.escape(name) + '"]');
        if (!r) return;
        if (state) r.setAttribute("data-state", state);
        else r.removeAttribute("data-state");
        if (desc != null) {
          var d = r.querySelector(".shad-attachment__description");
          if (d) d.textContent = desc;
        }
      },
      clear: function () {
        accepted = [];
        while (list.firstChild) list.removeChild(list.firstChild);
        emitChange();
      },
      destroy: function () {
        handlers.forEach(function (h) { h[0].removeEventListener(h[1], h[2]); });
      }
    };
  });
})();

/* FILE: inst/assets/components/data-table/data-table.js */
/* shadshiny — data-table behavior. Client-side or server-backed over a JSON row model.
   DEPENDENCY: load dropdown-menu.css/.js first if using column visibility.
   Markup:
     <div data-shad="data-table" class="shad-data-table"
          [data-selection="none|single|multiple"] [data-sticky]
          [data-global-filter] [data-column-filters] [data-page-size="10"]>
       <script type="application/json">{columns, rows, options}</script>
     </div>
   Model:
     columns: [{key, label, sortable?, filterable?, html?, visible?}]
     rows:    [{key, cells: {colKey: value}}]  value = string|number|
              {html: "..."} (pre-rendered from R; never generated here)
   Performance: only the current page is in the DOM. Client-side sort/filter
   operate on the JS array; server mode keeps the full dataset out of the DOM. */
(function () {
  "use strict";
  var SVG_NS = "http://www.w3.org/2000/svg";
  function svgArrow() {
    var s = document.createElementNS(SVG_NS, "svg");
    s.setAttribute("viewBox", "0 0 24 24"); s.setAttribute("fill", "none");
    s.setAttribute("stroke", "currentColor"); s.setAttribute("stroke-width", "2");
    s.setAttribute("stroke-linecap", "round"); s.setAttribute("stroke-linejoin", "round");
    s.setAttribute("class", "shad-data-table__sort-icon"); s.setAttribute("aria-hidden", "true");
    var p = document.createElementNS(SVG_NS, "path");
    p.setAttribute("d", "M12 19V5M5 12l7-7 7 7");
    s.appendChild(p); return s;
  }
  function svgCheck(cls) {
    var s = document.createElementNS(SVG_NS, "svg");
    s.setAttribute("viewBox", "0 0 24 24"); s.setAttribute("fill", "none");
    s.setAttribute("stroke", "currentColor"); s.setAttribute("stroke-width", "3");
    s.setAttribute("stroke-linecap", "round"); s.setAttribute("stroke-linejoin", "round");
    s.setAttribute("class", "shad-checkbox__indicator shad-checkbox__indicator--" + cls);
    s.setAttribute("aria-hidden", "true");
    var p = document.createElementNS(SVG_NS, "path");
    p.setAttribute("d", cls === "check" ? "M4 12l5 5L20 7" : "M5 12h14");
    p.setAttribute("pathLength", "1");
    s.appendChild(p); return s;
  }
  function makeCheckbox(label) {
    var b = document.createElement("button");
    b.type = "button";
    b.className = "shad-checkbox";
    b.setAttribute("role", "checkbox");
    b.setAttribute("aria-checked", "false");
    b.setAttribute("aria-label", label);
    b.setAttribute("data-state", "unchecked");
    b.appendChild(svgCheck("check"));
    b.appendChild(svgCheck("minus"));
    return b;
  }
  function setCheck(btn, state) { // "checked"|"unchecked"|"indeterminate"
    btn.setAttribute("data-state", state);
    btn.setAttribute("aria-checked",
      state === "indeterminate" ? "mixed" : String(state === "checked"));
  }
  function cellText(v) {
    if (v == null) return "";
    if (typeof v === "object") return v.html != null ? String(v.html) : "";
    return String(v);
  }
  function cmp(a, b) {
    var na = typeof a === "number", nb = typeof b === "number";
    if (na && nb) return a - b;
    if (a == null) return b == null ? 0 : -1;
    if (b == null) return 1;
    return String(a).localeCompare(String(b), undefined, { numeric: true, sensitivity: "base" });
  }

  shad.register("data-table", function (root) {
    var modelEl = root.querySelector('script[type="application/json"]');
    var model = modelEl ? JSON.parse(modelEl.textContent) : { columns: [], rows: [] };
    var columns = model.columns || [];
    var rows = model.rows || [];
    var opts = model.options || {};
    var selection = root.getAttribute("data-selection") || opts.selection || "none";
    var hasGlobal = root.hasAttribute("data-global-filter") || !!opts.globalFilter;
    var hasColFilters = root.hasAttribute("data-column-filters") || !!opts.columnFilters;
    var hasColVis = !!opts.columnVisibility;
    var sticky = root.hasAttribute("data-sticky") || !!opts.sticky;
    var pageSizes = opts.pageSizes || [10, 25, 50, 100];

    var state = {
      sort: [],                          // [{col, dir}]
      filter: { global: "", columns: {} },
      page: 1,
      pageSize: parseInt(root.getAttribute("data-page-size") || opts.pageSize || pageSizes[0], 10),
      selected: [],                      // row keys, persists across pages/filters
      hidden: {},                        // colKey -> true
      loading: !!opts.loading
    };
    columns.forEach(function (c) { if (c.visible === false) state.hidden[c.key] = true; });

    var debounceTimer = null, destroyed = false;
    var els = {}; // built refs
    var serverMode = false;
    var serverTotalRows = 0;
    var serverFilteredRows = 0;
    var serverRequestId = 0;
    var serverError = false;

    function focusToken() {
      var active = document.activeElement;
      if (!active || !root.contains(active)) return null;
      if (active.classList.contains("shad-data-table__sort")) {
        return { type: "sort", col: active.getAttribute("data-col") };
      }
      if (active.classList.contains("shad-data-table__page-btn")) {
        return {
          type: "page",
          page: active.getAttribute("data-page"),
          aria: active.getAttribute("aria-label")
        };
      }
      if (active.classList.contains("shad-data-table__retry")) return { type: "retry" };
      if (active === els.global) return { type: "global" };
      if (active === els.pageSizeSel) return { type: "page-size" };
      if (active.classList.contains("shad-data-table__col-filter")) {
        return { type: "col-filter", label: active.getAttribute("aria-label") };
      }
      return null;
    }
    function restoreFocus(token) {
      if (!token) return;
      var target = null;
      if (token.type === "sort") {
        var sortButtons = root.querySelectorAll(".shad-data-table__sort");
        for (var i = 0; i < sortButtons.length; i++) {
          if (sortButtons[i].getAttribute("data-col") === token.col) { target = sortButtons[i]; break; }
        }
      } else if (token.type === "page") {
        var pageButtons = root.querySelectorAll(".shad-data-table__page-btn");
        for (var j = 0; j < pageButtons.length; j++) {
          if ((token.aria === "Next page" || token.aria === "Previous page") &&
              pageButtons[j].getAttribute("aria-label") === token.aria) {
            target = pageButtons[j]; break;
          }
          if (token.aria !== "Next page" && token.aria !== "Previous page" &&
              pageButtons[j].getAttribute("data-page") === token.page) {
            target = pageButtons[j]; break;
          }
        }
      } else if (token.type === "retry") target = root.querySelector(".shad-data-table__retry");
      else if (token.type === "global") target = els.global;
      else if (token.type === "page-size") target = els.pageSizeSel;
      else if (token.type === "col-filter") {
        var filters = root.querySelectorAll(".shad-data-table__col-filter");
        for (var k = 0; k < filters.length; k++) {
          if (filters[k].getAttribute("aria-label") === token.label) { target = filters[k]; break; }
        }
      }
      if (target && target.disabled && token.type === "page") {
        var currentPage = root.querySelector('[aria-label="Page ' + state.page + '"]');
        if (currentPage) target = currentPage;
      }
      if (target && typeof target.focus === "function") target.focus({ preventScroll: true });
    }

    /* ---------------- build static skeleton ---------------- */
    root.classList.add("shad-data-table");
    if (sticky) root.classList.add("shad-data-table--sticky");
    while (root.firstChild) root.removeChild(root.firstChild); // model script consumed

    if (hasGlobal || hasColVis) {
      var bar = document.createElement("div");
      bar.className = "shad-data-table__toolbar";
      if (hasGlobal) {
        els.global = document.createElement("input");
        els.global.type = "search";
        els.global.className = "shad-data-table__filter";
        els.global.placeholder = opts.filterPlaceholder || "Filter rows…";
        els.global.setAttribute("aria-label", "Filter all columns");
        bar.appendChild(els.global);
      }
      var sp = document.createElement("div");
      sp.className = "shad-data-table__toolbar-spacer";
      bar.appendChild(sp);
      if (hasColVis) bar.appendChild(buildColVis());
      root.appendChild(bar);
    }

    els.viewport = document.createElement("div");
    els.viewport.className = "shad-data-table-viewport";
    if (sticky && opts.maxHeight) els.viewport.style.maxHeight = opts.maxHeight;
    var table = document.createElement("table");
    table.className = "shad-table";
    els.thead = document.createElement("thead");
    els.thead.className = "shad-table__header";
    els.tbody = document.createElement("tbody");
    els.tbody.className = "shad-table__body";
    table.appendChild(els.thead);
    table.appendChild(els.tbody);
    els.viewport.appendChild(table);
    root.appendChild(els.viewport);

    els.footer = document.createElement("div");
    els.footer.className = "shad-data-table__footer";
    els.summary = document.createElement("div");
    els.summary.className = "shad-data-table__summary";
    els.footer.appendChild(els.summary);
    els.footer.appendChild(buildPageSize());
    els.pager = document.createElement("nav");
    els.pager.className = "shad-data-table__pager";
    els.pager.setAttribute("aria-label", "Pagination");
    els.footer.appendChild(els.pager);
    root.appendChild(els.footer);

    /* ---------------- column visibility (dropdown-menu compose) ----------------
       Uses dropdown-menu.js's real anatomy: .shad-menu__trigger + .shad-menu__content
       with data-type="checkbox" items; the menu core owns open/close/toggle, we
       react to its shad:change. */
    function buildColVis() {
      var wrap = document.createElement("div");
      wrap.setAttribute("data-shad", "dropdown-menu");
      var trig = document.createElement("button");
      trig.type = "button";
      trig.className = "shad-btn shad-btn--outline shad-btn--sm shad-menu__trigger";
      trig.textContent = opts.columnsLabel || "Columns";
      wrap.appendChild(trig);
      var content = document.createElement("div");
      content.className = "shad-menu__content shad-anim-pop";
      content.hidden = true;
      columns.forEach(function (c) {
        var item = document.createElement("button");
        item.type = "button";
        item.className = "shad-menu__item";
        item.setAttribute("data-type", "checkbox");
        item.setAttribute("data-value", c.key);
        item.setAttribute("data-state", state.hidden[c.key] ? "unchecked" : "checked");
        var ind = document.createElement("span");
        ind.className = "shad-menu__indicator";
        ind.appendChild(svgCheck("check"));
        item.appendChild(ind);
        item.appendChild(document.createTextNode(c.label));
        content.appendChild(item);
      });
      wrap.appendChild(content);
      wrap.addEventListener("shad:change", function (ev) {
        var d = ev.detail || {};
        if (d.type !== "checkbox" || !d.value) return;
        ev.stopPropagation(); // don't leak the menu's change as the table's
        var item = content.querySelector('[data-value="' + CSS.escape(d.value) + '"]');
        if (d.checked === false) {
          var visible = columns.filter(function (x) { return !state.hidden[x.key]; });
          if (visible.length <= 1) { // keep ≥1 visible: revert the core's toggle
            if (item) { item.setAttribute("data-state", "checked"); item.setAttribute("aria-checked", "true"); }
            return;
          }
          state.hidden[d.value] = true;
        } else delete state.hidden[d.value];
        renderHead(); renderBody();
      });
      queueMicrotask(function () { if (!shad.get(wrap)) shad.init(wrap); });
      return wrap;
    }

    /* ---------------- page-size select (native-select compose) ---------------- */
    function buildPageSize() {
      var wrap = document.createElement("label");
      wrap.className = "shad-data-table__page-size";
      var txt = document.createElement("span");
      txt.textContent = opts.pageSizeLabel || "Rows per page";
      wrap.appendChild(txt);
      var sel = document.createElement("select");
      sel.className = "shad-native-select shad-native-select--sm";
      pageSizes.forEach(function (n) {
        var o = document.createElement("option");
        o.value = String(n); o.textContent = String(n);
        if (n === state.pageSize) o.selected = true;
        sel.appendChild(o);
      });
      sel.addEventListener("change", function () {
        state.pageSize = parseInt(sel.value, 10);
        state.page = 1;
        if (serverMode) serverRequest();
        else { renderBody(); emit(); }
      });
      els.pageSizeSel = sel;
      wrap.appendChild(sel);
      return wrap;
    }

    /* ---------------- derive: filter -> sort -> paginate ---------------- */
    function visibleColumns() {
      return columns.filter(function (c) { return !state.hidden[c.key]; });
    }
    function filteredRows() {
      var g = state.filter.global.trim().toLowerCase();
      var colFs = Object.keys(state.filter.columns).filter(function (k) {
        return state.filter.columns[k].trim() !== "";
      });
      if (!g && !colFs.length) return rows;
      return rows.filter(function (r) {
        for (var i = 0; i < colFs.length; i++) {
          var k = colFs[i];
          var t = cellText(r.cells[k]).toLowerCase();
          if (typeof r.cells[k] === "object" && r.cells[k] && r.cells[k].html != null) {
            t = String(r.cells[k].text != null ? r.cells[k].text : stripTags(r.cells[k].html)).toLowerCase();
          }
          if (t.indexOf(state.filter.columns[k].trim().toLowerCase()) === -1) return false;
        }
        if (g) {
          var hit = columns.some(function (c) {
            var v = r.cells[c.key];
            var s = (typeof v === "object" && v && v.html != null)
              ? String(v.text != null ? v.text : stripTags(v.html))
              : cellText(v);
            return s.toLowerCase().indexOf(g) !== -1;
          });
          if (!hit) return false;
        }
        return true;
      });
    }
    function stripTags(html) {
      var d = document.createElement("div");
      d.innerHTML = html;
      return d.textContent || "";
    }
    function sortedRows(list) {
      if (!state.sort.length) return list;
      var s = state.sort;
      return list.slice().sort(function (a, b) {
        for (var i = 0; i < s.length; i++) {
          var v = s[i];
          var av = a.cells[v.col], bv = b.cells[v.col];
          if (typeof av === "object" && av) av = av.sort != null ? av.sort : (av.text != null ? av.text : stripTags(av.html || ""));
          if (typeof bv === "object" && bv) bv = bv.sort != null ? bv.sort : (bv.text != null ? bv.text : stripTags(bv.html || ""));
          var c = cmp(av, bv);
          if (c) return v.dir === "desc" ? -c : c;
        }
        return 0;
      });
    }

    /* ---------------- render: head ---------------- */
    function renderHead() {
      var focus = focusToken();
      while (els.thead.firstChild) els.thead.removeChild(els.thead.firstChild);
      var tr = document.createElement("tr");
      tr.className = "shad-table__row";
      if (selection === "multiple") {
        var th = document.createElement("th");
        th.className = "shad-table__head shad-table__head--select";
        els.selectAll = makeCheckbox("Select all rows on this page");
        els.selectAll.addEventListener("click", onSelectAll);
        th.appendChild(els.selectAll);
        tr.appendChild(th);
      } else if (selection === "single") {
        var th0 = document.createElement("th");
        th0.className = "shad-table__head shad-table__head--select";
        tr.appendChild(th0);
      }
      visibleColumns().forEach(function (c) {
        var th = document.createElement("th");
        th.className = "shad-table__head";
        th.setAttribute("data-col", c.key);
        var sorted = state.sort.find(function (s) { return s.col === c.key; });
        if (c.sortable) {
          th.setAttribute("aria-sort", sorted ? (sorted.dir === "asc" ? "ascending" : "descending") : "none");
          var btn = document.createElement("button");
          btn.type = "button";
          btn.className = "shad-data-table__sort";
          btn.setAttribute("data-col", c.key);
          btn.setAttribute("data-sort", sorted ? sorted.dir : "none");
          btn.appendChild(document.createTextNode(c.label));
          btn.appendChild(svgArrow());
          if (sorted && state.sort.length > 1) {
            var idx = document.createElement("span");
            idx.className = "shad-data-table__sort-index";
            idx.textContent = String(state.sort.indexOf(sorted) + 1);
            btn.appendChild(idx);
          }
          btn.addEventListener("click", function (e) { onSort(c.key, e.shiftKey); });
          th.appendChild(btn);
        } else {
          th.textContent = c.label;
        }
        tr.appendChild(th);
      });
      els.thead.appendChild(tr);
      if (hasColFilters) {
        var fr = document.createElement("tr");
        fr.className = "shad-table__row";
        if (selection !== "none") {
          var pad = document.createElement("th");
          pad.className = "shad-table__head shad-table__head--select";
          fr.appendChild(pad);
        }
        visibleColumns().forEach(function (c) {
          var th = document.createElement("th");
          th.className = "shad-table__head";
          if (c.filterable !== false) {
            var inp = document.createElement("input");
            inp.type = "search";
            inp.className = "shad-data-table__col-filter";
            inp.placeholder = "Filter…";
            inp.setAttribute("aria-label", "Filter " + c.label);
            inp.value = state.filter.columns[c.key] || "";
            inp.addEventListener("input", function () {
              state.filter.columns[c.key] = inp.value;
              debouncedRefilter();
            });
            th.appendChild(inp);
          }
          fr.appendChild(th);
        });
        els.thead.appendChild(fr);
      }
      restoreFocus(focus);
    }

    /* ---------------- render: body (current page ONLY) ---------------- */
    var derived = { list: [], total: 0 };
    function renderBody() {
      var focus = focusToken();
      if (serverMode) {
        derived.list = rows.slice();
        derived.total = serverFilteredRows;
      } else {
        derived.list = sortedRows(filteredRows());
        derived.total = derived.list.length;
      }
      var pages = Math.max(1, Math.ceil(derived.total / state.pageSize));
      state.page = Math.min(Math.max(1, state.page), pages);
      var start = (state.page - 1) * state.pageSize;
      var pageRows = serverMode ? derived.list : derived.list.slice(start, start + state.pageSize);
      var colCount = Math.max(1, visibleColumns().length + (selection !== "none" ? 1 : 0));

      root.setAttribute("aria-busy", state.loading ? "true" : "false");

      while (els.tbody.firstChild) els.tbody.removeChild(els.tbody.firstChild);

      if (serverError) {
        var xtr = document.createElement("tr");
        xtr.className = "shad-table__row";
        var xtd = document.createElement("td");
        xtd.className = "shad-table__cell";
        xtd.colSpan = colCount;
        var alert = document.createElement("div");
        alert.className = "shad-data-table__error";
        alert.setAttribute("role", "alert");
        alert.appendChild(document.createTextNode("Unable to load data. "));
        var retry = document.createElement("button");
        retry.type = "button";
        retry.className = "shad-data-table__retry shad-btn shad-btn--outline shad-btn--sm";
        retry.textContent = "Try again";
        retry.addEventListener("click", function () { serverRequest(); });
        alert.appendChild(retry);
        xtd.appendChild(alert);
        xtr.appendChild(xtd);
        els.tbody.appendChild(xtr);
      } else if (state.loading) {
        for (var i = 0; i < Math.min(state.pageSize, 10); i++) {
          var tr = document.createElement("tr");
          tr.className = "shad-table__row";
          for (var j = 0; j < colCount; j++) {
            var td = document.createElement("td");
            td.className = "shad-table__cell";
            var sk = document.createElement("span");
            sk.className = "shad-data-table__skeleton";
            td.appendChild(sk);
            tr.appendChild(td);
          }
          els.tbody.appendChild(tr);
        }
      } else if (!pageRows.length) {
        var etr = document.createElement("tr");
        etr.className = "shad-table__row";
        var etd = document.createElement("td");
        etd.className = "shad-table__cell";
        etd.colSpan = colCount;
        var slot = document.createElement("div");
        slot.className = "shad-data-table__empty";
        if (opts.emptyHtml) slot.innerHTML = opts.emptyHtml;
        else slot.textContent = opts.emptyText || "No results.";
        etd.appendChild(slot);
        etr.appendChild(etd);
        els.tbody.appendChild(etr);
      } else {
        pageRows.forEach(function (r) {
          var tr = document.createElement("tr");
          tr.className = "shad-table__row";
          tr.setAttribute("data-key", String(r.key));
          var isSel = state.selected.indexOf(r.key) !== -1;
          if (isSel) tr.setAttribute("data-state", "selected");
          if (selection !== "none") {
            var td0 = document.createElement("td");
            td0.className = "shad-table__cell shad-table__cell--select";
            var cb = makeCheckbox("Select row");
            setCheck(cb, isSel ? "checked" : "unchecked");
            if (selection === "single") cb.setAttribute("role", "radio");
            cb.addEventListener("click", function () { toggleRow(r.key); });
            td0.appendChild(cb);
            tr.appendChild(td0);
          }
          visibleColumns().forEach(function (c) {
            var td = document.createElement("td");
            td.className = "shad-table__cell";
            var v = r.cells[c.key];
            if (v != null && typeof v === "object" && v.html != null) td.innerHTML = v.html; // pre-rendered by R
            else td.textContent = cellText(v); // plain text: escaped by construction
            tr.appendChild(td);
          });
          els.tbody.appendChild(tr);
        });
      }
      renderSummary(start, pageRows.length);
      renderPager(pages);
      updateSelectAll(pageRows);
      restoreFocus(focus);
    }

    function renderSummary(start, count) {
      if (state.loading) { els.summary.textContent = "Loading…"; return; }
      if (serverError) { els.summary.textContent = "Unable to load data"; return; }
      var sel = state.selected.length;
      var totalSuffix = serverMode && derived.total > 0 && serverTotalRows > derived.total
        ? " (" + serverTotalRows + " total)" : "";
      var base = derived.total === 0 ? "0 rows"
        : (start + 1) + "–" + (start + count) + " of " + derived.total + " rows" + totalSuffix;
      els.summary.textContent = sel ? sel + " selected · " + base : base;
    }

    /* windowed pager: first, last, current ±1, ellipsis (V1 deviation #6) */
    function renderPager(pages) {
      while (els.pager.firstChild) els.pager.removeChild(els.pager.firstChild);
      function btn(label, page, opts2) {
        var b = document.createElement("button");
        b.type = "button";
        b.className = "shad-data-table__page-btn";
        b.setAttribute("data-page", String(page));
        b.textContent = label;
        if (opts2 && opts2.aria) b.setAttribute("aria-label", opts2.aria);
        if (opts2 && opts2.disabled) { b.disabled = true; b.setAttribute("data-disabled", ""); }
        if (opts2 && opts2.active) { b.setAttribute("data-state", "active"); b.setAttribute("aria-current", "page"); }
        b.addEventListener("click", function () { goTo(page); });
        return b;
      }
      els.pager.appendChild(btn("‹", state.page - 1, { aria: "Previous page", disabled: state.page <= 1 }));
      var shown = [];
      for (var p = 1; p <= pages; p++) {
        if (p === 1 || p === pages || Math.abs(p - state.page) <= 1) shown.push(p);
      }
      var last = 0;
      shown.forEach(function (p) {
        if (p - last > 1) {
          var el = document.createElement("span");
          el.className = "shad-data-table__page-ellipsis";
          el.textContent = "…";
          el.setAttribute("aria-hidden", "true");
          els.pager.appendChild(el);
        }
        els.pager.appendChild(btn(String(p), p, { active: p === state.page, aria: "Page " + p }));
        last = p;
      });
      els.pager.appendChild(btn("›", state.page + 1, { aria: "Next page", disabled: state.page >= pages }));
    }

    /* ---------------- selection ---------------- */
    function toggleRow(key) {
      if (selection === "single") {
        state.selected = state.selected[0] === key ? [] : [key];
      } else {
        var i = state.selected.indexOf(key);
        if (i === -1) state.selected.push(key); else state.selected.splice(i, 1);
      }
      renderBody(); emit();
    }
    function currentPageRows() {
      if (serverMode) return derived.list.slice();
      var start = (state.page - 1) * state.pageSize;
      return derived.list.slice(start, start + state.pageSize);
    }
    function onSelectAll() {
      var pageRows = currentPageRows();
      var keys = pageRows.map(function (r) { return r.key; });
      var allSel = keys.length && keys.every(function (k) { return state.selected.indexOf(k) !== -1; });
      if (allSel) {
        state.selected = state.selected.filter(function (k) { return keys.indexOf(k) === -1; });
      } else {
        keys.forEach(function (k) { if (state.selected.indexOf(k) === -1) state.selected.push(k); });
      }
      renderBody(); emit();
    }
    function updateSelectAll(pageRows) {
      if (!els.selectAll) return;
      var keys = pageRows.map(function (r) { return r.key; });
      var selOnPage = keys.filter(function (k) { return state.selected.indexOf(k) !== -1; }).length;
      setCheck(els.selectAll,
        !keys.length || selOnPage === 0 ? "unchecked"
          : selOnPage === keys.length ? "checked" : "indeterminate");
    }

    /* ---------------- sort + filter handlers ---------------- */
    function serverRequest() {
      if (!serverMode || destroyed) return;
      serverRequestId += 1;
      serverError = false;
      state.loading = true;
      renderBody();
      emit();
    }
    function onSort(col, additive) {
      var cur = state.sort.find(function (s) { return s.col === col; });
      if (!additive) {
        var dir = cur ? (cur.dir === "asc" ? "desc" : null) : "asc";
        state.sort = dir ? [{ col: col, dir: dir }] : [];
      } else {
        if (!cur) state.sort.push({ col: col, dir: "asc" });
        else if (cur.dir === "asc") cur.dir = "desc";
        else state.sort = state.sort.filter(function (s) { return s !== cur; });
      }
      state.page = 1;
      renderHead();
      if (serverMode) serverRequest();
      else { renderBody(); emit(); }
    }
    function debouncedRefilter() {
      clearTimeout(debounceTimer);
      debounceTimer = setTimeout(function () {
        if (destroyed) return;
        state.page = 1;
        if (serverMode) serverRequest();
        else { renderBody(); emit(); }
      }, 150);
    }
    if (els.global) {
      els.global.addEventListener("input", function () {
        state.filter.global = els.global.value;
        debouncedRefilter();
      });
    }
    function goTo(p) {
      var pages = Math.max(1, Math.ceil(derived.total / state.pageSize));
      var np = Math.min(Math.max(1, p), pages);
      if (np === state.page) return;
      state.page = np;
      if (serverMode) serverRequest();
      else { renderBody(); emit(); }
    }

    /* ---------------- events + instance ---------------- */
    function value() {
      var result = {
        selected: state.selected.slice(),
        sort: state.sort.map(function (s) { return { col: s.col, dir: s.dir }; }),
        filter: { global: state.filter.global, columns: Object.assign({}, state.filter.columns) },
        page: state.page,
        pageSize: state.pageSize
      };
      if (serverMode) result.requestId = serverRequestId;
      return result;
    }
    function emit() { shad.util.emit(root, "shad:change", { value: value() }); }

    renderHead();
    renderBody();

    return {
      getValue: value,
      enableServerMode: function (config) {
        config = config || {};
        serverMode = true;
        serverError = false;
        state.loading = true;
        if (Array.isArray(config.columns)) {
          columns = config.columns;
          columns.forEach(function (c) { if (c.visible === false) state.hidden[c.key] = true; });
        }
        serverTotalRows = Number(config.totalRows) || 0;
        serverFilteredRows = Number(config.filteredRows) || serverTotalRows;
        renderHead();
        serverRequest();
      },
      setServerPage: function (payload) {
        if (!serverMode || !payload || Number(payload.requestId) !== serverRequestId) return;
        if (Array.isArray(payload.columns)) {
          columns = payload.columns;
          columns.forEach(function (c) { if (c.visible === false) state.hidden[c.key] = true; });
          renderHead();
        }
        rows = Array.isArray(payload.rows) ? payload.rows : [];
        serverTotalRows = Math.max(0, Number(payload.totalRows) || 0);
        serverFilteredRows = Math.max(0, Number(payload.filteredRows) || 0);
        state.loading = false;
        serverError = false;
        renderBody();
      },
      setServerError: function (payload) {
        if (!serverMode || !payload || Number(payload.requestId) !== serverRequestId) return;
        state.loading = false;
        serverError = true;
        renderBody();
      },
      setValue: function (v) { // accepts partial state
        if (!v) return;
        if (v.sort) state.sort = v.sort.map(function (s) { return { col: s.col, dir: s.dir }; });
        if (v.filter) {
          if (v.filter.global != null) {
            state.filter.global = v.filter.global;
            if (els.global) els.global.value = v.filter.global;
          }
          if (v.filter.columns) state.filter.columns = Object.assign({}, v.filter.columns);
        }
        if (v.selected) state.selected = v.selected.slice();
        if (v.pageSize) {
          state.pageSize = v.pageSize;
          if (els.pageSizeSel) els.pageSizeSel.value = String(v.pageSize);
        }
        if (v.page) state.page = v.page;
        if (v.loading != null) state.loading = !!v.loading;
        renderHead(); renderBody(); emit();
      },
      setData: function (newRows) { // server-pushed refresh; selection keys kept
        rows = newRows || [];
        state.loading = false;
        if (serverMode) {
          serverFilteredRows = rows.length;
          serverTotalRows = rows.length;
        }
        renderBody(); emit();
      },
      destroy: function () {
        destroyed = true;
        clearTimeout(debounceTimer);
        while (root.firstChild) root.removeChild(root.firstChild);
      }
    };
  });
})();

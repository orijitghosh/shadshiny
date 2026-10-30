/* FILE: inst/assets/components/tree/tree.js */
/* shadshiny — tree behavior (APG TreeView pattern; reuses shad.roving).
   Markup:
     <div data-shad="tree" class="shad-tree" [data-selection="single|multiple"]>
       <ul class="shad-tree__list" role="tree" aria-label="…">
         <li class="shad-tree__item" role="treeitem" data-key="k"
             [aria-expanded="true|false"] [aria-disabled="true"] [data-lazy]>
           <div class="shad-tree__row">
             <svg class="shad-tree__chevron [--leaf]">…</svg>
             [<span class="shad-tree__icon">…</span>]
             <span class="shad-tree__label">…</span>
           </div>
           [<ul class="shad-tree__group" role="group"> …children… </ul>]
         </li>…
       </ul>
     </div>
   Branch = item WITH aria-expanded (children in a role=group ul, or data-lazy).
   Lazy: expanding a data-lazy item shows a spinner row and emits shad:expand;
   host calls setChildren(key, html) to fill (or [] to mark leaf).
   Events: shad:change {value: selectedKeys[]}, shad:expand {key, expanded}. */
(function () {
  "use strict";
  shad.register("tree", function (root) {
    var list = root.querySelector('[role="tree"]');
    var selection = root.getAttribute("data-selection") || "single";
    var selected = [];

    function allItems() {
      return Array.from(list.querySelectorAll('[role="treeitem"]'));
    }
    function rowOf(item) { return item.querySelector(":scope > .shad-tree__row"); }
    function groupOf(item) { return item.querySelector(':scope > [role="group"]'); }
    function keyOf(item) { return item.getAttribute("data-key"); }
    function isBranch(item) { return item.hasAttribute("aria-expanded"); }
    function isDisabled(item) { return item.getAttribute("aria-disabled") === "true"; }
    function isVisible(item) {
      var p = item.parentElement && item.parentElement.closest('[role="treeitem"]');
      while (p) {
        if (p.getAttribute("aria-expanded") === "false") return false;
        p = p.parentElement && p.parentElement.closest('[role="treeitem"]');
      }
      return true;
    }

    /* levels + initial wiring */
    function wire() {
      allItems().forEach(function (item) {
        var level = 1, p = item.parentElement && item.parentElement.closest('[role="treeitem"]');
        while (p) { level++; p = p.parentElement && p.parentElement.closest('[role="treeitem"]'); }
        item.setAttribute("aria-level", String(level));
        if (!item.hasAttribute("aria-selected")) item.setAttribute("aria-selected", "false");
        if (!item.hasAttribute("tabindex")) item.setAttribute("tabindex", "-1");
        if (item.getAttribute("aria-selected") === "true" && selected.indexOf(keyOf(item)) === -1) {
          selected.push(keyOf(item));
        }
      });
      var first = allItems()[0];
      if (first && !list.querySelector('[role="treeitem"][tabindex="0"]')) {
        first.setAttribute("tabindex", "0");
      }
    }
    wire();

    function setExpanded(item, expanded) {
      if (!isBranch(item)) return;
      item.setAttribute("aria-expanded", String(expanded));
      if (expanded && item.hasAttribute("data-lazy") && !groupOf(item)) {
        var g = document.createElement("ul");
        g.className = "shad-tree__group";
        g.setAttribute("role", "group");
        var row = document.createElement("li");
        row.className = "shad-tree__spinner-row";
        row.setAttribute("role", "presentation");
        var sp = document.createElement("span");
        sp.className = "shad-tree__spinner";
        row.appendChild(sp);
        row.appendChild(document.createTextNode("Loading…"));
        g.appendChild(row);
        item.appendChild(g);
      }
      shad.util.emit(root, "shad:expand", { key: keyOf(item), expanded: expanded });
    }

    function select(item, additive) {
      if (isDisabled(item)) return;
      var key = keyOf(item);
      if (selection === "multiple" && additive) {
        var i = selected.indexOf(key);
        if (i === -1) selected.push(key); else selected.splice(i, 1);
      } else {
        selected = selected[0] === key && selected.length === 1 ? [] : [key];
      }
      allItems().forEach(function (it) {
        var on = selected.indexOf(keyOf(it)) !== -1;
        it.setAttribute("aria-selected", String(on));
        if (on) it.setAttribute("data-state", "selected");
        else it.removeAttribute("data-state");
      });
      shad.util.emit(root, "shad:change", { value: selected.slice() });
    }

    /* roving: vertical arrows / Home / End / typeahead / Enter-Space activate */
    var disposeRoving = shad.roving(list, {
      selector: '[role="treeitem"]',
      orientation: "vertical",
      loop: false,
      typeahead: true,
      onActivate: function (item, ev) { select(item, ev && (ev.ctrlKey || ev.metaKey)); }
    });

    /* Left/Right per APG (unhandled by vertical roving) */
    function onKeydown(ev) {
      var item = ev.target.closest('[role="treeitem"]');
      if (!item) return;
      if (ev.key === "ArrowRight") {
        ev.preventDefault();
        if (isBranch(item) && item.getAttribute("aria-expanded") === "false") setExpanded(item, true);
        else {
          var g = groupOf(item);
          var child = g && g.querySelector('[role="treeitem"]');
          // keyboard nav: let the browser reveal the new item (see rating.js)
          if (child) child.focus();
        }
      } else if (ev.key === "ArrowLeft") {
        ev.preventDefault();
        if (isBranch(item) && item.getAttribute("aria-expanded") === "true") setExpanded(item, false);
        else {
          var parent = item.parentElement && item.parentElement.closest('[role="treeitem"]');
          if (parent) parent.focus();
        }
      }
    }
    list.addEventListener("keydown", onKeydown);

    /* pointer */
    function onClick(ev) {
      var row = ev.target.closest(".shad-tree__row");
      if (!row || !list.contains(row)) return;
      var item = row.closest('[role="treeitem"]');
      if (isDisabled(item)) return;
      item.focus({ preventScroll: true });
      var onChevron = ev.target.closest(".shad-tree__chevron");
      if (isBranch(item) && (onChevron || ev.detail === 2)) {
        setExpanded(item, item.getAttribute("aria-expanded") !== "true");
      } else if (isBranch(item) && !onChevron) {
        // single-click on a branch row toggles AND selects (file-explorer feel)
        setExpanded(item, item.getAttribute("aria-expanded") !== "true");
        select(item, ev.ctrlKey || ev.metaKey);
      } else {
        select(item, ev.ctrlKey || ev.metaKey);
      }
    }
    list.addEventListener("click", onClick);

    return {
      getValue: function () { return selected.slice(); },
      setValue: function (keys) {
        selected = [];
        var want = Array.isArray(keys) ? keys : [keys];
        allItems().forEach(function (it) {
          var on = want.indexOf(keyOf(it)) !== -1;
          if (on) selected.push(keyOf(it));
          it.setAttribute("aria-selected", String(on));
          if (on) it.setAttribute("data-state", "selected");
          else it.removeAttribute("data-state");
        });
        shad.util.emit(root, "shad:change", { value: selected.slice() });
      },
      setChildren: function (key, html) {
        var item = list.querySelector('[role="treeitem"][data-key="' + CSS.escape(key) + '"]');
        if (!item) return;
        var g = groupOf(item);
        if (Array.isArray(html) && !html.length) { // no children: becomes leaf
          if (g) g.remove();
          item.removeAttribute("aria-expanded");
          item.removeAttribute("data-lazy");
          var chev = item.querySelector(":scope > .shad-tree__row .shad-tree__chevron");
          if (chev) chev.classList.add("shad-tree__chevron--leaf");
          return;
        }
        if (!g) {
          g = document.createElement("ul");
          g.className = "shad-tree__group";
          g.setAttribute("role", "group");
          item.appendChild(g);
        }
        g.innerHTML = typeof html === "string" ? html : "";
        if (Array.isArray(html)) html.forEach(function (n) { g.appendChild(n); });
        item.removeAttribute("data-lazy");
        wire();
      },
      expand: function (key, on) {
        var item = list.querySelector('[role="treeitem"][data-key="' + CSS.escape(key) + '"]');
        if (item) setExpanded(item, on !== false);
      },
      destroy: function () {
        if (disposeRoving) disposeRoving();
        list.removeEventListener("keydown", onKeydown);
        list.removeEventListener("click", onClick);
      }
    };
  });
})();

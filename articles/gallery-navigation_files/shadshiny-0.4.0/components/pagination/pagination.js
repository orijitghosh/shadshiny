/* FILE: inst/assets/components/pagination/pagination.js */
/* shadshiny – pagination behavior (optional; markup works without it).
   With data-shad="pagination" + data-pages="N" + data-page="i", JS renders
   the windowed page list (1 … i-1 i i+1 … N), maintains aria-current,
   wires prev/next, and reports page changes.
   DECISION: window = first, last, current ±1, ellipsis between gaps. */
(function () {
  "use strict";
  shad.register("pagination", function (root) {
    const list = root.querySelector(".shad-pagination__list");
    let pages = parseInt(root.getAttribute("data-pages") || "1", 10);
    let page = shad.util.clamp(parseInt(root.getAttribute("data-page") || "1", 10), 1, pages);

    root.setAttribute("role", "navigation");
    root.setAttribute("aria-label", root.getAttribute("aria-label") || "Pagination");

    function pageModel() {
      const win = new Set([1, pages, page - 1, page, page + 1]);
      const out = [];
      let prev = 0;
      for (let p = 1; p <= pages; p++) {
        if (!win.has(p)) continue;
        if (p - prev > 1) out.push("…");
        out.push(p);
        prev = p;
      }
      return out;
    }
    function render() {
      list.innerHTML = "";
      const mk = (html) => {
        const li = document.createElement("li");
        li.innerHTML = html;
        list.appendChild(li);
        return li.firstElementChild;
      };
      const prevBtn = mk('<button type="button" class="shad-pagination__link shad-pagination__link--nav"' +
        (page === 1 ? " data-disabled" : "") + ' aria-label="Go to previous page">' +
        '<svg class="shad-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m15 18-6-6 6-6"/></svg>' +
        "<span>Previous</span></button>");
      prevBtn.addEventListener("click", () => go(page - 1));
      pageModel().forEach((p) => {
        if (p === "…") {
          mk('<span class="shad-pagination__ellipsis" aria-hidden="true">' +
            '<svg class="shad-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="1"/><circle cx="19" cy="12" r="1"/><circle cx="5" cy="12" r="1"/></svg></span>');
          return;
        }
        const btn = mk('<button type="button" class="shad-pagination__link"' +
          (p === page ? ' data-state="active" aria-current="page"' : "") +
          ' aria-label="Page ' + p + '">' + p + "</button>");
        btn.addEventListener("click", () => go(p));
      });
      const nextBtn = mk('<button type="button" class="shad-pagination__link shad-pagination__link--nav"' +
        (page === pages ? " data-disabled" : "") + ' aria-label="Go to next page">' +
        "<span>Next</span>" +
        '<svg class="shad-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m9 18 6-6-6-6"/></svg></button>');
      nextBtn.addEventListener("click", () => go(page + 1));
    }
    function go(p) {
      p = shad.util.clamp(p, 1, pages);
      if (p === page) return;
      page = p;
      root.setAttribute("data-page", String(page));
      render();
      shad.util.emit(root, "shad:change", { value: page });
    }

    render();

    return {
      getValue() { return page; },
      setValue(p) { go(parseInt(p, 10)); },
      /** update total page count */
      setPages(n) {
        pages = Math.max(1, parseInt(n, 10));
        root.setAttribute("data-pages", String(pages));
        page = shad.util.clamp(page, 1, pages);
        render();
      },
      destroy() {}
    };
  });
})();

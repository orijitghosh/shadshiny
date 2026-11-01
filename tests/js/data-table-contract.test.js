/* Contract: data table cells and updates, the browser half. What
   shad_data_table_server() accepts from the browser is the R half, at the
   top of tests/testthat/test-data-table-server.R.

   Cells
   1. Filtering and sorting read an HTML cell's text from an inert parse:
      nothing in it comes to life (custom elements, images, inline handlers)
      for any row, on the page or off it. Only rows on the page render.
      (Image requests in Chromium: tests/browser/behavior.spec.js.)

   Updates from the server (update_shad_data_table() calls setValue())
   2. In server mode a page or page-size patch asks the server for that
      page: a new requestId and the loading state, never the current rows
      relabelled as another page. The page is clamped to the pages the last
      response allows, a page-size patch without a page starts at page 1 as
      the select does, and a selection patch asks for nothing.
   3. A page size the table does not offer is ignored with console.warn, so
      the page-size select always shows the size in use.
   4. A single-selection table takes at most one key; a longer list is
      ignored with console.warn. */
import { describe, it, expect, beforeEach, afterEach, vi } from "vitest";
import { loadRuntime, mount } from "./helpers.js";

// counts elements that came to life: a live parse upgrades x-probe, an inert
// one does not
let born = 0;
window.customElements.define("x-probe", class extends window.HTMLElement {
  constructor() { super(); born += 1; }
});

const COLUMNS = [{ key: "name", label: "Name", sortable: true, filterable: true }];

function table(rows, options = {}, attrs = "") {
  const model = {
    columns: COLUMNS,
    rows,
    options: { pageSize: 2, pageSizes: [2, 4], globalFilter: true, ...options }
  };
  return mount(`<div data-shad="data-table" ${attrs}>
    <script type="application/json">${JSON.stringify(model)}</script></div>`);
}
const textRows = (keys) => keys.map((k) => ({ key: k, cells: { name: "Name " + k } }));
const shown = (root) => Array.from(root.querySelectorAll("tbody tr[data-key]"),
  (tr) => tr.getAttribute("data-key"));

let warn;
beforeEach(() => {
  document.body.innerHTML = "";
  delete window.shad;
  loadRuntime("data-table");
  born = 0;
  warn = vi.spyOn(console, "warn").mockImplementation(() => {});
});
afterEach(() => {
  vi.useRealTimers();
  warn.mockRestore();
});

describe("cells", () => {
  it("reads HTML cells without bringing them to life (1)", () => {
    vi.useFakeTimers();
    const html = (name) => ({ html: "<x-probe></x-probe>" + name });
    const root = table([
      { key: "b", cells: { name: html("Beta") } },
      { key: "a", cells: { name: html("Alpha") } },
      { key: "c", cells: { name: html("Gamma") } }
    ], { pageSize: 1, pageSizes: [1] });
    expect(shown(root)).toEqual(["b"]);
    expect(born).toBe(1);                       // the row on the page

    root.querySelector(".shad-data-table__sort").click();
    expect(shown(root)).toEqual(["a"]);         // sorted by the cell text
    expect(born).toBe(2);                       // plus the newly shown row

    const filter = root.querySelector(".shad-data-table__filter");
    filter.value = "zzz";
    filter.dispatchEvent(new window.Event("input", { bubbles: true }));
    vi.advanceTimersByTime(150);
    expect(shown(root)).toEqual([]);
    expect(born).toBe(2);                       // every row read, none alive

    filter.value = "gam";
    filter.dispatchEvent(new window.Event("input", { bubbles: true }));
    vi.advanceTimersByTime(150);
    expect(shown(root)).toEqual(["c"]);
    expect(born).toBe(3);
  });
});

describe("updates from the server", () => {
  function serverTable() {
    const root = table([], { loading: true }, 'data-selection="multiple"');
    const inst = window.shad.get(root);
    inst.enableServerMode({ totalRows: 8, filteredRows: 8 });
    return { root, inst };
  }
  const page = (requestId, keys) => ({
    requestId, rows: textRows(keys), columns: COLUMNS, totalRows: 8, filteredRows: 8
  });
  const summary = (root) => root.querySelector(".shad-data-table__summary").textContent;

  it("asks the server for a patched page (2)", () => {
    const { root, inst } = serverTable();
    inst.setServerPage(page(1, ["a", "b"]));

    inst.setValue({ page: 3 });
    expect(inst.getValue()).toMatchObject({ requestId: 2, page: 3 });
    expect(root.getAttribute("aria-busy")).toBe("true");
    expect(shown(root)).toEqual([]);
    inst.setServerPage(page(2, ["e", "f"]));
    expect(shown(root)).toEqual(["e", "f"]);
    expect(summary(root)).toContain("5–6 of 8 rows");

    inst.setValue({ page: 99 });                // 8 rows at 2 a page: 4 pages
    expect(inst.getValue()).toMatchObject({ requestId: 3, page: 4 });
  });

  it("starts a patched page size at page 1 (2)", () => {
    const { root, inst } = serverTable();
    inst.setServerPage(page(1, ["a", "b"]));
    root.querySelector('[aria-label="Next page"]').click();
    inst.setServerPage(page(2, ["c", "d"]));

    inst.setValue({ pageSize: 4 });
    expect(inst.getValue()).toMatchObject({ requestId: 3, page: 1, pageSize: 4 });
    expect(root.querySelector("select").value).toBe("4");
  });

  it("asks for nothing on a selection patch (2)", () => {
    const { inst } = serverTable();
    inst.setServerPage(page(1, ["a", "b"]));
    inst.setValue({ selected: ["a"] });
    expect(inst.getValue()).toMatchObject({ requestId: 1, selected: ["a"] });
  });

  it("ignores a page size it does not offer (3)", () => {
    const root = table(textRows(["a", "b", "c", "d", "e"]));
    const inst = window.shad.get(root);
    const select = root.querySelector("select");

    inst.setValue({ pageSize: 3 });
    expect(inst.getValue().pageSize).toBe(2);
    expect(select.value).toBe("2");
    expect(shown(root)).toEqual(["a", "b"]);
    expect(warn).toHaveBeenCalledTimes(1);
    expect(String(warn.mock.calls[0])).toContain("3");

    inst.setValue({ pageSize: 4 });
    expect(select.value).toBe("4");
    expect(shown(root)).toEqual(["a", "b", "c", "d"]);
  });

  it("takes at most one key in single selection (4)", () => {
    const root = table(textRows(["a", "b"]), {}, 'data-selection="single"');
    const inst = window.shad.get(root);

    inst.setValue({ selected: ["a", "b"] });
    expect(inst.getValue().selected).toEqual([]);
    expect(root.querySelectorAll('tr[data-state="selected"]')).toHaveLength(0);
    expect(warn).toHaveBeenCalledTimes(1);

    inst.setValue({ selected: ["b"] });
    expect(inst.getValue().selected).toEqual(["b"]);
  });
});

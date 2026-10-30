import { describe, test, expect, beforeEach, afterEach, vi } from "vitest";
import { loadRuntime, mount, record } from "./helpers.js";

let shad;

function tableMarkup(options = {}) {
  const opts = JSON.stringify({
    pageSize: 2,
    pageSizes: [2, 4],
    globalFilter: true,
    columnFilters: true,
    selection: "multiple",
    loading: true,
    ...options
  });
  return `<div data-shad="data-table" data-global-filter data-column-filters
      data-selection="multiple" data-page-size="2">
    <script type="application/json">${JSON.stringify({
      columns: [
        { key: "id", label: "ID", sortable: true, filterable: true },
        { key: "name", label: "Name", sortable: true, filterable: true }
      ],
      rows: [],
      options: JSON.parse(opts)
    })}</script>
  </div>`;
}

function rows(ids) {
  return ids.map((id) => ({ key: id, cells: {
    id,
    name: `Name ${id}`
  }}));
}

function response(requestId, ids, filteredRows = ids.length, totalRows = filteredRows) {
  return {
    requestId,
    rows: rows(ids),
    columns: [
      { key: "id", label: "ID", sortable: true, filterable: true },
      { key: "name", label: "Name", sortable: true, filterable: true }
    ],
    totalRows,
    filteredRows
  };
}

beforeEach(() => {
  document.body.innerHTML = "";
  delete window.shad;
  shad = loadRuntime("data-table");
});

afterEach(() => {
  vi.useRealTimers();
});

describe("server-backed data table", () => {
  test("requests an initial page and reports server totals", () => {
    const root = mount(tableMarkup());
    const changes = record(root, "shad:change");
    const table = shad.get(root);

    table.enableServerMode({
      columns: [
        { key: "id", label: "ID", sortable: true, filterable: true },
        { key: "name", label: "Name", sortable: true, filterable: true }
      ],
      totalRows: 100000,
      filteredRows: 100000
    });

    expect(changes).toHaveLength(1);
    expect(changes[0].value.requestId).toBe(1);
    expect(changes[0].value.page).toBe(1);
    expect(root.getAttribute("aria-busy")).toBe("true");

    table.setServerPage(response(1, ["a", "b"], 100000, 100000));
    expect(root.getAttribute("aria-busy")).toBe("false");
    expect(root.querySelectorAll("tbody tr[data-key]")).toHaveLength(2);
    expect(root.querySelector(".shad-data-table__summary").textContent).toContain("100000 rows");
    expect(table.getValue().requestId).toBe(1);

    table.setServerPage(response(1, ["a"], 50, 100));
    expect(root.querySelector(".shad-data-table__summary").textContent).toContain("100 total");
  });

  test("rejects stale pages and keeps the newest request authoritative", () => {
    const root = mount(tableMarkup());
    const table = shad.get(root);
    table.enableServerMode({ totalRows: 8, filteredRows: 8 });
    expect(table.getValue().requestId).toBe(1);

    root.querySelector('[aria-label="Next page"]').click();
    expect(table.getValue().requestId).toBe(2);
    table.setServerPage(response(1, ["old-a", "old-b"], 8));
    expect(root.getAttribute("aria-busy")).toBe("true");
    expect(root.querySelector("tbody").textContent).not.toContain("old-a");

    table.setServerPage(response(2, ["new-a", "new-b"], 8));
    expect(root.querySelector("tbody").textContent).toContain("new-a");
    expect(root.querySelector("tbody").textContent).not.toContain("old-a");
  });

  test("sends server sort, filter, and page-size requests", () => {
    vi.useFakeTimers();
    const root = mount(tableMarkup());
    const changes = record(root, "shad:change");
    const table = shad.get(root);
    table.enableServerMode({ totalRows: 8, filteredRows: 8 });
    table.setServerPage(response(1, ["a", "b"], 8));

    root.querySelector('[data-col="name"] .shad-data-table__sort').click();
    expect(changes.at(-1).value.requestId).toBe(2);
    expect(changes.at(-1).value.sort).toEqual([{ col: "name", dir: "asc" }]);

    const filter = root.querySelector('.shad-data-table__filter');
    filter.value = "search";
    filter.dispatchEvent(new Event("input", { bubbles: true }));
    vi.advanceTimersByTime(150);
    expect(changes.at(-1).value.requestId).toBe(3);
    expect(changes.at(-1).value.filter.global).toBe("search");

    const pageSize = root.querySelector("select");
    pageSize.value = "4";
    pageSize.dispatchEvent(new Event("change", { bubbles: true }));
    expect(changes.at(-1).value.requestId).toBe(4);
    expect(changes.at(-1).value.pageSize).toBe(4);
  });

  test("shows a fixed safe error and retries without exposing detail", () => {
    const root = mount(tableMarkup());
    const changes = record(root, "shad:change");
    const table = shad.get(root);
    table.enableServerMode({ totalRows: 8, filteredRows: 8 });
    table.setServerError({ requestId: 1, message: "database password=secret" });

    const alert = root.querySelector('[role="alert"]');
    expect(alert).not.toBeNull();
    expect(alert.textContent).toContain("Unable to load data");
    expect(alert.textContent).not.toContain("secret");
    expect(root.getAttribute("aria-busy")).toBe("false");

    root.querySelector(".shad-data-table__retry").click();
    expect(changes.at(-1).value.requestId).toBe(2);
    expect(root.getAttribute("aria-busy")).toBe("true");
  });

  test("keeps selected keys across server pages and preserves action focus", () => {
    const root = mount(tableMarkup());
    const table = shad.get(root);
    table.enableServerMode({ totalRows: 4, filteredRows: 4 });
    table.setServerPage(response(1, ["a", "b"], 4));

    const next = root.querySelector('[aria-label="Next page"]');
    next.focus();
    next.click();
    table.setServerPage(response(2, ["c", "d"], 4));
    expect(document.activeElement.getAttribute("aria-label")).toBe("Page 2");

    root.querySelector('tr[data-key="c"] .shad-checkbox').click();
    expect(table.getValue().selected).toEqual(["c"]);
    table.setServerPage(response(2, ["c", "d"], 4));
    expect(root.querySelector('tr[data-key="c"]').getAttribute("data-state")).toBe("selected");
  });

  test("clears debounce work during teardown", () => {
    vi.useFakeTimers();
    const root = mount(tableMarkup());
    const changes = record(root, "shad:change");
    const table = shad.get(root);
    table.enableServerMode({ totalRows: 8, filteredRows: 8 });
    const filter = root.querySelector('.shad-data-table__filter');
    filter.value = "pending";
    filter.dispatchEvent(new Event("input", { bubbles: true }));
    const beforeDestroy = changes.length;

    shad.destroy(root);
    vi.advanceTimersByTime(200);
    expect(changes).toHaveLength(beforeDestroy);
    expect(root.childElementCount).toBe(0);
  });
});

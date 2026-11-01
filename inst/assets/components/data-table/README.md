<!-- FILE: inst/assets/components/data-table/README.md -->
# data-table (Tier 2, V2)

Full shadcn Data Table over a client-side JSON row model, with an experimental
server-backed mode. **Composes** `table/table.css` (load first), `checkbox/checkbox.css` (selection), `native-select/` (page size), and `dropdown-menu/` css+js (column visibility) — declare these as load-order dependencies like context-menu does.

## Anatomy (JS-built from the JSON model)
```
div.shad-data-table[data-shad=data-table]
│    [data-selection=none|single|multiple] [data-sticky]
│    [data-global-filter] [data-column-filters] [data-page-size=N]
├─ script[type=application/json]        (row model — consumed at init)
├─ div.shad-data-table__toolbar
│  ├─ input.shad-data-table__filter     (global, debounced 150ms)
│  └─ div[data-shad=dropdown-menu]      (column visibility checkboxes)
├─ div.shad-data-table-viewport         (h-scroll; +max-height when sticky)
│  └─ table.shad-table
│     ├─ thead.shad-table__header
│     │  ├─ tr > th.shad-table__head[aria-sort]
│     │  │   └─ button.shad-data-table__sort[data-sort=asc|desc|none]
│     │  │      └─ svg.shad-data-table__sort-icon (+ __sort-index on multi)
│     │  └─ tr (optional per-column filter row: input.shad-data-table__col-filter)
│     └─ tbody.shad-table__body
│        └─ tr.shad-table__row[data-key][data-state=selected?]
│           ├─ td.shad-table__cell--select > button.shad-checkbox
│           └─ td.shad-table__cell         (pre-rendered HTML or escaped text)
└─ div.shad-data-table__footer
   ├─ div.shad-data-table__summary       ("x–y of z rows", "· n selected")
   ├─ label.shad-data-table__page-size > select.shad-native-select
   └─ nav.shad-data-table__pager > button.shad-data-table__page-btn / __page-ellipsis
```

## Row model
```json
{
  "columns": [{"key": "", "label": "", "sortable": true, "filterable": true, "visible": true}],
  "rows": [{"key": "row-id", "cells": {"colKey": "text OR number OR {html, text?, sort?}"}}],
  "options": {"selection": "…", "globalFilter": true, "columnFilters": true,
              "columnVisibility": true, "sticky": true, "maxHeight": "20rem",
              "pageSize": 10, "pageSizes": [10,25,50,100],
              "loading": false, "emptyText": "", "emptyHtml": "", "filterPlaceholder": ""}
}
```
Cell values: plain string/number → text-escaped by construction. Object form: `html` is inserted verbatim (**pre-rendered by R** — the JS never generates cell markup), `text` powers filtering, `sort` powers ordering (falls back to `text`, then the html's text). Without `text`, the html's text is read once from an inert `<template>`, so filtering and sorting never load an image or run a handler for rows off the page.

## Behavior
- **Sort**: click cycles asc → desc → none; Shift+click adds multi-sort (numbered indicator); `aria-sort` on `<th>`. Numeric-aware `localeCompare` fallback.
- **Filter**: global substring across all columns + optional per-column inputs; both debounced 150 ms; reset to page 1.
- **Pagination**: window = first, last, current ±1, ellipsis (V1 deviation #6); page-size select; summary line.
- **Selection**: keys persist across pages/filters; tri-state select-all applies to the current page only; `data-state="selected"` on rows.
- **Column visibility**: dropdown-menu checkbox items; at least one column stays visible.
- **Loading**: `options.loading` or `setValue({loading:true})` renders skeleton rows; `setData(rows)` clears it.
- **Performance**: only the current page is in the DOM; sort/filter run on the JS array. 5 000×20 verified interactive at 60 fps (sort ≈ single rAF).

### Server-backed mode (experimental)

`shad_data_table_server(id, source, columns = NULL, row_key = NULL,
max_page_size = 1000, session = shiny::getDefaultReactiveDomain())` reuses this
anatomy while keeping the full dataset in the server. `source(request)` receives `page`, `page_size`,
multi-sort keys, a global filter, and named column filters. It must return a
data frame containing at most `page_size` rows plus `total_rows` and
`filtered_rows`. The source owns query construction and must parameterize any
database work; the package does not provide database adapters.

Requests are checked before `source` runs: the page size is at most
`max_page_size`, `(page - 1) * page_size` fits an R integer, sort and filter
values are single strings, and no column is sorted twice. With `columns`, a
sort or filter must name a declared column that allows it; undeclared columns
in a response still show, but are offered for neither. A refused request logs
a server warning and shows the fixed error state. Contract: the top of
`tests/testthat/test-data-table-server.R`.

Server responses use the existing R cell serialization and trusted-HTML rules.
Request IDs are monotonic and stale responses are ignored. A supplied `row_key`
must be unique and non-missing on each page to keep selection stable across
requests. Editing, grouping, pivoting, aggregation, downloads, and spreadsheet
behavior remain outside this experimental mode.

## Methods / Events
| Member | Description |
|---|---|
| `getValue()` | `{selected, sort, filter, page, pageSize}`; server mode also includes `requestId` |
| `setValue(v)` | partial-state patch; re-renders + emits. A `pageSize` the table does not offer, or several `selected` keys in single mode, is ignored with `console.warn`; a new `pageSize` starts at page 1. In server mode a page, page-size, sort or filter patch requests that page instead |
| `setData(rows)` | server-pushed refresh; keeps selection keys; clears loading |
| `enableServerMode(config)` | experimental server mode; requests the initial page |
| `setServerPage(response)` | accepts only the current request ID and renders one page |
| `setServerError(response)` | shows a fixed safe error and retry action |
| `destroy()` | unbind + empty root |
| `shad:change` | `{value}` — fires on sort/filter/page/pageSize/selection change |

## Keyboard
Sort buttons, filter inputs, checkboxes, page-size select, and pager buttons are all native focusables in DOM order — Tab traverses; Enter/Space activates; Shift+Enter on a sort header multi-sorts (Shift+click equivalent).

## A11y
`aria-sort` on sortable headers; selection checkboxes are `role=checkbox` (`radio` in single mode) with `aria-checked` (mixed for tri-state); pager is a `nav[aria-label=Pagination]` with `aria-current="page"`; filters carry `aria-label`s. Empty/loading states are real table rows so screen readers stay in table context.

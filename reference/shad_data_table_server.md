# Server-backed interactive data table

Experimental server-side paging for
[`shad_data_table()`](https://orijitghosh.github.io/shadshiny/reference/shad_data_table.md).
The table sends a normalized request to `source` whenever its page, page
size, sort, or filter changes. `source` must return a list with `data`
(a data frame containing at most the requested page), `total_rows`, and
`filtered_rows`.

## Usage

``` r
shad_data_table_server(
  id,
  source,
  columns = NULL,
  row_key = NULL,
  max_page_size = 1000,
  session = shiny::getDefaultReactiveDomain()
)
```

## Arguments

- id:

  The data-table input id.

- source:

  A function accepting one normalized request list and returning
  `list(data = <data.frame>, total_rows = <integer>, filtered_rows = <integer>)`.

- columns:

  Optional named list of
  [`shad_col()`](https://orijitghosh.github.io/shadshiny/reference/shad_col.md)
  specs. When omitted, column metadata is inferred from the first
  response, and requests are not checked against the columns. Supply it
  so the server, not the browser, decides which columns can be sorted
  and filtered.

- row_key:

  Optional stable id column in each response page.

- max_page_size:

  The largest page size a request may ask for. Keep it at least the
  largest of the table's `page_sizes`.

- session:

  The Shiny session.

## Value

Invisibly, the Shiny observer driving the source.

## Details

The request passed to `source` has `page`, `page_size`, `sort` (a list
of `column`/`direction` pairs), and `filter` (a global string plus named
column filters). The response is serialized using the same
[`shad_col()`](https://orijitghosh.github.io/shadshiny/reference/shad_col.md)
formatters and trusted-HTML rules as the client-side table.

Supply a stable `row_key` column when selections must survive paging.
With `row_key = NULL`, the existing page-local row-index behavior is
retained and is not suitable for cross-page selection. This helper
deliberately does not provide editing, grouping, pivoting, aggregation,
downloads, or database adapter behavior; the source owns query
construction and parameterization.

Requests come from the browser, so they are checked before `source`
runs. The page size is at most `max_page_size`, the page's first row
fits in an R integer, every sort and filter value is a single string,
and no column is sorted twice. With `columns`, a sort column must be
declared and sortable, and a filtered column declared and filterable. A
request that fails is never passed to `source`: the server logs a
warning and the table shows its "Unable to load data." state.

The table switches to server mode when its value first reaches the
server, so a table rendered by
[`shiny::renderUI()`](https://rdrr.io/pkg/shiny/man/renderUI.html), or
rendered again, is served too: call `shad_data_table_server()` once,
beside the render, not inside it. Each rendering starts its request IDs
again; within one, a request older than the last one answered is
ignored.

## See also

Other shadshiny data table:
[`shad_col()`](https://orijitghosh.github.io/shadshiny/reference/shad_col.md),
[`shad_data_table()`](https://orijitghosh.github.io/shadshiny/reference/shad_data_table.md),
[`shad_fmt`](https://orijitghosh.github.io/shadshiny/reference/shad_fmt.md),
[`update_shad_data_table()`](https://orijitghosh.github.io/shadshiny/reference/update_shad_data_table.md)

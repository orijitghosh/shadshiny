# Update a data table from the server

Push new rows to a
[`shad_data_table()`](https://orijitghosh.github.io/shadshiny/reference/shad_data_table.md)
(replacing its data while keeping selection keys) and/or patch its
interaction state.

## Usage

``` r
update_shad_data_table(
  id,
  data = NULL,
  columns = NULL,
  row_key = NULL,
  selected = NULL,
  page = NULL,
  page_size = NULL,
  loading = NULL,
  session = shiny::getDefaultReactiveDomain()
)
```

## Arguments

- id:

  The input id (namespaced automatically).

- data:

  Optional new data frame; sent via the table's `setData()`.

- columns:

  The
  [`shad_col()`](https://orijitghosh.github.io/shadshiny/reference/shad_col.md)
  specs used when re-serializing `data`. Supply the same specs used at
  construction for consistent formatting.

- row_key:

  Row-key column (as in
  [`shad_data_table()`](https://orijitghosh.github.io/shadshiny/reference/shad_data_table.md))
  for the new data.

- selected:

  Optional character vector of row keys to select. A single-selection
  table ignores more than one key, with a browser console warning.

- page, page_size:

  Optional pagination patch, as positive whole numbers. A page size the
  table does not offer is ignored, with a browser console warning, and a
  new page size starts at page 1. On a server-backed table
  ([`shad_data_table_server()`](https://orijitghosh.github.io/shadshiny/reference/shad_data_table_server.md))
  either one asks the server for that page.

- loading:

  Optional logical to toggle the skeleton state.

- session:

  The Shiny session.

## Value

Invisibly `NULL`.

## See also

Other shadshiny data table:
[`shad_col()`](https://orijitghosh.github.io/shadshiny/reference/shad_col.md),
[`shad_data_table()`](https://orijitghosh.github.io/shadshiny/reference/shad_data_table.md),
[`shad_data_table_server()`](https://orijitghosh.github.io/shadshiny/reference/shad_data_table_server.md),
[`shad_fmt`](https://orijitghosh.github.io/shadshiny/reference/shad_fmt.md)

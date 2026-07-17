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

  Optional character vector of row keys to select.

- page, page_size:

  Optional pagination patch.

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
[`shad_fmt`](https://orijitghosh.github.io/shadshiny/reference/shad_fmt.md)

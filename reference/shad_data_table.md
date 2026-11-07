# Interactive data table

A shadcn-styled data table: client-side multi-sort (Shift+click), global
and per-column filtering, windowed pagination, row selection, and column
visibility, rendered from a data frame. It is a bound Shiny input:
`input$<inputId>` is a list with `selected` (row keys), `sort`,
`filter`, `page`, and `pageSize`. Only the current page is in the DOM,
so it stays responsive to a few thousand rows; for larger or
server-computed data push new rows with
[`update_shad_data_table()`](https://orijitghosh.github.io/shadshiny/reference/update_shad_data_table.md).

## Usage

``` r
shad_data_table(
  inputId,
  data,
  columns = NULL,
  row_key = NULL,
  selection = c("none", "single", "multiple"),
  filter = c("none", "global", "columns", "both"),
  page_size = 10,
  page_sizes = c(10, 25, 50, 100),
  sortable = TRUE,
  column_visibility = FALSE,
  sticky_header = FALSE,
  max_height = "24rem",
  empty = "No results.",
  filter_placeholder = "Filter rows...",
  columns_label = "Columns",
  page_size_label = "Rows per page",
  loading = FALSE,
  width = NULL,
  class = NULL,
  ...
)
```

## Arguments

- inputId:

  Input id.

- data:

  A data frame (or object coercible with
  [`as.data.frame()`](https://rdrr.io/r/base/as.data.frame.html)).

- columns:

  Optional named list of
  [`shad_col()`](https://orijitghosh.github.io/shadshiny/reference/shad_col.md)
  specs, keyed by column name. Columns without a spec use type-based
  defaults.

- row_key:

  Optional column name providing stable row identities. `NULL` uses the
  row index.

- selection:

  `"none"` (default), `"single"`, or `"multiple"`.

- filter:

  `"none"` (default), `"global"`, `"columns"`, or `"both"`.

- page_size:

  Initial rows per page, a positive whole number.

- page_sizes:

  Selectable page sizes, positive whole numbers. `page_size` is added
  when it is not among them.

- sortable:

  Master switch for column sorting (per-column overridable in
  [`shad_col()`](https://orijitghosh.github.io/shadshiny/reference/shad_col.md)).

- column_visibility:

  Show the column-visibility dropdown.

- sticky_header:

  Freeze the header and scroll the body within `max_height`.

- max_height:

  Viewport height when `sticky_header = TRUE`.

- empty:

  Text or tags shown when there are no rows.

- filter_placeholder:

  Placeholder for the global filter input.

- columns_label, page_size_label:

  Labels for the column-visibility trigger and page-size select.

- loading:

  If `TRUE`, render skeleton rows until
  [`update_shad_data_table()`](https://orijitghosh.github.io/shadshiny/reference/update_shad_data_table.md)
  supplies data.

- width:

  CSS width.

- class:

  Extra CSS classes.

- ...:

  Extra attributes on the root.

## Value

A data-table tag, bound as a Shiny input.

## Details

Row identity comes from `row_key` (a column of stable ids) or the
1-based row index. Selection is reported as these keys.

## See also

Other shadshiny data table:
[`shad_col()`](https://orijitghosh.github.io/shadshiny/reference/shad_col.md),
[`shad_data_table_server()`](https://orijitghosh.github.io/shadshiny/reference/shad_data_table_server.md),
[`shad_fmt`](https://orijitghosh.github.io/shadshiny/reference/shad_fmt.md),
[`update_shad_data_table()`](https://orijitghosh.github.io/shadshiny/reference/update_shad_data_table.md)

## Examples

``` r
if (interactive()) {
  shad_data_table(
    "tbl", head(mtcars),
    selection = "multiple", filter = "global",
    columns = list(mpg = shad_col("MPG", format = shad_fmt_number(1)))
  )
}
```

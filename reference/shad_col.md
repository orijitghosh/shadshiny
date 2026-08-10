# Column specification for [`shad_data_table()`](https://orijitghosh.github.io/shadshiny/reference/shad_data_table.md)

Describe how a single data-table column renders. Pass a named list of
these as the `columns` argument of
[`shad_data_table()`](https://orijitghosh.github.io/shadshiny/reference/shad_data_table.md),
keyed by data-frame column name; any column without a spec uses sensible
type-based defaults.

## Usage

``` r
shad_col(
  header = NULL,
  sortable = NULL,
  filterable = NULL,
  align = c("left", "center", "right"),
  width = NULL,
  visible = TRUE,
  html = FALSE,
  format = NULL,
  cell = NULL
)
```

## Arguments

- header:

  Column header label. `NULL` uses the data-frame column name.

- sortable:

  Whether the column is sortable. `NULL` inherits the table's `sortable`
  master switch.

- filterable:

  Whether the per-column filter (when enabled) applies here. `NULL`
  defaults to `TRUE`.

- align:

  `"left"` (default), `"center"`, or `"right"`.

- width:

  Optional CSS width for the column header.

- visible:

  Whether the column starts visible (column-visibility menu can toggle
  it).

- html:

  If `TRUE`, the column's character values are treated as trusted,
  pre-rendered HTML rather than escaped text. Mutually exclusive with
  `format`/`cell`.

- format:

  A formatter from
  [`shad_fmt_number()`](https://orijitghosh.github.io/shadshiny/reference/shad_fmt.md),
  [`shad_fmt_percent()`](https://orijitghosh.github.io/shadshiny/reference/shad_fmt.md),
  [`shad_fmt_date()`](https://orijitghosh.github.io/shadshiny/reference/shad_fmt.md),
  or
  [`shad_fmt_badge()`](https://orijitghosh.github.io/shadshiny/reference/shad_fmt.md).
  Mutually exclusive with `cell`.

- cell:

  A function `function(value, row)` returning an htmltools tag or
  character string, evaluated in R at render time (for embedding
  [`shad_badge()`](https://orijitghosh.github.io/shadshiny/reference/shad_badge.md),
  [`shad_button()`](https://orijitghosh.github.io/shadshiny/reference/shad_button.md),
  links, …). Mutually exclusive with `format`.

## Value

A `shad_col` specification list.

## See also

Other shadshiny data table:
[`shad_data_table()`](https://orijitghosh.github.io/shadshiny/reference/shad_data_table.md),
[`shad_fmt`](https://orijitghosh.github.io/shadshiny/reference/shad_fmt.md),
[`update_shad_data_table()`](https://orijitghosh.github.io/shadshiny/reference/update_shad_data_table.md)

## Examples

``` r
shad_col("Amount", format = shad_fmt_number(prefix = "$"))
#> $header
#> [1] "Amount"
#> 
#> $sortable
#> NULL
#> 
#> $filterable
#> NULL
#> 
#> $align
#> [1] "left"
#> 
#> $width
#> NULL
#> 
#> $visible
#> [1] TRUE
#> 
#> $html
#> [1] FALSE
#> 
#> $format
#> function (x) 
#> {
#>     num <- suppressWarnings(as.numeric(x))
#>     disp <- ifelse(is.na(num), NA_character_, paste0(prefix, 
#>         formatC(num, format = "f", digits = digits, big.mark = big_mark), 
#>         suffix))
#>     .cell_num(disp, num)
#> }
#> <bytecode: 0x55ff8146c630>
#> <environment: 0x55ff8146b7c0>
#> attr(,"class")
#> [1] "shad_fmt"
#> 
#> $cell
#> NULL
#> 
#> attr(,"class")
#> [1] "shad_col"
shad_col("Status", cell = function(v, row) shad_badge(v))
#> $header
#> [1] "Status"
#> 
#> $sortable
#> NULL
#> 
#> $filterable
#> NULL
#> 
#> $align
#> [1] "left"
#> 
#> $width
#> NULL
#> 
#> $visible
#> [1] TRUE
#> 
#> $html
#> [1] FALSE
#> 
#> $format
#> NULL
#> 
#> $cell
#> function (v, row) 
#> shad_badge(v)
#> <environment: 0x55ff8145c5f8>
#> 
#> attr(,"class")
#> [1] "shad_col"
```

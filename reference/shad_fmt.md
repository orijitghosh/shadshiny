# Cell formatters for [`shad_data_table()`](https://orijitghosh.github.io/shadshiny/reference/shad_data_table.md)

Declarative column formatters passed to `shad_col(format=)`. Each
renders a display string while preserving a numeric (or raw) sort key so
ordering stays correct.

## Usage

``` r
shad_fmt_number(digits = 2, big_mark = ",", prefix = "", suffix = "")

shad_fmt_percent(digits = 1)

shad_fmt_date(format = "%Y-%m-%d")

shad_fmt_badge(map)
```

## Arguments

- digits:

  Decimal places.

- big_mark:

  Thousands separator (number formatter).

- prefix, suffix:

  Strings wrapped around the formatted value.

- format:

  A [`base::strftime()`](https://rdrr.io/r/base/strptime.html) format
  string (date formatter).

- map:

  A named vector mapping cell values to
  [`shad_badge()`](https://orijitghosh.github.io/shadshiny/reference/shad_badge.md)
  variants, e.g. `c(active = "default", failed = "destructive")`.

## Value

A `shad_fmt` object (a function of the column vector).

## See also

Other shadshiny data table:
[`shad_col()`](https://orijitghosh.github.io/shadshiny/reference/shad_col.md),
[`shad_data_table()`](https://orijitghosh.github.io/shadshiny/reference/shad_data_table.md),
[`update_shad_data_table()`](https://orijitghosh.github.io/shadshiny/reference/update_shad_data_table.md)

## Examples

``` r
shad_fmt_number(digits = 2, prefix = "$")
#> function (x) 
#> {
#>     num <- suppressWarnings(as.numeric(x))
#>     disp <- ifelse(is.na(num), NA_character_, paste0(prefix, 
#>         formatC(num, format = "f", digits = digits, big.mark = big_mark), 
#>         suffix))
#>     .cell_num(disp, num)
#> }
#> <bytecode: 0x556dd02f4cd0>
#> <environment: 0x556dd1f9e328>
#> attr(,"class")
#> [1] "shad_fmt"
shad_fmt_percent(digits = 1)
#> function (x) 
#> {
#>     num <- suppressWarnings(as.numeric(x))
#>     disp <- ifelse(is.na(num), NA_character_, paste0(formatC(100 * 
#>         num, format = "f", digits = digits), "%"))
#>     .cell_num(disp, num)
#> }
#> <bytecode: 0x556dd1fcddf8>
#> <environment: 0x556dd1fd0fb0>
#> attr(,"class")
#> [1] "shad_fmt"
shad_fmt_date("%b %d, %Y")
#> function (x) 
#> {
#>     d <- if (inherits(x, c("Date", "POSIXct"))) 
#>         x
#>     else as.Date(as.character(x))
#>     disp <- ifelse(is.na(d), NA_character_, format(d, format))
#>     .cell_num(disp, as.numeric(d))
#> }
#> <bytecode: 0x556dd2005c50>
#> <environment: 0x556dd2004e50>
#> attr(,"class")
#> [1] "shad_fmt"
shad_fmt_badge(c(active = "default", failed = "destructive"))
#> function (x) 
#> {
#>     xs <- as.character(x)
#>     lapply(xs, function(v) {
#>         if (is.na(v)) 
#>             return(NULL)
#>         variant <- if (!is.na(map[v]) && nzchar(map[v])) 
#>             unname(map[v])
#>         else "default"
#>         html <- htmltools::doRenderTags(shad_badge(v, variant = variant))
#>         list(html = html, text = v, sort = v)
#>     })
#> }
#> <bytecode: 0x556dd20390a0>
#> <environment: 0x556dd203ace8>
#> attr(,"class")
#> [1] "shad_fmt"
```

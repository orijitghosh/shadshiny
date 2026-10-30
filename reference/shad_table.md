# Table

A styled table. Pass a data frame for automatic rendering, or compose
manually with the part constructors.

## Usage

``` r
shad_table(
  x = NULL,
  ...,
  striped = FALSE,
  hover = FALSE,
  sticky_header = FALSE,
  caption = NULL,
  class = NULL
)

shad_table_header(..., class = NULL)

shad_table_body(..., class = NULL)

shad_table_footer(..., class = NULL)

shad_table_row(..., class = NULL)

shad_table_head(..., scope = "col", class = NULL)

shad_table_cell(..., class = NULL)

shad_table_caption(..., class = NULL)
```

## Arguments

- x:

  Optional data frame. When supplied, header and body are generated
  automatically.

- ...:

  Table sections when composing manually (and optional attributes).

- striped, hover, sticky_header:

  Style options.

- caption:

  Optional caption text.

- class:

  Extra CSS classes.

- scope:

  `<th>` scope attribute.

## Value

A `<div class="shad-table-container">` wrapping a `<table>`.

## See also

Other shadshiny tier-1 components:
[`shad_alert()`](https://orijitghosh.github.io/shadshiny/reference/shad_alert.md),
[`shad_aspect_ratio()`](https://orijitghosh.github.io/shadshiny/reference/shad_aspect_ratio.md),
[`shad_avatar()`](https://orijitghosh.github.io/shadshiny/reference/shad_avatar.md),
[`shad_badge()`](https://orijitghosh.github.io/shadshiny/reference/shad_badge.md),
[`shad_breadcrumb()`](https://orijitghosh.github.io/shadshiny/reference/shad_breadcrumb.md),
[`shad_button()`](https://orijitghosh.github.io/shadshiny/reference/shad_button.md),
[`shad_button_group()`](https://orijitghosh.github.io/shadshiny/reference/shad_button_group.md),
[`shad_card()`](https://orijitghosh.github.io/shadshiny/reference/shad_card.md),
[`shad_code_block()`](https://orijitghosh.github.io/shadshiny/reference/shad_code_block.md),
[`shad_empty()`](https://orijitghosh.github.io/shadshiny/reference/shad_empty.md),
[`shad_item()`](https://orijitghosh.github.io/shadshiny/reference/shad_item.md),
[`shad_kbd_group()`](https://orijitghosh.github.io/shadshiny/reference/shad_kbd_group.md),
[`shad_label()`](https://orijitghosh.github.io/shadshiny/reference/shad_label.md),
[`shad_progress()`](https://orijitghosh.github.io/shadshiny/reference/shad_progress.md),
[`shad_scroll_fade()`](https://orijitghosh.github.io/shadshiny/reference/shad_scroll_fade.md),
[`shad_separator()`](https://orijitghosh.github.io/shadshiny/reference/shad_separator.md),
[`shad_shimmer()`](https://orijitghosh.github.io/shadshiny/reference/shad_shimmer.md),
[`shad_skeleton()`](https://orijitghosh.github.io/shadshiny/reference/shad_skeleton.md),
[`shad_spinner()`](https://orijitghosh.github.io/shadshiny/reference/shad_spinner.md),
[`shad_typography`](https://orijitghosh.github.io/shadshiny/reference/shad_typography.md)

## Examples

``` r
shad_table(head(mtcars), striped = TRUE)
#> <div class="shad-table-container">
#>   <table class="shad-table shad-table--striped">
#>     <thead class="shad-table__header">
#>       <tr class="shad-table__row">
#>         <th class="shad-table__head" scope="col">mpg</th>
#>         <th class="shad-table__head" scope="col">cyl</th>
#>         <th class="shad-table__head" scope="col">disp</th>
#>         <th class="shad-table__head" scope="col">hp</th>
#>         <th class="shad-table__head" scope="col">drat</th>
#>         <th class="shad-table__head" scope="col">wt</th>
#>         <th class="shad-table__head" scope="col">qsec</th>
#>         <th class="shad-table__head" scope="col">vs</th>
#>         <th class="shad-table__head" scope="col">am</th>
#>         <th class="shad-table__head" scope="col">gear</th>
#>         <th class="shad-table__head" scope="col">carb</th>
#>       </tr>
#>     </thead>
#>     <tbody class="shad-table__body">
#>       <tr class="shad-table__row" mpg="&lt;td class=&quot;shad-table__cell&quot;&gt;21&lt;/td&gt;" cyl="&lt;td class=&quot;shad-table__cell&quot;&gt;6&lt;/td&gt;" disp="&lt;td class=&quot;shad-table__cell&quot;&gt;160&lt;/td&gt;" hp="&lt;td class=&quot;shad-table__cell&quot;&gt;110&lt;/td&gt;" drat="&lt;td class=&quot;shad-table__cell&quot;&gt;3.9&lt;/td&gt;" wt="&lt;td class=&quot;shad-table__cell&quot;&gt;2.62&lt;/td&gt;" qsec="&lt;td class=&quot;shad-table__cell&quot;&gt;16.46&lt;/td&gt;" vs="&lt;td class=&quot;shad-table__cell&quot;&gt;0&lt;/td&gt;" am="&lt;td class=&quot;shad-table__cell&quot;&gt;1&lt;/td&gt;" gear="&lt;td class=&quot;shad-table__cell&quot;&gt;4&lt;/td&gt;" carb="&lt;td class=&quot;shad-table__cell&quot;&gt;4&lt;/td&gt;"></tr>
#>       <tr class="shad-table__row" mpg="&lt;td class=&quot;shad-table__cell&quot;&gt;21&lt;/td&gt;" cyl="&lt;td class=&quot;shad-table__cell&quot;&gt;6&lt;/td&gt;" disp="&lt;td class=&quot;shad-table__cell&quot;&gt;160&lt;/td&gt;" hp="&lt;td class=&quot;shad-table__cell&quot;&gt;110&lt;/td&gt;" drat="&lt;td class=&quot;shad-table__cell&quot;&gt;3.9&lt;/td&gt;" wt="&lt;td class=&quot;shad-table__cell&quot;&gt;2.875&lt;/td&gt;" qsec="&lt;td class=&quot;shad-table__cell&quot;&gt;17.02&lt;/td&gt;" vs="&lt;td class=&quot;shad-table__cell&quot;&gt;0&lt;/td&gt;" am="&lt;td class=&quot;shad-table__cell&quot;&gt;1&lt;/td&gt;" gear="&lt;td class=&quot;shad-table__cell&quot;&gt;4&lt;/td&gt;" carb="&lt;td class=&quot;shad-table__cell&quot;&gt;4&lt;/td&gt;"></tr>
#>       <tr class="shad-table__row" mpg="&lt;td class=&quot;shad-table__cell&quot;&gt;22.8&lt;/td&gt;" cyl="&lt;td class=&quot;shad-table__cell&quot;&gt;4&lt;/td&gt;" disp="&lt;td class=&quot;shad-table__cell&quot;&gt;108&lt;/td&gt;" hp="&lt;td class=&quot;shad-table__cell&quot;&gt;93&lt;/td&gt;" drat="&lt;td class=&quot;shad-table__cell&quot;&gt;3.85&lt;/td&gt;" wt="&lt;td class=&quot;shad-table__cell&quot;&gt;2.32&lt;/td&gt;" qsec="&lt;td class=&quot;shad-table__cell&quot;&gt;18.61&lt;/td&gt;" vs="&lt;td class=&quot;shad-table__cell&quot;&gt;1&lt;/td&gt;" am="&lt;td class=&quot;shad-table__cell&quot;&gt;1&lt;/td&gt;" gear="&lt;td class=&quot;shad-table__cell&quot;&gt;4&lt;/td&gt;" carb="&lt;td class=&quot;shad-table__cell&quot;&gt;1&lt;/td&gt;"></tr>
#>       <tr class="shad-table__row" mpg="&lt;td class=&quot;shad-table__cell&quot;&gt;21.4&lt;/td&gt;" cyl="&lt;td class=&quot;shad-table__cell&quot;&gt;6&lt;/td&gt;" disp="&lt;td class=&quot;shad-table__cell&quot;&gt;258&lt;/td&gt;" hp="&lt;td class=&quot;shad-table__cell&quot;&gt;110&lt;/td&gt;" drat="&lt;td class=&quot;shad-table__cell&quot;&gt;3.08&lt;/td&gt;" wt="&lt;td class=&quot;shad-table__cell&quot;&gt;3.215&lt;/td&gt;" qsec="&lt;td class=&quot;shad-table__cell&quot;&gt;19.44&lt;/td&gt;" vs="&lt;td class=&quot;shad-table__cell&quot;&gt;1&lt;/td&gt;" am="&lt;td class=&quot;shad-table__cell&quot;&gt;0&lt;/td&gt;" gear="&lt;td class=&quot;shad-table__cell&quot;&gt;3&lt;/td&gt;" carb="&lt;td class=&quot;shad-table__cell&quot;&gt;1&lt;/td&gt;"></tr>
#>       <tr class="shad-table__row" mpg="&lt;td class=&quot;shad-table__cell&quot;&gt;18.7&lt;/td&gt;" cyl="&lt;td class=&quot;shad-table__cell&quot;&gt;8&lt;/td&gt;" disp="&lt;td class=&quot;shad-table__cell&quot;&gt;360&lt;/td&gt;" hp="&lt;td class=&quot;shad-table__cell&quot;&gt;175&lt;/td&gt;" drat="&lt;td class=&quot;shad-table__cell&quot;&gt;3.15&lt;/td&gt;" wt="&lt;td class=&quot;shad-table__cell&quot;&gt;3.44&lt;/td&gt;" qsec="&lt;td class=&quot;shad-table__cell&quot;&gt;17.02&lt;/td&gt;" vs="&lt;td class=&quot;shad-table__cell&quot;&gt;0&lt;/td&gt;" am="&lt;td class=&quot;shad-table__cell&quot;&gt;0&lt;/td&gt;" gear="&lt;td class=&quot;shad-table__cell&quot;&gt;3&lt;/td&gt;" carb="&lt;td class=&quot;shad-table__cell&quot;&gt;2&lt;/td&gt;"></tr>
#>       <tr class="shad-table__row" mpg="&lt;td class=&quot;shad-table__cell&quot;&gt;18.1&lt;/td&gt;" cyl="&lt;td class=&quot;shad-table__cell&quot;&gt;6&lt;/td&gt;" disp="&lt;td class=&quot;shad-table__cell&quot;&gt;225&lt;/td&gt;" hp="&lt;td class=&quot;shad-table__cell&quot;&gt;105&lt;/td&gt;" drat="&lt;td class=&quot;shad-table__cell&quot;&gt;2.76&lt;/td&gt;" wt="&lt;td class=&quot;shad-table__cell&quot;&gt;3.46&lt;/td&gt;" qsec="&lt;td class=&quot;shad-table__cell&quot;&gt;20.22&lt;/td&gt;" vs="&lt;td class=&quot;shad-table__cell&quot;&gt;1&lt;/td&gt;" am="&lt;td class=&quot;shad-table__cell&quot;&gt;0&lt;/td&gt;" gear="&lt;td class=&quot;shad-table__cell&quot;&gt;3&lt;/td&gt;" carb="&lt;td class=&quot;shad-table__cell&quot;&gt;1&lt;/td&gt;"></tr>
#>     </tbody>
#>   </table>
#> </div>
```

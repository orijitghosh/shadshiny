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
#>       <tr class="shad-table__row">
#>         <td class="shad-table__cell">21</td>
#>         <td class="shad-table__cell">6</td>
#>         <td class="shad-table__cell">160</td>
#>         <td class="shad-table__cell">110</td>
#>         <td class="shad-table__cell">3.9</td>
#>         <td class="shad-table__cell">2.62</td>
#>         <td class="shad-table__cell">16.46</td>
#>         <td class="shad-table__cell">0</td>
#>         <td class="shad-table__cell">1</td>
#>         <td class="shad-table__cell">4</td>
#>         <td class="shad-table__cell">4</td>
#>       </tr>
#>       <tr class="shad-table__row">
#>         <td class="shad-table__cell">21</td>
#>         <td class="shad-table__cell">6</td>
#>         <td class="shad-table__cell">160</td>
#>         <td class="shad-table__cell">110</td>
#>         <td class="shad-table__cell">3.9</td>
#>         <td class="shad-table__cell">2.875</td>
#>         <td class="shad-table__cell">17.02</td>
#>         <td class="shad-table__cell">0</td>
#>         <td class="shad-table__cell">1</td>
#>         <td class="shad-table__cell">4</td>
#>         <td class="shad-table__cell">4</td>
#>       </tr>
#>       <tr class="shad-table__row">
#>         <td class="shad-table__cell">22.8</td>
#>         <td class="shad-table__cell">4</td>
#>         <td class="shad-table__cell">108</td>
#>         <td class="shad-table__cell">93</td>
#>         <td class="shad-table__cell">3.85</td>
#>         <td class="shad-table__cell">2.32</td>
#>         <td class="shad-table__cell">18.61</td>
#>         <td class="shad-table__cell">1</td>
#>         <td class="shad-table__cell">1</td>
#>         <td class="shad-table__cell">4</td>
#>         <td class="shad-table__cell">1</td>
#>       </tr>
#>       <tr class="shad-table__row">
#>         <td class="shad-table__cell">21.4</td>
#>         <td class="shad-table__cell">6</td>
#>         <td class="shad-table__cell">258</td>
#>         <td class="shad-table__cell">110</td>
#>         <td class="shad-table__cell">3.08</td>
#>         <td class="shad-table__cell">3.215</td>
#>         <td class="shad-table__cell">19.44</td>
#>         <td class="shad-table__cell">1</td>
#>         <td class="shad-table__cell">0</td>
#>         <td class="shad-table__cell">3</td>
#>         <td class="shad-table__cell">1</td>
#>       </tr>
#>       <tr class="shad-table__row">
#>         <td class="shad-table__cell">18.7</td>
#>         <td class="shad-table__cell">8</td>
#>         <td class="shad-table__cell">360</td>
#>         <td class="shad-table__cell">175</td>
#>         <td class="shad-table__cell">3.15</td>
#>         <td class="shad-table__cell">3.44</td>
#>         <td class="shad-table__cell">17.02</td>
#>         <td class="shad-table__cell">0</td>
#>         <td class="shad-table__cell">0</td>
#>         <td class="shad-table__cell">3</td>
#>         <td class="shad-table__cell">2</td>
#>       </tr>
#>       <tr class="shad-table__row">
#>         <td class="shad-table__cell">18.1</td>
#>         <td class="shad-table__cell">6</td>
#>         <td class="shad-table__cell">225</td>
#>         <td class="shad-table__cell">105</td>
#>         <td class="shad-table__cell">2.76</td>
#>         <td class="shad-table__cell">3.46</td>
#>         <td class="shad-table__cell">20.22</td>
#>         <td class="shad-table__cell">1</td>
#>         <td class="shad-table__cell">0</td>
#>         <td class="shad-table__cell">3</td>
#>         <td class="shad-table__cell">1</td>
#>       </tr>
#>     </tbody>
#>   </table>
#> </div>
```

# Scroll fade container

Add CSS-only edge fades to a keyboard-focusable scrolling container.

## Usage

``` r
shad_scroll_fade(..., axis = c("vertical", "horizontal", "both"), class = NULL)
```

## Arguments

- ...:

  Child content and optional attributes.

- axis:

  One of vertical, horizontal, or both.

- class:

  Extra CSS classes.

## Value

A scrolling div tag.

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
[`shad_separator()`](https://orijitghosh.github.io/shadshiny/reference/shad_separator.md),
[`shad_shimmer()`](https://orijitghosh.github.io/shadshiny/reference/shad_shimmer.md),
[`shad_skeleton()`](https://orijitghosh.github.io/shadshiny/reference/shad_skeleton.md),
[`shad_spinner()`](https://orijitghosh.github.io/shadshiny/reference/shad_spinner.md),
[`shad_table()`](https://orijitghosh.github.io/shadshiny/reference/shad_table.md),
[`shad_typography`](https://orijitghosh.github.io/shadshiny/reference/shad_typography.md)

## Examples

``` r
shad_scroll_fade(
  style = "max-height: 8rem",
  htmltools::tags$ul(lapply(1:20, function(i) htmltools::tags$li("Item ", i)))
)
#> <div class="shad-scroll-fade" tabindex="0" data-axis="vertical" style="max-height: 8rem">
#>   <ul>
#>     <li>
#>       Item 
#>       1
#>     </li>
#>     <li>
#>       Item 
#>       2
#>     </li>
#>     <li>
#>       Item 
#>       3
#>     </li>
#>     <li>
#>       Item 
#>       4
#>     </li>
#>     <li>
#>       Item 
#>       5
#>     </li>
#>     <li>
#>       Item 
#>       6
#>     </li>
#>     <li>
#>       Item 
#>       7
#>     </li>
#>     <li>
#>       Item 
#>       8
#>     </li>
#>     <li>
#>       Item 
#>       9
#>     </li>
#>     <li>
#>       Item 
#>       10
#>     </li>
#>     <li>
#>       Item 
#>       11
#>     </li>
#>     <li>
#>       Item 
#>       12
#>     </li>
#>     <li>
#>       Item 
#>       13
#>     </li>
#>     <li>
#>       Item 
#>       14
#>     </li>
#>     <li>
#>       Item 
#>       15
#>     </li>
#>     <li>
#>       Item 
#>       16
#>     </li>
#>     <li>
#>       Item 
#>       17
#>     </li>
#>     <li>
#>       Item 
#>       18
#>     </li>
#>     <li>
#>       Item 
#>       19
#>     </li>
#>     <li>
#>       Item 
#>       20
#>     </li>
#>   </ul>
#> </div>
```

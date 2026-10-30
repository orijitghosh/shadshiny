# Button group

Joins adjoining buttons into a single segmented control: inner corners
collapse, the shared 1px border renders once, and the hovered/focused
button raises so its full outline shows. Drop in ordinary
[`shad_button()`](https://orijitghosh.github.io/shadshiny/reference/shad_button.md)s
(any variant; `"outline"` reads best) plus optional
`shad_button_group_text()` label segments and
`shad_button_group_separator()` hairlines.

## Usage

``` r
shad_button_group(
  ...,
  orientation = c("horizontal", "vertical"),
  aria_label = NULL,
  class = NULL
)

shad_button_group_separator(class = NULL)

shad_button_group_text(..., class = NULL)
```

## Arguments

- ...:

  Buttons and group parts, and/or named HTML attributes.

- orientation:

  `"horizontal"` (default) or `"vertical"`.

- aria_label:

  Accessible label describing the group.

- class:

  Extra CSS classes.

## Value

A button-group tag.

## See also

[`shad_button()`](https://orijitghosh.github.io/shadshiny/reference/shad_button.md),
`shad_button_group_text()`, `shad_button_group_separator()`

Other shadshiny tier-1 components:
[`shad_alert()`](https://orijitghosh.github.io/shadshiny/reference/shad_alert.md),
[`shad_aspect_ratio()`](https://orijitghosh.github.io/shadshiny/reference/shad_aspect_ratio.md),
[`shad_avatar()`](https://orijitghosh.github.io/shadshiny/reference/shad_avatar.md),
[`shad_badge()`](https://orijitghosh.github.io/shadshiny/reference/shad_badge.md),
[`shad_breadcrumb()`](https://orijitghosh.github.io/shadshiny/reference/shad_breadcrumb.md),
[`shad_button()`](https://orijitghosh.github.io/shadshiny/reference/shad_button.md),
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
[`shad_table()`](https://orijitghosh.github.io/shadshiny/reference/shad_table.md),
[`shad_typography`](https://orijitghosh.github.io/shadshiny/reference/shad_typography.md)

## Examples

``` r
shad_button_group(
  shad_button("Left", variant = "outline"),
  shad_button("Center", variant = "outline"),
  shad_button("Right", variant = "outline"),
  aria_label = "Text alignment"
)
#> <div class="shad-button-group" role="group" data-orientation="horizontal" aria-label="Text alignment">
#>   <button type="button" class="shad-btn shad-btn--outline">Left</button>
#>   <button type="button" class="shad-btn shad-btn--outline">Center</button>
#>   <button type="button" class="shad-btn shad-btn--outline">Right</button>
#> </div>
```

# Progress bar

A determinate or indeterminate progress indicator.

## Usage

``` r
shad_progress(
  value = NULL,
  max = 100,
  indeterminate = is.null(value),
  inputId = NULL,
  label = "Loading",
  class = NULL,
  ...
)
```

## Arguments

- value:

  Current value (`0`..`max`), or `NULL` for indeterminate.

- max:

  Maximum value. Default `100`.

- indeterminate:

  If `TRUE`, renders the indeterminate animation. Defaults to `TRUE`
  when `value` is `NULL`.

- inputId:

  Optional id (enables
  [`update_shad_progress()`](https://orijitghosh.github.io/shadshiny/reference/update_shad.md)).

- label:

  Accessible label for the progress bar.

- class:

  Extra CSS classes.

- ...:

  Extra attributes.

## Value

A `<div class="shad-progress" role="progressbar">`.

## See also

[`update_shad_progress()`](https://orijitghosh.github.io/shadshiny/reference/update_shad.md)

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
[`shad_scroll_fade()`](https://orijitghosh.github.io/shadshiny/reference/shad_scroll_fade.md),
[`shad_separator()`](https://orijitghosh.github.io/shadshiny/reference/shad_separator.md),
[`shad_shimmer()`](https://orijitghosh.github.io/shadshiny/reference/shad_shimmer.md),
[`shad_skeleton()`](https://orijitghosh.github.io/shadshiny/reference/shad_skeleton.md),
[`shad_spinner()`](https://orijitghosh.github.io/shadshiny/reference/shad_spinner.md),
[`shad_table()`](https://orijitghosh.github.io/shadshiny/reference/shad_table.md),
[`shad_typography`](https://orijitghosh.github.io/shadshiny/reference/shad_typography.md)

## Examples

``` r
shad_progress(60)
#> <div class="shad-progress" role="progressbar" aria-valuemin="0" aria-valuemax="100" aria-valuenow="60" aria-label="Loading" data-state="loading">
#>   <div class="shad-progress__indicator" style="transform: translateX(-40%);"></div>
#> </div>
shad_progress(indeterminate = TRUE)
#> <div class="shad-progress" role="progressbar" data-state="indeterminate" aria-label="Loading">
#>   <div class="shad-progress__indicator"></div>
#> </div>
```

# Alert

A callout banner with an optional icon.

## Usage

``` r
shad_alert(
  title = NULL,
  ...,
  variant = c("default", "destructive"),
  icon = NULL,
  class = NULL
)
```

## Arguments

- title:

  Alert title. Optional.

- ...:

  Description content (and optional named attributes).

- variant:

  One of `"default"`, `"destructive"`.

- icon:

  Optional icon (a
  [`shad_icon()`](https://orijitghosh.github.io/shadshiny/reference/shad_icon.md)
  name or tag). Rendered with the `shad-alert__icon` class.

- class:

  Extra CSS classes.

## Value

A `<div role="alert">`.

## See also

Other shadshiny tier-1 components:
[`shad_aspect_ratio()`](https://orijitghosh.github.io/shadshiny/reference/shad_aspect_ratio.md),
[`shad_avatar()`](https://orijitghosh.github.io/shadshiny/reference/shad_avatar.md),
[`shad_badge()`](https://orijitghosh.github.io/shadshiny/reference/shad_badge.md),
[`shad_breadcrumb()`](https://orijitghosh.github.io/shadshiny/reference/shad_breadcrumb.md),
[`shad_button()`](https://orijitghosh.github.io/shadshiny/reference/shad_button.md),
[`shad_button_group()`](https://orijitghosh.github.io/shadshiny/reference/shad_button_group.md),
[`shad_card()`](https://orijitghosh.github.io/shadshiny/reference/shad_card.md),
[`shad_empty()`](https://orijitghosh.github.io/shadshiny/reference/shad_empty.md),
[`shad_item()`](https://orijitghosh.github.io/shadshiny/reference/shad_item.md),
[`shad_label()`](https://orijitghosh.github.io/shadshiny/reference/shad_label.md),
[`shad_progress()`](https://orijitghosh.github.io/shadshiny/reference/shad_progress.md),
[`shad_separator()`](https://orijitghosh.github.io/shadshiny/reference/shad_separator.md),
[`shad_skeleton()`](https://orijitghosh.github.io/shadshiny/reference/shad_skeleton.md),
[`shad_spinner()`](https://orijitghosh.github.io/shadshiny/reference/shad_spinner.md),
[`shad_table()`](https://orijitghosh.github.io/shadshiny/reference/shad_table.md),
[`shad_typography`](https://orijitghosh.github.io/shadshiny/reference/shad_typography.md)

## Examples

``` r
shad_alert("Heads up!", "You can add components via the CLI.", icon = "terminal")
#> <div class="shad-alert" role="alert">
#>   <svg class="shad-alert__icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><polyline points="4 17 10 11 4 5"/><line x1="12" x2="20" y1="19" y2="19"/></svg>
#>   <div class="shad-alert__title">Heads up!</div>
#>   <div class="shad-alert__description">You can add components via the CLI.</div>
#> </div>
shad_alert("Error", "Session expired.", variant = "destructive",
           icon = "circle-alert")
#> <div class="shad-alert shad-alert--destructive" role="alert">
#>   <svg class="shad-alert__icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="12" cy="12" r="10"/><line x1="12" x2="12" y1="8" y2="12"/><line x1="12" x2="12.01" y1="16" y2="16"/></svg>
#>   <div class="shad-alert__title">Error</div>
#>   <div class="shad-alert__description">Session expired.</div>
#> </div>
```

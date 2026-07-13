# Card

A content container. Compose with `shad_card_header()`,
`shad_card_title()`, `shad_card_description()`, `shad_card_action()`,
`shad_card_content()` and `shad_card_footer()`.

## Usage

``` r
shad_card(..., class = NULL)

shad_card_header(..., class = NULL)

shad_card_title(..., class = NULL)

shad_card_description(..., class = NULL)

shad_card_action(..., class = NULL)

shad_card_content(..., class = NULL)

shad_card_footer(..., class = NULL)
```

## Arguments

- ...:

  Card sections (and optional named attributes).

- class:

  Extra CSS classes.

## Value

A `<div class="shad-card">`.

## See also

Other shadshiny tier-1 components:
[`shad_alert()`](https://orijitghosh.github.io/shadshiny/reference/shad_alert.md),
[`shad_aspect_ratio()`](https://orijitghosh.github.io/shadshiny/reference/shad_aspect_ratio.md),
[`shad_avatar()`](https://orijitghosh.github.io/shadshiny/reference/shad_avatar.md),
[`shad_badge()`](https://orijitghosh.github.io/shadshiny/reference/shad_badge.md),
[`shad_breadcrumb()`](https://orijitghosh.github.io/shadshiny/reference/shad_breadcrumb.md),
[`shad_button()`](https://orijitghosh.github.io/shadshiny/reference/shad_button.md),
[`shad_button_group()`](https://orijitghosh.github.io/shadshiny/reference/shad_button_group.md),
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
shad_card(
  shad_card_header(
    shad_card_title("Create project"),
    shad_card_description("Deploy in one click.")
  ),
  shad_card_content("Body"),
  shad_card_footer(shad_button("Deploy"))
)
#> <div class="shad-card">
#>   <div class="shad-card__header">
#>     <div class="shad-card__title">Create project</div>
#>     <div class="shad-card__description">Deploy in one click.</div>
#>   </div>
#>   <div class="shad-card__content">Body</div>
#>   <div class="shad-card__footer">
#>     <button type="button" class="shad-btn shad-btn--default">Deploy</button>
#>   </div>
#> </div>
```

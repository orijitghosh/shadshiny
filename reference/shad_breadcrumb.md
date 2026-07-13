# Breadcrumb

A breadcrumb navigation trail. Compose with `shad_breadcrumb_item()`,
`shad_breadcrumb_separator()` and `shad_breadcrumb_ellipsis()`, or pass
a named `items` vector for the common case.

## Usage

``` r
shad_breadcrumb(..., items = NULL, class = NULL)

shad_breadcrumb_item(label, href = NULL, current = FALSE)

shad_breadcrumb_separator()

shad_breadcrumb_ellipsis()
```

## Arguments

- ...:

  Breadcrumb parts. Ignored when `items` is supplied.

- items:

  Optional named character vector: names are labels, values are hrefs.
  Use `NA` as the href to mark the current page. Separators are inserted
  automatically.

- class:

  Extra CSS classes.

- label:

  Item label.

- href:

  Link URL; omit for a non-link item.

- current:

  If `TRUE`, renders the current-page item (non-link).

## Value

A `<nav class="shad-breadcrumb">`.

## See also

Other shadshiny tier-1 components:
[`shad_alert()`](https://orijitghosh.github.io/shadshiny/reference/shad_alert.md),
[`shad_aspect_ratio()`](https://orijitghosh.github.io/shadshiny/reference/shad_aspect_ratio.md),
[`shad_avatar()`](https://orijitghosh.github.io/shadshiny/reference/shad_avatar.md),
[`shad_badge()`](https://orijitghosh.github.io/shadshiny/reference/shad_badge.md),
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
shad_breadcrumb(items = c(Home = "/", Docs = "/docs", Breadcrumb = NA))
#> <nav class="shad-breadcrumb" aria-label="Breadcrumb">
#>   <ol class="shad-breadcrumb__list">
#>     <li class="shad-breadcrumb__item">
#>       <a class="shad-breadcrumb__link" href="/">Home</a>
#>     </li>
#>     <li class="shad-breadcrumb__separator" role="presentation" aria-hidden="true"><svg class="shad-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m9 18 6-6-6-6"/></svg></li>
#>     <li class="shad-breadcrumb__item">
#>       <a class="shad-breadcrumb__link" href="/docs">Docs</a>
#>     </li>
#>     <li class="shad-breadcrumb__separator" role="presentation" aria-hidden="true"><svg class="shad-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m9 18 6-6-6-6"/></svg></li>
#>     <li class="shad-breadcrumb__item">
#>       <span class="shad-breadcrumb__page" role="link" aria-disabled="true" aria-current="page">Breadcrumb</span>
#>     </li>
#>   </ol>
#> </nav>
```

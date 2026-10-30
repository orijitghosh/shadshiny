# Typography helpers

Apply shadshiny's typography utility classes to the appropriate semantic
element.

## Usage

``` r
shad_h1(..., class = NULL)

shad_h2(..., class = NULL)

shad_h3(..., class = NULL)

shad_h4(..., class = NULL)

shad_p(..., class = NULL)

shad_lead(..., class = NULL)

shad_large(..., class = NULL)

shad_small(..., class = NULL)

shad_muted(..., class = NULL)

shad_blockquote(..., class = NULL)

shad_code(..., class = NULL)

shad_kbd(..., class = NULL)

shad_list(..., ordered = FALSE, class = NULL)
```

## Arguments

- ...:

  Content (and optional named attributes).

- class:

  Extra CSS classes.

- ordered:

  If `TRUE`, renders an `<ol>` instead of `<ul>`.

## Value

An htmltools tag.

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
[`shad_table()`](https://orijitghosh.github.io/shadshiny/reference/shad_table.md)

## Examples

``` r
shad_h1("Title")
#> <h1 class="shad-h1">Title</h1>
shad_p("A paragraph.")
#> <p class="shad-p">A paragraph.</p>
shad_muted("Secondary text")
#> <p class="shad-muted">Secondary text</p>
```

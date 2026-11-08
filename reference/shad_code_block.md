# Code block

Render escaped source text with optional metadata, copy controls, and
line numbers.

## Usage

``` r
shad_code_block(
  code,
  language = NULL,
  filename = NULL,
  copy = TRUE,
  line_numbers = FALSE,
  class = NULL
)
```

## Arguments

- code:

  One scalar character value containing source text.

- language:

  Optional scalar character language label.

- filename:

  Optional scalar character filename label.

- copy:

  One scalar logical indicating whether to show the copy button.

- line_numbers:

  One scalar logical indicating whether to show line numbers.

- class:

  Extra CSS classes.

## Value

An htmltools figure tag.

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
shad_code_block("fit <- lm(mpg ~ wt, data = mtcars)",
                language = "r", filename = "model.R")
#> <figure class="shad-code-block" data-shad-code-block>
#>   <figcaption class="shad-code-block__header">
#>     <span class="shad-code-block__title">model.R</span>
#>     <span class="shad-code-block__language">r</span>
#>     <span class="shad-code-block__controls">
#>       <button type="button" class="shad-code-block__copy" aria-label="Copy code" data-shad-copy-code>Copy</button>
#>       <span class="shad-code-block__status" role="status" aria-live="polite" aria-atomic="true" data-shad-copy-status></span>
#>     </span>
#>   </figcaption>
#>   <pre class="shad-code-block__pre">
#>     <code class="shad-code-block__code" data-language="r">fit &lt;- lm(mpg ~ wt, data = mtcars)</code>
#>   </pre>
#> </figure>
```

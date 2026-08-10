# Centred content container

A max-width, horizontally centred column with inline padding — the
outermost wrapper for page content.

## Usage

``` r
shad_container(..., size = "md", padding = 4, class = NULL)
```

## Arguments

- ...:

  Children, or named HTML attributes for the root.

- size:

  `"sm"` (40rem), `"md"` (60rem, default), `"lg"` (80rem), `"xl"`
  (96rem), or `"full"` (no max-width). A CSS length is also accepted.

- padding:

  Inline padding: a spacing token step, a CSS length, or `FALSE` for
  none.

- class:

  Extra CSS classes.

## Value

A `<div>` tag.

## See also

Other shadshiny layout:
[`shad_grid()`](https://orijitghosh.github.io/shadshiny/reference/shad_grid.md),
[`shad_page_navbar()`](https://orijitghosh.github.io/shadshiny/reference/shad_page_navbar.md),
[`shad_page_sidebar()`](https://orijitghosh.github.io/shadshiny/reference/shad_page_sidebar.md),
[`shad_stack()`](https://orijitghosh.github.io/shadshiny/reference/shad_stack.md)

## Examples

``` r
shad_container(shad_h2("Title"), shad_p("Body"), size = "lg")
#> <div class="shad-container" style="--shad-container-max:80rem;--shad-container-pad:var(--shad-space-4);">
#>   <h2 class="shad-h2">Title</h2>
#>   <p class="shad-p">Body</p>
#> </div>
```

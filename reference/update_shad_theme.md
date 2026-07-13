# Switch the theme preset and/or dark mode at runtime

Sends a custom message that sets/removes `data-shad-theme` and toggles
`.dark` + `data-bs-theme` on `document.documentElement`.

## Usage

``` r
update_shad_theme(
  preset = NULL,
  dark = NULL,
  session = shiny::getDefaultReactiveDomain()
)
```

## Arguments

- preset:

  A preset name, `"default"` to clear the preset, or `NULL` to leave it
  unchanged.

- dark:

  `TRUE`/`FALSE` to set dark mode, or `NULL` to leave unchanged.

- session:

  The Shiny session.

## Value

Invisibly `NULL`, called for its side effect.

## See also

Other shadshiny page & theming:
[`page_shad()`](https://orijitghosh.github.io/shadshiny/reference/page_shad.md),
[`shad_theme_preset()`](https://orijitghosh.github.io/shadshiny/reference/shad_theme_preset.md)

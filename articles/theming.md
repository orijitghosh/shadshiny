# Theming

shadshiny’s look is entirely token-driven. Every colour, radius, and
surface is a CSS custom property, so theming means overriding properties
— never editing component CSS or hard-coding hex values.

## The token system

Colours are OKLCH `--shad-*` custom properties defined on the page root,
for example `--shad-background`, `--shad-foreground`, `--shad-primary`,
`--shad-muted`, `--shad-border`, `--shad-ring`. Components reference
these tokens exclusively. To restyle, set the token — not the element.

``` css
/* your own CSS, included via page_shad(..., tags$head(...)) or a www/ file */
:root {
  --shad-primary: oklch(0.55 0.22 265);
  --shad-radius: 0.75rem;
}
```

Because everything keys off the same variables, one override cascades
through every component consistently in both light and dark mode.

## The seven presets

shadshiny ships seven palettes: **slate, stone, blue, green, rose,
violet, orange**. Choose one at the page level:

``` r

library(shadshiny)
page_shad(theme_preset = "green")
```

Presets are applied through a `data-shad-theme` attribute on the page
root, so they compose with — rather than replace — your custom token
overrides.

## Dark mode

Dark mode keys off `.dark` **and** `[data-bs-theme="dark"]` on an
ancestor. That second signal is exactly what
[`bslib::input_dark_mode()`](https://rstudio.github.io/bslib/reference/input_dark_mode.html)
toggles, so a bslib dark-mode switch drives shadshiny components with
zero extra wiring:

``` r

library(shiny)
library(bslib)
library(shadshiny)

page_shad(
  input_dark_mode(),          # toggles [data-bs-theme]; shadshiny follows
  shad_card(shad_card_content(shad_p("I recolour automatically.")))
)
```

You can also force a mode at page level:

``` r

page_shad(dark = TRUE, ...)   # start in dark mode
```

## Changing theme at runtime

[`update_shad_theme()`](https://orijitghosh.github.io/shadshiny/reference/update_shad_theme.md)
swaps the preset and/or dark state live from the server — ideal for a
settings toolbar built from a
[`shad_select()`](https://orijitghosh.github.io/shadshiny/reference/shad_select.md)
and a
[`shad_switch()`](https://orijitghosh.github.io/shadshiny/reference/shad_switch.md):

``` r

ui <- page_shad(
  shad_select("preset", label = "Theme",
              choices = c("slate", "stone", "blue", "green",
                          "rose", "violet", "orange"),
              selected = "slate"),
  shad_switch("dark", label = "Dark mode")
)

server <- function(input, output, session) {
  observe({
    update_shad_theme(preset = input$preset, dark = input$dark)
  })
}
```

## Custom theming

For a bespoke brand, override the tokens you care about and leave the
rest to the preset. The sidebar family has its own `--shad-sidebar-*`
tokens (`--shad-sidebar-background`, `--shad-sidebar-foreground`,
`--shad-sidebar-border`, …) so you can give navigation a distinct
surface:

``` css
:root {
  --shad-sidebar-background: oklch(0.98 0.01 265);
}
.dark {
  --shad-sidebar-background: oklch(0.20 0.02 265);
}
```

Override under both the light selector and `.dark` to keep the two modes
in step.

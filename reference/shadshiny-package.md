# shadshiny: 'shadcn/ui' Components for 'Shiny'

A complete port of the shadcn/ui design system for Shiny: 72 accessible,
themeable components implemented in framework-free CSS and vanilla
JavaScript, wrapped as native R functions with Shiny input bindings. It
coexists with Bootstrap 5 and bslib, including automatic dark-mode
synchronization.

## Getting started

Wrap your UI in
[`page_shad()`](https://orijitghosh.github.io/shadshiny/reference/page_shad.md)
to attach the asset bundle and theme scope, then use the `shad_*()`
component constructors. Read bound values as `input$<inputId>` and
update them from the server with the `update_shad_*()` helpers.

## Load order & the uniform contract

All assets ship as a single bundled
[htmlDependency](https://rstudio.github.io/htmltools/reference/htmlDependency.html)
([`shadshiny_deps()`](https://orijitghosh.github.io/shadshiny/reference/shadshiny_deps.md))
whose files load in a fixed order: tokens, base and animation CSS, then
component CSS/JS, with the Shiny binding layer last. Every stateful
component root carries `data-shad="<name>"`; its JS instance exposes
`getValue()`/`setValue()` (plus
[`open()`](https://rdrr.io/r/base/connections.html)/[`close()`](https://rdrr.io/r/base/connections.html)
for overlays) and dispatches a bubbling `shad:change` event that the
generic Shiny input binding subscribes to.

## Theming

Colours come from `--shad-*` OKLCH custom properties. Switch palette
with
[`shad_theme_preset()`](https://orijitghosh.github.io/shadshiny/reference/shad_theme_preset.md)
or the `theme_preset` argument of
[`page_shad()`](https://orijitghosh.github.io/shadshiny/reference/page_shad.md),
and at runtime with
[`update_shad_theme()`](https://orijitghosh.github.io/shadshiny/reference/update_shad_theme.md).
Dark mode keys off both `.dark` and `[data-bs-theme="dark"]`, so
[`bslib::input_dark_mode()`](https://rstudio.github.io/bslib/reference/input_dark_mode.html)
works with no glue.

## See also

Useful links:

- <https://github.com/orijitghosh/shadshiny>

- <https://orijitghosh.github.io/shadshiny/>

- Report bugs at <https://github.com/orijitghosh/shadshiny/issues>

## Author

**Maintainer**: Arijit Ghosh <arijitghosh2009@gmail.com>

Authors:

- Arijit Ghosh <arijitghosh2009@gmail.com>

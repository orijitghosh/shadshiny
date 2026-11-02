#' shadshiny: 'shadcn/ui' Components for 'Shiny'
#'
#' A broad, experimental reimplementation of the shadcn/ui design system for
#' Shiny: 73 accessible, themeable components implemented in framework-free
#' CSS and vanilla JavaScript, wrapped as native R functions with Shiny input
#' bindings. It coexists with Bootstrap 5 and bslib, including automatic
#' dark-mode synchronization.
#'
#' A component is one asset family with an exported constructor of its own.
#' Page wrappers, aliases, server helpers, and parts that render only inside
#' another component (the workbench's sources, tools, prompt, and branch
#' switcher, or the date picker's preset rail) are not counted separately.
#'
#' @section Getting started:
#' Wrap your UI in [page_shad()] to attach the asset bundle and theme scope,
#' then use the `shad_*()` component constructors. Read bound values as
#' `input$<inputId>` and update them from the server with the `update_shad_*()`
#' helpers.
#'
#' @section Load order & the uniform contract:
#' All assets ship as a single bundled [htmlDependency][htmltools::htmlDependency]
#' ([shadshiny_deps()]): one minified stylesheet and one minified script, built
#' in a fixed order from tokens, base and animation CSS, then component CSS/JS,
#' with the Shiny binding layer last. Set `options(shadshiny.assets = "source")`
#' to load the per-component files instead when debugging the CSS or JS. Every
#' stateful component root carries `data-shad="<name>"`; its JS instance exposes
#' `getValue()`/`setValue()` (plus `open()`/`close()` for overlays) and
#' dispatches a bubbling `shad:change` event that the generic Shiny input binding
#' subscribes to.
#'
#' @section Theming:
#' Colours come from `--shad-*` OKLCH custom properties. Switch palette with
#' [shad_theme_preset()] or the `theme_preset` argument of [page_shad()], and at
#' runtime with [update_shad_theme()]. Dark mode keys off both `.dark` and
#' `[data-bs-theme="dark"]`, so `bslib::input_dark_mode()` works with no glue.
#'
#' @keywords internal
"_PACKAGE"

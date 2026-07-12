# Page + theming --------------------------------------------------------------

.shad_presets <- c("slate", "stone", "blue", "green", "rose", "violet", "orange")

#' A shadshiny page
#'
#' A page wrapper that attaches the shadshiny asset bundle and establishes a
#' `.shad-scope` root. Built on [bslib::page_fillable()] when \pkg{bslib} is
#' installed, otherwise on [shiny::fluidPage()]. Dark mode follows
#' `bslib::input_dark_mode()` automatically because the assets key off both
#' `.dark` and `[data-bs-theme="dark"]`.
#'
#' @param ... UI elements, or named HTML attributes for the scope container.
#' @param title Page title (browser tab).
#' @param theme_preset One of `NULL` (default zinc), `"slate"`, `"stone"`,
#'   `"blue"`, `"green"`, `"rose"`, `"violet"`, `"orange"`. Sets
#'   `data-shad-theme` on the scope container.
#' @param dark `NULL` to follow bslib/OS, `TRUE` to force dark, `FALSE` to
#'   force light.
#' @param lang Document language attribute.
#'
#' @returns A page UI object.
#' @family shadshiny page & theming
#' @examples
#' if (interactive()) {
#'   shiny::shinyApp(
#'     page_shad(shad_badge("Hello"), theme_preset = "blue"),
#'     function(input, output, session) {}
#'   )
#' }
#' @export
page_shad <- function(..., title = NULL, theme_preset = NULL, dark = NULL,
                      lang = "en") {
  if (!is.null(theme_preset)) arg_match_shad(theme_preset, .shad_presets, "theme_preset")

  scope_class <- c("shad-scope", if (isTRUE(dark)) "dark")
  scope_attrs <- drop_nulls(list(
    class = paste(scope_class, collapse = " "),
    `data-shad-theme` = theme_preset,
    `data-bs-theme` = if (isTRUE(dark)) "dark" else if (isFALSE(dark)) "light" else NULL
  ))
  scope <- do.call(htmltools::tags$div, c(scope_attrs, list(...)))

  body <- htmltools::tagList(shadshiny_dependency(), scope)

  if (requireNamespace("bslib", quietly = TRUE)) {
    bslib::page_fillable(title = title, lang = lang, body)
  } else {
    shiny::fluidPage(title = title, lang = lang, body)
  }
}

#' Wrap UI in a theme-preset scope
#'
#' Applies a shadshiny colour preset to a subtree via `data-shad-theme`. Nest
#' freely; the nearest ancestor wins.
#'
#' @param preset One of `"slate"`, `"stone"`, `"blue"`, `"green"`, `"rose"`,
#'   `"violet"`, `"orange"`.
#' @param ... UI children (and optional named attributes).
#' @returns A `<div>` tag carrying `data-shad-theme`.
#' @family shadshiny page & theming
#' @examples
#' shad_theme_preset("green", shad_badge("Success"))
#' @export
shad_theme_preset <- function(preset, ...) {
  arg_match_shad(preset, .shad_presets, "preset")
  with_deps(htmltools::tags$div(`data-shad-theme` = preset, ...))
}

#' Switch the theme preset and/or dark mode at runtime
#'
#' Sends a custom message that sets/removes `data-shad-theme` and toggles
#' `.dark` + `data-bs-theme` on `document.documentElement`.
#'
#' @param preset A preset name, `"default"` to clear the preset, or `NULL` to
#'   leave it unchanged.
#' @param dark `TRUE`/`FALSE` to set dark mode, or `NULL` to leave unchanged.
#' @param session The Shiny session.
#' @returns Invisibly `NULL`, called for its side effect.
#' @family shadshiny page & theming
#' @export
update_shad_theme <- function(preset = NULL, dark = NULL,
                              session = shiny::getDefaultReactiveDomain()) {
  if (!is.null(preset) && !identical(preset, "default")) {
    arg_match_shad(preset, .shad_presets, "preset")
  }
  session$sendCustomMessage("shadshiny:theme", drop_nulls(list(
    preset = preset,
    dark = if (is.null(dark)) NULL else isTRUE(dark)
  )))
  invisible(NULL)
}

#' Run a bundled shadshiny example app
#'
#' @param example Example app directory name under `inst/examples`. One of:
#'   \describe{
#'     \item{`"kitchen-sink"`}{(default) the full R-built demo of every component.}
#'     \item{`"00-static-parity"`}{hand-written anatomy reference, for visual parity checks.}
#'     \item{`"01-auth-onboarding"`}{sign-in / create-account flow with a 4-step
#'       onboarding wizard, 2FA (input-OTP) and social sign-in.}
#'     \item{`"02-analytics-dashboard"`}{admin console: sidebar, menubar, command
#'       palette, KPI cards, resizable chart split and a searchable team directory.}
#'     \item{`"03-support-chat"`}{support inbox with a stick-to-bottom transcript,
#'       quick replies, attachment popover and a simulated assistant.}
#'     \item{`"04-storefront"`}{product page: carousel, variant pickers, add-to-cart
#'       sheet, tabbed details and reviews pagination.}
#'     \item{`"05-settings-profile"`}{account settings with live theming, availability
#'       checks, 2FA and destructive alert-dialogs.}
#'     \item{`"06-docs-reader"`}{documentation site: sidebar nav, ⌘K search, resizable
#'       article/TOC split, rich typography and tabbed code examples.}
#'   }
#'   The six numbered apps are real-world examples that together exercise the whole
#'   component library.
#' @returns Called for its side effect (launches a Shiny app).
#' @family shadshiny utilities
#' @export
shad_run_example <- function(example = "kitchen-sink") {
  dir <- system.file("examples", example, package = "shadshiny")
  if (!nzchar(dir) || !dir.exists(dir)) {
    avail <- list.dirs(system.file("examples", package = "shadshiny"),
      full.names = FALSE, recursive = FALSE)
    stop(sprintf("Example `%s` not found. Available: %s",
      example, paste(avail, collapse = ", ")), call. = FALSE)
  }
  shiny::runApp(dir, display.mode = "normal")
}

# Asset dependency ------------------------------------------------------------

# Ordered CSS load list (paths relative to inst/assets).
# tokens -> base -> animations -> dropdown-menu (shared .shad-menu*) -> rest.
#' @noRd
shad_asset_css_order <- function() {
  base <- file.path("assets")
  root <- system.file(base, package = "shadshiny")
  comp_dirs <- list.dirs(file.path(root, "components"), recursive = FALSE, full.names = FALSE)
  comp_dirs <- sort(comp_dirs)

  css_for <- function(name) {
    rel <- file.path("components", name, paste0(name, ".css"))
    if (file.exists(file.path(root, rel))) rel else NULL
  }

  head <- c(
    "tokens/shad-tokens.css",
    "core/shad-base.css",
    "core/shad-animations.css",
    css_for("dropdown-menu")
  )
  rest <- unlist(lapply(setdiff(comp_dirs, "dropdown-menu"), css_for), use.names = FALSE)
  drop_nulls(as.list(c(head, rest))) |> unlist(use.names = FALSE)
}

# Ordered JS load list (paths relative to inst/assets).
# runtime -> dialog -> alert-dialog -> dropdown-menu -> rest -> shiny binding.
#' @noRd
shad_asset_js_order <- function() {
  root <- system.file("assets", package = "shadshiny")
  comp_dirs <- sort(list.dirs(file.path(root, "components"), recursive = FALSE, full.names = FALSE))

  js_for <- function(name) {
    rel <- file.path("components", name, paste0(name, ".js"))
    if (file.exists(file.path(root, rel))) rel else NULL
  }

  head_names <- c("dialog", "alert-dialog", "dropdown-menu")
  head <- c("core/shad-runtime.js", unlist(lapply(head_names, js_for), use.names = FALSE))
  rest <- unlist(lapply(setdiff(comp_dirs, head_names), js_for), use.names = FALSE)
  tail <- "shiny/shadshiny-shiny.js"
  c(head, rest, tail)
}

# The bundle built by tools/build-assets.mjs, or NULL when it is absent.
#' @noRd
shad_asset_bundle <- function() {
  root <- system.file("assets", package = "shadshiny")
  files <- file.path("dist", c("shadshiny.min.css", "shadshiny.min.js"))
  if (!all(file.exists(file.path(root, files)))) return(NULL)
  list(css = files[1], js = files[2])
}

#' The bundled shadshiny html dependency
#'
#' Serves one minified stylesheet and one minified script when the built bundle
#' is present, which is the case for any installed copy of the package. Set
#' `options(shadshiny.assets = "source")` to load the per-component files
#' instead, which is what you want when stepping through the CSS or JS.
#' @noRd
shadshiny_dependency <- function() {
  bundle <- if (identical(getOption("shadshiny.assets"), "source")) NULL else shad_asset_bundle()
  htmltools::htmlDependency(
    name       = "shadshiny",
    version    = as.character(utils::packageVersion("shadshiny")),
    package    = "shadshiny",
    src        = "assets",
    stylesheet = if (is.null(bundle)) shad_asset_css_order() else bundle$css,
    script     = if (is.null(bundle)) shad_asset_js_order() else bundle$js
  )
}

#' Attach the shadshiny asset bundle
#'
#' Returns the html dependency (tokens, core CSS, runtime JS, every component's
#' CSS/JS, and the Shiny binding layer) in the correct load order. Every
#' `shad_*()` constructor already attaches this, so you only need it when
#' composing raw HTML by hand or ensuring assets load on a page that renders no
#' shadshiny component up front.
#'
#' @returns An [htmltools::tagList()] carrying the html dependency.
#' @family shadshiny utilities
#' @examples
#' if (interactive()) {
#'   shiny::fluidPage(shadshiny_deps(), shad_badge("Ready"))
#' }
#' @export
shadshiny_deps <- function() {
  htmltools::tagList(shadshiny_dependency())
}

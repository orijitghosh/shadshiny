# Inline Lucide icon registry -------------------------------------------------
# Structural icons are embedded directly in component anatomy; this registry
# powers the exported shad_icon() helper and leading/trailing icons on buttons,
# badges, menu items, etc. All icons are 24x24, stroke-width 2, currentColor,
# matching the markup baked into inst/assets anatomy files (Lucide, MIT).

.shad_icon_paths <- list(
  "chevron-down"      = '<path d="m6 9 6 6 6-6"/>',
  "chevron-up"        = '<path d="m18 15-6-6-6 6"/>',
  "chevron-left"      = '<path d="m15 18-6-6 6-6"/>',
  "chevron-right"     = '<path d="m9 18 6-6-6-6"/>',
  "chevrons-up-down"  = '<path d="m7 15 5 5 5-5"/><path d="m7 9 5-5 5 5"/>',
  "chevrons-left-right" = '<path d="m9 7-5 5 5 5"/><path d="m15 7 5 5-5 5"/>',
  "check"             = '<path d="M20 6 9 17l-5-5"/>',
  "x"                 = '<path d="M18 6 6 18"/><path d="m6 6 12 12"/>',
  "minus"             = '<path d="M5 12h14"/>',
  "plus"              = '<path d="M5 12h14"/><path d="M12 5v14"/>',
  "circle"            = '<circle cx="12" cy="12" r="10"/>',
  "dot"               = '<circle cx="12" cy="12" r="4" fill="currentColor" stroke="none"/>',
  "search"            = '<circle cx="11" cy="11" r="8"/><path d="m21 21-4.3-4.3"/>',
  "calendar"          = '<path d="M8 2v4"/><path d="M16 2v4"/><rect width="18" height="18" x="3" y="4" rx="2"/><path d="M3 10h18"/>',
  "more-horizontal"   = '<circle cx="12" cy="12" r="1"/><circle cx="19" cy="12" r="1"/><circle cx="5" cy="12" r="1"/>',
  "more-vertical"     = '<circle cx="12" cy="12" r="1"/><circle cx="12" cy="5" r="1"/><circle cx="12" cy="19" r="1"/>',
  "mail"              = '<rect width="20" height="16" x="2" y="4" rx="2"/><path d="m22 7-8.97 5.7a1.94 1.94 0 0 1-2.06 0L2 7"/>',
  "terminal"          = '<polyline points="4 17 10 11 4 5"/><line x1="12" x2="20" y1="19" y2="19"/>',
  "circle-alert"      = '<circle cx="12" cy="12" r="10"/><line x1="12" x2="12" y1="8" y2="12"/><line x1="12" x2="12.01" y1="16" y2="16"/>',
  "circle-check"      = '<circle cx="12" cy="12" r="10"/><path d="m9 12 2 2 4-4"/>',
  "info"              = '<circle cx="12" cy="12" r="10"/><path d="M12 16v-4"/><path d="M12 8h.01"/>',
  "triangle-alert"    = '<path d="m21.73 18-8-14a2 2 0 0 0-3.48 0l-8 14A2 2 0 0 0 4 21h16a2 2 0 0 0 1.73-3"/><path d="M12 9v4"/><path d="M12 17h.01"/>',
  "loader"            = '<path d="M21 12a9 9 0 1 1-6.219-8.56"/>',
  "arrow-left"        = '<path d="m12 19-7-7 7-7"/><path d="M19 12H5"/>',
  "arrow-right"       = '<path d="M5 12h14"/><path d="m12 5 7 7-7 7"/>',
  "menu"              = '<line x1="4" x2="20" y1="12" y2="12"/><line x1="4" x2="20" y1="6" y2="6"/><line x1="4" x2="20" y1="18" y2="18"/>',
  "panel-left"        = '<rect width="18" height="18" x="3" y="3" rx="2"/><path d="M9 3v18"/>',
  "file"              = '<path d="M15 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V7Z"/><path d="M14 2v4a2 2 0 0 0 2 2h4"/>',
  "folder"            = '<path d="M20 20a2 2 0 0 0 2-2V8a2 2 0 0 0-2-2h-7.9a2 2 0 0 1-1.69-.9L9.6 3.9A2 2 0 0 0 7.93 3H4a2 2 0 0 0-2 2v13a2 2 0 0 0 2 2Z"/>',
  "clock"             = '<circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/>'
)

#' Inline Lucide icon
#'
#' Returns a 24x24 inline SVG (stroke-width 2, `currentColor`) matching the
#' icon markup embedded throughout the shadshiny asset bundle. Use it for
#' leading/trailing icons on buttons, menu items, and other slots that accept
#' an `icon` argument.
#'
#' @param name Icon name. See [shad_icon_names()] for the available set.
#' @param class CSS class(es) for the `<svg>`. Defaults to `"shad-icon"`.
#' @param ... Additional attributes for the `<svg>` (e.g. `aria-label`).
#'
#' @returns An [htmltools::HTML()] SVG string.
#' @family shadshiny utilities
#' @examples
#' shad_icon("check")
#' shad_icon("chevron-down", class = "shad-select__chevron")
#' @export
shad_icon <- function(name, class = "shad-icon", ...) {
  if (is.null(name) || !name %in% names(.shad_icon_paths)) {
    stop(sprintf(
      "Unknown icon `%s`. Available icons: %s.",
      if (is.null(name)) "NULL" else name,
      paste(names(.shad_icon_paths), collapse = ", ")
    ), call. = FALSE)
  }
  attrs <- list(...)
  extra_attr <- ""
  if (length(attrs)) {
    nms <- names(attrs)
    extra_attr <- paste0(
      " ",
      paste(sprintf('%s="%s"', nms, vapply(attrs, as.character, character(1))),
            collapse = " ")
    )
  }
  aria <- if ("aria-label" %in% names(attrs)) "" else ' aria-hidden="true"'
  htmltools::HTML(sprintf(
    '<svg class="%s" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"%s%s>%s</svg>',
    class, aria, extra_attr, .shad_icon_paths[[name]]
  ))
}

#' Available shadshiny icon names
#' @returns A character vector of icon names accepted by [shad_icon()].
#' @family shadshiny utilities
#' @examples
#' shad_icon_names()
#' @export
shad_icon_names <- function() {
  names(.shad_icon_paths)
}

# Normalise an `icon` argument (name string or tag) into a tag/HTML, or NULL.
#' @noRd
resolve_icon <- function(icon, class = "shad-icon") {
  if (is.null(icon)) return(NULL)
  if (is.character(icon) && length(icon) == 1) return(shad_icon(icon, class = class))
  icon
}

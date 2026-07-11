# Simple display components: separator, skeleton, spinner, aspect-ratio, label

#' Separator
#'
#' A horizontal or vertical divider.
#'
#' @param orientation `"horizontal"` or `"vertical"`.
#' @param decorative If `TRUE` (default), the separator is purely visual
#'   (`aria-hidden`); if `FALSE`, it exposes separator semantics.
#' @param class Extra CSS classes.
#' @param ... Extra attributes.
#' @returns A `<div class="shad-separator">`.
#' @family shadshiny tier-1 components
#' @examples
#' shad_separator()
#' shad_separator("vertical")
#' @export
shad_separator <- function(orientation = c("horizontal", "vertical"),
                           decorative = TRUE, class = NULL, ...) {
  orientation <- arg_match_shad(orientation, c("horizontal", "vertical"), "orientation")
  attrs <- if (isTRUE(decorative)) {
    list(`aria-hidden` = "true")
  } else {
    list(role = "separator", `aria-orientation` = orientation)
  }
  with_deps(do.call(htmltools::tags$div, c(
    list(class = shad_class("shad-separator", extra = class),
         `data-orientation` = orientation),
    attrs, list(...)
  )))
}

#' Skeleton
#'
#' A shimmering placeholder for loading content.
#'
#' @param width,height CSS sizes (e.g. `"60%"`, `"3rem"`).
#' @param variant `"default"`, `"text"` or `"circle"`.
#' @param class Extra CSS classes.
#' @param ... Extra attributes.
#' @returns A `<div class="shad-skeleton">`.
#' @family shadshiny tier-1 components
#' @examples
#' shad_skeleton(width = "60%")
#' shad_skeleton(width = "3rem", height = "3rem", variant = "circle")
#' @export
shad_skeleton <- function(width = NULL, height = NULL,
                          variant = c("default", "text", "circle"),
                          class = NULL, ...) {
  variant <- arg_match_shad(variant, c("default", "text", "circle"), "variant")
  variant_class <- if (variant == "default") NULL else paste0("shad-skeleton--", variant)
  style <- paste0(
    if (!is.null(width)) paste0("width:", htmltools::validateCssUnit(width), ";"),
    if (!is.null(height)) paste0("height:", htmltools::validateCssUnit(height), ";")
  )
  with_deps(htmltools::tags$div(
    class = shad_class("shad-skeleton", variant_class, extra = class),
    style = if (nzchar(style)) style else NULL,
    `aria-hidden` = "true", ...
  ))
}

#' Spinner
#'
#' An animated loading spinner.
#'
#' @param size `"default"`, `"sm"` or `"lg"`.
#' @param muted If `TRUE`, uses the muted colour.
#' @param label Accessible label.
#' @param class Extra CSS classes.
#' @param ... Extra attributes.
#' @returns An inline `<svg class="shad-spinner">`.
#' @family shadshiny tier-1 components
#' @examples
#' shad_spinner()
#' shad_spinner(size = "lg", muted = TRUE)
#' @export
shad_spinner <- function(size = c("default", "sm", "lg"), muted = FALSE,
                         label = "Loading", class = NULL, ...) {
  size <- arg_match_shad(size, c("default", "sm", "lg"), "size")
  size_class <- if (size == "default") NULL else paste0("shad-spinner--", size)
  muted_class <- if (isTRUE(muted)) "shad-spinner--muted" else NULL
  with_deps(htmltools::tags$svg(
    class = shad_class("shad-spinner", size_class, muted_class, extra = class),
    viewBox = "0 0 24 24", fill = "none", stroke = "currentColor",
    `stroke-width` = "2", `stroke-linecap` = "round", `stroke-linejoin` = "round",
    role = "status", `aria-label` = label, ...,
    htmltools::HTML('<path d="M21 12a9 9 0 1 1-6.219-8.56"/>')
  ))
}

#' Aspect ratio
#'
#' Constrains children to a fixed width/height ratio.
#'
#' @param ... Child content (typically an `<img>`), and optional attributes.
#' @param ratio Numeric aspect ratio (width / height). Default `16/9`.
#' @param class Extra CSS classes.
#' @returns A `<div class="shad-aspect-ratio">`.
#' @family shadshiny tier-1 components
#' @examples
#' shad_aspect_ratio(htmltools::tags$img(src = "x.png"), ratio = 1)
#' @export
shad_aspect_ratio <- function(..., ratio = 16 / 9, class = NULL) {
  # express ratio as a clean CSS `w / h` where possible
  style <- if (!isTRUE(all.equal(ratio, 16 / 9))) {
    paste0("--shad-ratio: ", format(ratio, digits = 6), ";")
  }
  with_deps(htmltools::tags$div(
    class = shad_class("shad-aspect-ratio", extra = class),
    style = style, ...
  ))
}

#' Label
#'
#' A form label.
#'
#' @param label Label text.
#' @param for_id The `id` of the control this labels.
#' @param disabled If `TRUE`, applies disabled styling (`data-disabled`).
#' @param class Extra CSS classes.
#' @param ... Extra attributes or child tags.
#' @returns A `<label class="shad-label">`.
#' @family shadshiny tier-1 components
#' @examples
#' shad_label("Email address", for_id = "email")
#' @export
shad_label <- function(label, for_id = NULL, disabled = FALSE, class = NULL, ...) {
  with_deps(htmltools::tags$label(
    class = shad_class("shad-label", extra = class),
    `for` = for_id, `data-disabled` = flag_attr(disabled),
    label, ...
  ))
}

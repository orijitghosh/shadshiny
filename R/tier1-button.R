#' Button
#'
#' A shadcn-style button. Renders a native `<button>` (or `<a>` when `href` is
#' supplied). Supplying `inputId` makes it a Shiny action button (readable as
#' `input$<inputId>` click count).
#'
#' @param label Button text.
#' @param inputId Optional input id. When set, the button becomes a Shiny
#'   action button.
#' @param variant One of `"default"`, `"secondary"`, `"destructive"`,
#'   `"outline"`, `"ghost"`, `"link"`.
#' @param size One of `"default"`, `"sm"`, `"lg"`, `"icon"`.
#' @param icon Optional leading/trailing icon: a [shad_icon()] name or a tag.
#' @param icon_position `"left"` or `"right"`.
#' @param icon_size For `size = "icon"`, an additional `"default"`, `"sm"` or
#'   `"lg"` sizing.
#' @param loading If `TRUE`, shows a spinner, disables the button, and sets
#'   `aria-busy`.
#' @param disabled If `TRUE`, disables the button.
#' @param href Optional URL; renders an `<a class="shad-btn">` instead.
#' @param aria_label Accessible label (required for icon-only buttons).
#' @param type Button `type` attribute (ignored for anchors).
#' @param class Extra CSS classes.
#' @param ... Extra attributes or child tags.
#'
#' @returns A button (or anchor) tag.
#' @family shadshiny tier-1 components
#' @seealso [shad_toast()], [update_shad_button()]
#' @examples
#' shad_button("Save", variant = "default")
#' shad_button("Delete", variant = "destructive", icon = "x")
#' shad_button(inputId = "go", "Run")
#' @export
shad_button <- function(label = NULL, inputId = NULL,
                        variant = c("default", "secondary", "destructive",
                                    "outline", "ghost", "link"),
                        size = c("default", "sm", "lg", "icon"),
                        icon = NULL, icon_position = c("left", "right"),
                        icon_size = c("default", "sm", "lg"),
                        loading = FALSE, disabled = FALSE, href = NULL,
                        aria_label = NULL, type = "button", class = NULL, ...) {
  variant <- arg_match_shad(variant, c("default", "secondary", "destructive",
                                       "outline", "ghost", "link"), "variant")
  size <- arg_match_shad(size, c("default", "sm", "lg", "icon"), "size")
  icon_position <- match.arg(icon_position)
  icon_size <- match.arg(icon_size)

  size_class <- if (size == "default") NULL else paste0("shad-btn--", size)
  icon_size_class <- if (size == "icon" && icon_size != "default") {
    paste0("shad-btn--", icon_size)
  } else NULL

  icon_only <- size == "icon" || is.null(label)
  if (icon_only && is.null(aria_label) && is.null(label)) {
    stop("Icon-only buttons require `aria_label`.", call. = FALSE)
  }

  icon_tag <- resolve_icon(icon)
  spinner <- if (isTRUE(loading)) {
    htmltools::tags$span(
      class = "shad-btn__spinner", `aria-hidden` = "true",
      shad_icon("loader")
    )
  }

  children <- drop_nulls(list(
    spinner,
    if (icon_position == "left") icon_tag,
    label,
    if (icon_position == "right") icon_tag
  ))

  cls <- shad_class("shad-btn", paste0("shad-btn--", variant),
                    size_class, icon_size_class, extra = class)

  common <- drop_nulls(list(
    id = inputId,
    class = if (!is.null(inputId)) paste(cls, "action-button") else cls,
    `aria-label` = aria_label,
    `data-loading` = flag_attr(loading),
    `aria-busy` = if (isTRUE(loading)) "true" else NULL,
    disabled = flag_attr(disabled || loading)
  ))

  tag <- if (!is.null(href)) {
    do.call(htmltools::tags$a, c(list(href = href), common[names(common) != "disabled"],
                                 list(...), children))
  } else {
    do.call(htmltools::tags$button, c(list(type = type), common, list(...), children))
  }
  with_deps(tag)
}

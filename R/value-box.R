# value-box --------------------------------------------------------------------

#' KPI / value box
#'
#' A compact stat card: a label, a large value, an optional trend delta chip, an
#' optional icon, caption, and sparkline slot. Grid-friendly – drop several into
#' a CSS grid for a KPI row.
#'
#' @param value The headline value (string or number; tags allowed).
#' @param label The stat label.
#' @param delta Optional delta text (e.g. `"+20.1%"`). Rendered as a chip.
#' @param delta_direction Trend for the chip: `"auto"` (default – inferred from a
#'   leading `+`/`-` in `delta`), `"up"`, `"down"`, or `"neutral"`.
#' @param icon Optional icon: a [shad_icon()] name or a tag, pinned top-right.
#' @param caption Optional muted caption line below the value.
#' @param sparkline Optional tag/output filling a small strip at the bottom
#'   (e.g. an inline `<svg>` or a `plotOutput()`).
#' @param size `"md"` (default), `"sm"`, or `"lg"`.
#' @param href Optional URL; makes the whole box a link.
#' @param class Extra CSS classes.
#' @param ... Extra attributes on the root.
#' @returns A value-box tag.
#' @family shadshiny dashboard
#' @examples
#' shad_value_box("$45,231.89", "Total revenue", delta = "+20.1%",
#'                caption = "vs. last month")
#' @export
shad_value_box <- function(value, label, delta = NULL,
                           delta_direction = c("auto", "up", "down", "neutral"),
                           icon = NULL, caption = NULL, sparkline = NULL,
                           size = c("md", "sm", "lg"), href = NULL,
                           class = NULL, ...) {
  size <- arg_match_shad(size, c("md", "sm", "lg"), "size")
  delta_direction <- arg_match_shad(delta_direction,
                                    c("auto", "up", "down", "neutral"),
                                    "delta_direction")

  trend <- delta_direction
  if (!is.null(delta) && trend == "auto") {
    d <- trimws(as.character(delta))
    # Arrow/minus glyphs: \u2191 up, \u2212 minus, \u2193 down.
    trend <- if (grepl("^[+\u2191]", d)) "up"
             else if (grepl("^[-\u2212\u2193]", d)) "down"
             else "neutral"
  }

  delta_tag <- if (!is.null(delta)) {
    arrow <- switch(trend,
      up = .svg("arrow_up_right"),
      down = .svg("arrow_down_right"),
      NULL)
    htmltools::tags$span(
      class = "shad-value-box__delta", `data-trend` = trend, arrow, delta
    )
  }

  size_class <- switch(size, sm = "shad-value-box--sm", lg = "shad-value-box--lg", NULL)
  tag_fn <- if (is.null(href)) htmltools::tags$div else htmltools::tags$a

  body <- drop_nulls(list(
    htmltools::tags$div(class = "shad-value-box__label", label),
    if (!is.null(icon)) {
      htmltools::tags$span(class = "shad-value-box__icon", resolve_icon(icon))
    },
    htmltools::tags$div(class = "shad-value-box__value", value, delta_tag),
    if (!is.null(caption)) htmltools::tags$div(class = "shad-value-box__caption", caption),
    if (!is.null(sparkline)) htmltools::tags$div(class = "shad-value-box__sparkline", sparkline)
  ))

  root <- do.call(tag_fn, c(
    drop_nulls(list(
      class = shad_class("shad-value-box", size_class, extra = class),
      href = href
    )),
    list(...),
    body
  ))
  with_deps(root)
}

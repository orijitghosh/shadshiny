# chart-container --------------------------------------------------------------

#' Chart container
#'
#' A card-styled wrapper that gives R plot output (a [shiny::plotOutput()],
#' htmlwidget, canvas, or inline SVG) the shadcn chart look: header title /
#' description, an aspect-locked body, an optional legend strip auto-colored from
#' the chart tokens, and a footer caption. Pair with the theming adapters in
#' [shad_theme_ggplot2()] / [shad_theme_plotly()] so the plot itself follows the
#' active theme.
#'
#' @param ... The plot output (and any extra named attributes) placed in the
#'   chart body.
#' @param title Optional chart title.
#' @param description Optional description under the title.
#' @param footer Optional footer caption.
#' @param legend Optional legend: a named character vector `c("Label" = color)`,
#'   or `TRUE` to auto-color a supplied `legend_labels` vector from the chart
#'   tokens, or a tag. `NULL` omits the legend.
#' @param legend_labels Character labels used when `legend = TRUE`.
#' @param aspect `"video"` (16:9, default), `"square"`, `"wide"` (21:9), or
#'   `"auto"` (natural height).
#' @param plain If `TRUE`, drop the card border/background (`--plain` variant).
#' @param class Extra CSS classes.
#' @returns A chart-container `<figure>` tag.
#' @family shadshiny dashboard
#' @examples
#' if (interactive()) {
#'   shad_chart_container(
#'     shiny::plotOutput("p"),
#'     title = "Monthly revenue", description = "Jan - Jun 2026"
#'   )
#' }
#' @export
shad_chart_container <- function(..., title = NULL, description = NULL,
                                 footer = NULL, legend = NULL,
                                 legend_labels = NULL,
                                 aspect = c("video", "square", "wide", "auto"),
                                 plain = FALSE, class = NULL) {
  aspect <- arg_match_shad(aspect, c("video", "square", "wide", "auto"), "aspect")
  dots <- split_dots(...)

  header <- if (!is.null(title) || !is.null(description)) {
    htmltools::tags$div(
      class = "shad-chart__header",
      if (!is.null(title)) htmltools::tags$div(class = "shad-chart__title", title),
      if (!is.null(description)) {
        htmltools::tags$div(class = "shad-chart__description", description)
      }
    )
  }

  body_attrs <- if (aspect == "auto") {
    list(class = "shad-chart__body shad-chart__body--auto")
  } else {
    list(class = "shad-chart__body", `data-aspect` = aspect)
  }
  body <- do.call(htmltools::tags$div, c(body_attrs, dots$attribs, dots$children))

  legend_tag <- .shad_chart_legend(legend, legend_labels)

  footer_tag <- if (!is.null(footer)) {
    htmltools::tags$figcaption(class = "shad-chart__footer", footer)
  }

  root <- htmltools::tags$figure(
    class = shad_class("shad-chart", if (isTRUE(plain)) "shad-chart--plain", extra = class),
    header, body, legend_tag, footer_tag
  )
  with_deps(root)
}

.shad_chart_legend <- function(legend, legend_labels) {
  if (is.null(legend)) return(NULL)
  if (is_tag_like(legend)) {
    return(htmltools::tags$div(class = "shad-chart-legend", legend))
  }
  items <- if (isTRUE(legend)) {
    stats::setNames(rep(list(NULL), length(legend_labels)), legend_labels)
  } else {
    as.list(legend)
  }
  labels <- names(items)
  tags <- lapply(seq_along(items), function(i) {
    color <- items[[i]]
    swatch_style <- if (!is.null(color) && !is.na(color) && nzchar(color)) {
      paste0("--legend-color:", color, ";")
    }
    htmltools::tags$span(
      class = "shad-chart-legend__item",
      htmltools::tags$span(class = "shad-chart-legend__swatch", style = swatch_style),
      labels[i]
    )
  })
  do.call(htmltools::tags$div, c(list(class = "shad-chart-legend"), tags))
}

# Chart theming adapters -------------------------------------------------------

# Resolve a token to hex for a preset/mode.
.tok_hex <- function(key, preset, dark) {
  .oklch_to_hex(shad_tokens(preset, dark)[[key]])
}

# Accept either (preset, dark) or a shad_current_theme()-style list in `preset`.
.resolve_theme_args <- function(preset, dark) {
  if (is.list(preset)) {
    list(preset = preset$preset, dark = isTRUE(preset$dark))
  } else {
    list(preset = preset, dark = isTRUE(dark))
  }
}

#' The active shadshiny theme (reactive)
#'
#' Read the theme currently applied in the browser – its preset and dark-mode
#' flag – inside a reactive context. The asset layer reports this as a hidden
#' input on load and whenever the theme changes, so a `renderPlot()` that calls
#' `shad_current_theme()` re-executes on every dark toggle or preset switch.
#'
#' @param session The Shiny session.
#' @returns A list with `preset` (character or `NULL`) and `dark` (logical).
#' @family shadshiny theming
#' @examples
#' if (interactive()) {
#'   ui <- page_shad(
#'     shad_select("preset", "Theme", selected = "slate",
#'                 choices = c("slate", "blue", "rose")),
#'     shiny::plotOutput("plot")
#'   )
#'   server <- function(input, output, session) {
#'     shiny::observe(update_shad_theme(preset = input$preset))
#'     output$plot <- shiny::renderPlot({
#'       th <- shad_current_theme()
#'       plot(1:10, pch = 19, col = shad_chart_colors(1, th$preset, th$dark))
#'     }, bg = "transparent")
#'   }
#'   shiny::shinyApp(ui, server)
#' }
#' @export
shad_current_theme <- function(session = shiny::getDefaultReactiveDomain()) {
  val <- if (!is.null(session)) session$input[[".shad_theme"]] else NULL
  preset <- val$preset
  if (!is.null(preset) && (identical(preset, "default") || !nzchar(preset))) preset <- NULL
  list(preset = preset, dark = isTRUE(val$dark))
}

#' ggplot2 theme matching the shadshiny design system
#'
#' Experimental.
#' A complete \pkg{ggplot2} theme (transparent plot/panel backgrounds, tokenised
#' grid and text colors) so plots sit correctly on any shadshiny surface. Pair
#' with [shad_scale_color_shad()] / [shad_scale_fill_shad()] for the categorical
#' palette. Requires \pkg{ggplot2}.
#'
#' @param preset A theme preset name, or a [shad_current_theme()] list (its
#'   `preset`/`dark` are used).
#' @param dark If `TRUE`, use dark-mode token colors.
#' @param base_size Base font size.
#' @returns A ggplot2 theme object.
#' @family shadshiny theming
#' @examples
#' if (interactive() && requireNamespace("ggplot2", quietly = TRUE)) {
#'   library(ggplot2)
#'   ggplot(mtcars, aes(wt, mpg)) + geom_point() + shad_theme_ggplot2()
#' }
#' @export
shad_theme_ggplot2 <- function(preset = NULL, dark = FALSE, base_size = 14) {
  if (!requireNamespace("ggplot2", quietly = TRUE)) {
    stop("shad_theme_ggplot2() requires the 'ggplot2' package.", call. = FALSE)
  }
  ta <- .resolve_theme_args(preset, dark)
  fg <- .tok_hex("foreground", ta$preset, ta$dark)
  muted <- .tok_hex("muted-foreground", ta$preset, ta$dark)
  grid <- .tok_hex("chart-grid", ta$preset, ta$dark)
  ggplot2::theme_minimal(base_size = base_size) +
    ggplot2::theme(
      plot.background  = ggplot2::element_rect(fill = NA, color = NA),
      panel.background = ggplot2::element_rect(fill = NA, color = NA),
      legend.background = ggplot2::element_rect(fill = NA, color = NA),
      panel.grid.major = ggplot2::element_line(color = grid, linewidth = 0.3),
      panel.grid.minor = ggplot2::element_blank(),
      text        = ggplot2::element_text(color = fg),
      axis.text   = ggplot2::element_text(color = muted),
      axis.title  = ggplot2::element_text(color = fg),
      plot.title  = ggplot2::element_text(color = fg, face = "bold"),
      legend.text = ggplot2::element_text(color = fg)
    )
}

#' @rdname shad_theme_ggplot2
#' @param ... Passed to the underlying ggplot2 scale.
#' @export
shad_scale_color_shad <- function(preset = NULL, dark = FALSE, ...) {
  if (!requireNamespace("ggplot2", quietly = TRUE)) {
    stop("shad_scale_color_shad() requires the 'ggplot2' package.", call. = FALSE)
  }
  ta <- .resolve_theme_args(preset, dark)
  ggplot2::scale_color_manual(values = shad_chart_colors(6, ta$preset, ta$dark), ...)
}

#' @rdname shad_theme_ggplot2
#' @export
shad_scale_fill_shad <- function(preset = NULL, dark = FALSE, ...) {
  if (!requireNamespace("ggplot2", quietly = TRUE)) {
    stop("shad_scale_fill_shad() requires the 'ggplot2' package.", call. = FALSE)
  }
  ta <- .resolve_theme_args(preset, dark)
  ggplot2::scale_fill_manual(values = shad_chart_colors(6, ta$preset, ta$dark), ...)
}

#' Apply the shadshiny theme to a plotly chart
#'
#' Experimental.
#' Restyle a \pkg{plotly} plot with transparent backgrounds, tokenised fonts and
#' gridlines, and the shadshiny categorical colorway. Requires \pkg{plotly}.
#'
#' @param p A plotly object.
#' @param preset A preset name or [shad_current_theme()] list.
#' @param dark If `TRUE`, use dark-mode colors.
#' @returns The modified plotly object.
#' @family shadshiny theming
#' @examples
#' if (requireNamespace("plotly", quietly = TRUE)) {
#'   p <- plotly::plot_ly(mtcars, x = ~wt, y = ~mpg,
#'                        type = "scatter", mode = "markers")
#'   p <- shad_theme_plotly(p, preset = "green", dark = TRUE)
#' }
#' @export
shad_theme_plotly <- function(p, preset = NULL, dark = FALSE) {
  if (!requireNamespace("plotly", quietly = TRUE)) {
    stop("shad_theme_plotly() requires the 'plotly' package.", call. = FALSE)
  }
  ta <- .resolve_theme_args(preset, dark)
  fg <- .tok_hex("foreground", ta$preset, ta$dark)
  grid <- .tok_hex("chart-grid", ta$preset, ta$dark)
  axis <- list(gridcolor = grid, zerolinecolor = grid, tickfont = list(color = fg))
  plotly::layout(
    p,
    paper_bgcolor = "rgba(0,0,0,0)",
    plot_bgcolor  = "rgba(0,0,0,0)",
    font = list(color = fg),
    colorway = shad_chart_colors(6, ta$preset, ta$dark),
    xaxis = axis, yaxis = axis
  )
}

#' Apply the shadshiny theme to an echarts4r chart
#'
#' Experimental.
#' Set the shadshiny categorical colors and tokenised text on an \pkg{echarts4r}
#' chart. A text style already set on the chart, such as its font family, is
#' kept; only its color changes. Requires \pkg{echarts4r}.
#'
#' @param e An echarts4r object.
#' @param preset A preset name or [shad_current_theme()] list.
#' @param dark If `TRUE`, use dark-mode colors.
#' @returns The modified echarts4r object.
#' @family shadshiny theming
#' @examples
#' if (requireNamespace("echarts4r", quietly = TRUE)) {
#'   chart <- echarts4r::e_charts(mtcars, wt)
#'   chart <- echarts4r::e_scatter(chart, mpg)
#'   chart <- shad_theme_echarts4r(chart, preset = "blue")
#' }
#' @export
shad_theme_echarts4r <- function(e, preset = NULL, dark = FALSE) {
  if (!requireNamespace("echarts4r", quietly = TRUE)) {
    stop("shad_theme_echarts4r() requires the 'echarts4r' package.", call. = FALSE)
  }
  ta <- .resolve_theme_args(preset, dark)
  fg <- .tok_hex("foreground", ta$preset, ta$dark)
  e <- echarts4r::e_color(e, color = shad_chart_colors(6, ta$preset, ta$dark))
  # e_text_style() replaces the whole style, so carry over what is there.
  opts <- if (isTRUE(e$x$tl)) e$x$opts$baseOption else e$x$opts
  style <- opts$textStyle
  style$color <- fg
  do.call(echarts4r::e_text_style, c(list(e), style))
}

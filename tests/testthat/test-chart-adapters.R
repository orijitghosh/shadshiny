# The chart adapters restyle third-party plots with shadshiny's tokens:
# transparent backgrounds, the foreground, muted and chart-grid colours, and the
# six chart colours in order, in light or dark mode, from a preset name or a
# shad_current_theme() list. Restyling keeps what the user already set on the
# plot, except where ggplot2's own rule applies: a complete theme replaces
# earlier theme settings, so tweaks go after it.

adapter_tokens <- function(preset = NULL, dark = FALSE) {
  tokens <- shad_tokens(preset, dark)
  hex <- function(key) .oklch_to_hex(tokens[[key]])
  list(
    fg = hex("foreground"),
    muted = hex("muted-foreground"),
    grid = hex("chart-grid"),
    colors = shad_chart_colors(6, preset, dark)
  )
}

adapter_data <- data.frame(x = 1:3, y = c(2, 1, 3), g = c("a", "b", "c"))

is_blank_element <- function(element) {
  inherits(element, "element_blank") || inherits(element, "ggplot2::element_blank")
}

test_that("the ggplot2 theme is transparent and uses the token colours", {
  skip_if_not_installed("ggplot2")
  expect_false(identical(adapter_tokens()$fg, adapter_tokens(dark = TRUE)$fg))

  for (dark in c(FALSE, TRUE)) {
    tokens <- adapter_tokens(dark = dark)
    theme <- shad_theme_ggplot2(dark = dark)
    expect_true(inherits(theme, "theme"))
    expect_true(isTRUE(attr(theme, "complete")))

    for (part in c("plot.background", "panel.background", "legend.background")) {
      expect_true(is.na(theme[[part]]$fill), info = part)
      expect_true(is.na(theme[[part]]$colour), info = part)
    }
    for (part in c("text", "axis.title", "plot.title", "legend.text")) {
      expect_identical(theme[[part]]$colour, tokens$fg, info = part)
    }
    expect_identical(theme$axis.text$colour, tokens$muted)
    expect_identical(theme$panel.grid.major$colour, tokens$grid)
    expect_true(is_blank_element(theme$panel.grid.minor))
  }

  expect_identical(shad_theme_ggplot2()$text$size, 14)
  expect_identical(shad_theme_ggplot2(base_size = 10)$text$size, 10)
})

test_that("the ggplot2 theme takes a shad_current_theme() list", {
  skip_if_not_installed("ggplot2")
  from_list <- shad_theme_ggplot2(list(preset = "blue", dark = TRUE))
  expect_equal(from_list, shad_theme_ggplot2("blue", dark = TRUE))
  expect_identical(from_list$text$colour, adapter_tokens("blue", TRUE)$fg)
})

test_that("the ggplot2 scales give groups the chart colours in order", {
  skip_if_not_installed("ggplot2")
  plot <- ggplot2::ggplot(adapter_data, ggplot2::aes(x, y, colour = g, fill = g)) +
    ggplot2::geom_point(shape = 21)

  for (args in list(list(), list(dark = TRUE), list(preset = "blue"),
                    list(preset = list(preset = "blue", dark = TRUE)))) {
    expected <- if (is.list(args$preset)) {
      adapter_tokens("blue", TRUE)$colors
    } else {
      adapter_tokens(args$preset, isTRUE(args$dark))$colors
    }
    built <- ggplot2::ggplot_build(
      plot + do.call(shad_scale_color_shad, args) + do.call(shad_scale_fill_shad, args)
    )$data[[1]]
    expect_identical(built$colour, expected[1:3])
    expect_identical(built$fill, expected[1:3])
  }
  expect_false(identical(adapter_tokens()$colors, adapter_tokens("blue")$colors))

  expect_identical(shad_scale_color_shad(name = "Group")$name, "Group")
  expect_identical(shad_scale_fill_shad(name = "Group")$name, "Group")
})

test_that("a ggplot2 plot with the theme and scales renders in both modes", {
  skip_if_not_installed("ggplot2")
  grDevices::pdf(NULL)
  withr::defer(grDevices::dev.off())
  plot <- ggplot2::ggplot(adapter_data, ggplot2::aes(x, y, colour = g)) +
    ggplot2::geom_point()
  for (dark in c(FALSE, TRUE)) {
    grob <- ggplot2::ggplotGrob(
      plot + shad_theme_ggplot2(dark = dark) + shad_scale_color_shad(dark = dark)
    )
    expect_true(inherits(grob, "gtable"), info = paste("dark:", dark))
  }
})

test_that("the plotly adapter restyles the layout and keeps the user's settings", {
  skip_if_not_installed("plotly")
  plot <- plotly::plot_ly(adapter_data, x = ~x, y = ~y, type = "scatter",
                          mode = "markers") |>
    plotly::layout(font = list(family = "Inter"), xaxis = list(title = "Weight"))

  for (dark in c(FALSE, TRUE)) {
    tokens <- adapter_tokens(dark = dark)
    layout <- plotly::plotly_build(shad_theme_plotly(plot, dark = dark))$x$layout
    expect_identical(layout$paper_bgcolor, "rgba(0,0,0,0)")
    expect_identical(layout$plot_bgcolor, "rgba(0,0,0,0)")
    expect_identical(layout$font$color, tokens$fg)
    expect_identical(unlist(layout$colorway), tokens$colors)
    for (axis in c("xaxis", "yaxis")) {
      expect_identical(layout[[axis]]$gridcolor, tokens$grid, info = axis)
      expect_identical(layout[[axis]]$zerolinecolor, tokens$grid, info = axis)
      expect_identical(layout[[axis]]$tickfont$color, tokens$fg, info = axis)
    }
    expect_identical(layout$font$family, "Inter")
    expect_true("Weight" %in% unlist(layout$xaxis$title))
  }

  from_list <- plotly::plotly_build(
    shad_theme_plotly(plot, list(preset = "blue", dark = TRUE))
  )$x$layout
  expect_identical(unlist(from_list$colorway), adapter_tokens("blue", TRUE)$colors)
})

test_that("the echarts4r adapter sets the colours and keeps the user's text style", {
  skip_if_not_installed("echarts4r")
  chart <- echarts4r::e_charts(adapter_data, x) |>
    echarts4r::e_line(y) |>
    echarts4r::e_text_style(fontFamily = "Inter", fontSize = 13)

  for (dark in c(FALSE, TRUE)) {
    tokens <- adapter_tokens(dark = dark)
    opts <- shad_theme_echarts4r(chart, dark = dark)$x$opts
    expect_identical(unlist(opts$color), tokens$colors)
    expect_identical(opts$textStyle$color, tokens$fg)
    expect_identical(opts$textStyle$fontFamily, "Inter")
    expect_identical(opts$textStyle$fontSize, 13)
  }

  from_list <- shad_theme_echarts4r(chart, list(preset = "blue", dark = TRUE))$x$opts
  expect_identical(unlist(from_list$color), adapter_tokens("blue", TRUE)$colors)
  expect_identical(from_list$textStyle$color, adapter_tokens("blue", TRUE)$fg)
})

test_that("the echarts4r adapter keeps the text style of a timeline chart", {
  skip_if_not_installed("echarts4r")
  frames <- data.frame(x = rep(1:3, 2), y = 1:6, t = rep(c("a", "b"), each = 3))
  chart <- echarts4r::e_charts(echarts4r::group_by(frames, t), x, timeline = TRUE) |>
    echarts4r::e_line(y) |>
    echarts4r::e_text_style(fontFamily = "Inter")

  base <- shad_theme_echarts4r(chart, dark = TRUE)$x$opts$baseOption
  expect_identical(unlist(base$color), adapter_tokens(dark = TRUE)$colors)
  expect_identical(base$textStyle$color, adapter_tokens(dark = TRUE)$fg)
  expect_identical(base$textStyle$fontFamily, "Inter")
})

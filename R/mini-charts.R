# Native mini-charts -----------------------------------------------------------
# Inline SVG, no plotting stack, no server round-trip. The point of doing this
# in SVG rather than via renderPlot() is colour: the marks are painted with
# var(--shad-chart-N), so a dark-mode toggle or a preset switch restyles them in
# CSS -- nothing re-renders, and they work on a static page with no R at all.
#
# Geometry is computed in a 0..100 viewBox and stretched with
# preserveAspectRatio="none", which is what lets a sparkline fill whatever box
# it is dropped into. Strokes carry vector-effect="non-scaling-stroke" so that
# stretch never turns a 2px line into a 9px wedge.

.shad_vb <- 100  # viewBox extent on both axes

# A colour argument -> a paint value. 1..5 name the chart tokens; anything else
# is passed through, so "var(--shad-primary)" or "#f00" both work.
#' @noRd
shad_chart_paint <- function(color) {
  if (is.numeric(color)) {
    idx <- ((as.integer(color) - 1L) %% 5L) + 1L
    paste0("var(--shad-chart-", idx, ")")
  } else {
    as.character(color)
  }
}

# Trim SVG coordinates: two decimals is under a thousandth of a chart, and it
# keeps the markup (which ships inside every page) small.
#' @noRd
.svg_num <- function(x) {
  formatC(round(x, 2), format = "f", digits = 2, drop0trailing = TRUE)
}

# Scale values into viewBox space, leaving `pad` units of headroom at each end
# so a stroked mark at the extreme is not clipped in half.
#' @noRd
.spark_scale <- function(values, pad) {
  finite <- values[is.finite(values)]
  if (!length(finite)) return(NULL)
  lo <- min(finite); hi <- max(finite)
  span <- hi - lo
  # A flat series has no span to scale by; draw it down the middle rather than
  # dividing by zero.
  y <- if (span == 0) rep(.shad_vb / 2, length(values)) else {
    .shad_vb - pad - (values - lo) / span * (.shad_vb - 2 * pad)
  }
  n <- length(values)
  x <- if (n == 1) .shad_vb / 2 else seq(0, .shad_vb, length.out = n)
  list(x = x, y = y, lo = lo, hi = hi, span = span)
}

# Split indices into runs of consecutive non-missing points, so a gap in the
# data becomes a gap in the line instead of a straight line across it.
#' @noRd
.spark_runs <- function(values) {
  ok <- is.finite(values)
  if (!any(ok)) return(list())
  r <- rle(ok)
  ends <- cumsum(r$lengths)
  starts <- ends - r$lengths + 1L
  Map(seq, starts[r$values], ends[r$values])
}

# Path data for one run, per type.
#' @noRd
.spark_path <- function(idx, sc, type) {
  x <- sc$x[idx]; y <- sc$y[idx]
  if (length(idx) == 1) {
    # A single point has no line to draw; a dot keeps it visible.
    return(paste0("M", .svg_num(x), " ", .svg_num(y), "h0.01"))
  }
  if (type == "step") {
    seg <- paste0("H", .svg_num(x[-1]), "V", .svg_num(y[-1]), collapse = "")
    paste0("M", .svg_num(x[1]), " ", .svg_num(y[1]), seg)
  } else {
    paste0("M", .svg_num(x[1]), " ", .svg_num(y[1]),
           paste0("L", .svg_num(x[-1]), " ", .svg_num(y[-1]), collapse = ""))
  }
}

#' Sparkline
#'
#' A tiny inline chart with no axes, no labels and no plotting stack: one SVG
#' path (or a row of bars) that stretches to fill its container. Built for
#' [shad_value_box()]'s `sparkline` slot, a table cell, or an item row.
#'
#' Marks are painted with the theme's chart tokens, so dark mode and preset
#' switches restyle them in CSS – nothing re-renders, and no Shiny session is
#' involved. Non-finite values (`NA`, `NaN`, `Inf`) break the series into
#' separate runs rather than being interpolated across.
#'
#' @param values A numeric vector.
#' @param type `"line"` (default), `"area"`, `"bar"`, or `"step"`.
#' @param color Chart-token index `1`–`5` (default `1`), or any CSS colour.
#' @param width,height CSS dimensions of the drawing box. Height defaults to
#'   `"2.5rem"`; width to `"100%"`, so it fills whatever it is dropped into.
#' @param stroke_width Line thickness in px (line/step/area outline).
#' @param fill_opacity Opacity of the area fill / bars.
#' @param baseline For `"bar"`, draw bars from zero when the data crosses it.
#'   `NULL` (default) picks automatically: zero-anchored if any value is
#'   negative, otherwise bars grow from the floor.
#' @param label Accessible name. When `NULL` (default) the chart is decorative
#'   and hidden from assistive technology – correct when the number it
#'   illustrates is already on screen.
#' @param class Extra CSS classes.
#' @param ... Extra attributes for the root `<svg>`.
#' @returns An SVG tag.
#' @family shadshiny dashboard
#' @seealso [shad_mini_donut()], [shad_value_box()]
#' @examples
#' shad_sparkline(c(3, 5, 4, 8, 7, 12, 11))
#' shad_sparkline(c(-2, 1, 3, -1, 4), type = "bar", color = 2)
#' @export
shad_sparkline <- function(values, type = c("line", "area", "bar", "step"),
                           color = 1, width = "100%", height = "2.5rem",
                           stroke_width = 2, fill_opacity = 0.18,
                           baseline = NULL, label = NULL, class = NULL, ...) {
  type <- arg_match_shad(type, c("line", "area", "bar", "step"), "type")
  values <- as.numeric(values)
  if (!length(values)) stop("`values` must have at least one element.", call. = FALSE)
  paint <- shad_chart_paint(color)

  # Bars are drawn from an edge, so they need no stroke headroom; stroked
  # paths do, or the top and bottom marks are clipped through their middle.
  pad <- if (type == "bar") 0 else stroke_width
  sc <- .spark_scale(values, pad)
  if (is.null(sc)) stop("`values` must contain at least one finite value.", call. = FALSE)

  marks <- if (type == "bar") {
    n <- length(values)
    gap <- if (n > 1) min(2, .shad_vb / n * 0.3) else 0
    slot <- .shad_vb / n
    w <- max(slot - gap, 0.5)
    zeroed <- if (is.null(baseline)) any(values < 0, na.rm = TRUE) else isTRUE(baseline)
    # Where the bars grow from: the zero line if asked (and in range), else the
    # bottom of the box.
    base_y <- if (zeroed && sc$span > 0 && sc$lo <= 0 && sc$hi >= 0) {
      .shad_vb - (0 - sc$lo) / sc$span * .shad_vb
    } else {
      .shad_vb
    }
    keep <- which(is.finite(values))
    lapply(keep, function(i) {
      top <- min(sc$y[i], base_y); bottom <- max(sc$y[i], base_y)
      htmltools::tags$rect(
        x = .svg_num((i - 1) * slot + gap / 2), width = .svg_num(w),
        y = .svg_num(top), height = .svg_num(max(bottom - top, 0.5)),
        fill = paint, `fill-opacity` = fill_opacity, rx = .svg_num(min(w / 3, 1.5))
      )
    })
  } else {
    runs <- .spark_runs(values)
    line_type <- if (type == "step") "step" else "line"
    fills <- if (type == "area") {
      lapply(runs, function(idx) {
        d <- .spark_path(idx, sc, line_type)
        htmltools::tags$path(
          d = paste0(d, "V", .svg_num(.shad_vb), "H", .svg_num(sc$x[idx[1]]), "Z"),
          fill = paint, `fill-opacity` = fill_opacity, stroke = "none"
        )
      })
    }
    strokes <- lapply(runs, function(idx) {
      htmltools::tags$path(
        d = .spark_path(idx, sc, line_type), fill = "none", stroke = paint,
        `stroke-width` = stroke_width, `stroke-linecap` = "round",
        `stroke-linejoin` = "round", `vector-effect` = "non-scaling-stroke"
      )
    })
    c(fills, strokes)
  }

  with_deps(do.call(htmltools::tags$svg, c(
    list(
      class = shad_class("shad-sparkline", extra = class),
      viewBox = paste0("0 0 ", .shad_vb, " ", .shad_vb),
      preserveAspectRatio = "none",
      xmlns = "http://www.w3.org/2000/svg",
      style = paste0("width:", htmltools::validateCssUnit(width),
                     ";height:", htmltools::validateCssUnit(height), ";"),
      role = if (!is.null(label)) "img" else NULL,
      `aria-label` = label,
      `aria-hidden` = if (is.null(label)) "true" else NULL
    ),
    marks, list(...)
  )))
}

#' Mini donut chart
#'
#' A ring showing a handful of parts of a whole, with an optional label in the
#' middle. Like [shad_sparkline()] it is plain SVG painted with the theme's
#' chart tokens, so it follows dark mode and preset switches in CSS.
#'
#' Segments are drawn as dashes on a single circle, which is why there is no
#' path arithmetic here and why the ring stays perfectly round at any size.
#'
#' @param values A numeric vector of non-negative parts. They are shown in
#'   proportion to their sum, so they need not add to 1 or 100.
#' @param colors Chart-token indices or CSS colours, recycled across the
#'   segments. Defaults to chart tokens 1–5.
#' @param size CSS diameter (default `"6rem"`).
#' @param thickness Ring thickness as a fraction of the radius (default `0.28`).
#'   `1` gives a pie.
#' @param center Optional content for the middle of the ring (a value, a
#'   percentage, a tag).
#' @param track If `TRUE` (default), draw the muted background ring that shows
#'   through when the segments do not fill it.
#' @param label Accessible name. `NULL` (default) marks the chart decorative.
#' @param class Extra CSS classes.
#' @param ... Extra attributes for the root `<div>`.
#' @returns A `<div>` wrapping an SVG.
#' @family shadshiny dashboard
#' @seealso [shad_sparkline()]
#' @examples
#' shad_mini_donut(c(62, 24, 14), center = "62%")
#' @export
shad_mini_donut <- function(values, colors = 1:5, size = "6rem",
                            thickness = 0.28, center = NULL, track = TRUE,
                            label = NULL, class = NULL, ...) {
  values <- as.numeric(values)
  values[!is.finite(values)] <- 0
  if (!length(values) || any(values < 0)) {
    stop("`values` must be a non-empty vector of non-negative numbers.",
         call. = FALSE)
  }
  total <- sum(values)
  if (total <= 0) stop("`values` must sum to more than zero.", call. = FALSE)
  if (thickness <= 0 || thickness > 1) {
    stop("`thickness` must be in (0, 1].", call. = FALSE)
  }

  # Radius is measured to the middle of the stroke, so the ring's outer edge
  # lands exactly on the viewBox no matter how thick it is.
  r <- 50 / (1 + thickness)
  stroke <- 2 * r * thickness
  circumference <- 2 * pi * r
  paints <- vapply(colors, shad_chart_paint, character(1))

  offset <- 0
  segs <- list()
  for (i in seq_along(values)) {
    len <- values[[i]] / total * circumference
    if (len > 0) {
      segs[[length(segs) + 1L]] <- htmltools::tags$circle(
        cx = "50", cy = "50", r = .svg_num(r), fill = "none",
        stroke = paints[[((i - 1L) %% length(paints)) + 1L]],
        `stroke-width` = .svg_num(stroke),
        `stroke-dasharray` = paste(.svg_num(len), .svg_num(circumference - len)),
        # R keeps signed zero, and "-0" in an attribute is just noise
        `stroke-dashoffset` = .svg_num(if (offset == 0) 0 else -offset)
      )
    }
    offset <- offset + len
  }

  svg <- do.call(htmltools::tags$svg, c(
    list(
      class = "shad-donut__svg", viewBox = "0 0 100 100",
      xmlns = "http://www.w3.org/2000/svg",
      role = if (!is.null(label)) "img" else NULL,
      `aria-label` = label,
      `aria-hidden` = if (is.null(label)) "true" else NULL
    ),
    list(if (isTRUE(track)) {
      htmltools::tags$circle(
        cx = "50", cy = "50", r = .svg_num(r), fill = "none",
        stroke = "var(--shad-muted)", `stroke-width` = .svg_num(stroke)
      )
    }),
    segs
  ))

  with_deps(do.call(htmltools::tags$div, c(
    list(
      class = shad_class("shad-donut", extra = class),
      style = paste0("width:", htmltools::validateCssUnit(size),
                     ";height:", htmltools::validateCssUnit(size), ";")
    ),
    list(svg),
    list(if (!is.null(center)) {
      htmltools::tags$div(class = "shad-donut__center", center)
    }),
    list(...)
  )))
}

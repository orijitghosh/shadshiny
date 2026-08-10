# Native SVG mini-charts: sparkline + mini donut.

html <- function(x) as.character(htmltools::as.tags(x))

# --- paint --------------------------------------------------------------------

test_that("colour indices map onto chart tokens and wrap at five", {
  expect_identical(shadshiny:::shad_chart_paint(1), "var(--shad-chart-1)")
  expect_identical(shadshiny:::shad_chart_paint(5), "var(--shad-chart-5)")
  expect_identical(shadshiny:::shad_chart_paint(6), "var(--shad-chart-1)")
  # anything non-numeric passes through untouched
  expect_identical(shadshiny:::shad_chart_paint("#f00"), "#f00")
  expect_identical(shadshiny:::shad_chart_paint("var(--shad-primary)"),
                   "var(--shad-primary)")
})

# --- sparkline geometry -------------------------------------------------------

test_that("sparkline scales the series across the viewBox", {
  h <- html(shad_sparkline(c(0, 10), stroke_width = 2))
  # 2 units of stroke headroom top and bottom: min -> 98, max -> 2
  expect_match(h, 'd="M0 98L100 2"')
  expect_match(h, 'vector-effect="non-scaling-stroke"')
  expect_match(h, 'preserveAspectRatio="none"')
})

test_that("a flat series is drawn down the middle, not divided by zero", {
  h <- html(shad_sparkline(c(5, 5, 5)))
  expect_match(h, 'd="M0 50L50 50L100 50"')
})

test_that("a single point still renders a mark", {
  h <- html(shad_sparkline(7))
  expect_match(h, "M50 50h0.01")
})

test_that("non-finite values break the line rather than interpolating", {
  h <- html(shad_sparkline(c(1, 2, NA, 4, 5)))
  # two runs -> two paths, and nothing spans the gap
  expect_equal(lengths(regmatches(h, gregexpr("<path", h))), 2L)
})

test_that("step draws right angles and area closes to the floor", {
  expect_match(html(shad_sparkline(c(1, 2), type = "step")), "H100V2")
  area <- html(shad_sparkline(c(1, 2), type = "area"))
  expect_match(area, "V100H0Z")
  expect_match(area, 'fill-opacity="0.18"')
})

test_that("bar charts anchor to zero only when the data crosses it", {
  # all positive: bars grow from the floor, so every one ends at y = 100
  pos <- html(shad_sparkline(c(1, 2, 3), type = "bar"))
  expect_equal(lengths(regmatches(pos, gregexpr("<rect", pos))), 3L)
  expect_match(pos, 'y="100" height="0.5"')  # the minimum lands on the floor

  # crossing zero: bars hang off a shared baseline in the middle
  neg <- html(shad_sparkline(c(-5, 5), type = "bar"))
  expect_match(neg, 'y="50" height="50"')
  # ... and the caller can force it off
  flat <- html(shad_sparkline(c(-5, 5), type = "bar", baseline = FALSE))
  expect_false(grepl('y="50" height="50"', flat, fixed = TRUE))
})

test_that("sparkline rejects empty and all-missing input", {
  expect_error(shad_sparkline(numeric(0)), "at least one element")
  expect_error(shad_sparkline(c(NA, NA)), "at least one finite value")
  expect_error(shad_sparkline(1:3, type = "pie"), "`type` must be one of")
})

test_that("sparkline is decorative unless given a label", {
  expect_match(html(shad_sparkline(1:3)), 'aria-hidden="true"')
  labelled <- html(shad_sparkline(1:3, label = "Revenue trend"))
  expect_match(labelled, 'role="img"')
  expect_match(labelled, 'aria-label="Revenue trend"')
  expect_false(grepl("aria-hidden", labelled, fixed = TRUE))
})

# --- donut --------------------------------------------------------------------

test_that("donut segments divide the circumference in proportion", {
  h <- html(shad_mini_donut(c(1, 3)))
  # r = 50 / (1 + 0.28) = 39.06 -> circumference 245.44
  expect_match(h, 'r="39.06"')
  expect_match(h, 'stroke-dasharray="61.36 184.08"')   # a quarter
  expect_match(h, 'stroke-dasharray="184.08 61.36"')   # three quarters
  expect_match(h, 'stroke-dashoffset="-61.36"')        # ... starting after it
  expect_match(h, 'stroke-dashoffset="0"')             # never "-0"
})

test_that("donut colours cycle through the tokens given", {
  h <- html(shad_mini_donut(rep(1, 7)))
  expect_match(h, "var\\(--shad-chart-5\\)")
  # the sixth segment wraps back to the first token
  expect_equal(lengths(regmatches(h, gregexpr("var\\(--shad-chart-1\\)", h))), 2L)
})

test_that("donut takes a centre label and an optional track", {
  expect_match(html(shad_mini_donut(c(1, 1), center = "50%")),
               "shad-donut__center")
  expect_match(html(shad_mini_donut(1)), "var\\(--shad-muted\\)")
  expect_false(grepl("var(--shad-muted)", html(shad_mini_donut(1, track = FALSE)),
                     fixed = TRUE))
})

test_that("donut validates its inputs", {
  expect_error(shad_mini_donut(numeric(0)), "non-empty")
  expect_error(shad_mini_donut(c(1, -1)), "non-negative")
  expect_error(shad_mini_donut(c(0, 0)), "sum to more than zero")
  expect_error(shad_mini_donut(1, thickness = 0), "thickness")
  expect_error(shad_mini_donut(1, thickness = 2), "thickness")
})

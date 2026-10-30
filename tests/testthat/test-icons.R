test_that("every registered icon renders a conforming svg", {
  for (nm in shad_icon_names()) {
    svg <- as.character(shad_icon(nm))
    expect_match(svg, 'class="shad-icon"', fixed = TRUE, info = nm)
    expect_match(svg, 'viewBox="0 0 24 24"', fixed = TRUE, info = nm)
    expect_match(svg, 'stroke="currentColor"', fixed = TRUE, info = nm)
    expect_match(svg, "^<svg", info = nm)
  }
})

test_that("unknown icon errors and lists valid names", {
  err <- expect_error(shad_icon("not-a-real-icon"))
  expect_match(conditionMessage(err), "not-a-real-icon", fixed = TRUE)
  expect_match(conditionMessage(err), "check", fixed = TRUE)
})

test_that("icon with aria-label drops aria-hidden", {
  svg <- as.character(shad_icon("check", `aria-label` = "Done"))
  expect_match(svg, 'aria-label="Done"', fixed = TRUE)
  expect_false(grepl("aria-hidden", svg))
})

test_that("a custom class overrides the default", {
  svg <- as.character(shad_icon("check", class = "my-icon"))
  expect_match(svg, 'class="my-icon"', fixed = TRUE)
})

test_that("shad_icon escapes class and attribute values", {
  hostile <- 'x" data-inert="marker'
  rendered <- as.character(shad_icon("check", class = hostile, title = hostile))

  expect_false(grepl(' data-inert="marker"', rendered, fixed = TRUE))
  expect_match(rendered, "&quot;", fixed = TRUE)
})

test_that("resolve_icon accepts a name or a tag", {
  expect_match(as.character(shadshiny:::resolve_icon("check")), "svg")
  tag <- htmltools::tags$span("x")
  expect_identical(shadshiny:::resolve_icon(tag), tag)
  expect_null(shadshiny:::resolve_icon(NULL))
})

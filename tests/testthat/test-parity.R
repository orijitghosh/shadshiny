# Structural parity against the canonical anatomy files. Each test pins an
# anatomy fragment by index (see the component's <name>.html source).
skip_if_not_installed("xml2")

test_that("button default matches anatomy", {
  # nodes 1..: default, secondary, destructive, outline, ghost, link
  expect_anatomy_match(shad_button("Button"), "button", index = 1)
  expect_anatomy_match(shad_button("Secondary", variant = "secondary"),
                       "button", index = 2)
})

test_that("badge variants match anatomy", {
  expect_anatomy_match(shad_badge("Badge"), "badge", index = 1)
  expect_anatomy_match(shad_badge("Secondary", variant = "secondary"),
                       "badge", index = 2)
})

test_that("separator semantic horizontal matches anatomy", {
  # nodes: 1 "Above" div, 2 semantic separator, 3 "Below" div, ...
  expect_anatomy_match(shad_separator(decorative = FALSE), "separator", index = 2)
})

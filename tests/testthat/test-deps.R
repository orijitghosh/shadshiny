test_that("asset dependency has the expected structure", {
  dep <- shadshiny:::shadshiny_dependency()
  expect_s3_class(dep, "html_dependency")
  expect_identical(dep$name, "shadshiny")
})

test_that("CSS load order leads with tokens, base, animations, dropdown-menu", {
  css <- shadshiny:::shad_asset_css_order()
  expect_identical(css[1:4], c(
    "tokens/shad-tokens.css",
    "core/shad-base.css",
    "core/shad-animations.css",
    "components/dropdown-menu/dropdown-menu.css"
  ))
  # 49 component CSS + tokens + base + animations
  expect_length(css, 49 + 3)
  # no component css appears twice (dropdown-menu hoisted, not duplicated)
  expect_false(any(duplicated(css)))
})

test_that("JS load order leads with runtime and ends with the shiny binding", {
  js <- shadshiny:::shad_asset_js_order()
  expect_identical(js[1:4], c(
    "core/shad-runtime.js",
    "components/dialog/dialog.js",
    "components/alert-dialog/alert-dialog.js",
    "components/dropdown-menu/dropdown-menu.js"
  ))
  expect_identical(js[length(js)], "shiny/shadshiny-shiny.js")
  # 34 component JS + runtime + shiny binding
  expect_length(js, 34 + 2)
  expect_false(any(duplicated(js)))
})

test_that("shadshiny_deps() returns a tagList carrying the dependency", {
  tl <- shadshiny_deps()
  expect_s3_class(tl, "shiny.tag.list")
})

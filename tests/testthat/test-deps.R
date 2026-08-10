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
  # every component dir that ships a .css, plus tokens + base + animations
  n_css <- length(list.files(
    system.file("assets", "components", package = "shadshiny"),
    pattern = "[.]css$", recursive = TRUE))
  expect_length(css, n_css + 3)
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
  # 36 component JS + runtime + shiny binding
  expect_length(js, 43 + 2)
  expect_false(any(duplicated(js)))
})

test_that("shadshiny_deps() returns a tagList carrying the dependency", {
  tl <- shadshiny_deps()
  expect_s3_class(tl, "shiny.tag.list")
})

test_that("the built bundle is served as one stylesheet and one script", {
  skip_if(is.null(shadshiny:::shad_asset_bundle()), "bundle not built")
  dep <- shadshiny:::shadshiny_dependency()
  expect_identical(dep$stylesheet, "dist/shadshiny.min.css")
  expect_identical(dep$script, "dist/shadshiny.min.js")
})

test_that("options(shadshiny.assets = 'source') falls back to the split files", {
  withr::local_options(shadshiny.assets = "source")
  dep <- shadshiny:::shadshiny_dependency()
  expect_identical(dep$stylesheet, shadshiny:::shad_asset_css_order())
  expect_identical(dep$script, shadshiny:::shad_asset_js_order())
})

test_that("the bundle was built from the same files, in the same order", {
  # tools/build-assets.mjs reimplements the load order in JS. If the two ever
  # disagree the bundle silently ships stale or misordered CSS, so pin them.
  path <- system.file("assets", "dist", "manifest.json", package = "shadshiny")
  skip_if(!nzchar(path), "bundle not built")
  manifest <- jsonlite::fromJSON(path)
  expect_identical(manifest$css, shadshiny:::shad_asset_css_order())
  expect_identical(manifest$js, shadshiny:::shad_asset_js_order())
})

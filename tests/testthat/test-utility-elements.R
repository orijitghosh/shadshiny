# Plan 7 utility element contracts --------------------------------------------

test_that("kbd groups render separators and preserve nested kbd tags", {
  ui <- shad_kbd_group(
    shad_kbd("Ctrl"), shad_kbd("K"),
    separator = " + ", class = "shortcut-group", `data-testid` = "keys"
  )
  html <- as.character(ui)

  expect_match(html, "shad-kbd-group shortcut-group", fixed = TRUE)
  expect_match(html, 'data-testid="keys"', fixed = TRUE)
  expect_match(html, 'role="group"', fixed = TRUE)
  expect_match(html, '<kbd class="shad-kbd">Ctrl</kbd>', fixed = TRUE)
  expect_match(html, '<kbd class="shad-kbd">K</kbd>', fixed = TRUE)
  expect_match(html, 'class="shad-kbd-group__separator"', fixed = TRUE)
  expect_match(html, "> + </span>", fixed = TRUE)
  expect_length(htmltools::htmlDependencies(ui), 1L)
})

test_that("kbd groups allow empty separators and empty content", {
  expect_silent(shad_kbd_group(separator = ""))
  expect_silent(shad_kbd_group(shad_kbd(""), separator = ""))
  expect_error(shad_kbd_group(separator = character()), "separator")
  expect_error(shad_kbd_group(separator = NA_character_), "separator")
  expect_error(shad_kbd_group(separator = c("+", "-")), "separator")
})

test_that("code blocks escape code and metadata and isolate line numbers", {
  hostile_code <- '<script>alert("x")</script> & <b>unsafe</b>\nsecond'
  hostile_filename <- 'demo.html" data-bad="yes'
  hostile_language <- 'html" data-bad="yes'
  ui <- shad_code_block(
    hostile_code,
    language = hostile_language,
    filename = hostile_filename,
    line_numbers = TRUE,
    class = "example-code"
  )
  html <- as.character(ui)

  expect_match(html, 'data-shad-code-block', fixed = TRUE)
  expect_match(html, 'class="shad-code-block example-code"', fixed = TRUE)
  expect_match(html, "&lt;script&gt;alert", fixed = TRUE)
  expect_false(grepl("<script>", html, fixed = TRUE))
  expect_match(html, "&lt;b&gt;unsafe&lt;/b&gt;", fixed = TRUE)
  expect_match(html, "demo.html", fixed = TRUE)
  expect_match(html, "data-language=", fixed = TRUE)
  expect_match(html, "&quot;", fixed = TRUE)
  expect_false(grepl('data-bad="yes"', html, fixed = TRUE))
  expect_false(grepl("data-code=", html, fixed = TRUE))
  expect_match(html, 'class="shad-code-block__gutter"', fixed = TRUE)
  expect_match(html, 'aria-hidden="true"', fixed = TRUE)
  expect_match(html, '<pre', fixed = TRUE)
  expect_match(html, '<code', fixed = TRUE)
  expect_match(html, 'data-shad-copy-code', fixed = TRUE)
  expect_match(html, 'role="status"', fixed = TRUE)
  expect_match(html, 'aria-live="polite"', fixed = TRUE)
  expect_length(htmltools::htmlDependencies(ui), 1L)
})

test_that("code blocks preserve empty code and optional controls", {
  html <- as.character(shad_code_block(
    "", copy = FALSE, line_numbers = FALSE, language = "", filename = ""
  ))

  expect_match(html, '<pre', fixed = TRUE)
  expect_match(html, '<code', fixed = TRUE)
  expect_false(grepl("data-shad-copy-code", html, fixed = TRUE))
  expect_false(grepl("shad-code-block__gutter", html, fixed = TRUE))
  expect_match(html, 'data-language=""', fixed = TRUE)
})

test_that("code block scalar arguments are strict", {
  expect_error(shad_code_block(character()), "code")
  expect_error(shad_code_block(NA_character_), "code")
  expect_error(shad_code_block(c("a", "b")), "code")
  expect_error(shad_code_block("x", language = NA_character_), "language")
  expect_error(shad_code_block("x", language = c("r", "R")), "language")
  expect_error(shad_code_block("x", filename = NA_character_), "filename")
  expect_error(shad_code_block("x", copy = c(TRUE, FALSE)), "copy")
  expect_error(shad_code_block("x", line_numbers = 1), "line_numbers")
})

test_that("scroll fades render logical axis metadata and remain tabbable", {
  vertical <- shad_scroll_fade(shad_p("Vertical"), axis = "vertical")
  horizontal <- shad_scroll_fade("Horizontal", axis = "horizontal", class = "wide")
  both <- shad_scroll_fade("Both", axis = "both", `data-testid` = "both")

  expect_match(as.character(vertical), 'class="shad-scroll-fade"', fixed = TRUE)
  expect_match(as.character(vertical), 'data-axis="vertical"', fixed = TRUE)
  expect_match(as.character(vertical), 'tabindex="0"', fixed = TRUE)
  expect_match(as.character(horizontal), 'data-axis="horizontal"', fixed = TRUE)
  expect_match(as.character(horizontal), 'shad-scroll-fade wide', fixed = TRUE)
  expect_match(as.character(both), 'data-axis="both"', fixed = TRUE)
  expect_match(as.character(both), 'data-testid="both"', fixed = TRUE)
  expect_length(htmltools::htmlDependencies(vertical), 1L)
  expect_error(shad_scroll_fade("x", axis = "diagonal"), "axis")
  expect_error(shad_scroll_fade("x", axis = character()), "axis")
})

test_that("shimmer has readable active and inactive states", {
  active <- as.character(shad_shimmer("Loading", active = TRUE, class = "status"))
  inactive <- as.character(shad_shimmer("Ready", active = FALSE))

  expect_match(active, 'class="shad-shimmer status"', fixed = TRUE)
  expect_match(active, "data-active", fixed = TRUE)
  expect_match(active, "Loading", fixed = TRUE)
  expect_match(inactive, 'class="shad-shimmer"', fixed = TRUE)
  expect_false(grepl("data-active", inactive, fixed = TRUE))
  expect_match(inactive, "Ready", fixed = TRUE)
  expect_error(shad_shimmer("x", active = c(TRUE, FALSE)), "active")
  expect_error(shad_shimmer("x", active = NA), "active")
})

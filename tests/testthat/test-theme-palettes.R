# Contract for the theme presets:
# 1. the CSS that ships and the JSON that shad_tokens() reads carry the same
#    values for every preset, in light and dark;
# 2. every full-ramp palette keeps its text readable (WCAG AA, 4.5:1) on the
#    surfaces it sits on.

ramp_presets <- c("slate", "stone", "zinc", "mauve", "olive", "mist", "taupe")

preset_css_tokens <- function(preset, dark) {
  path <- system.file("assets/tokens/shad-tokens.css", package = "shadshiny")
  css <- paste(readLines(path, warn = FALSE), collapse = "\n")
  css <- gsub("(?s)/\\*.*?\\*/", "", css, perl = TRUE)
  squish <- function(x) gsub("\\s*,\\s*", ",", gsub("\\s+", " ", trimws(x)))
  target <- if (dark) {
    sprintf(':is(.dark, [data-bs-theme="dark"]) [data-shad-theme="%1$s"], [data-shad-theme="%1$s"]:is(.dark, [data-bs-theme="dark"])', preset)
  } else {
    sprintf('[data-shad-theme="%s"]', preset)
  }
  blocks <- regmatches(css, gregexpr("[^{}]+\\{[^{}]*\\}", css, perl = TRUE))[[1]]
  out <- list()
  for (block in blocks) {
    if (!identical(squish(sub("\\{.*$", "", block)), squish(target))) next
    body <- sub("\\}\\s*$", "", sub("^[^{]*\\{", "", block))
    for (decl in trimws(strsplit(body, ";", fixed = TRUE)[[1]])) {
      if (!nzchar(decl)) next
      name <- sub("^--shad-", "", trimws(sub(":.*$", "", decl)))
      out[[name]] <- trimws(sub("^[^:]*:", "", decl))
    }
  }
  out
}

contrast_ratio <- function(a, b) {
  luminance <- function(color) {
    rgb <- grDevices::col2rgb(substr(shadshiny:::.oklch_to_hex(color), 1, 7))[, 1] / 255
    linear <- ifelse(rgb <= 0.04045, rgb / 12.92, ((rgb + 0.055) / 1.055)^2.4)
    sum(c(0.2126, 0.7152, 0.0722) * linear)
  }
  l <- sort(c(luminance(a), luminance(b)), decreasing = TRUE)
  (l[[1]] + 0.05) / (l[[2]] + 0.05)
}

test_that("every preset ships the same tokens in CSS and in shad-tokens.json", {
  presets <- shadshiny:::.shad_presets
  expect_true(all(ramp_presets %in% presets))
  json <- shadshiny:::.shad_load_tokens()$presets
  expect_setequal(names(json), presets)

  for (preset in presets) {
    for (dark in c(FALSE, TRUE)) {
      mode <- if (dark) "dark" else "light"
      css <- preset_css_tokens(preset, dark)
      info <- paste(preset, mode)
      expect_true(length(css) > 0, info = info)
      expect_setequal(names(css), names(json[[preset]][[mode]]))
      expect_identical(css[names(json[[preset]][[mode]])],
                       json[[preset]][[mode]], info = info)
    }
  }
})

test_that("full-ramp palettes keep text at 4.5:1 on their surfaces", {
  pairs <- list(
    c("foreground", "background"),
    c("muted-foreground", "background"),
    c("muted-foreground", "muted"),
    c("chart-label", "background"),
    c("card-foreground", "card"),
    c("primary-foreground", "primary"),
    c("secondary-foreground", "secondary"),
    c("accent-foreground", "accent"),
    c("sidebar-foreground", "sidebar"),
    c("sidebar-accent-foreground", "sidebar-accent")
  )
  for (preset in ramp_presets) {
    for (dark in c(FALSE, TRUE)) {
      tokens <- shad_tokens(preset, dark = dark)
      for (pair in pairs) {
        ratio <- contrast_ratio(tokens[[pair[[1]]]], tokens[[pair[[2]]]])
        expect_gte(ratio, 4.5, label = sprintf(
          "%s %s: %s on %s", preset, if (dark) "dark" else "light", pair[[1]], pair[[2]]
        ))
      }
    }
  }
})

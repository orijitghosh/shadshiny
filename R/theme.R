# Theming ----------------------------------------------------------------------

# --- OKLCH -> hex (base R; avoids a farver runtime dependency) ----------------
# Parses "oklch(L C H)" / "oklch(L C H / a)" and returns an #rrggbb (or
# #rrggbbaa) string. Non-oklch inputs (raw hex, rgb(), names) pass through.
.oklch_to_hex <- function(x) {
  if (is.null(x) || is.na(x)) return(NA_character_)
  x <- trimws(x)
  m <- regmatches(x, regexec(
    "^oklch\\(\\s*([0-9.]+)\\s+([0-9.]+)\\s+([0-9.]+)\\s*(?:/\\s*([0-9.]+)\\s*)?\\)$", x))[[1]]
  if (length(m) == 0) return(x)  # already a CSS/R-parseable color
  L <- as.numeric(m[2]); C <- as.numeric(m[3]); H <- as.numeric(m[4])
  alpha <- if (nzchar(m[5])) as.numeric(m[5]) else 1
  hr <- H * pi / 180
  a <- C * cos(hr); b <- C * sin(hr)
  # OKLab -> LMS'
  l_ <- L + 0.3963377774 * a + 0.2158037573 * b
  m_ <- L - 0.1055613458 * a - 0.0638541728 * b
  s_ <- L - 0.0894841775 * a - 1.2914855480 * b
  l <- l_^3; m2 <- m_^3; s <- s_^3
  # LMS -> linear sRGB
  r <-  4.0767416621 * l - 3.3077115913 * m2 + 0.2309699292 * s
  g <- -1.2684380046 * l + 2.6097574011 * m2 - 0.3413193965 * s
  bl <- -0.0041960863 * l - 0.7034186147 * m2 + 1.7076147010 * s
  gamma <- function(u) {
    u <- pmin(pmax(u, 0), 1)
    ifelse(u <= 0.0031308, 12.92 * u, 1.055 * u^(1 / 2.4) - 0.055)
  }
  rgb <- round(gamma(c(r, g, bl)) * 255)
  hex <- sprintf("#%02X%02X%02X", rgb[1], rgb[2], rgb[3])
  if (alpha < 1) hex <- paste0(hex, sprintf("%02X", round(alpha * 255)))
  hex
}

# --- token table (cached) -----------------------------------------------------
.shad_token_cache <- new.env(parent = emptyenv())

.shad_load_tokens <- function() {
  if (is.null(.shad_token_cache$data)) {
    path <- system.file("assets/tokens/shad-tokens.json", package = "shadshiny")
    if (!nzchar(path)) stop("shad-tokens.json not found in package assets.", call. = FALSE)
    .shad_token_cache$data <- jsonlite::fromJSON(path, simplifyVector = FALSE)
  }
  .shad_token_cache$data
}

#' Resolve theme tokens
#'
#' Return the resolved shadshiny design tokens for a theme preset and mode, as a
#' named list of raw CSS values (OKLCH strings). Used by the chart adapters and
#' available for custom plotting. Names are the token keys without the `--shad-`
#' prefix (e.g. `primary`, `chart-1`, `chart-grid`).
#'
#' @param preset One of the seven presets (`"slate"`, `"stone"`, `"blue"`,
#'   `"green"`, `"rose"`, `"violet"`, `"orange"`), or `NULL` for the base (zinc)
#'   theme.
#' @param dark If `TRUE`, return dark-mode values.
#' @param overrides Optional named list of token overrides (without `--shad-`),
#'   e.g. from a [shad_theme()] object, applied on top.
#' @returns A named list of CSS value strings.
#' @family shadshiny theming
#' @examples
#' shad_tokens()[["primary"]]
#' shad_tokens("blue", dark = TRUE)[["chart-1"]]
#' @export
shad_tokens <- function(preset = NULL, dark = FALSE, overrides = NULL) {
  tk <- .shad_load_tokens()
  mode <- if (isTRUE(dark)) "dark" else "light"
  vals <- tk$base[[mode]]
  if (!is.null(preset)) {
    preset <- arg_match_shad(preset, .shad_presets, "preset")
    pv <- tk$presets[[preset]][[mode]]
    if (!is.null(pv)) vals[names(pv)] <- pv
  }
  if (!is.null(overrides)) vals[names(overrides)] <- overrides
  vals
}

#' Chart series colors
#'
#' The categorical chart palette (`--shad-chart-1` … `--shad-chart-6`) for a
#' theme, converted to hex for use with R plotting libraries.
#'
#' @param n Number of colors (recycled past 6, with a warning).
#' @param preset Theme preset (see [shad_tokens()]); `NULL` = base.
#' @param dark If `TRUE`, use dark-mode values.
#' @returns A character vector of `#rrggbb` hex colors.
#' @family shadshiny theming
#' @examples
#' shad_chart_colors(3)
#' shad_chart_colors(4, preset = "blue")
#' @export
shad_chart_colors <- function(n = 6, preset = NULL, dark = FALSE) {
  vals <- shad_tokens(preset, dark)
  base <- vapply(paste0("chart-", 1:6), function(k) .oklch_to_hex(vals[[k]]),
                 character(1))
  base <- unname(base)
  if (n <= 6) return(base[seq_len(n)])
  warning("Requested more than 6 chart colors; recycling.", call. = FALSE)
  rep(base, length.out = n)
}

# --- custom themes ------------------------------------------------------------

#' Define a custom theme
#'
#' Build a custom shadshiny theme by overriding design tokens. Only the tokens
#' you supply are emitted; everything else inherits the base theme, so a
#' one-liner like `shad_theme(primary = "#7c3aed")` is a complete brand theme.
#' Pass the result to [page_shad()], [shad_theme_scope()], or
#' [update_shad_theme()].
#'
#' @param primary,primary_foreground,background,foreground,card,card_foreground,muted,muted_foreground,accent,accent_foreground,destructive,border,input,ring
#'   Color tokens. Accept any CSS color string (`"#7c3aed"`, `"oklch(...)"`) or
#'   an R color name.
#' @param radius Base radius (e.g. `"0.5rem"`).
#' @param font_sans,font_mono CSS font-family strings.
#' @param chart Character vector of up to 6 chart series colors.
#' @param dark Optional dark-mode overrides, applied under `.dark`. Either a
#'   second [shad_theme()] or a named list of the same token arguments, which is
#'   passed to [shad_theme()] for you. Tokens you omit keep their light value.
#' @param ... Any additional raw token: `sidebar = ...` maps to
#'   `--shad-sidebar`, `sidebar_primary = ...` to `--shad-sidebar-primary`, etc.
#' @returns A `shad_theme` object.
#' @family shadshiny theming
#' @examples
#' shad_theme(primary = "#7c3aed", radius = "0.75rem")
#' @export
shad_theme <- function(primary = NULL, primary_foreground = NULL,
                       background = NULL, foreground = NULL, card = NULL,
                       card_foreground = NULL, muted = NULL,
                       muted_foreground = NULL, accent = NULL,
                       accent_foreground = NULL, destructive = NULL,
                       border = NULL, input = NULL, ring = NULL, radius = NULL,
                       font_sans = NULL, font_mono = NULL, chart = NULL,
                       dark = NULL, ...) {
  named <- drop_nulls(list(
    primary = primary, `primary-foreground` = primary_foreground,
    background = background, foreground = foreground, card = card,
    `card-foreground` = card_foreground, muted = muted,
    `muted-foreground` = muted_foreground, accent = accent,
    `accent-foreground` = accent_foreground, destructive = destructive,
    border = border, input = input, ring = ring, radius = radius,
    `font-sans` = font_sans, `font-mono` = font_mono
  ))
  if (!is.null(chart)) {
    for (i in seq_along(chart)) named[[paste0("chart-", i)]] <- chart[[i]]
  }
  extra <- list(...)
  if (length(extra)) {
    names(extra) <- gsub("_", "-", names(extra))
    named[names(extra)] <- extra
  }
  # normalise R color names to hex; leave CSS strings intact
  named <- lapply(named, .normalize_color)
  # `dark` may be a shad_theme() or a bare named list of the same tokens
  if (!is.null(dark) && !inherits(dark, "shad_theme")) {
    if (!is.list(dark) || is.null(names(dark)) || !all(nzchar(names(dark)))) {
      stop("`dark` must be a shad_theme() or a fully named list of tokens.",
           call. = FALSE)
    }
    dark <- do.call(shad_theme, dark)
  }
  structure(list(tokens = named, dark = dark), class = "shad_theme")
}

.normalize_color <- function(v) {
  v <- as.character(v)
  # pass through CSS functions, hex, rem/px units, font stacks
  if (grepl("[(#,]", v) || grepl("rem|px|em|%|\\s", v)) return(v)
  # R color name -> hex
  if (v %in% grDevices::colors()) {
    rgb <- grDevices::col2rgb(v)
    return(sprintf("#%02X%02X%02X", rgb[1], rgb[2], rgb[3]))
  }
  v
}

# Render a shad_theme to a scoped <style> tag body.
.shad_theme_css <- function(theme, selector = ":root") {
  decl <- function(tokens) {
    paste(vapply(names(tokens), function(k) {
      sprintf("  --shad-%s: %s;", k, tokens[[k]])
    }, character(1)), collapse = "\n")
  }
  css <- sprintf("%s {\n%s\n}", selector, decl(theme$tokens))
  if (!is.null(theme$dark) && inherits(theme$dark, "shad_theme")) {
    dark_sel <- if (selector == ":root") {
      ".dark, [data-bs-theme=\"dark\"]"
    } else {
      sprintf("%s.dark, [data-bs-theme=\"dark\"] %s", selector, selector)
    }
    css <- paste0(css, "\n", sprintf("%s {\n%s\n}", dark_sel, decl(theme$dark$tokens)))
  }
  css
}

#' Scope a custom theme to a subtree
#'
#' Wrap UI in a custom [shad_theme()] applied only to its descendants.
#'
#' @param theme A [shad_theme()] object.
#' @param ... UI to wrap.
#' @param class Extra CSS classes on the wrapper.
#' @returns A `<div>` scoping the theme.
#' @family shadshiny theming
#' @examples
#' shad_theme_scope(shad_theme(primary = "#16a34a"), shad_button("Go"))
#' @export
shad_theme_scope <- function(theme, ..., class = NULL) {
  if (!inherits(theme, "shad_theme")) stop("`theme` must be a shad_theme().", call. = FALSE)
  scope <- shad_uid("theme")
  sel <- paste0(".", scope)
  with_deps(htmltools::tagList(
    htmltools::tags$style(htmltools::HTML(.shad_theme_css(theme, sel))),
    htmltools::tags$div(class = shad_class(scope, extra = class), ...)
  ))
}

# Head <style> tag for a page-level custom theme (used by page_shad(theme=)).
#' @noRd
shad_theme_style_tag <- function(theme) {
  if (is.null(theme)) return(NULL)
  if (!inherits(theme, "shad_theme")) stop("`theme` must be a shad_theme().", call. = FALSE)
  htmltools::tags$style(htmltools::HTML(.shad_theme_css(theme, ":root")))
}

# --- registry / tweakcn import ------------------------------------------------

#' Import a theme from a shadcn / tweakcn registry export
#'
#' Experimental.
#' Convert a shadcn registry item or tweakcn theme export (its `cssVars` blocks)
#' into a [shad_theme()], mapping upstream variable names to shadshiny tokens via
#' the bundled theme map. Unmapped variables are skipped with a single warning.
#'
#' @param json A file path, URL, or JSON string of a registry/tweakcn export.
#' @returns A `shad_theme` object.
#' @family shadshiny theming
#' @examples
#' \dontrun{
#' shad_theme_from_registry("https://tweakcn.com/r/themes/my-theme.json")
#' }
#' @export
shad_theme_from_registry <- function(json) {
  data <- jsonlite::fromJSON(json, simplifyVector = TRUE)
  map_path <- system.file("assets/tokens/shad-theme-map.json", package = "shadshiny")
  themap <- jsonlite::fromJSON(map_path, simplifyVector = FALSE)

  css_vars <- data$cssVars
  if (is.null(css_vars)) stop("No `cssVars` block found in the registry export.", call. = FALSE)

  # upstream var name (e.g. "--primary") -> shadshiny token (e.g. "primary").
  # The map's `shad` values keep the "shad-" prefix; strip it to the token key.
  entries <- themap$map %||% themap
  lut <- list()
  for (up in names(entries)) {
    e <- entries[[up]]
    if (is.list(e) && !is.null(e$shad) && !is.na(e$shad)) {
      lut[[up]] <- sub("^shad-", "", e$shad)
      lut[[sub("^--", "", up)]] <- sub("^shad-", "", e$shad)  # also key without --
    }
  }

  unmapped <- character(0)
  convert <- function(block) {
    out <- list()
    for (up in names(block)) {
      shad_key <- lut[[up]] %||% lut[[sub("^--", "", up)]]
      if (is.null(shad_key)) { unmapped <<- c(unmapped, up); next }
      out[[shad_key]] <- block[[up]]
    }
    out
  }

  light <- convert(css_vars$light %||% css_vars$theme %||% list())
  dark_block <- if (!is.null(css_vars$dark)) convert(css_vars$dark) else NULL

  if (length(unmapped)) {
    warning(sprintf("Skipped %d unmapped theme variable(s): %s.",
                    length(unmapped),
                    paste(unique(unmapped), collapse = ", ")), call. = FALSE)
  }

  dark_theme <- if (!is.null(dark_block)) {
    structure(list(tokens = dark_block, dark = NULL), class = "shad_theme")
  }
  structure(list(tokens = light, dark = dark_theme), class = "shad_theme")
}

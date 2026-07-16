# V2 shared internals ----------------------------------------------------------

# Inline SVG glyphs used by the V2 constructors (kept as raw markup so the R
# layer emits the exact icons the design bundle ships). Each is a self-contained
# <svg>; callers wrap with htmltools::HTML().
.shad_svg <- list(
  check = '<svg class="%s" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M4 12l5 5L20 7" pathLength="1"/></svg>',
  x     = '<svg class="%s" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" aria-hidden="true"><path d="M6 6l12 12M18 6L6 18"/></svg>',
  chevron = '<svg class="%s" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M9 6l6 6-6 6"/></svg>',
  chevron_leaf = '<svg class="%s" viewBox="0 0 24 24" aria-hidden="true"><path d="M9 6l6 6-6 6"/></svg>',
  minus = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" aria-hidden="true"><path d="M5 12h14"/></svg>',
  plus  = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" aria-hidden="true"><path d="M12 5v14M5 12h14"/></svg>',
  upload = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><path d="M17 8l-5-5-5 5"/><path d="M12 3v12"/></svg>',
  alert_circle = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="12" cy="12" r="10"/><path d="M12 8v4M12 16h.01"/></svg>',
  check_plain = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M4 12l5 5L20 7"/></svg>',
  triangle = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M10.3 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.7 3.86a2 2 0 0 0-3.4 0z"/><path d="M12 9v4M12 17h.01"/></svg>',
  arrow_up_right = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M7 17L17 7M7 7h10v10"/></svg>',
  arrow_down_right = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M7 7l10 10M7 17h10V7"/></svg>'
)

# Return an HTML() glyph, optionally class-formatted.
.svg <- function(name, class = NULL) {
  raw <- .shad_svg[[name]]
  if (grepl("%s", raw, fixed = TRUE)) raw <- sprintf(raw, class %||% "")
  htmltools::HTML(raw)
}

# Coerce an `icon` argument (a shad_icon name, a tag, or NULL) to a tag.
.resolve_icon <- function(icon) {
  if (is.null(icon)) return(NULL)
  if (is_tag_like(icon)) return(icon)
  if (is.character(icon) && length(icon) == 1) return(shad_icon(icon))
  icon
}

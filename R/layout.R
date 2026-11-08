# Layout primitives ------------------------------------------------------------
# Container / stack / grid plus the two page shells. Everything is CSS-only:
# the constructors only translate their arguments into custom properties on the
# root, which layout.css consumes. Spacing arguments accept either a token step
# (a number -- 4 means --shad-space-4) or any CSS length, so gaps line up with
# component internals by default but stay escapable.

.shad_space_steps <- c("0", "0.5", "1", "1.5", "2", "2.5", "3", "4", "5", "6",
                       "8", "10", "12")

# A spacing value -> CSS length. Numbers that name a token step become
# var(--shad-space-N); anything else goes through validateCssUnit().
#' @noRd
shad_space <- function(x) {
  if (is.null(x)) return(NULL)
  if (identical(x, 0) || identical(x, "0")) return("0")
  key <- sub("\\.", "_", format(x, trim = TRUE, drop0trailing = TRUE))
  if (is.numeric(x) && as.character(x) %in% .shad_space_steps) {
    paste0("var(--shad-space-", key, ")")
  } else {
    htmltools::validateCssUnit(x)
  }
}

# align/justify keyword -> flexbox value. "between"/"around"/"evenly" are the
# Tailwind spellings, which is what people type.
.shad_flex_align <- c(start = "flex-start", center = "center", end = "flex-end",
                      stretch = "stretch", baseline = "baseline")
.shad_flex_justify <- c(start = "flex-start", center = "center", end = "flex-end",
                        between = "space-between", around = "space-around",
                        evenly = "space-evenly")

# Collapse named style parts into a style string (NULL when nothing is set).
#' @noRd
shad_style <- function(...) {
  parts <- drop_nulls(list(...))
  if (!length(parts)) return(NULL)
  paste0(names(parts), ":", unlist(parts, use.names = FALSE), ";", collapse = "")
}

#' Centred content container
#'
#' A max-width, horizontally centred column with inline padding – the outermost
#' wrapper for page content.
#'
#' @param ... Children, or named HTML attributes for the root.
#' @param size `"sm"` (40rem), `"md"` (60rem, default), `"lg"` (80rem),
#'   `"xl"` (96rem), or `"full"` (no max-width). A CSS length is also accepted.
#' @param padding Inline padding: a spacing token step, a CSS length, or
#'   `FALSE` for none.
#' @param class Extra CSS classes.
#' @returns A `<div>` tag.
#' @family shadshiny layout
#' @examples
#' shad_container(shad_h2("Title"), shad_p("Body"), size = "lg")
#' @export
shad_container <- function(..., size = "md", padding = 4, class = NULL) {
  named <- c(sm = "40rem", md = "60rem", lg = "80rem", xl = "96rem")
  full <- identical(size, "full")
  max_w <- if (full) NULL else if (size %in% names(named)) named[[size]] else
    htmltools::validateCssUnit(size)

  with_deps(do.call(htmltools::tags$div, c(
    list(
      class = shad_class("shad-container",
                         if (full) "shad-container--full",
                         if (isFALSE(padding)) "shad-container--flush",
                         extra = class),
      style = shad_style(
        `--shad-container-max` = max_w,
        `--shad-container-pad` = if (isFALSE(padding)) NULL else shad_space(padding)
      )
    ),
    list(...)
  )))
}

#' Flex stack
#'
#' A one-dimensional flex layout: children in a column (default) or a row, with
#' a token-scale gap. The workhorse for "these things, spaced".
#'
#' @param ... Children, or named HTML attributes for the root.
#' @param direction `"vertical"` (default) or `"horizontal"`.
#' @param gap Gap between children: a spacing token step (default `4` = 1rem) or
#'   a CSS length.
#' @param align Cross-axis alignment: `"stretch"` (default), `"start"`,
#'   `"center"`, `"end"`, `"baseline"`.
#' @param justify Main-axis distribution: `"start"` (default), `"center"`,
#'   `"end"`, `"between"`, `"around"`, `"evenly"`.
#' @param wrap If `TRUE`, children wrap onto new lines.
#' @param fill If `TRUE`, children share the free space equally.
#' @param class Extra CSS classes.
#' @returns A `<div>` tag.
#' @family shadshiny layout
#' @examples
#' shad_stack(shad_button("Save"), shad_button("Cancel", variant = "outline"),
#'            direction = "horizontal", gap = 2)
#' @export
shad_stack <- function(..., direction = c("vertical", "horizontal"), gap = 4,
                       align = NULL, justify = NULL, wrap = FALSE, fill = FALSE,
                       class = NULL) {
  direction <- arg_match_shad(direction, c("vertical", "horizontal"), "direction")
  if (!is.null(align)) align <- arg_match_shad(align, names(.shad_flex_align), "align")
  if (!is.null(justify)) {
    justify <- arg_match_shad(justify, names(.shad_flex_justify), "justify")
  }

  with_deps(do.call(htmltools::tags$div, c(
    list(
      class = shad_class("shad-stack",
                         if (isTRUE(wrap)) "shad-stack--wrap",
                         if (isTRUE(fill)) "shad-stack--fill",
                         extra = class),
      style = shad_style(
        `--shad-stack-dir` = if (direction == "horizontal") "row" else NULL,
        `--shad-stack-gap` = shad_space(gap),
        `--shad-stack-align` = if (!is.null(align)) .shad_flex_align[[align]] else NULL,
        `--shad-stack-justify` = if (!is.null(justify)) .shad_flex_justify[[justify]] else NULL
      )
    ),
    list(...)
  )))
}

#' Responsive grid
#'
#' A CSS grid with either a fixed (optionally per-breakpoint) column count or a
#' responsive auto-fit track list.
#'
#' Pass `cols` as a single number for a fixed count, or as a named vector over
#' the breakpoints `base`/`sm`/`md`/`lg` (40rem / 48rem / 64rem) – unnamed
#' entries are the base. Each breakpoint falls back to the one below it, so
#' `cols = c(base = 1, md = 3)` is two rules, not four.
#'
#' `min_width` is usually simpler still: it lays out as many equal columns as
#' fit at that minimum width, with no breakpoints at all.
#'
#' @param ... Children, or named HTML attributes for the root.
#' @param cols Column count: a number, or a named vector over
#'   `base`/`sm`/`md`/`lg`.
#' @param min_width Minimum column width for an auto-fit grid (e.g. `"16rem"`).
#'   Takes precedence over `cols`.
#' @param template An explicit `grid-template-columns` value, e.g. `"1fr 2fr"`.
#'   Takes precedence over both.
#' @param gap Gap between cells: a spacing token step (default `4`) or a CSS
#'   length.
#' @param align Block-axis alignment of cells: `"stretch"` (default),
#'   `"start"`, `"center"`, `"end"`.
#' @param class Extra CSS classes.
#' @returns A `<div>` tag.
#' @family shadshiny layout
#' @examples
#' shad_grid(shad_value_box("1", "One"), shad_value_box("2", "Two"),
#'           min_width = "12rem")
#' shad_grid(shad_card("a"), shad_card("b"), cols = c(base = 1, md = 2))
#' @export
shad_grid <- function(..., cols = NULL, min_width = NULL, template = NULL,
                      gap = 4, align = NULL, class = NULL) {
  if (!is.null(align)) {
    align <- arg_match_shad(align, c("stretch", "start", "center", "end"), "align")
  }
  if (is.null(cols) && is.null(min_width) && is.null(template)) min_width <- "16rem"

  col_vars <- list()
  if (!is.null(cols)) {
    nms <- names(cols)
    if (is.null(nms)) nms <- rep("", length(cols))
    nms[!nzchar(nms)] <- "base"
    unknown <- setdiff(nms, c("base", "sm", "md", "lg"))
    if (length(unknown)) {
      stop(sprintf("`cols` names must be base/sm/md/lg, not %s.",
                   paste(sprintf('"%s"', unknown), collapse = ", ")), call. = FALSE)
    }
    keys <- ifelse(nms == "base", "--shad-grid-cols",
                   paste0("--shad-grid-cols-", nms))
    col_vars <- as.list(as.character(unname(cols)))
    names(col_vars) <- keys
  }

  style <- do.call(shad_style, c(
    col_vars,
    list(
      `--shad-grid-gap` = shad_space(gap),
      `--shad-grid-align` = if (!is.null(align)) {
        if (align == "start") "start" else if (align == "end") "end" else align
      },
      `--shad-grid-min` = if (!is.null(min_width) && is.null(template)) {
        htmltools::validateCssUnit(min_width)
      },
      `--shad-grid-template` = template
    )
  ))

  with_deps(do.call(htmltools::tags$div, c(
    list(
      class = shad_class("shad-grid",
                         if (!is.null(template)) "shad-grid--template"
                         else if (!is.null(min_width)) "shad-grid--auto",
                         extra = class),
      style = style
    ),
    list(...)
  )))
}

#' @rdname shad_grid
#' @param span Number of columns this cell spans, or `"full"` for the whole row.
#' @export
shad_grid_item <- function(..., span = 1, class = NULL) {
  full <- identical(span, "full")
  do.call(htmltools::tags$div, c(
    list(
      class = shad_class("shad-grid__item",
                         if (full) "shad-grid__item--full", extra = class),
      style = if (!full) shad_style(`--shad-span` = as.character(span))
    ),
    list(...)
  ))
}

# Page shells ------------------------------------------------------------------

# The bar shared by both shells: optional trigger, title, and an end slot.
#' @noRd
shad_page_bar <- function(..., title = NULL, end = NULL, lead = NULL,
                          sticky = TRUE) {
  htmltools::tags$header(
    class = shad_class("shad-page__bar", if (isTRUE(sticky)) "shad-page__bar--sticky"),
    lead,
    if (!is.null(title)) htmltools::tags$h1(class = "shad-page__title", title),
    ...,
    if (!is.null(end)) htmltools::tags$div(class = "shad-page__bar-end", end)
  )
}

#' Page shell with a sidebar
#'
#' A full-height page built on [shad_sidebar_layout()]: a collapsible sidebar, a
#' bar carrying the sidebar trigger and page title, and a scrolling main region.
#' `input$<inputId>` reports the sidebar state (including `active`, the clicked
#' [shad_sidebar_item()]); toggle it from the server with [shad_sidebar_toggle()].
#'
#' @param sidebar A [shad_sidebar()].
#' @param ... Main content, or named HTML attributes for the scope container.
#' @param inputId Input id for the sidebar layout.
#' @param title Optional page title shown in the bar.
#' @param header Optional content appended to the bar (after the title).
#' @param header_end Optional content pinned to the end of the bar (e.g. a dark
#'   mode switch).
#' @param container If `TRUE` (default), wrap the main content in a
#'   [shad_container()]. Pass a list of arguments to configure it, or `FALSE` to
#'   place content flush.
#' @param page_title,theme_preset,dark,theme,lang Passed to [page_shad()].
#' @returns A page UI object.
#' @family shadshiny layout
#' @seealso [page_shad()], [shad_sidebar_layout()]
#' @examples
#' if (interactive()) {
#'   shiny::shinyApp(
#'     shad_page_sidebar(
#'       sidebar = shad_sidebar(shad_sidebar_group("Menu",
#'         shad_sidebar_item("home", "Home", icon = "home"))),
#'       title = "Acme", shad_p("Main content")
#'     ),
#'     function(input, output, session) {}
#'   )
#' }
#' @export
shad_page_sidebar <- function(sidebar, ..., inputId = "sidebar", title = NULL,
                              header = NULL, header_end = NULL, container = TRUE,
                              page_title = title, theme_preset = NULL,
                              dark = NULL, theme = NULL, lang = "en") {
  dots <- split_dots(...)
  body <- .shad_page_body(dots$children, container)

  main <- htmltools::tagList(
    shad_page_bar(header, title = title, end = header_end,
                  lead = shad_sidebar_trigger()),
    htmltools::tags$div(class = "shad-page__main", body)
  )

  do.call(page_shad, c(
    list(
      htmltools::tags$div(
        class = "shad-page shad-page--sidebar",
        shad_sidebar_layout(inputId, sidebar = sidebar, main = main)
      ),
      title = page_title, theme_preset = theme_preset, dark = dark,
      theme = theme, lang = lang
    ),
    dots$attribs
  ))
}

#' Page shell with a tabbed navbar
#'
#' A full-height page whose top bar carries a [shad_tabs()] strip: the standard
#' "app with a handful of top-level views" shell. `input$<inputId>` is the
#' active tab value; switch it from the server with [update_shad_tabs()].
#'
#' @param ... One or more [shad_tab()], or named HTML attributes for the scope
#'   container.
#' @param inputId Input id for the tab set.
#' @param title Optional brand/title shown at the start of the bar.
#' @param selected Initially active tab value (defaults to the first tab).
#' @param header_end Optional content pinned to the end of the bar.
#' @param container If `TRUE` (default), wrap each panel's content in a
#'   [shad_container()]. Pass a list of arguments to configure it, or `FALSE`.
#' @param page_title,theme_preset,dark,theme,lang Passed to [page_shad()].
#' @returns A page UI object.
#' @family shadshiny layout
#' @seealso [page_shad()], [shad_tabs()]
#' @examples
#' if (interactive()) {
#'   shiny::shinyApp(
#'     shad_page_navbar(
#'       shad_tab("home", "Home", shad_p("Home panel")),
#'       shad_tab("about", "About", shad_p("About panel")),
#'       title = "Acme"
#'     ),
#'     function(input, output, session) {}
#'   )
#' }
#' @export
shad_page_navbar <- function(..., inputId = "navbar", title = NULL,
                             selected = NULL, header_end = NULL,
                             container = TRUE, page_title = title,
                             theme_preset = NULL, dark = NULL, theme = NULL,
                             lang = "en") {
  dots <- split_dots(...)
  # Anything that is not a tab (a command palette, an overlay, an output that
  # belongs to the page rather than to one view) rides along outside the tab
  # set instead of being dropped on the floor by shad_tabs().
  is_tab <- vapply(dots$children, inherits, logical(1), "shad_tab")
  extras <- dots$children[!is_tab]
  tabs <- do.call(shad_tabs, c(list(inputId), dots$children[is_tab],
                               list(selected = selected)))

  # shad_tabs() renders [list, panels...]. Re-parent those children into the
  # bar and the main region -- the root stays the tabs element, so the
  # component's root-scoped queries and its input binding are untouched.
  kids <- tabs$children
  list_tag <- kids[[1]]
  panels <- lapply(kids[-1], function(p) {
    p$children <- list(.shad_page_body(p$children, container))
    p
  })

  tabs$attribs$class <- shad_class("shad-page", "shad-page--navbar",
                                   extra = tabs$attribs$class)
  tabs$children <- c(
    list(
      shad_page_bar(list_tag, title = title, end = header_end),
      do.call(htmltools::tags$div, c(list(class = "shad-page__main"), panels))
    ),
    extras
  )

  do.call(page_shad, c(
    list(tabs, title = page_title, theme_preset = theme_preset, dark = dark,
         theme = theme, lang = lang),
    dots$attribs
  ))
}

# Wrap page content in a container unless the caller opted out. `container` is
# TRUE/FALSE or a list of shad_container() arguments.
#' @noRd
.shad_page_body <- function(children, container) {
  if (isFALSE(container)) return(children)
  args <- if (is.list(container)) container else list()
  do.call(shad_container, c(children, args))
}

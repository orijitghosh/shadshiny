# tree -------------------------------------------------------------------------

.tree_folder_icon <- htmltools::HTML('<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 7a2 2 0 0 1 2-2h4l2 2h8a2 2 0 0 1 2 2v9a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/></svg>')
.tree_file_icon <- htmltools::HTML('<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><path d="M14 2v6h6"/></svg>')

#' Tree view
#'
#' A file-explorer tree (APG TreeView) with keyboard navigation, single or
#' multiple selection, and optional lazy branches. A bound Shiny input:
#' `input$<inputId>` is the character vector of selected keys. Expanding a lazy
#' branch fires `input$<inputId>_expanded` (a list with `key`, `expanded`, and a
#' `nonce`); answer it with `update_shad_tree(children=)`. Compose from
#' [shad_tree_item()].
#'
#' @param inputId Input id.
#' @param ... [shad_tree_item()] entries, plus optional named attributes.
#' @param selected Character vector of initially selected keys.
#' @param selection `"single"` (default) or `"multiple"`.
#' @param label Accessible label for the tree.
#' @param class Extra CSS classes.
#' @returns A tree tag, bound as a Shiny input.
#' @family shadshiny flow
#' @examples
#' shad_tree(
#'   "files",
#'   shad_tree_item("src", "src", expanded = TRUE,
#'     shad_tree_item("src/app.R", "app.R"),
#'     shad_tree_item("src/utils.R", "utils.R")
#'   ),
#'   shad_tree_item("data", "data", lazy = TRUE)
#' )
#' @export
shad_tree <- function(inputId, ..., selected = NULL,
                      selection = c("single", "multiple"),
                      label = "Tree", class = NULL) {
  selection <- arg_match_shad(selection, c("single", "multiple"), "selection")
  selected <- shiny::restoreInput(id = inputId, default = selected)
  dots <- split_dots(...)

  items <- lapply(dots$children, function(it) .tree_apply_selected(it, as.character(selected)))

  ul <- do.call(htmltools::tags$ul, c(
    list(class = "shad-tree__list", role = "tree", `aria-label` = label,
         `aria-multiselectable` = if (selection == "multiple") "true" else NULL),
    items
  ))

  root <- do.call(htmltools::tags$div, c(
    list(class = shad_class("shad-tree", extra = class), id = inputId,
         `data-shad` = "tree", `data-selection` = selection),
    dots$attribs, list(ul)
  ))
  with_deps(root)
}

# Recursively stamp aria-selected="true" on items whose data-key is selected.
.tree_apply_selected <- function(tag, selected) {
  if (!inherits(tag, "shiny.tag")) return(tag)
  key <- tag$attribs[["data-key"]]
  if (!is.null(key) && key %in% selected) {
    tag$attribs[["aria-selected"]] <- "true"
    tag$attribs[["data-state"]] <- "selected"
  }
  tag$children <- lapply(tag$children, function(ch) {
    if (inherits(ch, "shiny.tag")) .tree_apply_selected(ch, selected)
    else if (is.list(ch) && !inherits(ch, "html")) lapply(ch, function(g) .tree_apply_selected(g, selected))
    else ch
  })
  tag
}

#' Tree item
#'
#' @param value The item key (row identity in values/events; must be unique).
#' @param label The item label.
#' @param ... Child [shad_tree_item()] nodes (makes this a branch), plus optional
#'   named attributes.
#' @param icon Optional icon: a [shad_icon()] name or tag. Defaults to a folder
#'   glyph for branches and a file glyph for leaves.
#' @param expanded If `TRUE`, a branch starts open.
#' @param lazy If `TRUE`, mark a childless branch whose children load on first
#'   expand (via `update_shad_tree(children=)`).
#' @param disabled If `TRUE`, the item is unselectable and skipped by keyboard
#'   navigation.
#' @returns A tree item `<li>` tag.
#' @family shadshiny flow
#' @export
shad_tree_item <- function(value, label, ..., icon = NULL, expanded = FALSE,
                           lazy = FALSE, disabled = FALSE) {
  dots <- split_dots(...)
  kids <- dots$children
  is_branch <- length(kids) > 0 || isTRUE(lazy)

  icon_tag <- if (!is.null(icon)) {
    resolve_icon(icon)
  } else if (is_branch) {
    .tree_folder_icon
  } else {
    .tree_file_icon
  }

  chevron <- if (is_branch) {
    .svg("chevron", "shad-tree__chevron")
  } else {
    .svg("chevron_leaf", "shad-tree__chevron shad-tree__chevron--leaf")
  }

  row <- htmltools::tags$div(
    class = "shad-tree__row",
    chevron,
    htmltools::tags$span(class = "shad-tree__icon", icon_tag),
    htmltools::tags$span(class = "shad-tree__label", label)
  )

  group <- if (length(kids) > 0) {
    do.call(htmltools::tags$ul, c(list(class = "shad-tree__group", role = "group"), kids))
  }

  do.call(htmltools::tags$li, c(
    list(
      class = "shad-tree__item", role = "treeitem", `data-key` = value,
      `aria-expanded` = if (is_branch) tolower(as.character(isTRUE(expanded))) else NULL,
      `data-lazy` = flag_attr(lazy && length(kids) == 0),
      `aria-disabled` = if (isTRUE(disabled)) "true" else NULL
    ),
    dots$attribs,
    drop_nulls(list(row, group))
  ))
}

#' Update a tree from the server
#'
#' @param id Input id (namespaced automatically).
#' @param selected Optional character vector of keys to select.
#' @param expanded Optional named list mapping keys to logicals (expand/collapse).
#' @param children Optional list `list(value = <parent key>, items = <tagList of
#'   [shad_tree_item()]>)` to fill a lazy branch (an empty `items` marks it a
#'   leaf).
#' @param session The Shiny session.
#' @returns Invisibly `NULL`.
#' @family shadshiny flow
#' @export
update_shad_tree <- function(id, selected = NULL, expanded = NULL,
                             children = NULL,
                             session = shiny::getDefaultReactiveDomain()) {
  if (!is.null(selected)) {
    shad_set_value(id, I(as.character(selected)), session)
  }
  if (!is.null(expanded)) {
    for (k in names(expanded)) {
      shad_invoke(id, "expand", list(k, isTRUE(expanded[[k]])), session)
    }
  }
  if (!is.null(children)) {
    html <- if (length(children$items)) {
      htmltools::doRenderTags(htmltools::tagList(children$items))
    } else {
      ""
    }
    shad_invoke(id, "setChildren", list(children$value, html), session)
  }
  invisible(NULL)
}

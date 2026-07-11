# toggle & toggle-group --------------------------------------------------------

#' Toggle
#'
#' A shadcn two-state toggle button. `input$<inputId>` is a logical.
#'
#' @param inputId Input id.
#' @param label Optional text content.
#' @param value Initial pressed state (logical).
#' @param variant `"default"` or `"outline"`.
#' @param size `"default"`, `"sm"`, or `"lg"`.
#' @param icon Optional icon: a [shad_icon()] name or a tag.
#' @param disabled If `TRUE`, disables the control.
#' @param class Extra CSS classes.
#' @param ... Extra attributes.
#' @returns A toggle button tag.
#' @family shadshiny tier-2 components
#' @examples
#' shad_toggle("bold", icon = "plus", value = TRUE)
#' shad_toggle("mode", "Outline", variant = "outline")
#' @export
shad_toggle <- function(inputId, label = NULL, value = FALSE,
                        variant = c("default", "outline"),
                        size = c("default", "sm", "lg"),
                        icon = NULL, disabled = FALSE, class = NULL, ...) {
  variant <- arg_match_shad(variant, c("default", "outline"), "variant")
  size <- arg_match_shad(size, c("default", "sm", "lg"), "size")
  cls <- shad_class(
    "shad-toggle",
    if (variant == "outline") "shad-toggle--outline",
    if (size != "default") paste0("shad-toggle--", size),
    extra = class
  )
  with_deps(htmltools::tags$button(
    type = "button", class = cls,
    `data-shad` = "toggle",
    `data-state` = if (isTRUE(value)) "on" else "off",
    id = inputId,
    `data-disabled` = flag_attr(disabled),
    disabled = flag_attr(disabled),
    ...,
    resolve_icon(icon),
    label
  ))
}

#' Toggle group
#'
#' A shadcn toggle group. `input$<inputId>` is a string/`NULL` (single mode) or
#' a character vector (multiple mode).
#'
#' @param inputId Input id.
#' @param choices A named/unnamed vector or a list of [shad_toggle_group_item()].
#' @param selected Initially pressed value(s).
#' @param type `"single"` or `"multiple"`.
#' @param variant `"default"` or `"outline"`.
#' @param size `"default"`, `"sm"`, or `"lg"`.
#' @param orientation `"horizontal"` (default) or `"vertical"`.
#' @param disabled If `TRUE`, disables every item.
#' @param class Extra CSS classes.
#' @param ... Extra attributes on the group root.
#' @returns A toggle-group tag.
#' @family shadshiny tier-2 components
#' @examples
#' shad_toggle_group("align", choices = c(Left = "left", Center = "center",
#'                   Right = "right"), selected = "center", type = "single")
#' @export
shad_toggle_group <- function(inputId, choices, selected = NULL,
                              type = c("single", "multiple"),
                              variant = c("default", "outline"),
                              size = c("default", "sm", "lg"),
                              orientation = c("horizontal", "vertical"),
                              disabled = FALSE, class = NULL, ...) {
  type <- arg_match_shad(type, c("single", "multiple"), "type")
  variant <- arg_match_shad(variant, c("default", "outline"), "variant")
  size <- arg_match_shad(size, c("default", "sm", "lg"), "size")
  orientation <- arg_match_shad(orientation, c("horizontal", "vertical"),
                                "orientation")
  items <- normalize_choices(choices)
  sel <- as.character(selected)

  size_class <- if (size != "default") paste0("shad-toggle--", size) else NULL
  btns <- lapply(items, function(it) {
    val <- as.character(it$value)
    it_disabled <- isTRUE(disabled) || isTRUE(it$disabled)
    htmltools::tags$button(
      type = "button",
      class = shad_class("shad-toggle", size_class),
      `data-value` = val,
      `data-state` = if (val %in% sel) "on" else "off",
      `aria-label` = if (is.null(it$label)) val else NULL,
      `data-disabled` = flag_attr(it_disabled),
      disabled = flag_attr(it_disabled),
      resolve_icon(it$icon),
      it$label
    )
  })

  do.call(htmltools::tags$div, c(
    list(
      class = shad_class(
        "shad-toggle-group",
        if (variant == "outline") "shad-toggle-group--outline",
        extra = class
      ),
      `data-shad` = "toggle-group",
      id = inputId,
      `data-type` = type,
      role = "group",
      `data-orientation` = if (orientation == "vertical") "vertical" else NULL,
      ...
    ),
    btns
  )) |> with_deps()
}

#' @rdname shad_toggle_group
#' @param value The item's value.
#' @param icon Optional icon for the item.
#' @export
shad_toggle_group_item <- function(value, label = NULL, icon = NULL,
                                   disabled = FALSE) {
  list(value = value, label = label, icon = icon, disabled = disabled)
}

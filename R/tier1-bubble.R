# bubble -----------------------------------------------------------------------

.shad_bubble_variants <- c("default", "secondary", "muted", "tinted",
                           "outline", "ghost", "destructive")

# Normalise `reactions` into overlapping reaction chips, or pass a tag through.
.shad_bubble_reactions <- function(reactions, align) {
  if (is.null(reactions)) return(NULL)
  chips <- if (is_tag_like(reactions)) {
    list(reactions)
  } else {
    lapply(reactions, function(r) {
      if (is_tag_like(r)) r else htmltools::tags$span(class = "shad-bubble__reaction", r)
    })
  }
  do.call(htmltools::tags$div, c(
    list(class = "shad-bubble__reactions", `data-side` = align),
    chips
  ))
}

#' Chat bubble
#'
#' A conversational message surface. Part of the chat/AI kit; usually composed
#' inside [shad_message()], but usable on its own.
#'
#' @param ... Bubble content (text or tags), plus optional named attributes.
#' @param variant One of `"default"`, `"secondary"`, `"muted"`, `"tinted"`,
#'   `"outline"`, `"ghost"` (full-width assistant prose), `"destructive"`.
#' @param align `"start"` (received) or `"end"` (sent). Ignored inside a
#'   [shad_bubble_group()], which aligns all its children.
#' @param reactions Optional overlapping reaction chips: a character vector
#'   (each becomes a chip) or a tag. Give counts/emoji an `aria-label`.
#' @param class Extra CSS classes.
#' @returns A bubble tag.
#' @family shadshiny chat components
#' @examples
#' shad_bubble("How many rows have missing values?", align = "end")
#' shad_bubble("1,284 rows (2.6%).", variant = "muted", align = "start")
#' @export
shad_bubble <- function(..., variant = "default", align = c("start", "end"),
                        reactions = NULL, class = NULL) {
  variant <- arg_match_shad(variant, .shad_bubble_variants, "variant")
  align <- match.arg(align)
  dots <- split_dots(...)

  root <- do.call(htmltools::tags$div, c(
    list(
      class = shad_class("shad-bubble", paste0("shad-bubble--", variant),
                         paste0("shad-bubble--", align), extra = class)
    ),
    dots$attribs,
    list(
      do.call(htmltools::tags$div, c(list(class = "shad-bubble__content"), dots$children)),
      .shad_bubble_reactions(reactions, align)
    )
  ))
  with_deps(root)
}

#' @rdname shad_bubble
#' @param align For `shad_bubble_group()`, the alignment applied to every child
#'   bubble: `"start"` or `"end"`.
#' @export
shad_bubble_group <- function(..., align = c("start", "end"), class = NULL) {
  align <- match.arg(align)
  with_deps(htmltools::tags$div(
    class = shad_class("shad-bubble-group", paste0("shad-bubble-group--", align),
                       extra = class),
    ...
  ))
}

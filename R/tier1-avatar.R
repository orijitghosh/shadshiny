#' Avatar
#'
#' A user avatar with an image and an initials fallback. The fallback is
#' layered under the image and revealed automatically if the image is missing
#' or fails to load (zero JavaScript).
#'
#' @param src Image URL. Optional.
#' @param alt Image alt text; also the source of default initials.
#' @param fallback Fallback text (initials). Defaults to initials derived from
#'   `alt`.
#' @param size One of `"default"`, `"sm"`, `"lg"`, `"xl"`.
#' @param class Extra CSS classes.
#' @param ... Extra attributes.
#' @returns A `<span class="shad-avatar">`.
#' @family shadshiny tier-1 components
#' @examples
#' shad_avatar(src = "https://github.com/shadcn.png", alt = "@shadcn")
#' shad_avatar(fallback = "JD")
#' @export
shad_avatar <- function(src = NULL, alt = "", fallback = NULL,
                        size = c("default", "sm", "lg", "xl"), class = NULL, ...) {
  size <- arg_match_shad(size, c("default", "sm", "lg", "xl"), "size")
  size_class <- if (size == "default") NULL else paste0("shad-avatar--", size)
  if (is.null(fallback)) fallback <- initials_from(alt)

  fallback_tag <- htmltools::tags$span(
    class = "shad-avatar__fallback",
    `aria-hidden` = if (!is.null(src)) "true" else NULL,
    fallback
  )
  image_tag <- if (!is.null(src)) {
    htmltools::tags$img(
      class = "shad-avatar__image", src = src, alt = alt,
      onerror = "this.hidden=true"
    )
  }
  with_deps(do.call(htmltools::tags$span, c(
    list(class = shad_class("shad-avatar", size_class, extra = class)),
    list(...),
    drop_nulls(list(fallback_tag, image_tag))
  )))
}

#' @rdname shad_avatar
#' @param max Maximum avatars to show in a group before collapsing the rest
#'   into a "+N" overflow avatar.
#' @export
shad_avatar_group <- function(..., max = NULL, class = NULL) {
  items <- list(...)
  is_child <- !nzchar(names(items) %||% rep("", length(items)))
  children <- items[is_child]
  attribs <- items[!is_child]

  if (!is.null(max) && length(children) > max) {
    overflow <- length(children) - max
    children <- children[seq_len(max)]
    children <- c(children, list(
      htmltools::tags$span(
        class = "shad-avatar",
        htmltools::tags$span(class = "shad-avatar__fallback", paste0("+", overflow))
      )
    ))
  }
  with_deps(do.call(htmltools::tags$span, c(
    list(class = shad_class("shad-avatar-group", extra = class)),
    attribs, children
  )))
}

# initials: first letters of the first two words, uppercased.
#' @noRd
initials_from <- function(x) {
  if (is.null(x) || !nzchar(x)) return("")
  x <- gsub("^@", "", x)
  words <- strsplit(trimws(x), "\\s+")[[1]]
  words <- words[nzchar(words)]
  if (length(words) == 0) return("")
  toupper(paste0(substr(words[seq_len(min(2, length(words)))], 1, 1), collapse = ""))
}

`%||%` <- function(a, b) if (is.null(a)) b else a

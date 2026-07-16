# dropzone ---------------------------------------------------------------------

#' File dropzone
#'
#' A drag-and-drop file picker styled like shadcn. It bridges to Shiny's native
#' file-upload machinery: `input$<inputId>` is the standard files data frame
#' (`name`, `size`, `type`, `datapath`), exactly as [shiny::fileInput()]. Files
#' can be dropped onto the zone or chosen via the browse dialog.
#'
#' @param inputId Input id (yields the uploaded-files data frame).
#' @param label Optional label shown above the zone.
#' @param multiple If `TRUE`, allow selecting several files.
#' @param accept Character vector of accepted types (`.csv`, `text/csv`,
#'   `image/*`, …), as in [shiny::fileInput()].
#' @param max_size Optional per-file size cap in bytes (client-side pre-check;
#'   oversize files are rejected inline and never uploaded).
#' @param hint Zone hint text. The default emphasises "Click to browse".
#' @param meta Optional constraints line (e.g. `"CSV up to 1 MB"`).
#' @param width CSS width.
#' @param disabled If `TRUE`, disable the zone.
#' @param class Extra CSS classes.
#' @returns A dropzone tag; uploads bind to `input$<inputId>`.
#' @family shadshiny flow
#' @examples
#' if (interactive()) {
#'   shad_dropzone("upload", multiple = TRUE, accept = ".csv",
#'                 meta = "CSV files only")
#' }
#' @export
shad_dropzone <- function(inputId, label = NULL, multiple = FALSE, accept = NULL,
                          max_size = NULL, hint = NULL, meta = NULL,
                          width = NULL, disabled = FALSE, class = NULL) {
  accept_attr <- if (!is.null(accept)) paste(accept, collapse = ",") else NULL

  # Visually-hidden real Shiny fileInput carries the actual upload transport and
  # owns `inputId`; the bridge in shadshiny-shiny.js forwards dropped/browsed
  # files into it.
  hidden_upload <- htmltools::div(
    class = "shad-sr-only", `aria-hidden` = "true",
    shiny::fileInput(inputId, label = NULL, multiple = multiple, accept = accept)
  )

  zone <- htmltools::tags$div(
    class = "shad-dropzone__zone",
    tabindex = if (isTRUE(disabled)) "-1" else "0",
    role = "button",
    `aria-label` = label %||% "Upload files: click to browse or drag and drop",
    htmltools::tags$span(class = "shad-dropzone__icon", .svg("upload")),
    htmltools::tags$div(
      class = "shad-dropzone__hint",
      hint %||% htmltools::tagList(
        htmltools::tags$strong("Click to browse"), " or drag files here"
      )
    ),
    if (!is.null(meta)) htmltools::tags$div(class = "shad-dropzone__meta", meta)
  )

  browse_input <- htmltools::tags$input(
    type = "file", class = "shad-dropzone__input",
    multiple = flag_attr(multiple), accept = accept_attr,
    disabled = flag_attr(disabled)
  )

  root <- htmltools::tags$div(
    class = shad_class("shad-dropzone", extra = class),
    id = paste0(inputId, "__dz"),
    `data-shad` = "dropzone",
    `data-upload-target` = inputId,
    `data-multiple` = flag_attr(multiple),
    `data-accept` = accept_attr,
    `data-max-size` = max_size,
    `data-disabled` = flag_attr(disabled),
    style = width_style(width),
    zone, browse_input,
    htmltools::tags$div(class = "shad-dropzone__files")
  )

  wrapped <- if (!is.null(label)) {
    htmltools::tagList(
      htmltools::tags$label(class = "shad-label", `for` = inputId, label),
      root
    )
  } else {
    root
  }

  with_deps(htmltools::tagList(hidden_upload, wrapped))
}

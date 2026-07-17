# File dropzone

A drag-and-drop file picker styled like shadcn. It bridges to Shiny's
native file-upload machinery: `input$<inputId>` is the standard files
data frame (`name`, `size`, `type`, `datapath`), exactly as
[`shiny::fileInput()`](https://rdrr.io/pkg/shiny/man/fileInput.html).
Files can be dropped onto the zone or chosen via the browse dialog.

## Usage

``` r
shad_dropzone(
  inputId,
  label = NULL,
  multiple = FALSE,
  accept = NULL,
  max_size = NULL,
  hint = NULL,
  meta = NULL,
  width = NULL,
  disabled = FALSE,
  class = NULL
)
```

## Arguments

- inputId:

  Input id (yields the uploaded-files data frame).

- label:

  Optional label shown above the zone.

- multiple:

  If `TRUE`, allow selecting several files.

- accept:

  Character vector of accepted types (`.csv`, `text/csv`, `image/*`, …),
  as in
  [`shiny::fileInput()`](https://rdrr.io/pkg/shiny/man/fileInput.html).

- max_size:

  Optional per-file size cap in bytes (client-side pre-check; oversize
  files are rejected inline and never uploaded).

- hint:

  Zone hint text. The default emphasises "Click to browse".

- meta:

  Optional constraints line (e.g. `"CSV up to 1 MB"`).

- width:

  CSS width.

- disabled:

  If `TRUE`, disable the zone.

- class:

  Extra CSS classes.

## Value

A dropzone tag; uploads bind to `input$<inputId>`.

## See also

Other shadshiny flow:
[`shad_number_input()`](https://orijitghosh.github.io/shadshiny/reference/shad_number_input.md),
[`shad_rating()`](https://orijitghosh.github.io/shadshiny/reference/shad_rating.md),
[`shad_step()`](https://orijitghosh.github.io/shadshiny/reference/shad_step.md),
[`shad_stepper()`](https://orijitghosh.github.io/shadshiny/reference/shad_stepper.md),
[`shad_tree()`](https://orijitghosh.github.io/shadshiny/reference/shad_tree.md),
[`shad_tree_item()`](https://orijitghosh.github.io/shadshiny/reference/shad_tree_item.md),
[`update_shad_number_input()`](https://orijitghosh.github.io/shadshiny/reference/update_shad_number_input.md),
[`update_shad_rating()`](https://orijitghosh.github.io/shadshiny/reference/update_shad_rating.md),
[`update_shad_stepper()`](https://orijitghosh.github.io/shadshiny/reference/update_shad_stepper.md),
[`update_shad_tree()`](https://orijitghosh.github.io/shadshiny/reference/update_shad_tree.md)

## Examples

``` r
if (interactive()) {
  shad_dropzone("upload", multiple = TRUE, accept = ".csv",
                meta = "CSV files only")
}
```

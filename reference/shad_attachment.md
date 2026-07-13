# Attachment

A file/image attachment chip with media, metadata, an upload-lifecycle
state, and action buttons. Part of the chat/AI kit — for composers,
message threads, and upload lists. Row up with
`shad_attachment_group()`.

## Usage

``` r
shad_attachment(
  title,
  description = NULL,
  media = NULL,
  actions = NULL,
  orientation = c("horizontal", "vertical"),
  size = NULL,
  state = "idle",
  media_variant = NULL,
  href = NULL,
  class = NULL,
  ...
)

shad_attachment_action(icon, aria_label, ...)

shad_attachment_group(..., class = NULL)
```

## Arguments

- title:

  The file name (truncated when long).

- description:

  Optional metadata (type, size, status).

- media:

  Optional
  [`shad_icon()`](https://orijitghosh.github.io/shadshiny/reference/shad_icon.md)
  name or a tag (icon or image thumb).

- actions:

  Optional action buttons — see `shad_attachment_action()`.

- orientation:

  `"horizontal"` (default) or `"vertical"` (media on top).

- size:

  One of `NULL` (default), `"sm"`, `"xs"`.

- state:

  Upload lifecycle: `"idle"`, `"uploading"`, `"processing"`, `"error"`,
  `"done"`. The server flips this to animate progress.

- media_variant:

  `"icon"` (muted tile) or `"image"` (cover thumb). Defaults to `"icon"`
  when `media` is an icon name.

- href:

  Optional URL; adds a full-card `<a>` trigger overlay (labelled from
  `title`).

- class:

  Extra CSS classes.

- ...:

  For `shad_attachment_action()`, extra attributes on the button.

- icon:

  A
  [`shad_icon()`](https://orijitghosh.github.io/shadshiny/reference/shad_icon.md)
  name or a tag for the action button.

- aria_label:

  Accessible label (required — the button is icon-only).

## Value

An attachment tag.

## See also

Other shadshiny chat components:
[`shad_bubble()`](https://orijitghosh.github.io/shadshiny/reference/shad_bubble.md),
[`shad_marker()`](https://orijitghosh.github.io/shadshiny/reference/shad_marker.md),
[`shad_message()`](https://orijitghosh.github.io/shadshiny/reference/shad_message.md),
[`shad_message_spinner()`](https://orijitghosh.github.io/shadshiny/reference/shad_message_spinner.md)

## Examples

``` r
shad_attachment("q3-report.pdf", description = "PDF · 2.4 MB",
                media = "file",
                actions = shad_attachment_action("x", "Remove attachment"))
#> <div class="shad-attachment">
#>   <div class="shad-attachment__media shad-attachment__media--icon" aria-hidden="true"><svg class="shad-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M15 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V7Z"/><path d="M14 2v4a2 2 0 0 0 2 2h4"/></svg></div>
#>   <div class="shad-attachment__content">
#>     <div class="shad-attachment__title">q3-report.pdf</div>
#>     <div class="shad-attachment__description">PDF · 2.4 MB</div>
#>   </div>
#>   <div class="shad-attachment__actions">
#>     <button type="button" class="shad-attachment__action" aria-label="Remove attachment"><svg class="shad-icon shad-icon--sm" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M18 6 6 18"/><path d="m6 6 12 12"/></svg></button>
#>   </div>
#> </div>
```

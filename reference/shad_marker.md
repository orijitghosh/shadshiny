# Conversation marker

An inline marker row for chat transcripts: status notes, date dividers,
and streaming ("thinking") labels. Part of the chat/AI kit.

## Usage

``` r
shad_marker(
  label,
  icon = NULL,
  variant = c("default", "border", "separator"),
  streaming = FALSE,
  class = NULL,
  ...
)
```

## Arguments

- label:

  The marker text.

- icon:

  Optional
  [`shad_icon()`](https://orijitghosh.github.io/shadshiny/reference/shad_icon.md)
  name or a tag, shown before the label (omitted for
  `variant = "separator"` unless supplied).

- variant:

  One of `"default"` (inline row), `"border"` (adds a bottom rule),
  `"separator"` (centred label with divider lines on both sides).

- streaming:

  If `TRUE`, adds a shimmer sweep over the text and `role="status"` so
  updates are announced politely.

- class:

  Extra CSS classes.

- ...:

  Extra attributes on the root.

## Value

A marker tag.

## See also

Other shadshiny chat components:
[`shad_attachment()`](https://orijitghosh.github.io/shadshiny/reference/shad_attachment.md),
[`shad_bubble()`](https://orijitghosh.github.io/shadshiny/reference/shad_bubble.md),
[`shad_message()`](https://orijitghosh.github.io/shadshiny/reference/shad_message.md),
[`shad_message_spinner()`](https://orijitghosh.github.io/shadshiny/reference/shad_message_spinner.md)

## Examples

``` r
shad_marker("Conversation started at 9:41 AM", icon = "clock")
#> <div class="shad-marker shad-marker--default">
#>   <span class="shad-marker__icon" aria-hidden="true">
#>     <svg class="shad-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
#>   </span>
#>   <span class="shad-marker__content">Conversation started at 9:41 AM</span>
#> </div>
shad_marker("Today", variant = "separator")
#> <div class="shad-marker shad-marker--separator">
#>   <span class="shad-marker__content">Today</span>
#> </div>
shad_marker("Thinking...", streaming = TRUE)
#> <div class="shad-marker shad-marker--default shad-marker--shimmer" role="status">
#>   <span class="shad-marker__content">Thinking...</span>
#> </div>
```

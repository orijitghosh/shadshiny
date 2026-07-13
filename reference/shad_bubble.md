# Chat bubble

A conversational message surface. Part of the chat/AI kit; usually
composed inside
[`shad_message()`](https://orijitghosh.github.io/shadshiny/reference/shad_message.md),
but usable on its own.

## Usage

``` r
shad_bubble(
  ...,
  variant = "default",
  align = c("start", "end"),
  reactions = NULL,
  class = NULL
)

shad_bubble_group(..., align = c("start", "end"), class = NULL)
```

## Arguments

- ...:

  Bubble content (text or tags), plus optional named attributes.

- variant:

  One of `"default"`, `"secondary"`, `"muted"`, `"tinted"`, `"outline"`,
  `"ghost"` (full-width assistant prose), `"destructive"`.

- align:

  For `shad_bubble_group()`, the alignment applied to every child
  bubble: `"start"` or `"end"`.

- reactions:

  Optional overlapping reaction chips: a character vector (each becomes
  a chip) or a tag. Give counts/emoji an `aria-label`.

- class:

  Extra CSS classes.

## Value

A bubble tag.

## See also

Other shadshiny chat components:
[`shad_attachment()`](https://orijitghosh.github.io/shadshiny/reference/shad_attachment.md),
[`shad_marker()`](https://orijitghosh.github.io/shadshiny/reference/shad_marker.md),
[`shad_message()`](https://orijitghosh.github.io/shadshiny/reference/shad_message.md),
[`shad_message_spinner()`](https://orijitghosh.github.io/shadshiny/reference/shad_message_spinner.md)

## Examples

``` r
shad_bubble("How many rows have missing values?", align = "end")
#> <div class="shad-bubble shad-bubble--default shad-bubble--end">
#>   <div class="shad-bubble__content">How many rows have missing values?</div>
#> </div>
shad_bubble("1,284 rows (2.6%).", variant = "muted", align = "start")
#> <div class="shad-bubble shad-bubble--muted shad-bubble--start">
#>   <div class="shad-bubble__content">1,284 rows (2.6%).</div>
#> </div>
```

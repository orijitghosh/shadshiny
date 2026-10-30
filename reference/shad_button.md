# Button

A shadcn-style button. Renders a native `<button>` (or `<a>` when `href`
is supplied). Supplying `inputId` makes it a Shiny action button
(readable as `input$<inputId>` click count).

## Usage

``` r
shad_button(
  label = NULL,
  inputId = NULL,
  variant = c("default", "secondary", "destructive", "outline", "ghost", "link"),
  size = c("default", "sm", "lg", "icon"),
  icon = NULL,
  icon_position = c("left", "right"),
  icon_size = c("default", "sm", "lg"),
  loading = FALSE,
  disabled = FALSE,
  href = NULL,
  aria_label = NULL,
  type = "button",
  class = NULL,
  ...
)
```

## Arguments

- label:

  Button text.

- inputId:

  Optional input id. When set, the button becomes a Shiny action button.

- variant:

  One of `"default"`, `"secondary"`, `"destructive"`, `"outline"`,
  `"ghost"`, `"link"`.

- size:

  One of `"default"`, `"sm"`, `"lg"`, `"icon"`.

- icon:

  Optional leading/trailing icon: a
  [`shad_icon()`](https://orijitghosh.github.io/shadshiny/reference/shad_icon.md)
  name or a tag.

- icon_position:

  `"left"` or `"right"`.

- icon_size:

  For `size = "icon"`, an additional `"default"`, `"sm"` or `"lg"`
  sizing.

- loading:

  If `TRUE`, shows a spinner, disables the button, and sets `aria-busy`.

- disabled:

  If `TRUE`, disables the button.

- href:

  Optional URL; renders an `<a class="shad-btn">` instead.

- aria_label:

  Accessible label (required for icon-only buttons).

- type:

  Button `type` attribute (ignored for anchors).

- class:

  Extra CSS classes.

- ...:

  Extra attributes or child tags.

## Value

A button (or anchor) tag.

## See also

[`shad_toast()`](https://orijitghosh.github.io/shadshiny/reference/shad_toast.md),
[`update_shad_button()`](https://orijitghosh.github.io/shadshiny/reference/update_shad.md)

Other shadshiny tier-1 components:
[`shad_alert()`](https://orijitghosh.github.io/shadshiny/reference/shad_alert.md),
[`shad_aspect_ratio()`](https://orijitghosh.github.io/shadshiny/reference/shad_aspect_ratio.md),
[`shad_avatar()`](https://orijitghosh.github.io/shadshiny/reference/shad_avatar.md),
[`shad_badge()`](https://orijitghosh.github.io/shadshiny/reference/shad_badge.md),
[`shad_breadcrumb()`](https://orijitghosh.github.io/shadshiny/reference/shad_breadcrumb.md),
[`shad_button_group()`](https://orijitghosh.github.io/shadshiny/reference/shad_button_group.md),
[`shad_card()`](https://orijitghosh.github.io/shadshiny/reference/shad_card.md),
[`shad_code_block()`](https://orijitghosh.github.io/shadshiny/reference/shad_code_block.md),
[`shad_empty()`](https://orijitghosh.github.io/shadshiny/reference/shad_empty.md),
[`shad_item()`](https://orijitghosh.github.io/shadshiny/reference/shad_item.md),
[`shad_kbd_group()`](https://orijitghosh.github.io/shadshiny/reference/shad_kbd_group.md),
[`shad_label()`](https://orijitghosh.github.io/shadshiny/reference/shad_label.md),
[`shad_progress()`](https://orijitghosh.github.io/shadshiny/reference/shad_progress.md),
[`shad_scroll_fade()`](https://orijitghosh.github.io/shadshiny/reference/shad_scroll_fade.md),
[`shad_separator()`](https://orijitghosh.github.io/shadshiny/reference/shad_separator.md),
[`shad_shimmer()`](https://orijitghosh.github.io/shadshiny/reference/shad_shimmer.md),
[`shad_skeleton()`](https://orijitghosh.github.io/shadshiny/reference/shad_skeleton.md),
[`shad_spinner()`](https://orijitghosh.github.io/shadshiny/reference/shad_spinner.md),
[`shad_table()`](https://orijitghosh.github.io/shadshiny/reference/shad_table.md),
[`shad_typography`](https://orijitghosh.github.io/shadshiny/reference/shad_typography.md)

## Examples

``` r
shad_button("Save", variant = "default")
#> <button type="button" class="shad-btn shad-btn--default">Save</button>
shad_button("Delete", variant = "destructive", icon = "x")
#> <button type="button" class="shad-btn shad-btn--destructive">
#>   <svg class="shad-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M18 6 6 18"/><path d="m6 6 12 12"/></svg>
#>   Delete
#> </button>
shad_button(inputId = "go", "Run")
#> <button type="button" id="go" class="shad-btn shad-btn--default action-button">Run</button>
```

# Item

A flexible list-row primitive: media, title/description, and actions in
one flex row. Group with `shad_item_group()` and divide with
`shad_item_separator()`. Render as a link with `href` for a clickable
row.

## Usage

``` r
shad_item(
  title,
  description = NULL,
  media = NULL,
  actions = NULL,
  variant = c("default", "outline", "muted"),
  size = c("default", "sm", "xs"),
  media_variant = NULL,
  header = NULL,
  footer = NULL,
  href = NULL,
  class = NULL,
  ...
)

shad_item_group(..., role = "list", class = NULL)

shad_item_separator()
```

## Arguments

- title:

  The item's title (or any content for the title slot).

- description:

  Optional secondary text (clamped to two lines).

- media:

  Optional
  [`shad_icon()`](https://orijitghosh.github.io/shadshiny/reference/shad_icon.md)
  name or a tag (icon, image, avatar).

- actions:

  Optional trailing controls (buttons, a switch, a chevron).

- variant:

  One of `"default"` (transparent), `"outline"`, `"muted"`.

- size:

  One of `"default"`, `"sm"`, `"xs"`.

- media_variant:

  `"icon"` (bordered muted tile) or `"image"` (rounded thumb). Ignored
  when `media` is `NULL` or free-form (e.g. an avatar).

- header:

  Optional full-width top row.

- footer:

  Optional full-width bottom row.

- href:

  Optional URL; renders the row as `<a class="shad-item">`.

- class:

  Extra CSS classes.

- ...:

  Extra attributes on the root.

- role:

  ARIA role for the group container (default `"list"`); items keep
  `role="listitem"`.

## Value

An item tag.

## See also

Other shadshiny tier-1 components:
[`shad_alert()`](https://orijitghosh.github.io/shadshiny/reference/shad_alert.md),
[`shad_aspect_ratio()`](https://orijitghosh.github.io/shadshiny/reference/shad_aspect_ratio.md),
[`shad_avatar()`](https://orijitghosh.github.io/shadshiny/reference/shad_avatar.md),
[`shad_badge()`](https://orijitghosh.github.io/shadshiny/reference/shad_badge.md),
[`shad_breadcrumb()`](https://orijitghosh.github.io/shadshiny/reference/shad_breadcrumb.md),
[`shad_button()`](https://orijitghosh.github.io/shadshiny/reference/shad_button.md),
[`shad_button_group()`](https://orijitghosh.github.io/shadshiny/reference/shad_button_group.md),
[`shad_card()`](https://orijitghosh.github.io/shadshiny/reference/shad_card.md),
[`shad_empty()`](https://orijitghosh.github.io/shadshiny/reference/shad_empty.md),
[`shad_label()`](https://orijitghosh.github.io/shadshiny/reference/shad_label.md),
[`shad_progress()`](https://orijitghosh.github.io/shadshiny/reference/shad_progress.md),
[`shad_separator()`](https://orijitghosh.github.io/shadshiny/reference/shad_separator.md),
[`shad_skeleton()`](https://orijitghosh.github.io/shadshiny/reference/shad_skeleton.md),
[`shad_spinner()`](https://orijitghosh.github.io/shadshiny/reference/shad_spinner.md),
[`shad_table()`](https://orijitghosh.github.io/shadshiny/reference/shad_table.md),
[`shad_typography`](https://orijitghosh.github.io/shadshiny/reference/shad_typography.md)

## Examples

``` r
shad_item("Nightly backup", description = "Runs every day at 02:00 UTC.",
          media = "clock", variant = "outline",
          actions = shad_button("Configure", variant = "outline", size = "sm"))
#> <div class="shad-item shad-item--outline">
#>   <div class="shad-item__media shad-item__media--icon" aria-hidden="true"><svg class="shad-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg></div>
#>   <div class="shad-item__content">
#>     <div class="shad-item__title">Nightly backup</div>
#>     <div class="shad-item__description">Runs every day at 02:00 UTC.</div>
#>   </div>
#>   <div class="shad-item__actions">
#>     <button type="button" class="shad-btn shad-btn--outline shad-btn--sm">Configure</button>
#>   </div>
#> </div>
```

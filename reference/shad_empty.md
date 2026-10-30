# Empty state

A centred empty-state panel for "no data", search-miss, or 404 screens.
Compose a media slot (icon or illustration), a title, a description, and
an optional actions area.

## Usage

``` r
shad_empty(
  title,
  description = NULL,
  media = NULL,
  media_variant = c("default", "icon"),
  content = NULL,
  class = NULL,
  ...
)
```

## Arguments

- title:

  The empty-state title.

- description:

  Optional supporting text (may contain links/tags).

- media:

  Optional
  [`shad_icon()`](https://orijitghosh.github.io/shadshiny/reference/shad_icon.md)
  name or a tag (icon, image, avatar) shown above the title.

- media_variant:

  `"icon"` (rounded muted tile) or `"default"` (free-form illustration).
  Ignored when `media` is `NULL`.

- content:

  Optional actions area — buttons, an input, links.

- class:

  Extra CSS classes.

- ...:

  Extra attributes on the root.

## Value

An empty-state tag.

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
[`shad_code_block()`](https://orijitghosh.github.io/shadshiny/reference/shad_code_block.md),
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
shad_empty(
  "No projects yet",
  description = "Create your first project to get started.",
  media = "folder", media_variant = "icon",
  content = shad_button("New project")
)
#> <div class="shad-empty">
#>   <div class="shad-empty__header">
#>     <div class="shad-empty__media shad-empty__media--icon" aria-hidden="true">
#>       <svg class="shad-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M20 20a2 2 0 0 0 2-2V8a2 2 0 0 0-2-2h-7.9a2 2 0 0 1-1.69-.9L9.6 3.9A2 2 0 0 0 7.93 3H4a2 2 0 0 0-2 2v13a2 2 0 0 0 2 2Z"/></svg>
#>     </div>
#>     <div class="shad-empty__title">No projects yet</div>
#>     <div class="shad-empty__description">Create your first project to get started.</div>
#>   </div>
#>   <div class="shad-empty__content">
#>     <button type="button" class="shad-btn shad-btn--default">New project</button>
#>   </div>
#> </div>
```

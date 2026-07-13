# Avatar

A user avatar with an image and an initials fallback. The fallback is
layered under the image and revealed automatically if the image is
missing or fails to load (zero JavaScript).

## Usage

``` r
shad_avatar(
  src = NULL,
  alt = "",
  fallback = NULL,
  size = c("default", "sm", "lg", "xl"),
  class = NULL,
  ...
)

shad_avatar_group(..., max = NULL, class = NULL)
```

## Arguments

- src:

  Image URL. Optional.

- alt:

  Image alt text; also the source of default initials.

- fallback:

  Fallback text (initials). Defaults to initials derived from `alt`.

- size:

  One of `"default"`, `"sm"`, `"lg"`, `"xl"`.

- class:

  Extra CSS classes.

- ...:

  Extra attributes.

- max:

  Maximum avatars to show in a group before collapsing the rest into a
  "+N" overflow avatar.

## Value

A `<span class="shad-avatar">`.

## See also

Other shadshiny tier-1 components:
[`shad_alert()`](https://orijitghosh.github.io/shadshiny/reference/shad_alert.md),
[`shad_aspect_ratio()`](https://orijitghosh.github.io/shadshiny/reference/shad_aspect_ratio.md),
[`shad_badge()`](https://orijitghosh.github.io/shadshiny/reference/shad_badge.md),
[`shad_breadcrumb()`](https://orijitghosh.github.io/shadshiny/reference/shad_breadcrumb.md),
[`shad_button()`](https://orijitghosh.github.io/shadshiny/reference/shad_button.md),
[`shad_button_group()`](https://orijitghosh.github.io/shadshiny/reference/shad_button_group.md),
[`shad_card()`](https://orijitghosh.github.io/shadshiny/reference/shad_card.md),
[`shad_empty()`](https://orijitghosh.github.io/shadshiny/reference/shad_empty.md),
[`shad_item()`](https://orijitghosh.github.io/shadshiny/reference/shad_item.md),
[`shad_label()`](https://orijitghosh.github.io/shadshiny/reference/shad_label.md),
[`shad_progress()`](https://orijitghosh.github.io/shadshiny/reference/shad_progress.md),
[`shad_separator()`](https://orijitghosh.github.io/shadshiny/reference/shad_separator.md),
[`shad_skeleton()`](https://orijitghosh.github.io/shadshiny/reference/shad_skeleton.md),
[`shad_spinner()`](https://orijitghosh.github.io/shadshiny/reference/shad_spinner.md),
[`shad_table()`](https://orijitghosh.github.io/shadshiny/reference/shad_table.md),
[`shad_typography`](https://orijitghosh.github.io/shadshiny/reference/shad_typography.md)

## Examples

``` r
shad_avatar(src = "https://github.com/shadcn.png", alt = "@shadcn")
#> <span class="shad-avatar">
#>   <span class="shad-avatar__fallback" aria-hidden="true">S</span>
#>   <img class="shad-avatar__image" src="https://github.com/shadcn.png" alt="@shadcn" onerror="this.hidden=true"/>
#> </span>
shad_avatar(fallback = "JD")
#> <span class="shad-avatar">
#>   <span class="shad-avatar__fallback">JD</span>
#> </span>
```

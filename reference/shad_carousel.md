# Carousel

A scroll-snap carousel. When `inputId` is set, `input$<inputId>` is the
current slide index (1-based).

## Usage

``` r
shad_carousel(
  inputId = NULL,
  ...,
  show_dots = TRUE,
  show_arrows = TRUE,
  class = NULL
)

shad_carousel_item(...)
```

## Arguments

- inputId:

  Optional input id (binds the current slide when set).

- ...:

  One or more `shad_carousel_item()`.

- show_dots:

  If `TRUE` (default), render the dot indicators.

- show_arrows:

  If `TRUE` (default), render the prev/next arrows.

- class:

  Extra CSS classes.

## Value

A carousel tag.

## See also

[`update_shad_carousel()`](https://orijitghosh.github.io/shadshiny/reference/update_shad.md)

Other shadshiny tier-3 components:
[`shad_accordion()`](https://orijitghosh.github.io/shadshiny/reference/shad_accordion.md),
[`shad_alert_dialog()`](https://orijitghosh.github.io/shadshiny/reference/shad_alert_dialog.md),
[`shad_collapsible()`](https://orijitghosh.github.io/shadshiny/reference/shad_collapsible.md),
[`shad_command()`](https://orijitghosh.github.io/shadshiny/reference/shad_command.md),
[`shad_command_palette()`](https://orijitghosh.github.io/shadshiny/reference/shad_command_palette.md),
[`shad_context_menu()`](https://orijitghosh.github.io/shadshiny/reference/shad_context_menu.md),
[`shad_dialog()`](https://orijitghosh.github.io/shadshiny/reference/shad_dialog.md),
[`shad_drawer()`](https://orijitghosh.github.io/shadshiny/reference/shad_drawer.md),
[`shad_dropdown_menu()`](https://orijitghosh.github.io/shadshiny/reference/shad_dropdown_menu.md),
[`shad_hover_card()`](https://orijitghosh.github.io/shadshiny/reference/shad_hover_card.md),
[`shad_menu_parts`](https://orijitghosh.github.io/shadshiny/reference/shad_menu_parts.md),
[`shad_menubar()`](https://orijitghosh.github.io/shadshiny/reference/shad_menubar.md),
[`shad_message_scroller()`](https://orijitghosh.github.io/shadshiny/reference/shad_message_scroller.md),
[`shad_navigation_menu()`](https://orijitghosh.github.io/shadshiny/reference/shad_navigation_menu.md),
[`shad_pagination()`](https://orijitghosh.github.io/shadshiny/reference/shad_pagination.md),
[`shad_popover()`](https://orijitghosh.github.io/shadshiny/reference/shad_popover.md),
[`shad_resizable()`](https://orijitghosh.github.io/shadshiny/reference/shad_resizable.md),
[`shad_scroll_area()`](https://orijitghosh.github.io/shadshiny/reference/shad_scroll_area.md),
[`shad_sheet()`](https://orijitghosh.github.io/shadshiny/reference/shad_sheet.md),
[`shad_sidebar_layout()`](https://orijitghosh.github.io/shadshiny/reference/shad_sidebar_layout.md),
[`shad_tabs()`](https://orijitghosh.github.io/shadshiny/reference/shad_tabs.md),
[`shad_tooltip()`](https://orijitghosh.github.io/shadshiny/reference/shad_tooltip.md)

## Examples

``` r
shad_carousel("c",
  shad_carousel_item("Slide 1"), shad_carousel_item("Slide 2"))
#> <div class="shad-carousel" data-shad="carousel" id="c" aria-label="Carousel">
#>   <div class="shad-carousel__viewport">
#>     <div class="shad-carousel__track">
#>       <div class="shad-carousel__slide">Slide 1</div>
#>       <div class="shad-carousel__slide">Slide 2</div>
#>     </div>
#>   </div>
#>   <button type="button" class="shad-carousel__prev" aria-label="Previous slide"><svg class="shad-icon shad-icon--directional" data-direction="back" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m12 19-7-7 7-7"/><path d="M19 12H5"/></svg></button>
#>   <button type="button" class="shad-carousel__next" aria-label="Next slide"><svg class="shad-icon shad-icon--directional" data-direction="forward" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M5 12h14"/><path d="m12 5 7 7-7 7"/></svg></button>
#>   <div class="shad-carousel__dots"></div>
#> </div>
```

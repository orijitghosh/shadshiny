# Accordion

A vertically stacked set of expandable items. `input$<inputId>` is the
open value(s): a string/`NULL` (single) or a character vector
(multiple).

## Usage

``` r
shad_accordion(
  inputId,
  ...,
  type = c("single", "multiple"),
  collapsible = TRUE,
  value = NULL,
  class = NULL
)

shad_accordion_item(value, title, ...)
```

## Arguments

- inputId:

  Input id.

- ...:

  One or more `shad_accordion_item()`.

- type:

  `"single"` (default) or `"multiple"`.

- collapsible:

  For `type = "single"`, allow closing the open item.

- value:

  Item value.

- class:

  Extra CSS classes.

- title:

  Trigger text.

## Value

An accordion tag.

## See also

[`update_shad_accordion()`](https://orijitghosh.github.io/shadshiny/reference/update_shad.md)

Other shadshiny tier-3 components:
[`shad_alert_dialog()`](https://orijitghosh.github.io/shadshiny/reference/shad_alert_dialog.md),
[`shad_carousel()`](https://orijitghosh.github.io/shadshiny/reference/shad_carousel.md),
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
shad_accordion("a",
  shad_accordion_item("item-1", "Is it accessible?", "Yes."),
  shad_accordion_item("item-2", "Is it styled?", "Yes."),
  value = "item-1")
#> <div data-shad="accordion" id="a" data-type="single" data-collapsible>
#>   <div class="shad-accordion__item" data-value="item-1" data-open>
#>     <button type="button" class="shad-accordion__trigger">
#>       Is it accessible?
#>       <svg class="shad-accordion__chevron" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m6 9 6 6 6-6"/></svg>
#>     </button>
#>     <div class="shad-accordion__content">
#>       <div class="shad-accordion__content-inner">Yes.</div>
#>     </div>
#>   </div>
#>   <div class="shad-accordion__item" data-value="item-2">
#>     <button type="button" class="shad-accordion__trigger">
#>       Is it styled?
#>       <svg class="shad-accordion__chevron" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m6 9 6 6 6-6"/></svg>
#>     </button>
#>     <div class="shad-accordion__content">
#>       <div class="shad-accordion__content-inner">Yes.</div>
#>     </div>
#>   </div>
#> </div>
```

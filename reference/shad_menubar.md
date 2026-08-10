# Menubar

A horizontal application menubar. `input$<inputId>` is the value of the
last activated item across all menus.

## Usage

``` r
shad_menubar(inputId, ..., class = NULL)

shad_menubar_menu(label, ...)
```

## Arguments

- inputId:

  Input id.

- ...:

  One or more `shad_menubar_menu()`.

- class:

  Extra CSS classes.

- label:

  Top-level menu label.

## Value

A menubar tag.

## See also

Other shadshiny tier-3 components:
[`shad_accordion()`](https://orijitghosh.github.io/shadshiny/reference/shad_accordion.md),
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
shad_menubar("mb",
  shad_menubar_menu("File", shad_menu_item("new-tab", "New tab")),
  shad_menubar_menu("Edit", shad_menu_item("undo", "Undo")))
#> <div class="shad-menubar" data-shad="menubar" id="mb">
#>   <div data-shad-menubar-menu>
#>     <button type="button" class="shad-menubar__trigger">File</button>
#>     <div class="shad-menu__content shad-anim-pop" hidden>
#>       <button type="button" class="shad-menu__item" data-value="new-tab">New tab</button>
#>     </div>
#>   </div>
#>   <div data-shad-menubar-menu>
#>     <button type="button" class="shad-menubar__trigger">Edit</button>
#>     <div class="shad-menu__content shad-anim-pop" hidden>
#>       <button type="button" class="shad-menu__item" data-value="undo">Undo</button>
#>     </div>
#>   </div>
#> </div>
```

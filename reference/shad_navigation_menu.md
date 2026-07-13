# Navigation menu

A horizontal navigation bar with animated dropdown panels. Not a Shiny
input by default.

## Usage

``` r
shad_navigation_menu(inputId = NULL, ..., class = NULL)

shad_navigation_menu_item(label, ..., href = NULL)
```

## Arguments

- inputId:

  Optional input id.

- ...:

  One or more `shad_navigation_menu_item()`.

- class:

  Extra CSS classes.

- label:

  Item label.

- href:

  If supplied (and no `...` panel content), renders a plain link.

## Value

A navigation-menu tag.

## See also

Other shadshiny tier-3 components:
[`shad_accordion()`](https://orijitghosh.github.io/shadshiny/reference/shad_accordion.md),
[`shad_alert_dialog()`](https://orijitghosh.github.io/shadshiny/reference/shad_alert_dialog.md),
[`shad_carousel()`](https://orijitghosh.github.io/shadshiny/reference/shad_carousel.md),
[`shad_collapsible()`](https://orijitghosh.github.io/shadshiny/reference/shad_collapsible.md),
[`shad_command()`](https://orijitghosh.github.io/shadshiny/reference/shad_command.md),
[`shad_context_menu()`](https://orijitghosh.github.io/shadshiny/reference/shad_context_menu.md),
[`shad_dialog()`](https://orijitghosh.github.io/shadshiny/reference/shad_dialog.md),
[`shad_drawer()`](https://orijitghosh.github.io/shadshiny/reference/shad_drawer.md),
[`shad_dropdown_menu()`](https://orijitghosh.github.io/shadshiny/reference/shad_dropdown_menu.md),
[`shad_hover_card()`](https://orijitghosh.github.io/shadshiny/reference/shad_hover_card.md),
[`shad_menu_parts`](https://orijitghosh.github.io/shadshiny/reference/shad_menu_parts.md),
[`shad_menubar()`](https://orijitghosh.github.io/shadshiny/reference/shad_menubar.md),
[`shad_message_scroller()`](https://orijitghosh.github.io/shadshiny/reference/shad_message_scroller.md),
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
shad_navigation_menu("nav",
  shad_navigation_menu_item("Docs", href = "#"),
  shad_navigation_menu_item("Components", htmltools::a(href = "#", "Dialog")))
#> <nav class="shad-nav-menu" data-shad="navigation-menu" id="nav" aria-label="Main">
#>   <ul class="shad-nav-menu__list">
#>     <li>
#>       <a class="shad-nav-menu__link" href="#">Docs</a>
#>     </li>
#>     <li data-shad-nav-item>
#>       <button type="button" class="shad-nav-menu__trigger" data-state="closed">
#>         Components
#>         <svg class="shad-nav-menu__chevron" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m6 9 6 6 6-6"/></svg>
#>       </button>
#>       <div class="shad-nav-menu__panel" hidden>
#>         <div class="shad-nav-menu__grid">
#>           <a href="#">Dialog</a>
#>         </div>
#>       </div>
#>     </li>
#>   </ul>
#>   <div class="shad-nav-menu__viewport" hidden></div>
#> </nav>
```

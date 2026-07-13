# Tabs

A tabbed panel set. `input$<inputId>` is the active tab value. Build
tabs with `shad_tab()`, which supplies both the trigger and its content
panel.

## Usage

``` r
shad_tabs(
  inputId,
  ...,
  selected = NULL,
  orientation = c("horizontal", "vertical"),
  class = NULL
)

shad_tab(value, title, ..., icon = NULL, disabled = FALSE)
```

## Arguments

- inputId:

  Input id.

- ...:

  One or more `shad_tab()`.

- selected:

  Initially active tab value (defaults to the first tab).

- orientation:

  `"horizontal"` (default) or `"vertical"`.

- class:

  Extra CSS classes.

- value:

  Tab value.

- title:

  Tab trigger label.

- icon:

  Optional trigger icon.

- disabled:

  If `TRUE`, the tab cannot be selected.

## Value

A tabs tag.

## See also

[`update_shad_tabs()`](https://orijitghosh.github.io/shadshiny/reference/update_shad.md)

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
[`shad_navigation_menu()`](https://orijitghosh.github.io/shadshiny/reference/shad_navigation_menu.md),
[`shad_pagination()`](https://orijitghosh.github.io/shadshiny/reference/shad_pagination.md),
[`shad_popover()`](https://orijitghosh.github.io/shadshiny/reference/shad_popover.md),
[`shad_resizable()`](https://orijitghosh.github.io/shadshiny/reference/shad_resizable.md),
[`shad_scroll_area()`](https://orijitghosh.github.io/shadshiny/reference/shad_scroll_area.md),
[`shad_sheet()`](https://orijitghosh.github.io/shadshiny/reference/shad_sheet.md),
[`shad_sidebar_layout()`](https://orijitghosh.github.io/shadshiny/reference/shad_sidebar_layout.md),
[`shad_tooltip()`](https://orijitghosh.github.io/shadshiny/reference/shad_tooltip.md)

## Examples

``` r
shad_tabs("t",
  shad_tab("account", "Account", "Account panel"),
  shad_tab("password", "Password", "Password panel"))
#> <div data-shad="tabs" id="t" data-value="account">
#>   <div class="shad-tabs__list">
#>     <div class="shad-tabs__indicator" aria-hidden="true"></div>
#>     <button type="button" class="shad-tabs__trigger" data-value="account">Account</button>
#>     <button type="button" class="shad-tabs__trigger" data-value="password">Password</button>
#>   </div>
#>   <div class="shad-tabs__content" data-value="account">Account panel</div>
#>   <div class="shad-tabs__content" data-value="password">Password panel</div>
#> </div>
```

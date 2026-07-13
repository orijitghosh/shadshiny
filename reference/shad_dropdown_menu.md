# Dropdown menu

A button-triggered menu. `input$<inputId>` is the value of the last
activated item. Compose contents from the
[shad_menu_parts](https://orijitghosh.github.io/shadshiny/reference/shad_menu_parts.md).

## Usage

``` r
shad_dropdown_menu(
  inputId,
  trigger,
  ...,
  side = c("bottom", "top", "right", "left"),
  align = c("start", "center", "end"),
  class = NULL
)
```

## Arguments

- inputId:

  Input id.

- trigger:

  The tag that opens the menu.

- ...:

  Menu parts (items, separators, labels, submenus).

- side:

  `"bottom"` (default), `"top"`, `"right"`, `"left"`.

- align:

  `"start"` (default), `"center"`, `"end"`.

- class:

  Extra CSS classes.

## Value

A dropdown-menu tag.

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
shad_dropdown_menu("m", trigger = shad_button("Open"),
  shad_menu_label("My Account"), shad_menu_separator(),
  shad_menu_item("profile", "Profile", shortcut = "⇧⌘P"))
#> <div data-shad="dropdown-menu" data-align="start" id="m" style="display:inline-block">
#>   <button class="shad-btn shad-btn--default shad-menu__trigger" type="button">Open</button>
#>   <div class="shad-menu__content shad-anim-pop" hidden>
#>     <div class="shad-menu__label">My Account</div>
#>     <div class="shad-menu__separator"></div>
#>     <button type="button" class="shad-menu__item" data-value="profile">
#>       Profile
#>       <span class="shad-menu__shortcut">⇧⌘P</span>
#>     </button>
#>   </div>
#> </div>
```

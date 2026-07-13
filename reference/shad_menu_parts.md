# Menu part constructors

Building blocks for
[`shad_dropdown_menu()`](https://orijitghosh.github.io/shadshiny/reference/shad_dropdown_menu.md),
[`shad_context_menu()`](https://orijitghosh.github.io/shadshiny/reference/shad_context_menu.md),
and
[`shad_menubar()`](https://orijitghosh.github.io/shadshiny/reference/shad_menubar.md)
menus. Activating an item reports its `value` as the menu's input value.

## Usage

``` r
shad_menu_item(
  value,
  label = NULL,
  icon = NULL,
  shortcut = NULL,
  disabled = FALSE,
  destructive = FALSE
)

shad_menu_checkbox_item(value, label, checked = FALSE, disabled = FALSE)

shad_menu_radio_group(value = NULL, ...)

shad_menu_radio_item(value, label = NULL, disabled = FALSE)

shad_menu_label(...)

shad_menu_separator()

shad_menu_sub(trigger_label, ..., icon = NULL)
```

## Arguments

- value:

  Item value reported on activation.

- label:

  Item text.

- icon:

  Optional leading icon.

- shortcut:

  Optional keyboard-shortcut hint (right-aligned).

- disabled:

  If `TRUE`, the item is not selectable.

- destructive:

  If `TRUE`, styles the item as destructive.

- checked:

  Initial checked state.

- ...:

  For `shad_menu_radio_group()`, `shad_menu_radio_item()` specs; for
  `shad_menu_sub()`, the submenu contents.

- trigger_label:

  Submenu trigger text.

## Value

An htmltools tag (or tagList) for use inside a menu.

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

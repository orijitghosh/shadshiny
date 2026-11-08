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
[`shad_command_palette()`](https://orijitghosh.github.io/shadshiny/reference/shad_command_palette.md),
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

## Examples

``` r
shad_dropdown_menu(
  "view", trigger = shad_button("View", variant = "outline"),
  shad_menu_label("Panels"),
  shad_menu_checkbox_item("sidebar", "Sidebar", checked = TRUE),
  shad_menu_separator(),
  shad_menu_radio_group(
    "comfortable",
    shad_menu_radio_item("compact", "Compact"),
    shad_menu_radio_item("comfortable", "Comfortable")
  ),
  shad_menu_separator(),
  shad_menu_sub("More", shad_menu_item("reset", "Reset layout")),
  shad_menu_item("close", "Close window", destructive = TRUE)
)
#> <div data-shad="dropdown-menu" data-align="start" id="view" style="display:inline-block">
#>   <button class="shad-btn shad-btn--outline shad-menu__trigger" type="button">View</button>
#>   <div class="shad-menu__content shad-anim-pop" hidden>
#>     <div class="shad-menu__label">Panels</div>
#>     <button type="button" class="shad-menu__item" data-type="checkbox" data-state="checked" data-value="sidebar">
#>       <span class="shad-menu__indicator"><svg class="shad-icon shad-icon--sm" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M20 6 9 17l-5-5"/></svg></span>
#>       Sidebar
#>     </button>
#>     <div class="shad-menu__separator"></div>
#>     <button type="button" class="shad-menu__item" data-type="radio" data-group="shad-menuradio-2" data-state="unchecked" data-value="compact">
#>       <span class="shad-menu__indicator"><svg class="shad-icon shad-icon--sm" viewBox="0 0 24 24" fill="currentColor" stroke="none" aria-hidden="true"><circle cx="12" cy="12" r="4"/></svg></span>
#>       Compact
#>     </button>
#>     <button type="button" class="shad-menu__item" data-type="radio" data-group="shad-menuradio-2" data-state="checked" data-value="comfortable">
#>       <span class="shad-menu__indicator"><svg class="shad-icon shad-icon--sm" viewBox="0 0 24 24" fill="currentColor" stroke="none" aria-hidden="true"><circle cx="12" cy="12" r="4"/></svg></span>
#>       Comfortable
#>     </button>
#>     <div class="shad-menu__separator"></div>
#>     <div data-shad-submenu>
#>       <button type="button" class="shad-menu__item" data-shad-submenu-trigger aria-haspopup="menu" aria-expanded="false" data-state="closed">
#>         More
#>         <svg class="shad-menu__chevron" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m9 18 6-6-6-6"/></svg>
#>       </button>
#>       <div class="shad-menu__content shad-anim-pop" hidden>
#>         <button type="button" class="shad-menu__item" data-value="reset">Reset layout</button>
#>       </div>
#>     </div>
#>     <button type="button" class="shad-menu__item shad-menu__item--destructive" data-value="close">Close window</button>
#>   </div>
#> </div>
```

# Sidebar layout

A collapsible application sidebar with a main content area.
`input$<inputId>` is a list `list(collapsed=, mobileOpen=, active=)`.
Toggle with the Cmd+B / Ctrl+B shortcut, a `shad_sidebar_trigger()`, or
[`shad_sidebar_toggle()`](https://orijitghosh.github.io/shadshiny/reference/shad_overlay_server.md).

## Usage

``` r
shad_sidebar_layout(inputId, sidebar, main, class = NULL)

shad_sidebar(..., header = NULL, footer = NULL, collapsed = FALSE)

shad_sidebar_group(label = NULL, ...)

shad_sidebar_item(
  value,
  label,
  icon = NULL,
  badge = NULL,
  href = NULL,
  active = FALSE
)

shad_sidebar_trigger(class = NULL)
```

## Arguments

- inputId:

  Input id.

- sidebar:

  A `shad_sidebar()`.

- main:

  The main content.

- class:

  Extra CSS classes.

- ...:

  Sidebar body content (typically `shad_sidebar_group()`s).

- header, footer:

  Optional header/footer content.

- collapsed:

  If `TRUE`, start collapsed.

- label:

  Optional group label.

- value:

  Item value (reported as `active` when clicked).

- icon:

  Optional leading icon.

- badge:

  Optional trailing badge content.

- href:

  Optional link; renders an `<a>` instead of a `<button>`.

- active:

  If `TRUE`, marks the item active.

## Value

A sidebar-layout tag.

## See also

[`shad_sidebar_toggle()`](https://orijitghosh.github.io/shadshiny/reference/shad_overlay_server.md),
[`update_shad_sidebar()`](https://orijitghosh.github.io/shadshiny/reference/update_shad.md)

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
[`shad_menubar()`](https://orijitghosh.github.io/shadshiny/reference/shad_menubar.md),
[`shad_message_scroller()`](https://orijitghosh.github.io/shadshiny/reference/shad_message_scroller.md),
[`shad_navigation_menu()`](https://orijitghosh.github.io/shadshiny/reference/shad_navigation_menu.md),
[`shad_pagination()`](https://orijitghosh.github.io/shadshiny/reference/shad_pagination.md),
[`shad_popover()`](https://orijitghosh.github.io/shadshiny/reference/shad_popover.md),
[`shad_resizable()`](https://orijitghosh.github.io/shadshiny/reference/shad_resizable.md),
[`shad_scroll_area()`](https://orijitghosh.github.io/shadshiny/reference/shad_scroll_area.md),
[`shad_sheet()`](https://orijitghosh.github.io/shadshiny/reference/shad_sheet.md),
[`shad_tabs()`](https://orijitghosh.github.io/shadshiny/reference/shad_tabs.md),
[`shad_tooltip()`](https://orijitghosh.github.io/shadshiny/reference/shad_tooltip.md)

## Examples

``` r
shad_sidebar_layout("sb",
  sidebar = shad_sidebar(
    shad_sidebar_group("Platform",
      shad_sidebar_item("home", "Home", active = TRUE))),
  main = htmltools::div(shad_sidebar_trigger(), "Dashboard"))
#> <div class="shad-sidebar-layout" data-shad="sidebar" id="sb">
#>   <div class="shad-sidebar__overlay" hidden></div>
#>   <aside class="shad-sidebar" aria-label="Sidebar">
#>     <div class="shad-sidebar__content">
#>       <div class="shad-sidebar__group">
#>         <div class="shad-sidebar__group-label">Platform</div>
#>         <ul class="shad-sidebar__menu">
#>           <li>
#>             <button type="button" class="shad-sidebar__item" data-value="home" data-state="active">
#>               <span class="shad-sidebar__label">Home</span>
#>             </button>
#>           </li>
#>         </ul>
#>       </div>
#>     </div>
#>   </aside>
#>   <main class="shad-sidebar-layout__main">
#>     <div>
#>       <button type="button" class="shad-sidebar__trigger" aria-label="Toggle sidebar">
#>         <svg class="shad-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><rect width="18" height="18" x="3" y="3" rx="2"/><path d="M9 3v18"/></svg>
#>       </button>
#>       Dashboard
#>     </div>
#>   </main>
#> </div>
```

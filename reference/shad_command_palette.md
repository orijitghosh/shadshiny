# Command palette for app navigation

The Cmd+K / Ctrl+K pattern: a modal, searchable list of everything the
app can do. A thin shape over
[`shad_command()`](https://orijitghosh.github.io/shadshiny/reference/shad_command.md)
that takes its items as data, opens on the hotkey (or from
`shad_command_trigger()`, or from the server), and reports every
activation.

## Usage

``` r
shad_command_palette(
  inputId,
  items = NULL,
  ...,
  hotkey = "mod+k",
  placeholder = "Type a command or search...",
  empty_text = "No results found.",
  class = NULL
)

shad_command_trigger(
  id,
  label = "Search...",
  icon = "search",
  shortcut = "\u2318K",
  variant = "outline",
  size = "sm",
  class = NULL,
  ...
)

shad_command_open(id, session = shiny::getDefaultReactiveDomain())

shad_command_close(id, session = shiny::getDefaultReactiveDomain())
```

## Arguments

- inputId:

  Input id.

- items:

  The commands. Either a named character vector (`c(Home = "home")` –
  names are labels, values are what you observe), a named list of such
  vectors (each name becomes a group heading, separated), or a list of
  [`shad_command_item()`](https://orijitghosh.github.io/shadshiny/reference/shad_command.md)
  /
  [`shad_command_group()`](https://orijitghosh.github.io/shadshiny/reference/shad_command.md)
  tags for full control. List entries may also be lists carrying
  `value`, `label`, `icon`, `shortcut`, `keywords`, `disabled`.

- ...:

  Extra content appended after `items`.

- hotkey:

  Key that opens the palette, e.g. `"mod+k"` (default; Cmd+K on macOS,
  Ctrl+K elsewhere). `NULL` for no hotkey – open it from a trigger or
  the server instead. Write `+`-separated modifiers, then the key: `mod`
  (Cmd or Ctrl), `ctrl`, `meta` / `cmd`, `alt` / `option`, `shift`, and
  `space` for the space bar, as in `"mod+shift+p"` or `"/"`. Exactly the
  named modifiers must be held. A hotkey without Ctrl, Cmd or Alt is
  left to text fields, so `"/"` still types a slash there. A hotkey
  naming an unknown modifier never fires, with a browser console
  warning.

- placeholder:

  Search-input placeholder.

- empty_text:

  Text shown when nothing matches.

- class:

  Extra CSS classes.

- id:

  The palette's input id. In a module, namespace it yourself with `ns()`
  – this is a UI-side attribute, not a server message.

- label:

  Trigger text.

- icon:

  Leading icon name or tag.

- shortcut:

  Hint shown at the end of the trigger, e.g. `"Ctrl K"`, or `"\u2318K"`
  for the macOS key symbols of Cmd+K. `NULL` for none.

- variant, size:

  Passed to
  [`shad_button()`](https://orijitghosh.github.io/shadshiny/reference/shad_button.md).

- session:

  The Shiny session.

## Value

A command tag, hidden until opened.

## Details

Read selections from `input$<inputId>_event`, a list of `value` and
`nonce`. `input$<inputId>` also holds the last value, but Shiny drops a
repeat of the same value – which is wrong for navigation, where choosing
"Settings" twice has to work twice. The `_event` input fires every time.

Refresh the items from the server with
[`update_shad_command()`](https://orijitghosh.github.io/shadshiny/reference/update_shad_command.md)
– a recent-docs list, search results, whatever the session knows.

## See also

[`shad_command()`](https://orijitghosh.github.io/shadshiny/reference/shad_command.md),
`shad_command_trigger()`,
[`update_shad_command()`](https://orijitghosh.github.io/shadshiny/reference/update_shad_command.md)

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
[`shad_tabs()`](https://orijitghosh.github.io/shadshiny/reference/shad_tabs.md),
[`shad_tooltip()`](https://orijitghosh.github.io/shadshiny/reference/shad_tooltip.md)

## Examples

``` r
shad_command_palette("palette", items = list(
  "Go to" = c(Dashboard = "dashboard", Reports = "reports"),
  "Actions" = c("New report" = "new")
))
#> <div class="shad-command" data-shad="command" id="palette" data-dialog aria-label="Command palette" data-hotkey="mod+k">
#>   <div class="shad-command__header">
#>     <svg class="shad-command__search-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="11" cy="11" r="8"/><path d="m21 21-4.3-4.3"/></svg>
#>     <input class="shad-command__input" type="text" placeholder="Type a command or search..." aria-label="Search commands"/>
#>   </div>
#>   <div class="shad-command__list">
#>     <div class="shad-command__empty">No results found.</div>
#>     <div class="shad-command__group">
#>       <div class="shad-command__group-heading">Go to</div>
#>       <button type="button" class="shad-command__item" data-value="dashboard">Dashboard</button>
#>       <button type="button" class="shad-command__item" data-value="reports">Reports</button>
#>     </div>
#>     <div class="shad-command__separator"></div>
#>     <div class="shad-command__group">
#>       <div class="shad-command__group-heading">Actions</div>
#>       <button type="button" class="shad-command__item" data-value="new">New report</button>
#>     </div>
#>   </div>
#> </div>
```

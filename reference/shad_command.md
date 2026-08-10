# Command palette

A searchable command menu. `input$<inputId>` is the value of the
selected item. Compose contents with `shad_command_group()`,
`shad_command_item()`, and `shad_command_separator()`.

## Usage

``` r
shad_command(
  inputId,
  ...,
  placeholder = "Type a command or search...",
  empty_text = "No results found.",
  dialog = FALSE,
  hotkey = dialog,
  class = NULL
)

shad_command_group(label, ...)

shad_command_item(
  value,
  label = NULL,
  icon = NULL,
  shortcut = NULL,
  keywords = NULL,
  disabled = FALSE
)

shad_command_separator()
```

## Arguments

- inputId:

  Input id.

- ...:

  Command content (groups, items, separators).

- placeholder:

  Search-input placeholder.

- empty_text:

  Text shown when no item matches.

- dialog:

  If `TRUE`, render the ⌘K/Ctrl+K dialog variant.

- hotkey:

  If `TRUE`, bind the `mod+k` open hotkey (defaults to `dialog`).

- class:

  Extra CSS classes.

- label:

  Group heading, or item text.

- value:

  Item value reported on selection.

- icon:

  Optional leading icon.

- shortcut:

  Optional shortcut hint.

- keywords:

  Extra search terms (space-separated or a character vector).

- disabled:

  If `TRUE`, the item is not selectable.

## Value

A command tag.

## See also

Other shadshiny tier-3 components:
[`shad_accordion()`](https://orijitghosh.github.io/shadshiny/reference/shad_accordion.md),
[`shad_alert_dialog()`](https://orijitghosh.github.io/shadshiny/reference/shad_alert_dialog.md),
[`shad_carousel()`](https://orijitghosh.github.io/shadshiny/reference/shad_carousel.md),
[`shad_collapsible()`](https://orijitghosh.github.io/shadshiny/reference/shad_collapsible.md),
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
shad_command("cmd",
  shad_command_group("Suggestions",
    shad_command_item("calendar", "Calendar", keywords = "date schedule")))
#> <div class="shad-command" data-shad="command" id="cmd">
#>   <div class="shad-command__header">
#>     <svg class="shad-command__search-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="11" cy="11" r="8"/><path d="m21 21-4.3-4.3"/></svg>
#>     <input class="shad-command__input" type="text" placeholder="Type a command or search..." aria-label="Search commands"/>
#>   </div>
#>   <div class="shad-command__list">
#>     <div class="shad-command__empty">No results found.</div>
#>     <div class="shad-command__group">
#>       <div class="shad-command__group-heading">Suggestions</div>
#>       <button type="button" class="shad-command__item" data-value="calendar" data-keywords="date schedule">Calendar</button>
#>     </div>
#>   </div>
#> </div>
```

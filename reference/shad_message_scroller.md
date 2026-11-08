# Message scroller

A stick-to-bottom transcript viewport for streaming chat. Follows the
live edge only while the reader is at the bottom; scrolling up detaches
and surfaces a jump-to-latest button. Prepended history preserves the
visible anchor. Part of the chat/AI kit.

## Usage

``` r
shad_message_scroller(
  id,
  ...,
  auto_scroll = TRUE,
  default_position = c("end", "start", "last-anchor"),
  jump_label = "Jump to latest",
  height = NULL,
  class = NULL
)

shad_message_scroller_item(..., anchor = FALSE, class = NULL)
```

## Arguments

- id:

  Element id (namespaced automatically in modules).

- ...:

  Rows – typically `shad_message_scroller_item()` wrapping a
  [`shad_message()`](https://orijitghosh.github.io/shadshiny/reference/shad_message.md),
  [`shad_bubble()`](https://orijitghosh.github.io/shadshiny/reference/shad_bubble.md),
  or
  [`shad_marker()`](https://orijitghosh.github.io/shadshiny/reference/shad_marker.md).

- auto_scroll:

  If `TRUE` (default), follow new content while at the bottom. `FALSE`
  never auto-follows.

- default_position:

  Initial scroll position: `"end"` (default), `"start"`, or
  `"last-anchor"` (scroll the last `data-anchor` item to top).

- jump_label:

  Label for the jump-to-latest button.

- height:

  CSS height of the scroller (e.g. `400`, `"60vh"`).

- class:

  Extra CSS classes.

- anchor:

  If `TRUE`, marks this row as a turn boundary (`data-anchor`) for
  `default_position = "last-anchor"`.

## Value

A message-scroller tag.

## Details

Position is not a form value, so there is no `input$<id>`. Drive it from
the server with
[`shad_message_scroller_to_bottom()`](https://orijitghosh.github.io/shadshiny/reference/shad_message_scroller_to_bottom.md).

## See also

`shad_message_scroller_item()`,
[`shad_message_scroller_to_bottom()`](https://orijitghosh.github.io/shadshiny/reference/shad_message_scroller_to_bottom.md)

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
shad_message_scroller(
  "chat", height = 400,
  shad_message_scroller_item(shad_marker("Today", variant = "separator"),
                             anchor = TRUE),
  shad_message_scroller_item(shad_bubble("Hi!", align = "start"))
)
#> <div class="shad-message-scroller" data-shad="message-scroller" id="chat" data-auto-scroll data-default-position="end" style="height:400px;">
#>   <div class="shad-message-scroller__viewport" aria-live="polite" tabindex="0">
#>     <div class="shad-message-scroller__content">
#>       <div class="shad-message-scroller__item" data-anchor>
#>         <div class="shad-marker shad-marker--separator">
#>           <span class="shad-marker__content">Today</span>
#>         </div>
#>       </div>
#>       <div class="shad-message-scroller__item">
#>         <div class="shad-bubble shad-bubble--default shad-bubble--start">
#>           <div class="shad-bubble__content">Hi!</div>
#>         </div>
#>       </div>
#>     </div>
#>   </div>
#>   <button type="button" class="shad-message-scroller__button" aria-label="Jump to latest">
#>     <svg class="shad-icon shad-icon--sm" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M12 5v14"/><path d="m19 12-7 7-7-7"/></svg>
#>     Jump to latest
#>   </button>
#> </div>
```

# Dialog (modal)

A modal dialog. `input$<inputId>` is the open state (logical).
Open/close from the server with
[`shad_dialog_open()`](https://orijitghosh.github.io/shadshiny/reference/shad_overlay_server.md)
/
[`shad_dialog_close()`](https://orijitghosh.github.io/shadshiny/reference/shad_overlay_server.md),
or supply a `trigger` to open client-side with no round trip.

## Usage

``` r
shad_dialog(
  inputId,
  ...,
  title = NULL,
  description = NULL,
  footer = NULL,
  trigger = NULL,
  size = NULL,
  show_close = TRUE,
  class = NULL
)

shad_dialog_close_button(label = "Cancel", ...)
```

## Arguments

- inputId:

  Input id.

- ...:

  For `shad_dialog_close_button()`, extra attributes for the `<button>`.

- title, description:

  Optional header text (auto-wired for a11y).

- footer:

  Optional footer content (e.g. buttons); often includes
  `shad_dialog_close_button()`.

- trigger:

  Optional tag whose click opens the dialog.

- size:

  Optional CSS max-width for the content (e.g. `"40rem"`).

- show_close:

  If `TRUE` (default), render the top-right close button.

- class:

  Extra CSS classes.

- label:

  Close-button label.

## Value

A dialog tag.

## See also

[`shad_dialog_open()`](https://orijitghosh.github.io/shadshiny/reference/shad_overlay_server.md),
[`shad_dialog_close()`](https://orijitghosh.github.io/shadshiny/reference/shad_overlay_server.md)

Other shadshiny tier-3 components:
[`shad_accordion()`](https://orijitghosh.github.io/shadshiny/reference/shad_accordion.md),
[`shad_alert_dialog()`](https://orijitghosh.github.io/shadshiny/reference/shad_alert_dialog.md),
[`shad_carousel()`](https://orijitghosh.github.io/shadshiny/reference/shad_carousel.md),
[`shad_collapsible()`](https://orijitghosh.github.io/shadshiny/reference/shad_collapsible.md),
[`shad_command()`](https://orijitghosh.github.io/shadshiny/reference/shad_command.md),
[`shad_context_menu()`](https://orijitghosh.github.io/shadshiny/reference/shad_context_menu.md),
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
shad_dialog("edit", trigger = shad_button("Edit"),
            title = "Edit profile", "Body here")
#> <div class="shad-dialog" data-shad="dialog" id="edit">
#>   <button class="shad-btn shad-btn--default shad-dialog__trigger" type="button">Edit</button>
#>   <div class="shad-dialog__overlay shad-anim-overlay" hidden></div>
#>   <div class="shad-dialog__content shad-anim-dialog" hidden>
#>     <button type="button" class="shad-dialog__close" data-shad-dialog-close aria-label="Close"><svg class="shad-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M18 6 6 18"/><path d="m6 6 12 12"/></svg></button>
#>     <div class="shad-dialog__header">
#>       <div class="shad-dialog__title">Edit profile</div>
#>     </div>
#>     Body here
#>   </div>
#> </div>
```

# Alert dialog (confirmation)

A non-dismissible confirmation dialog. The confirm button carries the
derived id `<inputId>_confirm` (a Shiny action button), so observe
confirmations with `input$<inputId>_confirm`. `input$<inputId>` is the
open state.

## Usage

``` r
shad_alert_dialog(
  inputId,
  ...,
  title,
  description = NULL,
  cancel = "Cancel",
  action = "Continue",
  action_variant = "default",
  trigger = NULL,
  class = NULL
)
```

## Arguments

- inputId:

  Input id.

- ...:

  Extra body content (between description and footer).

- title:

  Dialog title (required).

- description:

  Supporting text.

- cancel:

  Cancel-button label (closes only).

- action:

  Confirm-button label.

- action_variant:

  Confirm-button
  [`shad_button()`](https://orijitghosh.github.io/shadshiny/reference/shad_button.md)
  variant.

- trigger:

  Optional tag whose click opens the dialog.

- class:

  Extra CSS classes.

## Value

An alert-dialog tag.

## See also

Other shadshiny tier-3 components:
[`shad_accordion()`](https://orijitghosh.github.io/shadshiny/reference/shad_accordion.md),
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
[`shad_sidebar_layout()`](https://orijitghosh.github.io/shadshiny/reference/shad_sidebar_layout.md),
[`shad_tabs()`](https://orijitghosh.github.io/shadshiny/reference/shad_tabs.md),
[`shad_tooltip()`](https://orijitghosh.github.io/shadshiny/reference/shad_tooltip.md)

## Examples

``` r
shad_alert_dialog("del", title = "Are you sure?",
                  description = "This cannot be undone.",
                  action = "Delete", action_variant = "destructive")
#> <div class="shad-dialog" data-shad="alert-dialog" id="del">
#>   <div class="shad-dialog__overlay shad-anim-overlay" hidden></div>
#>   <div class="shad-dialog__content shad-anim-dialog" hidden>
#>     <div class="shad-dialog__header">
#>       <div class="shad-dialog__title">Are you sure?</div>
#>       <div class="shad-dialog__description">This cannot be undone.</div>
#>     </div>
#>     <div class="shad-dialog__footer">
#>       <button type="button" class="shad-btn shad-btn--outline" data-shad-dialog-close data-shad-autofocus>Cancel</button>
#>       <button type="button" class="shad-btn shad-btn--destructive action-button" id="del_confirm" data-shad-dialog-close>Delete</button>
#>     </div>
#>   </div>
#> </div>
```

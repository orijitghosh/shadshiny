# Update bound component values from the server

Each function sets the current value of a bound shadshiny input,
mirroring Shiny's built-in `update*Input()` helpers. Changing the
available *choices* of a component is a non-goal — re-render with
[`shiny::renderUI()`](https://rdrr.io/pkg/shiny/man/renderUI.html)
instead.

## Usage

``` r
update_shad_checkbox(id, value, session = shiny::getDefaultReactiveDomain())

update_shad_radio_group(
  id,
  selected,
  session = shiny::getDefaultReactiveDomain()
)

update_shad_switch(id, value, session = shiny::getDefaultReactiveDomain())

update_shad_slider(id, value, session = shiny::getDefaultReactiveDomain())

update_shad_toggle(id, value, session = shiny::getDefaultReactiveDomain())

update_shad_toggle_group(
  id,
  selected,
  session = shiny::getDefaultReactiveDomain()
)

update_shad_select(id, selected, session = shiny::getDefaultReactiveDomain())

update_shad_combobox(
  id,
  selected,
  multiple = FALSE,
  session = shiny::getDefaultReactiveDomain()
)

update_shad_input_otp(id, value, session = shiny::getDefaultReactiveDomain())

update_shad_native_select(
  id,
  selected,
  session = shiny::getDefaultReactiveDomain()
)

update_shad_calendar(id, value, session = shiny::getDefaultReactiveDomain())

update_shad_date_picker(id, value, session = shiny::getDefaultReactiveDomain())

update_shad_tabs(id, selected, session = shiny::getDefaultReactiveDomain())

update_shad_accordion(id, value, session = shiny::getDefaultReactiveDomain())

update_shad_pagination(
  id,
  selected,
  session = shiny::getDefaultReactiveDomain()
)

update_shad_carousel(id, selected, session = shiny::getDefaultReactiveDomain())

update_shad_sidebar(
  id,
  collapsed = NULL,
  mobile_open = NULL,
  active = NULL,
  session = shiny::getDefaultReactiveDomain()
)

update_shad_progress(
  id,
  value,
  max = 100,
  session = shiny::getDefaultReactiveDomain()
)

update_shad_button(
  id,
  loading = NULL,
  disabled = NULL,
  label = NULL,
  session = shiny::getDefaultReactiveDomain()
)
```

## Arguments

- id:

  The input id (namespaced automatically).

- value, selected:

  The new value. See each component's UI constructor for its value
  contract.

- session:

  The Shiny session.

- multiple:

  For `update_shad_combobox()`, whether the combobox is in multiple mode
  (forces an array even for a single value).

- collapsed, mobile_open, active:

  For `update_shad_sidebar()`; `NULL` leaves that facet unchanged.
  `active` selects the
  [`shad_sidebar_item()`](https://orijitghosh.github.io/shadshiny/reference/shad_sidebar_layout.md)
  with that value, so navigating from elsewhere (a command palette, a
  link) moves the rail too.

- max:

  For `update_shad_progress()`, the maximum value.

- loading, disabled, label:

  For `update_shad_button()`; `NULL` leaves that facet unchanged.

## Value

Invisibly `NULL`; called for its side effect.

## See also

Other shadshiny server API:
[`shad_message_scroller_to_bottom()`](https://orijitghosh.github.io/shadshiny/reference/shad_message_scroller_to_bottom.md),
[`shad_overlay_server`](https://orijitghosh.github.io/shadshiny/reference/shad_overlay_server.md),
[`shad_remove_dialog()`](https://orijitghosh.github.io/shadshiny/reference/shad_remove_dialog.md),
[`shad_show_dialog()`](https://orijitghosh.github.io/shadshiny/reference/shad_show_dialog.md),
[`shad_toast()`](https://orijitghosh.github.io/shadshiny/reference/shad_toast.md),
[`update_shad_command()`](https://orijitghosh.github.io/shadshiny/reference/update_shad_command.md)

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

update_shad_collapsible(id, open, session = shiny::getDefaultReactiveDomain())

update_shad_resizable(id, sizes, session = shiny::getDefaultReactiveDomain())

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

- open:

  For `update_shad_collapsible()`, the logical open state.

- sizes:

  For `update_shad_resizable()`, the non-negative panel sizes.

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

## Details

`update_shad_select()` and `update_shad_combobox()` match `selected`
against the choices as strings, and `NULL` clears the input. A value
that is not one of the choices is ignored and the browser console says
so; in multiple mode only the unknown entries are dropped.

`update_shad_calendar()` and `update_shad_date_picker()` take a `Date`
or an ISO `"YYYY-MM-DD"` string. A length-2 value sets a range and is
put in order; `NULL` or `NA` clears. A date outside the component's
`min` / `max` is ignored and the browser console says so; a range with
one such end is ignored whole. A date picker never opens, closes or
takes focus because of a server value.

## See also

Other shadshiny server API:
[`bind_shad_task_button()`](https://orijitghosh.github.io/shadshiny/reference/bind_shad_task_button.md),
[`shad_message_scroller_to_bottom()`](https://orijitghosh.github.io/shadshiny/reference/shad_message_scroller_to_bottom.md),
[`shad_overlay_server`](https://orijitghosh.github.io/shadshiny/reference/shad_overlay_server.md),
[`shad_remove_dialog()`](https://orijitghosh.github.io/shadshiny/reference/shad_remove_dialog.md),
[`shad_show_dialog()`](https://orijitghosh.github.io/shadshiny/reference/shad_show_dialog.md),
[`shad_toast()`](https://orijitghosh.github.io/shadshiny/reference/shad_toast.md),
[`update_shad_command()`](https://orijitghosh.github.io/shadshiny/reference/update_shad_command.md)

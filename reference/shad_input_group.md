# Input group

A bordered shell that wraps a
[`shad_input()`](https://orijitghosh.github.io/shadshiny/reference/shad_input.md)
or
[`shad_textarea()`](https://orijitghosh.github.io/shadshiny/reference/shad_textarea.md)
together with leading/trailing addons (icons, prefixes, buttons) or
block toolbars. The shell owns the border, shadow, and focus/invalid
ring; the wrapped control drops its own chrome so the group reads as one
field. The control keeps its native Shiny binding — read it with
`input$<inputId>` as usual.

## Usage

``` r
shad_input_group(..., block = FALSE, invalid = FALSE, class = NULL)

shad_input_group_addon(
  ...,
  align = c("inline-start", "inline-end", "block-start", "block-end"),
  class = NULL
)

shad_input_group_text(..., class = NULL)

shad_input_group_button(label = NULL, ..., variant = "ghost", class = NULL)
```

## Arguments

- ...:

  Addons (`shad_input_group_addon()`) and the wrapped control, in render
  order, and/or named HTML attributes.

- block:

  If `TRUE`, stretch to full width (default is content width).

- invalid:

  If `TRUE`, paint the destructive border/ring (mirror the wrapped
  control's `invalid`).

- class:

  Extra CSS classes.

- align:

  Addon placement: `"inline-start"`, `"inline-end"`, `"block-start"`, or
  `"block-end"`. Block addons take their own full-width row (toolbar
  strips).

- label:

  Button label (first positional, for convenience).

- variant:

  Button variant (defaults to `"ghost"` to sit quietly in the field).

## Value

An input-group tag.

## See also

[`shad_input()`](https://orijitghosh.github.io/shadshiny/reference/shad_input.md),
[`shad_textarea()`](https://orijitghosh.github.io/shadshiny/reference/shad_textarea.md),
`shad_input_group_addon()`

Other shadshiny tier-2 components:
[`shad_calendar()`](https://orijitghosh.github.io/shadshiny/reference/shad_calendar.md),
[`shad_checkbox()`](https://orijitghosh.github.io/shadshiny/reference/shad_checkbox.md),
[`shad_combobox()`](https://orijitghosh.github.io/shadshiny/reference/shad_combobox.md),
[`shad_date_picker()`](https://orijitghosh.github.io/shadshiny/reference/shad_date_picker.md),
[`shad_form_field()`](https://orijitghosh.github.io/shadshiny/reference/shad_form_field.md),
[`shad_input()`](https://orijitghosh.github.io/shadshiny/reference/shad_input.md),
[`shad_input_otp()`](https://orijitghosh.github.io/shadshiny/reference/shad_input_otp.md),
[`shad_native_select()`](https://orijitghosh.github.io/shadshiny/reference/shad_native_select.md),
[`shad_radio_group()`](https://orijitghosh.github.io/shadshiny/reference/shad_radio_group.md),
[`shad_select()`](https://orijitghosh.github.io/shadshiny/reference/shad_select.md),
[`shad_slider()`](https://orijitghosh.github.io/shadshiny/reference/shad_slider.md),
[`shad_switch()`](https://orijitghosh.github.io/shadshiny/reference/shad_switch.md),
[`shad_textarea()`](https://orijitghosh.github.io/shadshiny/reference/shad_textarea.md),
[`shad_toggle()`](https://orijitghosh.github.io/shadshiny/reference/shad_toggle.md),
[`shad_toggle_group()`](https://orijitghosh.github.io/shadshiny/reference/shad_toggle_group.md)

## Examples

``` r
shad_input_group(
  shad_input_group_addon(shad_icon("search"), align = "inline-start"),
  shad_input("q", placeholder = "Search..."),
  block = TRUE
)
#> <div class="shad-input-group shad-input-group--block" role="group">
#>   <span class="shad-input-group__addon" data-align="inline-start"><svg class="shad-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="11" cy="11" r="8"/><path d="m21 21-4.3-4.3"/></svg></span>
#>   <input id="q" class="shad-input" type="text" placeholder="Search..."/>
#> </div>
```

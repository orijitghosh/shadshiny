# Native select

A styled native HTML `<select>`. Unlike
[`shad_select()`](https://orijitghosh.github.io/shadshiny/reference/shad_select.md)
(a custom listbox), this keeps full browser-native behaviour – mobile
pickers, form participation, typeahead – and only bridges the value to
Shiny. `input$<inputId>` is the selected option value (a string).

## Usage

``` r
shad_native_select(
  inputId,
  choices,
  selected = NULL,
  size = NULL,
  disabled = FALSE,
  invalid = FALSE,
  width = NULL,
  label = NULL,
  class = NULL,
  ...
)
```

## Arguments

- inputId:

  Input id.

- choices:

  A named/unnamed vector for flat options, or a named list of vectors to
  build `<optgroup>`s (names become group labels).

- selected:

  Initially selected value.

- size:

  One of `NULL` (default), `"sm"`, `"lg"`.

- disabled:

  If `TRUE`, disables the control.

- invalid:

  If `TRUE`, sets `aria-invalid` (destructive styling).

- width:

  CSS width.

- label:

  Accessible label applied as `aria-label` on the `<select>`.

- class:

  Extra CSS classes on the root.

- ...:

  Extra attributes on the root `<div>`.

## Value

A native-select tag.

## See also

[`update_shad_native_select()`](https://orijitghosh.github.io/shadshiny/reference/update_shad.md)

Other shadshiny tier-2 components:
[`shad_calendar()`](https://orijitghosh.github.io/shadshiny/reference/shad_calendar.md),
[`shad_checkbox()`](https://orijitghosh.github.io/shadshiny/reference/shad_checkbox.md),
[`shad_combobox()`](https://orijitghosh.github.io/shadshiny/reference/shad_combobox.md),
[`shad_date_picker()`](https://orijitghosh.github.io/shadshiny/reference/shad_date_picker.md),
[`shad_date_presets()`](https://orijitghosh.github.io/shadshiny/reference/shad_date_presets.md),
[`shad_form_field()`](https://orijitghosh.github.io/shadshiny/reference/shad_form_field.md),
[`shad_input()`](https://orijitghosh.github.io/shadshiny/reference/shad_input.md),
[`shad_input_group()`](https://orijitghosh.github.io/shadshiny/reference/shad_input_group.md),
[`shad_input_otp()`](https://orijitghosh.github.io/shadshiny/reference/shad_input_otp.md),
[`shad_radio_group()`](https://orijitghosh.github.io/shadshiny/reference/shad_radio_group.md),
[`shad_select()`](https://orijitghosh.github.io/shadshiny/reference/shad_select.md),
[`shad_slider()`](https://orijitghosh.github.io/shadshiny/reference/shad_slider.md),
[`shad_switch()`](https://orijitghosh.github.io/shadshiny/reference/shad_switch.md),
[`shad_textarea()`](https://orijitghosh.github.io/shadshiny/reference/shad_textarea.md),
[`shad_toggle()`](https://orijitghosh.github.io/shadshiny/reference/shad_toggle.md),
[`shad_toggle_group()`](https://orijitghosh.github.io/shadshiny/reference/shad_toggle_group.md)

## Examples

``` r
shad_native_select("tz", choices = list(
  Americas = c("America/New_York", "America/Sao_Paulo"),
  Europe   = c("Europe/London", "Europe/Berlin")
))
#> <div class="shad-native-select" data-shad="native-select" id="tz">
#>   <select class="shad-native-select__select">
#>     <optgroup label="Americas">
#>       <option value="America/New_York">America/New_York</option>
#>       <option value="America/Sao_Paulo">America/Sao_Paulo</option>
#>     </optgroup>
#>     <optgroup label="Europe">
#>       <option value="Europe/London">Europe/London</option>
#>       <option value="Europe/Berlin">Europe/Berlin</option>
#>     </optgroup>
#>   </select>
#>   <svg class="shad-icon shad-native-select__chevron" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m6 9 6 6 6-6"/></svg>
#> </div>
```

# Calendar

A shadcn calendar. The month grid is rendered client-side from the seed
attributes. `input$<inputId>` is a `Date` (single) or length-2 `Date`
(range), via the `shadshiny.date` input handler.

## Usage

``` r
shad_calendar(
  inputId,
  value = NULL,
  mode = c("single", "range"),
  min = NULL,
  max = NULL,
  month = NULL,
  caption_layout = c("label", "dropdown", "dropdown-months", "dropdown-years"),
  year_range = NULL,
  week_starts_on = 0,
  disabled = FALSE,
  class = NULL,
  ...
)
```

## Arguments

- inputId:

  Input id.

- value:

  Initial selection: a `Date`/character (single) or length-2
  `Date`/character (range).

- mode:

  `"single"` (default) or `"range"`.

- min, max:

  Selectable bounds (inclusive), `Date`/character.

- month:

  Initially displayed month (`Date` or `"YYYY-MM"`). Sets the month the
  grid opens on without selecting anything.

- caption_layout:

  Header style: `"label"` (default, month and year as text),
  `"dropdown"` (both as selects), `"dropdown-months"` or
  `"dropdown-years"`. Use a dropdown when the user has to travel years,
  such as a date of birth.

- year_range:

  Length-2 numeric bounding the year dropdown, e.g. `c(1900, 2025)`.
  Defaults to the years of `min`/`max` when given, otherwise 100 years
  back and 10 forward.

- week_starts_on:

  `0` (Sunday, default) or `1` (Monday).

- disabled:

  If `TRUE`, disables the control.

- class:

  Extra CSS classes.

- ...:

  Extra attributes on the calendar root.

## Value

A calendar tag.

## See also

Other shadshiny tier-2 components:
[`shad_checkbox()`](https://orijitghosh.github.io/shadshiny/reference/shad_checkbox.md),
[`shad_combobox()`](https://orijitghosh.github.io/shadshiny/reference/shad_combobox.md),
[`shad_date_picker()`](https://orijitghosh.github.io/shadshiny/reference/shad_date_picker.md),
[`shad_date_presets()`](https://orijitghosh.github.io/shadshiny/reference/shad_date_presets.md),
[`shad_form_field()`](https://orijitghosh.github.io/shadshiny/reference/shad_form_field.md),
[`shad_input()`](https://orijitghosh.github.io/shadshiny/reference/shad_input.md),
[`shad_input_group()`](https://orijitghosh.github.io/shadshiny/reference/shad_input_group.md),
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
shad_calendar("day", value = Sys.Date())
#> <div class="shad-calendar" data-shad="calendar" id="day" data-mode="single" data-value="2026-11-08" data-week-start="0"></div>
shad_calendar("range", mode = "range", week_starts_on = 1)
#> <div class="shad-calendar" data-shad="calendar" id="range" data-mode="range" data-week-start="1"></div>
shad_calendar("dob", caption_layout = "dropdown", year_range = c(1900, 2025))
#> <div class="shad-calendar" data-shad="calendar" id="dob" data-mode="single" data-week-start="0" data-caption-layout="dropdown" data-from-year="1900" data-to-year="2025"></div>
```

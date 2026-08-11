# Date picker

A shadcn date picker: a trigger button that opens a
[`shad_calendar()`](https://orijitghosh.github.io/shadshiny/reference/shad_calendar.md)
in a popover. Value contract is identical to
[`shad_calendar()`](https://orijitghosh.github.io/shadshiny/reference/shad_calendar.md).

## Usage

``` r
shad_date_picker(
  inputId,
  label = NULL,
  value = NULL,
  mode = c("single", "range"),
  placeholder = "Pick a date",
  min = NULL,
  max = NULL,
  presets = NULL,
  caption_layout = c("label", "dropdown", "dropdown-months", "dropdown-years"),
  year_range = NULL,
  disabled = FALSE,
  width = NULL,
  class = NULL,
  ...
)
```

## Arguments

- inputId:

  Input id.

- label:

  Optional label (wraps in
  [`shad_form_field()`](https://orijitghosh.github.io/shadshiny/reference/shad_form_field.md)).

- value:

  Initial selection: a `Date`/character (single) or length-2
  `Date`/character (range).

- mode:

  `"single"` (default) or `"range"`.

- placeholder:

  Trigger text shown when nothing is selected.

- min, max:

  Selectable bounds (inclusive), `Date`/character.

- presets:

  Optional quick-range rail, only valid with `mode = "range"`. A named
  list; names are the button labels and each value is either a keyword
  (`"today"`, `"yesterday"`, `"this-week"`, `"this-month"`,
  `"last-month"`, `"this-year"`), an integer `N` meaning the last `N`
  days, or a length-2 `Date` vector giving an explicit start and end.
  [`shad_date_presets()`](https://orijitghosh.github.io/shadshiny/reference/shad_date_presets.md)
  returns a ready-made set.

- caption_layout:

  Header style: `"label"` (default, month and year as text),
  `"dropdown"` (both as selects), `"dropdown-months"` or
  `"dropdown-years"`. Use a dropdown when the user has to travel years,
  such as a date of birth.

- year_range:

  Length-2 numeric bounding the year dropdown, e.g. `c(1900, 2025)`.
  Defaults to the years of `min`/`max` when given, otherwise 100 years
  back and 10 forward.

- disabled:

  If `TRUE`, disables the control.

- width:

  CSS width.

- class:

  Extra CSS classes.

- ...:

  Extra attributes on the calendar root.

## Value

A date-picker tag.

## See also

Other shadshiny tier-2 components:
[`shad_calendar()`](https://orijitghosh.github.io/shadshiny/reference/shad_calendar.md),
[`shad_checkbox()`](https://orijitghosh.github.io/shadshiny/reference/shad_checkbox.md),
[`shad_combobox()`](https://orijitghosh.github.io/shadshiny/reference/shad_combobox.md),
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
shad_date_picker("d", label = "Date")
#> <div class="shad-form-field" data-shad="form-field">
#>   <label class="shad-label">Date</label>
#>   <div class="shad-date-picker" data-shad="date-picker" id="d">
#>     <button type="button" class="shad-date-picker__trigger" data-placeholder>
#>       <svg class="shad-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M8 2v4"/><path d="M16 2v4"/><rect width="18" height="18" x="3" y="4" rx="2"/><path d="M3 10h18"/></svg>
#>       <span class="shad-date-picker__value">Pick a date</span>
#>     </button>
#>     <div class="shad-date-picker__content shad-anim-pop" hidden>
#>       <div class="shad-calendar" data-shad="calendar" data-mode="single" data-week-start="0"></div>
#>     </div>
#>   </div>
#>   <p class="shad-form-field__error" hidden></p>
#> </div>
shad_date_picker("range", mode = "range")
#> <div class="shad-date-picker" data-shad="date-picker" id="range">
#>   <button type="button" class="shad-date-picker__trigger" data-placeholder>
#>     <svg class="shad-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M8 2v4"/><path d="M16 2v4"/><rect width="18" height="18" x="3" y="4" rx="2"/><path d="M3 10h18"/></svg>
#>     <span class="shad-date-picker__value">Pick a date</span>
#>   </button>
#>   <div class="shad-date-picker__content shad-anim-pop" hidden>
#>     <div class="shad-calendar" data-shad="calendar" data-mode="range" data-week-start="1"></div>
#>   </div>
#> </div>
shad_date_picker("dob", label = "Date of birth", caption_layout = "dropdown")
#> <div class="shad-form-field" data-shad="form-field">
#>   <label class="shad-label">Date of birth</label>
#>   <div class="shad-date-picker" data-shad="date-picker" id="dob">
#>     <button type="button" class="shad-date-picker__trigger" data-placeholder>
#>       <svg class="shad-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M8 2v4"/><path d="M16 2v4"/><rect width="18" height="18" x="3" y="4" rx="2"/><path d="M3 10h18"/></svg>
#>       <span class="shad-date-picker__value">Pick a date</span>
#>     </button>
#>     <div class="shad-date-picker__content shad-anim-pop" hidden>
#>       <div class="shad-calendar" data-shad="calendar" data-mode="single" data-week-start="0" data-caption-layout="dropdown"></div>
#>     </div>
#>   </div>
#>   <p class="shad-form-field__error" hidden></p>
#> </div>
```

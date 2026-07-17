# One-time-code input

A shadcn OTP input: one real hidden input overlays a row of rendered
cells. `input$<inputId>` is the string as typed (may be partial).

## Usage

``` r
shad_input_otp(
  inputId,
  length = 6,
  groups = NULL,
  label = NULL,
  value = NULL,
  pattern = c("numeric", "alphanumeric"),
  disabled = FALSE,
  class = NULL,
  ...
)
```

## Arguments

- inputId:

  Input id.

- length:

  Total number of cells / code length.

- groups:

  Optional integer vector splitting cells into groups separated by a
  divider (e.g. `c(3, 3)`). Must sum to `length`.

- label:

  Optional label (wraps in
  [`shad_form_field()`](https://orijitghosh.github.io/shadshiny/reference/shad_form_field.md)).

- value:

  Optional initial code (also restored on bookmark reload).

- pattern:

  `"numeric"` (digits only) or `"alphanumeric"` (any character).

- disabled:

  If `TRUE`, disables the control.

- class:

  Extra CSS classes.

- ...:

  Extra attributes on the OTP root.

## Value

An OTP input tag.

## See also

Other shadshiny tier-2 components:
[`shad_calendar()`](https://orijitghosh.github.io/shadshiny/reference/shad_calendar.md),
[`shad_checkbox()`](https://orijitghosh.github.io/shadshiny/reference/shad_checkbox.md),
[`shad_combobox()`](https://orijitghosh.github.io/shadshiny/reference/shad_combobox.md),
[`shad_date_picker()`](https://orijitghosh.github.io/shadshiny/reference/shad_date_picker.md),
[`shad_date_presets()`](https://orijitghosh.github.io/shadshiny/reference/shad_date_presets.md),
[`shad_form_field()`](https://orijitghosh.github.io/shadshiny/reference/shad_form_field.md),
[`shad_input()`](https://orijitghosh.github.io/shadshiny/reference/shad_input.md),
[`shad_input_group()`](https://orijitghosh.github.io/shadshiny/reference/shad_input_group.md),
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
shad_input_otp("code", length = 6, groups = c(3, 3))
#> <div class="shad-otp" data-shad="input-otp" id="code" data-length="6" data-pattern="\d">
#>   <input class="shad-otp__input" type="text" inputmode="numeric" autocomplete="one-time-code" aria-label="One-time code"/>
#>   <div class="shad-otp__group">
#>     <div class="shad-otp__cell" aria-hidden="true"></div>
#>     <div class="shad-otp__cell" aria-hidden="true"></div>
#>     <div class="shad-otp__cell" aria-hidden="true"></div>
#>   </div>
#>   <div class="shad-otp__separator" aria-hidden="true"><svg class="shad-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M5 12h14"/></svg></div>
#>   <div class="shad-otp__group">
#>     <div class="shad-otp__cell" aria-hidden="true"></div>
#>     <div class="shad-otp__cell" aria-hidden="true"></div>
#>     <div class="shad-otp__cell" aria-hidden="true"></div>
#>   </div>
#> </div>
```

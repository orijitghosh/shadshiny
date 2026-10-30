# Checkbox

A shadcn checkbox. `input$<inputId>` is `TRUE`, `FALSE`, or
`"indeterminate"`.

## Usage

``` r
shad_checkbox(
  inputId,
  label = NULL,
  value = FALSE,
  indeterminate = FALSE,
  disabled = FALSE,
  description = NULL,
  class = NULL,
  tristate = FALSE,
  ...
)
```

## Arguments

- inputId:

  Input id.

- label:

  Optional label shown next to the box.

- value:

  Initial value: `TRUE`, `FALSE`, or `"indeterminate"`.

- indeterminate:

  If `TRUE`, seeds the indeterminate (mixed) state.

- disabled:

  If `TRUE`, disables the control.

- description:

  Optional help text below the row.

- class:

  Extra CSS classes.

- tristate:

  If `TRUE`, clicks cycle unchecked, checked, indeterminate, then back
  to unchecked. A shadshiny addition; shadcn/ui has no equivalent.

- ...:

  Extra attributes on the checkbox button.

## Value

A checkbox row tag.

## Details

By default clicks follow shadcn/ui (Radix): an indeterminate box becomes
checked, and from then on clicks only toggle checked and unchecked. Only
the server can set it back with
`update_shad_checkbox(id, "indeterminate")`, which suits a "select all"
box whose state comes from other inputs. Set `tristate = TRUE` to let
the user click through all three states instead.

## See also

Other shadshiny tier-2 components:
[`shad_calendar()`](https://orijitghosh.github.io/shadshiny/reference/shad_calendar.md),
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
shad_checkbox("terms", "Accept terms and conditions")
#> <div class="shad-checkbox-row">
#>   <button type="button" class="shad-checkbox" data-shad="checkbox" data-state="unchecked" id="terms" aria-labelledby="terms-label"><svg class="shad-checkbox__indicator shad-checkbox__indicator--check" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path pathLength="1" d="M20 6 9 17l-5-5"/></svg><svg class="shad-checkbox__indicator shad-checkbox__indicator--minus" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" aria-hidden="true"><path d="M5 12h14"/></svg></button>
#>   <label class="shad-label" id="terms-label" for="terms">Accept terms and conditions</label>
#> </div>
shad_checkbox("all", "Select all", indeterminate = TRUE)
#> <div class="shad-checkbox-row">
#>   <button type="button" class="shad-checkbox" data-shad="checkbox" data-state="indeterminate" id="all" aria-labelledby="all-label"><svg class="shad-checkbox__indicator shad-checkbox__indicator--check" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path pathLength="1" d="M20 6 9 17l-5-5"/></svg><svg class="shad-checkbox__indicator shad-checkbox__indicator--minus" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" aria-hidden="true"><path d="M5 12h14"/></svg></button>
#>   <label class="shad-label" id="all-label" for="all">Select all</label>
#> </div>
shad_checkbox("filter", "Include archived", tristate = TRUE)
#> <div class="shad-checkbox-row">
#>   <button type="button" class="shad-checkbox" data-shad="checkbox" data-state="unchecked" id="filter" aria-labelledby="filter-label" data-tristate><svg class="shad-checkbox__indicator shad-checkbox__indicator--check" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path pathLength="1" d="M20 6 9 17l-5-5"/></svg><svg class="shad-checkbox__indicator shad-checkbox__indicator--minus" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" aria-hidden="true"><path d="M5 12h14"/></svg></button>
#>   <label class="shad-label" id="filter-label" for="filter">Include archived</label>
#> </div>
```

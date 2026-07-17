# Default date-range presets

A ready-made set of range presets for
[`shad_date_picker()`](https://orijitghosh.github.io/shadshiny/reference/shad_date_picker.md)'s
`presets` argument: Today, Yesterday, Last 7 days, Last 30 days, This
month, Last month.

## Usage

``` r
shad_date_presets()
```

## Value

A named list suitable for `shad_date_picker(presets=)`.

## See also

Other shadshiny tier-2 components:
[`shad_calendar()`](https://orijitghosh.github.io/shadshiny/reference/shad_calendar.md),
[`shad_checkbox()`](https://orijitghosh.github.io/shadshiny/reference/shad_checkbox.md),
[`shad_combobox()`](https://orijitghosh.github.io/shadshiny/reference/shad_combobox.md),
[`shad_date_picker()`](https://orijitghosh.github.io/shadshiny/reference/shad_date_picker.md),
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
shad_date_picker("range", mode = "range", presets = shad_date_presets())
#> <div class="shad-date-picker" data-shad="date-picker" id="range">
#>   <button type="button" class="shad-date-picker__trigger" data-placeholder>
#>     <svg class="shad-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M8 2v4"/><path d="M16 2v4"/><rect width="18" height="18" x="3" y="4" rx="2"/><path d="M3 10h18"/></svg>
#>     <span class="shad-date-picker__value">Pick a date</span>
#>   </button>
#>   <div class="shad-date-picker__content shad-anim-pop" hidden>
#>     <div class="shad-date-range-presets" data-shad="date-range-presets" role="group" aria-label="Quick ranges">
#>       <button type="button" class="shad-date-range-presets__item" data-preset="today">Today</button>
#>       <button type="button" class="shad-date-range-presets__item" data-preset="yesterday">Yesterday</button>
#>       <button type="button" class="shad-date-range-presets__item" data-days="7">Last 7 days</button>
#>       <button type="button" class="shad-date-range-presets__item" data-days="30">Last 30 days</button>
#>       <button type="button" class="shad-date-range-presets__item" data-preset="this-month">This month</button>
#>       <button type="button" class="shad-date-range-presets__item" data-preset="last-month">Last month</button>
#>     </div>
#>     <div class="shad-calendar" data-shad="calendar" data-mode="range" data-week-start="1"></div>
#>   </div>
#> </div>
```

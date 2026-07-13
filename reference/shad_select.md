# Select

A shadcn select (listbox popup). `input$<inputId>` is the selected value
or `NULL`.

## Usage

``` r
shad_select(
  inputId,
  label = NULL,
  choices,
  selected = NULL,
  placeholder = "Select2026",
  disabled = FALSE,
  width = NULL,
  description = NULL,
  class = NULL,
  ...
)

shad_select_item(value, label = NULL, disabled = FALSE)

shad_select_group(label, ...)

shad_select_separator()
```

## Arguments

- inputId:

  Input id.

- label:

  Optional label (wraps in
  [`shad_form_field()`](https://orijitghosh.github.io/shadshiny/reference/shad_form_field.md)).

- choices:

  A named/unnamed vector, or a list mixing `shad_select_item()`,
  `shad_select_group()`, and `shad_select_separator()`.

- selected:

  Initially selected value.

- placeholder:

  Trigger placeholder text.

- disabled:

  If `TRUE`, disables the control.

- width:

  CSS width.

- description:

  Optional help text (wraps in
  [`shad_form_field()`](https://orijitghosh.github.io/shadshiny/reference/shad_form_field.md)).

- class:

  Extra CSS classes.

- ...:

  For `shad_select_group()`, the group's items.

- value:

  The item's value.

## Value

A select tag.

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
[`shad_slider()`](https://orijitghosh.github.io/shadshiny/reference/shad_slider.md),
[`shad_switch()`](https://orijitghosh.github.io/shadshiny/reference/shad_switch.md),
[`shad_textarea()`](https://orijitghosh.github.io/shadshiny/reference/shad_textarea.md),
[`shad_toggle()`](https://orijitghosh.github.io/shadshiny/reference/shad_toggle.md),
[`shad_toggle_group()`](https://orijitghosh.github.io/shadshiny/reference/shad_toggle_group.md)

## Examples

``` r
shad_select("fruit", choices = c("Apple" = "apple", "Banana" = "banana"),
            selected = "banana")
#> <div class="shad-select" data-shad="select" id="fruit">
#>   <button type="button" class="shad-select__trigger">
#>     <span class="shad-select__value">Banana</span>
#>     <svg class="shad-select__chevron" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m6 9 6 6 6-6"/></svg>
#>   </button>
#>   <div class="shad-select__content shad-anim-pop" hidden>
#>     <button type="button" class="shad-select__scroll-btn" data-dir="up" hidden tabindex="-1" aria-hidden="true"><svg class="shad-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="m18 15-6-6-6 6"/></svg></button>
#>     <div class="shad-select__viewport">
#>       <div class="shad-select__item" role="option" data-value="apple" data-state="unchecked">
#>         <svg class="shad-select__item-check" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M20 6 9 17l-5-5"/></svg>
#>         Apple
#>       </div>
#>       <div class="shad-select__item" role="option" data-value="banana" data-state="checked">
#>         <svg class="shad-select__item-check" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M20 6 9 17l-5-5"/></svg>
#>         Banana
#>       </div>
#>     </div>
#>     <button type="button" class="shad-select__scroll-btn" data-dir="down" hidden tabindex="-1" aria-hidden="true"><svg class="shad-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="m6 9 6 6 6-6"/></svg></button>
#>   </div>
#> </div>
```

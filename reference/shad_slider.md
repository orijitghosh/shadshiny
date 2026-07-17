# Slider

A shadcn slider. A length-1 `value` renders a single thumb (numeric
`input$<inputId>`); a length-2 `value` renders a range (numeric
length-2). The binding debounces at 250 ms.

## Usage

``` r
shad_slider(
  inputId,
  label = NULL,
  min = 0,
  max = 100,
  value = min,
  step = 1,
  marks = NULL,
  orientation = c("horizontal", "vertical"),
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

- min, max, step:

  Numeric domain (defaults 0 / 100 / 1).

- value:

  Initial value: length 1 (single) or length 2 (range).

- marks:

  Optional numeric vector of tick positions. If named
  (`c("Low" = 0, "High" = 100)`), tick labels are shown.

- orientation:

  `"horizontal"` (default) or `"vertical"`.

- disabled:

  If `TRUE`, disables the control.

- width:

  CSS width.

- class:

  Extra CSS classes.

- ...:

  Extra attributes on the slider root.

## Value

A slider tag.

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
[`shad_input_otp()`](https://orijitghosh.github.io/shadshiny/reference/shad_input_otp.md),
[`shad_native_select()`](https://orijitghosh.github.io/shadshiny/reference/shad_native_select.md),
[`shad_radio_group()`](https://orijitghosh.github.io/shadshiny/reference/shad_radio_group.md),
[`shad_select()`](https://orijitghosh.github.io/shadshiny/reference/shad_select.md),
[`shad_switch()`](https://orijitghosh.github.io/shadshiny/reference/shad_switch.md),
[`shad_textarea()`](https://orijitghosh.github.io/shadshiny/reference/shad_textarea.md),
[`shad_toggle()`](https://orijitghosh.github.io/shadshiny/reference/shad_toggle.md),
[`shad_toggle_group()`](https://orijitghosh.github.io/shadshiny/reference/shad_toggle_group.md)

## Examples

``` r
shad_slider("volume", value = 50)
#> <div class="shad-slider" data-shad="slider" id="volume" data-min="0" data-max="100" data-step="1" data-value="50">
#>   <div class="shad-slider__track">
#>     <div class="shad-slider__range"></div>
#>   </div>
#>   <div class="shad-slider__thumb" role="slider" tabindex="0" aria-label="Value"></div>
#> </div>
shad_slider("price", min = 0, max = 100, value = c(25, 75), step = 5)
#> <div class="shad-slider" data-shad="slider" id="price" data-min="0" data-max="100" data-step="5" data-value="25" data-value2="75">
#>   <div class="shad-slider__track">
#>     <div class="shad-slider__range"></div>
#>   </div>
#>   <div class="shad-slider__thumb" role="slider" tabindex="0" aria-label="Minimum"></div>
#>   <div class="shad-slider__thumb" role="slider" tabindex="0" aria-label="Maximum"></div>
#> </div>
```

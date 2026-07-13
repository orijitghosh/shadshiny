# Switch

A shadcn switch (toggle). `input$<inputId>` is a logical.

## Usage

``` r
shad_switch(
  inputId,
  label = NULL,
  value = FALSE,
  disabled = FALSE,
  description = NULL,
  class = NULL,
  ...
)
```

## Arguments

- inputId:

  Input id.

- label:

  Optional label shown next to the switch.

- value:

  Initial logical value.

- disabled:

  If `TRUE`, disables the control.

- description:

  Optional help text below the row.

- class:

  Extra CSS classes.

- ...:

  Extra attributes on the switch button.

## Value

A switch row tag.

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
[`shad_textarea()`](https://orijitghosh.github.io/shadshiny/reference/shad_textarea.md),
[`shad_toggle()`](https://orijitghosh.github.io/shadshiny/reference/shad_toggle.md),
[`shad_toggle_group()`](https://orijitghosh.github.io/shadshiny/reference/shad_toggle_group.md)

## Examples

``` r
shad_switch("wifi", "Wi-Fi", value = TRUE)
#> <div class="shad-switch-row">
#>   <button type="button" class="shad-switch" data-shad="switch" role="switch" data-state="checked" id="wifi">
#>     <span class="shad-switch__thumb" aria-hidden="true"></span>
#>   </button>
#>   <label class="shad-label" for="wifi">Wi-Fi</label>
#> </div>
```

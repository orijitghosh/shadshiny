# Radio group

A shadcn radio group. `input$<inputId>` is the selected value (a string)
or `NULL`.

## Usage

``` r
shad_radio_group(
  inputId,
  label = NULL,
  choices,
  selected = NULL,
  orientation = c("vertical", "horizontal"),
  disabled = FALSE,
  class = NULL,
  ...
)

shad_radio_item(value, label = value, disabled = FALSE, description = NULL)
```

## Arguments

- inputId:

  Input id.

- label:

  Optional group label (rendered above the group).

- choices:

  A named character vector (`c(Label = "value")`), an unnamed vector, or
  a list of `shad_radio_item()` specs.

- selected:

  Initially selected value.

- orientation:

  `"vertical"` (default) or `"horizontal"`.

- disabled:

  If `TRUE`, disables every item.

- class:

  Extra CSS classes.

- ...:

  Extra attributes on the group root.

- value:

  The item's value.

- description:

  Optional per-item help text.

## Value

A radio-group tag.

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
[`shad_select()`](https://orijitghosh.github.io/shadshiny/reference/shad_select.md),
[`shad_slider()`](https://orijitghosh.github.io/shadshiny/reference/shad_slider.md),
[`shad_switch()`](https://orijitghosh.github.io/shadshiny/reference/shad_switch.md),
[`shad_textarea()`](https://orijitghosh.github.io/shadshiny/reference/shad_textarea.md),
[`shad_toggle()`](https://orijitghosh.github.io/shadshiny/reference/shad_toggle.md),
[`shad_toggle_group()`](https://orijitghosh.github.io/shadshiny/reference/shad_toggle_group.md)

## Examples

``` r
shad_radio_group("plan", choices = c(Free = "free", Pro = "pro"),
                 selected = "pro")
#> <div class="shad-radio-group" data-shad="radio-group" id="plan" role="radiogroup">
#>   <div class="shad-radio-row">
#>     <button type="button" class="shad-radio" role="radio" data-value="free" data-state="unchecked" id="plan-1">
#>       <span class="shad-radio__indicator" aria-hidden="true"></span>
#>     </button>
#>     <label class="shad-label" for="plan-1">Free</label>
#>   </div>
#>   <div class="shad-radio-row">
#>     <button type="button" class="shad-radio" role="radio" data-value="pro" data-state="checked" id="plan-2">
#>       <span class="shad-radio__indicator" aria-hidden="true"></span>
#>     </button>
#>     <label class="shad-label" for="plan-2">Pro</label>
#>   </div>
#> </div>
```

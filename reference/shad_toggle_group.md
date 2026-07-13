# Toggle group

A shadcn toggle group. `input$<inputId>` is a string/`NULL` (single
mode) or a character vector (multiple mode).

## Usage

``` r
shad_toggle_group(
  inputId,
  choices,
  selected = NULL,
  type = c("single", "multiple"),
  variant = c("default", "outline"),
  size = c("default", "sm", "lg"),
  orientation = c("horizontal", "vertical"),
  disabled = FALSE,
  class = NULL,
  ...
)

shad_toggle_group_item(value, label = NULL, icon = NULL, disabled = FALSE)
```

## Arguments

- inputId:

  Input id.

- choices:

  A named/unnamed vector or a list of `shad_toggle_group_item()`.

- selected:

  Initially pressed value(s).

- type:

  `"single"` or `"multiple"`.

- variant:

  `"default"` or `"outline"`.

- size:

  `"default"`, `"sm"`, or `"lg"`.

- orientation:

  `"horizontal"` (default) or `"vertical"`.

- disabled:

  If `TRUE`, disables every item.

- class:

  Extra CSS classes.

- ...:

  Extra attributes on the group root.

- value:

  The item's value.

- label:

  The item's label (defaults to the value).

- icon:

  Optional icon for the item.

## Value

A toggle-group tag.

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
[`shad_toggle()`](https://orijitghosh.github.io/shadshiny/reference/shad_toggle.md)

## Examples

``` r
shad_toggle_group("align", choices = c(Left = "left", Center = "center",
                  Right = "right"), selected = "center", type = "single")
#> <div class="shad-toggle-group" data-shad="toggle-group" id="align" data-type="single" role="group">
#>   <button type="button" class="shad-toggle" data-value="left" data-state="off">Left</button>
#>   <button type="button" class="shad-toggle" data-value="center" data-state="on">Center</button>
#>   <button type="button" class="shad-toggle" data-value="right" data-state="off">Right</button>
#> </div>
```

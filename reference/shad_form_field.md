# Form field wrapper

Wraps a control with a label, help description, and error slot, matching
the shadcn form-field anatomy. The bundled JS wires `aria-describedby`
from the description/error elements to the contained control on init.
Most Tier 2 constructors reuse this internally when given
`label`/`description`.

## Usage

``` r
shad_form_field(
  ...,
  label = NULL,
  description = NULL,
  error = NULL,
  required = FALSE,
  inputId = NULL,
  class = NULL
)
```

## Arguments

- ...:

  The control(s) to wrap, plus optional named attributes.

- label:

  Optional field label text.

- description:

  Optional help text shown below the control.

- error:

  Optional error message. When non-`NULL` the error slot is shown
  (otherwise it is rendered but `hidden`, ready for client-side
  validation).

- required:

  If `TRUE`, appends a visual required marker to the label.

- inputId:

  Optional id for the field root.

- class:

  Extra CSS classes.

## Value

A `<div class="shad-form-field">` tag.

## See also

Other shadshiny tier-2 components:
[`shad_calendar()`](https://orijitghosh.github.io/shadshiny/reference/shad_calendar.md),
[`shad_checkbox()`](https://orijitghosh.github.io/shadshiny/reference/shad_checkbox.md),
[`shad_combobox()`](https://orijitghosh.github.io/shadshiny/reference/shad_combobox.md),
[`shad_date_picker()`](https://orijitghosh.github.io/shadshiny/reference/shad_date_picker.md),
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
shad_form_field(
  shad_input("user", value = "shadcn"),
  label = "Username",
  description = "This is your public display name."
)
#> <div class="shad-form-field" data-shad="form-field">
#>   <label class="shad-label">Username</label>
#>   <input id="user" class="shad-input" type="text" value="shadcn"/>
#>   <p class="shad-form-field__description">This is your public display name.</p>
#>   <p class="shad-form-field__error" hidden></p>
#> </div>
```

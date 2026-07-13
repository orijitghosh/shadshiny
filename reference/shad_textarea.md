# Textarea

A shadcn-styled multi-line `<textarea>`. Bound by Shiny's native
binding;
[`shiny::updateTextAreaInput()`](https://rdrr.io/pkg/shiny/man/updateTextAreaInput.html)
works. `autosize = TRUE` grows the control to fit its content (behavior
handled by the bundled JS).

## Usage

``` r
shad_textarea(
  inputId,
  label = NULL,
  value = "",
  placeholder = NULL,
  rows = 3,
  autosize = FALSE,
  invalid = FALSE,
  disabled = FALSE,
  description = NULL,
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

  Initial value.

- placeholder:

  Placeholder text.

- rows:

  Initial visible rows.

- autosize:

  If `TRUE`, the textarea grows with its content.

- invalid:

  If `TRUE`, sets `aria-invalid="true"` (destructive border).

- disabled:

  If `TRUE`, disables the input.

- description:

  Optional help text (wraps in
  [`shad_form_field()`](https://orijitghosh.github.io/shadshiny/reference/shad_form_field.md)).

- width:

  CSS width.

- class:

  Extra CSS classes.

- ...:

  Extra attributes.

## Value

A `<textarea>` tag, optionally wrapped in a form field.

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
[`shad_toggle()`](https://orijitghosh.github.io/shadshiny/reference/shad_toggle.md),
[`shad_toggle_group()`](https://orijitghosh.github.io/shadshiny/reference/shad_toggle_group.md)

## Examples

``` r
shad_textarea("bio", label = "Bio", placeholder = "Tell us about yourself")
#> <div class="shad-form-field" data-shad="form-field">
#>   <label class="shad-label">Bio</label>
#>   <textarea id="bio" class="shad-textarea" placeholder="Tell us about yourself" rows="3"></textarea>
#>   <p class="shad-form-field__error" hidden></p>
#> </div>
shad_textarea("msg", autosize = TRUE)
#> <textarea id="msg" class="shad-textarea" rows="3" data-shad="textarea" data-autosize></textarea>
```

# Text input

A shadcn-styled `<input>`. Bound by Shiny's native text-input binding,
so `input$<inputId>` reflects the value and
[`shiny::updateTextInput()`](https://rdrr.io/pkg/shiny/man/updateTextInput.html)
works.

## Usage

``` r
shad_input(
  inputId,
  label = NULL,
  value = "",
  placeholder = NULL,
  type = "text",
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

- type:

  Input `type` attribute (`"text"`, `"email"`, `"password"`, ...).

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

An `<input>` tag, optionally wrapped in a form field.

## See also

Other shadshiny tier-2 components:
[`shad_calendar()`](https://orijitghosh.github.io/shadshiny/reference/shad_calendar.md),
[`shad_checkbox()`](https://orijitghosh.github.io/shadshiny/reference/shad_checkbox.md),
[`shad_combobox()`](https://orijitghosh.github.io/shadshiny/reference/shad_combobox.md),
[`shad_date_picker()`](https://orijitghosh.github.io/shadshiny/reference/shad_date_picker.md),
[`shad_form_field()`](https://orijitghosh.github.io/shadshiny/reference/shad_form_field.md),
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
shad_input("email", type = "email", placeholder = "you@example.com")
#> <input id="email" class="shad-input" type="email" placeholder="you@example.com"/>
shad_input("user", label = "Username", value = "shadcn")
#> <div class="shad-form-field" data-shad="form-field">
#>   <label class="shad-label">Username</label>
#>   <input id="user" class="shad-input" type="text" value="shadcn"/>
#>   <p class="shad-form-field__error" hidden></p>
#> </div>
```

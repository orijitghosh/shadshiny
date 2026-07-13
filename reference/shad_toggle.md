# Toggle

A shadcn two-state toggle button. `input$<inputId>` is a logical.

## Usage

``` r
shad_toggle(
  inputId,
  label = NULL,
  value = FALSE,
  variant = c("default", "outline"),
  size = c("default", "sm", "lg"),
  icon = NULL,
  disabled = FALSE,
  class = NULL,
  ...
)
```

## Arguments

- inputId:

  Input id.

- label:

  Optional text content.

- value:

  Initial pressed state (logical).

- variant:

  `"default"` or `"outline"`.

- size:

  `"default"`, `"sm"`, or `"lg"`.

- icon:

  Optional icon: a
  [`shad_icon()`](https://orijitghosh.github.io/shadshiny/reference/shad_icon.md)
  name or a tag.

- disabled:

  If `TRUE`, disables the control.

- class:

  Extra CSS classes.

- ...:

  Extra attributes.

## Value

A toggle button tag.

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
[`shad_toggle_group()`](https://orijitghosh.github.io/shadshiny/reference/shad_toggle_group.md)

## Examples

``` r
shad_toggle("bold", icon = "plus", value = TRUE)
#> <button type="button" class="shad-toggle" data-shad="toggle" data-state="on" id="bold"><svg class="shad-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M5 12h14"/><path d="M12 5v14"/></svg></button>
shad_toggle("mode", "Outline", variant = "outline")
#> <button type="button" class="shad-toggle shad-toggle--outline" data-shad="toggle" data-state="off" id="mode">Outline</button>
```

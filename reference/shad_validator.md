# Form validator

A server-side validator that pushes shadcn-styled errors into the
[`shad_form_field()`](https://orijitghosh.github.io/shadshiny/reference/shad_form_field.md)
wrapping each control (via
[`update_shad_form_field()`](https://orijitghosh.github.io/shadshiny/reference/update_shad_form_field.md)),
with optional submit-button gating and an error summary. API shape
mirrors shinyvalidate; implemented natively with no extra dependencies.

## Usage

``` r
shad_validator(session = shiny::getDefaultReactiveDomain())
```

## Arguments

- session:

  The Shiny session.

## Value

A validator object (list of functions).

## Details

The returned object's methods:

- `add_rule(inputId, rule, ...)`:

  Register a rule (chainable). Multiple rules per field run in order;
  the first failure wins.

- `enable()` / `disable()`:

  Start / stop live validation (errors show on change once enabled;
  `disable()` clears them).

- `is_valid()`:

  Reactive-context logical: all rules currently pass.

- [`validate()`](https://rdrr.io/pkg/shiny/man/validate.html):

  Imperative full pass; shows every error and returns a logical (use in
  submit handlers).

- `fields()`:

  Registered input ids.

- `bind_submit(buttonId)`:

  Disable a
  [`shad_button()`](https://orijitghosh.github.io/shadshiny/reference/shad_button.md)
  while invalid.

- `bind_summary(id)`:

  Render a
  [`shad_form_summary()`](https://orijitghosh.github.io/shadshiny/reference/shad_form_summary.md)
  on validate/enable.

## See also

Other shadshiny forms:
[`shad_form_counter()`](https://orijitghosh.github.io/shadshiny/reference/shad_form_counter.md),
[`shad_form_message()`](https://orijitghosh.github.io/shadshiny/reference/shad_form_message.md),
[`shad_form_summary()`](https://orijitghosh.github.io/shadshiny/reference/shad_form_summary.md),
[`shad_rules`](https://orijitghosh.github.io/shadshiny/reference/shad_rules.md),
[`update_shad_form_field()`](https://orijitghosh.github.io/shadshiny/reference/update_shad_form_field.md)

## Examples

``` r
if (interactive()) {
  server <- function(input, output, session) {
    sv <- shad_validator()
    sv$add_rule("email", shad_rule_required())
    sv$add_rule("email", shad_rule_email())
    sv$enable()
    observeEvent(input$submit, if (sv$validate()) message("ok"))
  }
}
```

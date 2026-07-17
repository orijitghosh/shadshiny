# Set or clear a field's error state from the server

Pushes a shadcn error message into the
[`shad_form_field()`](https://orijitghosh.github.io/shadshiny/reference/shad_form_field.md)
wrapping a control, toggling `data-invalid`, `aria-invalid`, and
`aria-describedby` and creating/removing the message element. This is
the primitive that
[`shad_validator()`](https://orijitghosh.github.io/shadshiny/reference/shad_validator.md)
and shinyvalidate bridges build on.

## Usage

``` r
update_shad_form_field(
  inputId,
  error = NULL,
  session = shiny::getDefaultReactiveDomain()
)
```

## Arguments

- inputId:

  The bound control's id (namespaced automatically).

- error:

  Error text to show, or `NULL` to clear.

- session:

  The Shiny session.

## Value

Invisibly `NULL`.

## See also

Other shadshiny forms:
[`shad_form_counter()`](https://orijitghosh.github.io/shadshiny/reference/shad_form_counter.md),
[`shad_form_message()`](https://orijitghosh.github.io/shadshiny/reference/shad_form_message.md),
[`shad_form_summary()`](https://orijitghosh.github.io/shadshiny/reference/shad_form_summary.md),
[`shad_rules`](https://orijitghosh.github.io/shadshiny/reference/shad_rules.md),
[`shad_validator()`](https://orijitghosh.github.io/shadshiny/reference/shad_validator.md)

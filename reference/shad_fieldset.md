# Semantic fieldset

Experimental. Groups related controls under a native legend while
keeping the existing shad_form_field() wrapper as the single-control
primitive. The optional description is associated with the fieldset
through aria-describedby.

## Usage

``` r
shad_fieldset(
  legend,
  ...,
  description = NULL,
  variant = c("legend", "label"),
  class = NULL
)
```

## Arguments

- legend:

  Legend content for the fieldset.

- ...:

  Child controls, field groups, and/or named HTML attributes.

- description:

  Optional help text rendered below the legend.

- variant:

  "legend" (default) or "label" for the legend's visual treatment.

- class:

  Extra CSS classes.

## Value

A native

tag.

## See also

Other shadshiny forms:
[`shad_field_group()`](https://orijitghosh.github.io/shadshiny/reference/shad_field_group.md),
[`shad_field_separator()`](https://orijitghosh.github.io/shadshiny/reference/shad_field_separator.md),
[`shad_form_counter()`](https://orijitghosh.github.io/shadshiny/reference/shad_form_counter.md),
[`shad_form_message()`](https://orijitghosh.github.io/shadshiny/reference/shad_form_message.md),
[`shad_form_summary()`](https://orijitghosh.github.io/shadshiny/reference/shad_form_summary.md),
[`shad_rules`](https://orijitghosh.github.io/shadshiny/reference/shad_rules.md),
[`shad_validator()`](https://orijitghosh.github.io/shadshiny/reference/shad_validator.md),
[`update_shad_form_field()`](https://orijitghosh.github.io/shadshiny/reference/update_shad_form_field.md)

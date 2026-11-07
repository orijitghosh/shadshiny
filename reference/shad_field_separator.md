# Field separator

Experimental. Inserts a labelled or unlabelled visual separator between
fields. For a labelled separator, the visible label is deliberately
outside the child separator node so assistive technology does not treat
the text as the separator's accessible name.

## Usage

``` r
shad_field_separator(label = NULL, class = NULL)
```

## Arguments

- label:

  Optional visible separator label.

- class:

  Extra CSS classes.

## Value

A separator tag.

## See also

Other shadshiny forms:
[`shad_field_group()`](https://orijitghosh.github.io/shadshiny/reference/shad_field_group.md),
[`shad_fieldset()`](https://orijitghosh.github.io/shadshiny/reference/shad_fieldset.md),
[`shad_form_counter()`](https://orijitghosh.github.io/shadshiny/reference/shad_form_counter.md),
[`shad_form_message()`](https://orijitghosh.github.io/shadshiny/reference/shad_form_message.md),
[`shad_form_summary()`](https://orijitghosh.github.io/shadshiny/reference/shad_form_summary.md),
[`shad_rules`](https://orijitghosh.github.io/shadshiny/reference/shad_rules.md),
[`shad_validator()`](https://orijitghosh.github.io/shadshiny/reference/shad_validator.md),
[`update_shad_form_field()`](https://orijitghosh.github.io/shadshiny/reference/update_shad_form_field.md)

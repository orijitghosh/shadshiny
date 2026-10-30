# Validation rules

Rules for
[`shad_validator()`](https://orijitghosh.github.io/shadshiny/reference/shad_validator.md).
Each is a function of a field value returning `NULL` when valid or an
error message string. Empty optional fields skip non-`required` rules
(matching shinyvalidate).

## Usage

``` r
shad_rule_required(message = "Required.")

shad_rule_email(message = "Enter a valid email address.")

shad_rule_min_chars(n, message = NULL)

shad_rule_max_chars(n, message = NULL)

shad_rule_range(min = -Inf, max = Inf, message = NULL)

shad_rule_regex(pattern, message = "Invalid format.")

shad_rule_in(choices, message = NULL)

shad_rule_fn(fn)
```

## Arguments

- message:

  Custom error message (`NULL` uses a sensible default).

- n:

  Character/threshold count.

- min, max:

  Numeric bounds.

- pattern:

  A regular expression.

- choices:

  Allowed values.

- fn:

  A custom `function(value)` returning `NULL` or a message.

## Value

A rule function.

## See also

Other shadshiny forms:
[`shad_field_group()`](https://orijitghosh.github.io/shadshiny/reference/shad_field_group.md),
[`shad_field_separator()`](https://orijitghosh.github.io/shadshiny/reference/shad_field_separator.md),
[`shad_fieldset()`](https://orijitghosh.github.io/shadshiny/reference/shad_fieldset.md),
[`shad_form_counter()`](https://orijitghosh.github.io/shadshiny/reference/shad_form_counter.md),
[`shad_form_message()`](https://orijitghosh.github.io/shadshiny/reference/shad_form_message.md),
[`shad_form_summary()`](https://orijitghosh.github.io/shadshiny/reference/shad_form_summary.md),
[`shad_validator()`](https://orijitghosh.github.io/shadshiny/reference/shad_validator.md),
[`update_shad_form_field()`](https://orijitghosh.github.io/shadshiny/reference/update_shad_form_field.md)

## Examples

``` r
r <- shad_rule_required()
r("")      # error message
#> [1] "Required."
r("hello") # NULL
#> NULL
```

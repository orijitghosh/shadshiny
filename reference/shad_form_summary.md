# Form error summary

A `role="alert"` box listing field errors with anchor links to each
field. Place it above the form and move focus to it on a failed submit.
Populated by hand, or via
[`shad_validator()`](https://orijitghosh.github.io/shadshiny/reference/shad_validator.md)'s
`bind_summary()`.

## Usage

``` r
shad_form_summary(
  id,
  title = "Please fix the errors below",
  errors = NULL,
  class = NULL
)
```

## Arguments

- id:

  Element id (targeted by the validator).

- title:

  Summary heading (e.g. `"2 fields need attention"`).

- errors:

  Optional named character vector `c(field_id = "message")`; each
  becomes a link to `#field_id`.

- class:

  Extra CSS classes.

## Value

A form-summary tag.

## See also

Other shadshiny forms:
[`shad_form_counter()`](https://orijitghosh.github.io/shadshiny/reference/shad_form_counter.md),
[`shad_form_message()`](https://orijitghosh.github.io/shadshiny/reference/shad_form_message.md),
[`shad_rules`](https://orijitghosh.github.io/shadshiny/reference/shad_rules.md),
[`shad_validator()`](https://orijitghosh.github.io/shadshiny/reference/shad_validator.md),
[`update_shad_form_field()`](https://orijitghosh.github.io/shadshiny/reference/update_shad_form_field.md)

## Examples

``` r
shad_form_summary(
  "errs", "2 fields need attention",
  errors = c(email = "Email is not valid", pw = "Password too short")
)
#> <div class="shad-form-summary" id="errs" role="alert">
#>   <div class="shad-form-summary__title">
#>     <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="12" cy="12" r="10"/><path d="M12 8v4M12 16h.01"/></svg>
#>     2 fields need attention
#>   </div>
#>   <ul class="shad-form-summary__list">
#>     <li>
#>       <a href="#email">Email is not valid</a>
#>     </li>
#>     <li>
#>       <a href="#pw">Password too short</a>
#>     </li>
#>   </ul>
#> </div>
```

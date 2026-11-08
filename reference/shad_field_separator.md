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

## Examples

``` r
shad_fieldset(
  "Sign in",
  shad_input("email", "Email"),
  shad_field_separator("or"),
  shad_button("Continue with a passkey", variant = "outline")
)
#> <fieldset class="shad-fieldset">
#>   <legend class="shad-fieldset__legend">Sign in</legend>
#>   <div class="shad-form-field" data-shad="form-field">
#>     <label class="shad-label">Email</label>
#>     <input id="email" class="shad-input" type="text"/>
#>     <p class="shad-form-field__error" hidden></p>
#>   </div>
#>   <div class="shad-field-separator">
#>     <span class="shad-field-separator__label">or</span>
#>     <div class="shad-field-separator__line" role="separator" aria-orientation="horizontal" aria-hidden="true"></div>
#>   </div>
#>   <button type="button" class="shad-btn shad-btn--outline">Continue with a passkey</button>
#> </fieldset>
```

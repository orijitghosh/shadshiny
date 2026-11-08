# Field group

Experimental. Arranges shad_form_field() children vertically,
horizontally, or responsively inside a container-query-aware group.

## Usage

``` r
shad_field_group(
  ...,
  orientation = c("vertical", "horizontal", "responsive"),
  class = NULL
)
```

## Arguments

- ...:

  Child fields and/or named HTML attributes.

- orientation:

  "vertical" (default), "horizontal", or "responsive".

- class:

  Extra CSS classes.

## Value

A

field-group tag.

## See also

Other shadshiny forms:
[`shad_field_separator()`](https://orijitghosh.github.io/shadshiny/reference/shad_field_separator.md),
[`shad_fieldset()`](https://orijitghosh.github.io/shadshiny/reference/shad_fieldset.md),
[`shad_form_counter()`](https://orijitghosh.github.io/shadshiny/reference/shad_form_counter.md),
[`shad_form_message()`](https://orijitghosh.github.io/shadshiny/reference/shad_form_message.md),
[`shad_form_summary()`](https://orijitghosh.github.io/shadshiny/reference/shad_form_summary.md),
[`shad_rules`](https://orijitghosh.github.io/shadshiny/reference/shad_rules.md),
[`shad_validator()`](https://orijitghosh.github.io/shadshiny/reference/shad_validator.md),
[`update_shad_form_field()`](https://orijitghosh.github.io/shadshiny/reference/update_shad_form_field.md)

## Examples

``` r
shad_field_group(
  shad_input("first", "First name"),
  shad_input("last", "Last name"),
  orientation = "responsive"
)
#> <div class="shad-field-group" data-orientation="responsive">
#>   <div class="shad-form-field" data-shad="form-field">
#>     <label class="shad-label">First name</label>
#>     <input id="first" class="shad-input" type="text"/>
#>     <p class="shad-form-field__error" hidden></p>
#>   </div>
#>   <div class="shad-form-field" data-shad="form-field">
#>     <label class="shad-label">Last name</label>
#>     <input id="last" class="shad-input" type="text"/>
#>     <p class="shad-form-field__error" hidden></p>
#>   </div>
#> </div>
```

## On this page

Developed by Arijit Ghosh.

Site built with [pkgdown](https://pkgdown.r-lib.org/) 2.2.1.

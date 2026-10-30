# Form validation message

A field-level validation line (error / success / warning / info) or a
right-aligned character counter, matching shadcn's form messaging. Place
inside a
[`shad_form_field()`](https://orijitghosh.github.io/shadshiny/reference/shad_form_field.md)
after the control. For server-driven errors, prefer
[`update_shad_form_field()`](https://orijitghosh.github.io/shadshiny/reference/update_shad_form_field.md)
/ the
[`shad_validator()`](https://orijitghosh.github.io/shadshiny/reference/shad_validator.md)
framework, which create and remove these for you.

## Usage

``` r
shad_form_message(
  message,
  type = c("info", "error", "success", "warning"),
  icon = TRUE,
  id = NULL,
  class = NULL
)
```

## Arguments

- message:

  The message text (or tags).

- type:

  `"info"` (default, muted), `"error"`, `"success"`, or `"warning"`.

- icon:

  If `TRUE` (default), show the type's leading icon.

- id:

  Optional id (point the control's `aria-describedby` at it).

- class:

  Extra CSS classes.

## Value

A form-message tag.

## See also

Other shadshiny forms:
[`shad_field_group()`](https://orijitghosh.github.io/shadshiny/reference/shad_field_group.md),
[`shad_field_separator()`](https://orijitghosh.github.io/shadshiny/reference/shad_field_separator.md),
[`shad_fieldset()`](https://orijitghosh.github.io/shadshiny/reference/shad_fieldset.md),
[`shad_form_counter()`](https://orijitghosh.github.io/shadshiny/reference/shad_form_counter.md),
[`shad_form_summary()`](https://orijitghosh.github.io/shadshiny/reference/shad_form_summary.md),
[`shad_rules`](https://orijitghosh.github.io/shadshiny/reference/shad_rules.md),
[`shad_validator()`](https://orijitghosh.github.io/shadshiny/reference/shad_validator.md),
[`update_shad_form_field()`](https://orijitghosh.github.io/shadshiny/reference/update_shad_form_field.md)

## Examples

``` r
shad_form_message("Enter a valid email address.", type = "error")
#> <div class="shad-form-message shad-form-message--error">
#>   <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="12" cy="12" r="10"/><path d="M12 8v4M12 16h.01"/></svg>
#>   Enter a valid email address.
#> </div>
shad_form_message("Username is available.", type = "success")
#> <div class="shad-form-message shad-form-message--success">
#>   <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M4 12l5 5L20 7"/></svg>
#>   Username is available.
#> </div>
```

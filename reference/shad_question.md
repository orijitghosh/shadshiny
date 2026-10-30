# Define one questionnaire question

Creates a serializable question definition consumed by
[`shad_questionnaire()`](https://orijitghosh.github.io/shadshiny/reference/shad_questionnaire.md).
Conditions are named equality checks; they are data, not R or JavaScript
callbacks.

## Usage

``` r
shad_question(
  name,
  prompt,
  ...,
  type = c("single", "multiple", "text"),
  choices = NULL,
  description = NULL,
  required = TRUE,
  skippable = FALSE,
  show_if = NULL,
  shortcuts = NULL
)
```

## Arguments

- name:

  Stable question name. Names must be non-empty and unique within one
  questionnaire.

- prompt:

  Question prompt rendered in the fieldset legend.

- ...:

  Reserved named HTML attributes for the question definition.

- type:

  One of `"single"`, `"multiple"`, or `"text"`.

- choices:

  A named/unnamed vector, or a list of `value`/`label` items, required
  for choice questions and forbidden for text questions.

- description:

  Optional help text.

- required:

  If `TRUE`, the question must be answered before advancing.

- skippable:

  If `TRUE`, the user may explicitly skip the question.

- show_if:

  Named list of question names to accepted values. All entries must
  match for this question to be visible.

- shortcuts:

  Named choice values mapped to printable keyboard keys.

## Value

A serializable `shad_question` object.

## See also

Other shadshiny questionnaire:
[`shad_questionnaire()`](https://orijitghosh.github.io/shadshiny/reference/shad_questionnaire.md),
[`update_shad_questionnaire()`](https://orijitghosh.github.io/shadshiny/reference/update_shad_questionnaire.md)

## Examples

``` r
shad_question(
  "plan", "What should be built?", type = "single",
  choices = c("Server table" = "data", RTL = "rtl")
)
#> $name
#> [1] "plan"
#> 
#> $prompt
#> [1] "What should be built?"
#> 
#> $attributes
#> list()
#> 
#> $type
#> [1] "single"
#> 
#> $choices
#> $choices$`Server table`
#> $choices$`Server table`$value
#> [1] "Server table"
#> 
#> $choices$`Server table`$label
#> [1] "data"
#> 
#> 
#> $choices$RTL
#> $choices$RTL$value
#> [1] "RTL"
#> 
#> $choices$RTL$label
#> [1] "rtl"
#> 
#> 
#> 
#> $description
#> NULL
#> 
#> $required
#> [1] TRUE
#> 
#> $skippable
#> [1] FALSE
#> 
#> $show_if
#> list()
#> 
#> $shortcuts
#> NULL
#> 
#> attr(,"class")
#> [1] "shad_question"
```

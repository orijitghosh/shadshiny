# Update a questionnaire from the server

Experimental. Sends only the supplied state facets. `reset = TRUE` calls
the client instance's reset method. Answer and error lists must be named
so module instances and question definitions remain stable.

## Usage

``` r
update_shad_questionnaire(
  id,
  active = NULL,
  answers = NULL,
  errors = NULL,
  reset = FALSE,
  session = shiny::getDefaultReactiveDomain()
)
```

## Arguments

- id:

  Input id (namespaced automatically).

- active:

  Optional 1-based active question index.

- answers:

  Optional named answer list.

- errors:

  Optional named question-error list; use `NULL` values to clear.

- reset:

  If `TRUE`, reset active state, answers, skips, errors, and completion.

- session:

  The Shiny session.

## Value

Invisibly `NULL`.

## See also

Other shadshiny questionnaire:
[`shad_question()`](https://orijitghosh.github.io/shadshiny/reference/shad_question.md),
[`shad_questionnaire()`](https://orijitghosh.github.io/shadshiny/reference/shad_questionnaire.md)

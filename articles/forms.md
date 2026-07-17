# Forms & validation

shadshiny inputs are ordinary Shiny inputs, so building and validating a
form uses the reactivity you already know. This guide covers the field
wrapper, the `invalid` state, server-side validation, and updating
inputs.

## Reading values

Every bound input contributes one reactive value under
`input$<inputId>`. The shape matches the control: a string for text and
select, a logical for checkbox and switch, a vector for multi-selects
and toggle groups.

``` r

shad_input("email", label = "Email")
# server:
observe(print(input$email))     # the current string
```

## The field wrapper

[`shad_form_field()`](https://orijitghosh.github.io/shadshiny/reference/shad_form_field.md)
gives any control a label, description, a required marker and an error
slot — the standard anatomy of a form row. Wrap the input and pass the
metadata to the wrapper:

``` r

shad_form_field(
  shad_input("site", placeholder = "example.com"),
  label = "Website",
  description = "No https:// needed.",
  required = TRUE
)
```

Many inputs also accept `label` / `description` directly for the common
case, so reach for
[`shad_form_field()`](https://orijitghosh.github.io/shadshiny/reference/shad_form_field.md)
when you need the error slot or a shared layout.

## Signalling invalid input

Bound inputs take an `invalid` argument that switches them to the error
style. Drive it from validation state and pair it with a message:

``` r

ui <- page_shad(
  shad_form_field(
    shad_input("email", label = "Email", type = "email"),
    inputId = "email",
    error = textOutput("email_err", inline = TRUE)
  ),
  shad_button("submit", "Sign up")
)

server <- function(input, output, session) {
  valid_email <- reactive(grepl("^[^@ ]+@[^@ ]+\\.[^@ ]+$", input$email %||% ""))

  output$email_err <- renderText(
    if (!isTRUE(valid_email()) && nzchar(input$email %||% ""))
      "Enter a valid email address." else ""
  )

  observeEvent(input$submit, {
    if (!isTRUE(valid_email())) {
      shad_toast_error("Please fix the errors first.")
    } else {
      shad_toast_success(paste("Welcome,", input$email))
    }
  })
}
```

> `%||%` (null-coalescing) is handy for guarding inputs before they’ve
> initialised: `input$email %||% ""`. Define it once with
> `` `%||%` <- function(a, b) if (is.null(a)) b else a `` or import it
> from rlang.

## The validator

Hand-rolling that per field gets old fast.
[`shad_validator()`](https://orijitghosh.github.io/shadshiny/reference/shad_validator.md)
does the same thing declaratively: you register rules per input, and it
drives the field’s `aria-invalid` state and inline error text for you —
no `error =` slot or
[`textOutput()`](https://rdrr.io/pkg/shiny/man/textOutput.html) needed
in the UI.

``` r

ui <- page_shad(
  shad_input("email", label = "Email", type = "email"),
  shad_input("pw", label = "Password", type = "password"),
  shad_button("submit", "Sign up")
)

server <- function(input, output, session) {
  sv <- shad_validator()
  sv$add_rule("email", shad_rule_required())
  sv$add_rule("email", shad_rule_email())
  sv$add_rule("pw", shad_rule_min_chars(8))
  sv$enable()

  observeEvent(input$submit, {
    if (sv$validate()) shad_toast_success(paste("Welcome,", input$email))
  })
}
```

`enable()` starts live validation: errors appear as the user changes a
field. [`validate()`](https://rdrr.io/pkg/shiny/man/validate.html) runs
a full pass — it shows *every* error and returns a logical, which is
what you want in a submit handler, since a field the user never touched
has never been checked.

### The rules

| Rule | Fails when |
|----|----|
| `shad_rule_required(message)` | Value is empty, `NULL`, `""`, or an unchecked checkbox/switch. |
| `shad_rule_email(message)` | Not a plausible email address. |
| `shad_rule_min_chars(n, message)` | Shorter than `n`. |
| `shad_rule_max_chars(n, message)` | Longer than `n`. |
| `shad_rule_range(min, max, message)` | Not numeric, or outside `[min, max]`. |
| `shad_rule_regex(pattern, message)` | `pattern` doesn’t match. |
| `shad_rule_in(choices, message)` | Any value is outside `choices`. |
| `shad_rule_fn(fn)` | Your own `function(value)` returning an error string, or `NULL` to pass. |

Every rule takes a `message` you can override. Rules for one field run
in the order you added them and the first failure wins, so put
[`shad_rule_required()`](https://orijitghosh.github.io/shadshiny/reference/shad_rules.md)
first — every other rule passes an empty value on purpose, leaving “is
this mandatory?” as a separate decision.

``` r

sv$add_rule("username", shad_rule_required())
sv$add_rule("username", shad_rule_regex("^[a-z0-9_]+$",
                                        "Lowercase, digits, and _ only."))
sv$add_rule("username", shad_rule_fn(function(value) {
  if (value %in% taken_usernames) "That username is taken." else NULL
}))
```

### The rest of the object

| Method | Does |
|----|----|
| `add_rule(inputId, rule, label)` | Register a rule. Chainable. |
| `enable()` / `disable()` | Start / stop live validation (`disable()` clears the messages). |
| `is_valid()` | Reactive logical: do all rules currently pass? |
| [`validate()`](https://rdrr.io/pkg/shiny/man/validate.html) | Imperative full pass; shows every error, returns a logical. |
| `fields()` | The registered input ids. |
| `bind_submit(buttonId)` | Keep a [`shad_button()`](https://orijitghosh.github.io/shadshiny/reference/shad_button.md) disabled while the form is invalid. |
| `bind_summary(id)` | Render a [`shad_form_summary()`](https://orijitghosh.github.io/shadshiny/reference/shad_form_summary.md) of the outstanding errors. |

``` r

ui <- page_shad(
  shad_input("email", label = "Email", type = "email"),
  uiOutput("errors"),
  shad_button("submit", "Sign up")
)

server <- function(input, output, session) {
  sv <- shad_validator()
  sv$add_rule("email", shad_rule_required(), label = "Email")
  sv$add_rule("email", shad_rule_email())
  sv$bind_submit("submit")     # button greys out until valid
  sv$bind_summary("errors")    # error list renders here on validate()
  sv$enable()
}
```

`label =` is the human name used in the summary; without it the summary
falls back to the input id.

### Standalone messages

The pieces the validator drives are also plain components, for when you
want one without the machinery:

``` r

shad_form_message("We'll never share this.", type = "info")
shad_form_message("Username is taken.", type = "error")
shad_form_counter(nchar(input$bio %||% ""), 280)   # a 42/280 counter chip
```

### Base `validate()` / `need()`

Still fine, and still the right tool for *outputs* —
[`shad_validator()`](https://orijitghosh.github.io/shadshiny/reference/shad_validator.md)
is about inputs. The two coexist.

## Gating submission

Use [`shiny::req()`](https://rdrr.io/pkg/shiny/man/req.html) to hold
logic until required inputs are present and truthy, and validate the
rest before acting:

``` r

observeEvent(input$submit, {
  req(input$email, input$plan)          # both must be truthy
  if (!isTRUE(input$tos)) {
    shad_toast_error("Please accept the terms.")
    return()
  }
  # ... persist the form ...
  shad_toast_success("Account created.")
})
```

## Updating inputs from the server

Each valued component has an `update_shad_*()` twin. They take the same
`inputId`, are Shiny-module safe, and are the way to reset or prefill a
form:

``` r

observeEvent(input$reset, {
  updateTextInput(session, "email", value = "")   # shad_input uses the
  updateTextInput(session, "site", value = "")    # native text binding
  update_shad_select("plan", selected = "free")
  update_shad_checkbox("tos", value = FALSE)
  update_shad_slider("seats", value = 1)
})
```

Two things to note:

- **[`shad_input()`](https://orijitghosh.github.io/shadshiny/reference/shad_input.md)
  and
  [`shad_textarea()`](https://orijitghosh.github.io/shadshiny/reference/shad_textarea.md)
  render real `<input>`/`<textarea>` elements and use Shiny’s native
  text bindings.** Update them with
  [`shiny::updateTextInput()`](https://rdrr.io/pkg/shiny/man/updateTextInput.html)
  /
  [`updateTextAreaInput()`](https://rdrr.io/pkg/shiny/man/updateTextAreaInput.html),
  *not* a `update_shad_*()` function (there isn’t one).
- Everything else — select, combobox, checkbox, switch, radio,
  toggle(s), slider, OTP, calendar, date-picker — has a dedicated
  `update_shad_*()` helper. See the [Server
  API](https://orijitghosh.github.io/shadshiny/articles/server-api.md)
  guide for the full list.

## A complete example

``` r

library(shiny)
library(shadshiny)
`%||%` <- function(a, b) if (is.null(a)) b else a

ui <- page_shad(
  theme_preset = "violet",
  shad_card(
    shad_card_header(shad_card_title("Create account")),
    shad_card_content(
      shad_input("email", label = "Email", type = "email",
                 placeholder = "you@example.com"),
      shad_input("pw", label = "Password", type = "password",
                 description = "At least 8 characters."),
      shad_select("plan", label = "Plan",
                  choices = c(Free = "free", Pro = "pro", Team = "team"),
                  selected = "pro"),
      shad_checkbox("tos", label = "I accept the terms")
    ),
    shad_card_footer(
      shad_button("submit", "Sign up"),
      shad_button("reset", "Reset", variant = "outline")
    )
  )
)

server <- function(input, output, session) {
  sv <- shad_validator()
  sv$add_rule("email", shad_rule_required(), label = "Email")
  sv$add_rule("email", shad_rule_email())
  sv$add_rule("pw", shad_rule_required(), label = "Password")
  sv$add_rule("pw", shad_rule_min_chars(8))
  sv$add_rule("tos", shad_rule_required("Accept the terms to continue."))
  sv$enable()

  observeEvent(input$reset, {
    updateTextInput(session, "email", value = "")
    updateTextInput(session, "pw", value = "")
    update_shad_select("plan", selected = "free")
    update_shad_checkbox("tos", value = FALSE)
  })

  observeEvent(input$submit, {
    if (sv$validate()) shad_toast_success(paste("Welcome,", input$email))
  })
}

shinyApp(ui, server)
```

## Where to next

- [Server
  API](https://orijitghosh.github.io/shadshiny/articles/server-api.md) —
  updating inputs, overlays and toasts.
- [Gallery: form
  inputs](https://orijitghosh.github.io/shadshiny/articles/gallery-inputs.md)
  — every input, live.
- [Migrating from base Shiny
  inputs](https://orijitghosh.github.io/shadshiny/articles/migrating-inputs.md).
  \`\`\`

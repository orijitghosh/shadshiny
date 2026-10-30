# Structural parity against the canonical anatomy files. Each test pins an
# anatomy fragment by index (see the component's <name>.html source).
skip_if_not_installed("xml2")

test_that("parity normalization records id-attribute presence recursively", {
  a <- r_node(htmltools::tags$div(
    id = "one",
    htmltools::tags$span(
      class = "x", `aria-controls` = "panel-a",
      htmltools::tags$em("A")
    )
  ))
  b <- r_node(htmltools::tags$div(
    id = "two",
    htmltools::tags$span(
      class = "x", `aria-controls` = "panel-b",
      htmltools::tags$em("B")
    )
  ))
  expect_identical(norm_node(a), norm_node(b))

  missing <- r_node(htmltools::tags$div(
    id = "two",
    htmltools::tags$span(class = "x", htmltools::tags$em("B"))
  ))
  expect_false(identical(norm_node(a), norm_node(missing)))

  nested <- r_node(htmltools::tags$div(
    id = "two",
    htmltools::tags$span(
      class = "x", `aria-controls` = "panel-b",
      htmltools::tags$strong("B")
    )
  ))
  expect_false(identical(norm_node(a), norm_node(nested)))
})

test_that("button default matches anatomy", {
  # nodes 1..: default, secondary, destructive, outline, ghost, link
  expect_anatomy_match(shad_button("Button"), "button", index = 1)
  expect_anatomy_match(shad_button("Secondary", variant = "secondary"),
                       "button", index = 2)
})

test_that("badge variants match anatomy", {
  expect_anatomy_match(shad_badge("Badge"), "badge", index = 1)
  expect_anatomy_match(shad_badge("Secondary", variant = "secondary"),
                       "badge", index = 2)
})

test_that("separator semantic horizontal matches anatomy", {
  # nodes: 1 "Above" div, 2 semantic separator, 3 "Below" div, ...
  expect_anatomy_match(shad_separator(decorative = FALSE), "separator", index = 2)
})

test_that("representative component families match complete anatomy", {
  expect_anatomy_match(
    shad_card(
      shad_card_content("Content-only card."),
      style = "max-width: 24rem;"
    ),
    "card", index = 2
  )

  expect_anatomy_match(
    shad_input("email", type = "email", placeholder = "Email"),
    "input", index = 1
  )

  expect_anatomy_match(
    shad_checkbox("cb-terms", label = "Accept terms and conditions"),
    "checkbox", index = 1
  )

  dialog <- shad_dialog(
    "dlg",
    htmltools::tags$div(
      class = "shad-form-field",
      htmltools::tags$label(class = "shad-label", `for` = "dlg-name", "Name"),
      htmltools::tags$input(
        class = "shad-input", id = "dlg-name", type = "text",
        value = "Pedro Duarte", `data-shad-autofocus` = NA
      )
    ),
    htmltools::tags$div(
      class = "shad-form-field",
      htmltools::tags$label(
        class = "shad-label", `for` = "dlg-username", "Username"
      ),
      htmltools::tags$input(
        class = "shad-input", id = "dlg-username", type = "text",
        value = "@peduarte"
      )
    ),
    title = "Edit profile",
    description = "Make changes to your profile here. Click save when you're done.",
    footer = htmltools::tagList(
      shad_dialog_close_button("Cancel"),
      shad_button("Save changes", `data-shad-dialog-close` = NA)
    ),
    trigger = shad_button("Edit Profile", variant = "outline")
  )
  expect_anatomy_match(dialog, "dialog", index = 1)

  account_card <- shad_card(
    shad_card_header(
      shad_card_title("Account"),
      shad_card_description("Make changes to your account here.")
    ),
    shad_card_content(
      htmltools::tags$div(
        class = "shad-form-field",
        htmltools::tags$label(class = "shad-label", `for` = "tabs-name", "Name"),
        htmltools::tags$input(
          class = "shad-input", id = "tabs-name", type = "text",
          value = "Pedro Duarte"
        )
      )
    ),
    shad_card_footer(shad_button("Save changes"))
  )
  password_card <- shad_card(
    shad_card_header(
      shad_card_title("Password"),
      shad_card_description("Change your password here.")
    ),
    shad_card_content(
      htmltools::tags$div(
        class = "shad-form-field",
        htmltools::tags$label(
          class = "shad-label", `for` = "tabs-pw", "New password"
        ),
        htmltools::tags$input(
          class = "shad-input", id = "tabs-pw", type = "password"
        )
      )
    ),
    shad_card_footer(shad_button("Save password"))
  )
  tabs <- htmltools::tagAppendAttributes(
    shad_tabs(
      "tabs",
      shad_tab("account", "Account", account_card),
      shad_tab("password", "Password", password_card),
      shad_tab("team", "Team", "Team content.", disabled = TRUE)
    ),
    style = "max-width:24rem"
  )
  expect_anatomy_match(tabs, "tabs", index = 1)

  expect_anatomy_match(
    shad_progress(value = 60, label = "Progress"),
    "progress", index = 1
  )

  expect_anatomy_match(
    shad_questionnaire(
      "survey",
      shad_question(
        "direction", "What should be built?", type = "single",
        choices = c(data = "Server table", rtl = "RTL")
      )
    ),
    "questionnaire", index = 1
  )

  expect_anatomy_match(
    shad_fieldset(
      "Delivery",
      shad_field_group(
        shad_form_field(shad_input("street"), label = "Street"),
        shad_field_separator("Optional"),
        orientation = "responsive"
      ),
      description = "Where the order will be sent."
    ),
    "form-field", index = 4
  )
})

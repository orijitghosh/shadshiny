# Complete field-family constructor contracts ---------------------------------

test_that("fieldsets and groups use native form semantics", {
  ui <- shad_fieldset(
    "Delivery",
    shad_field_group(
      shad_form_field(shad_input("street"), label = "Street"),
      shad_field_separator("Optional"),
      orientation = "responsive"
    ),
    description = "Where the order will be sent."
  )
  html <- as.character(ui)
  expect_match(html, "<fieldset", fixed = TRUE)
  expect_match(html, "<legend", fixed = TRUE)
  expect_match(html, 'data-orientation="responsive"', fixed = TRUE)
  expect_match(html, "shad-field-separator", fixed = TRUE)
  expect_match(html, "Where the order will be sent.", fixed = TRUE)
})

test_that("field constructors forward attributes and custom classes", {
  group <- shad_field_group(
    shad_form_field(shad_input("email"), label = "Email"),
    orientation = "horizontal",
    class = "checkout-fields",
    `data-testid` = "checkout",
    role = "group"
  )
  group_html <- as.character(group)
  expect_match(group_html, "checkout-fields", fixed = TRUE)
  expect_match(group_html, 'data-testid="checkout"', fixed = TRUE)
  expect_match(group_html, 'role="group"', fixed = TRUE)
  expect_match(group_html, 'data-orientation="horizontal"', fixed = TRUE)

  fieldset_html <- as.character(shad_fieldset(
    "Settings",
    shad_input("timezone"),
    variant = "label",
    class = "settings-fields",
    `data-testid` = "settings"
  ))
  expect_match(fieldset_html, "settings-fields", fixed = TRUE)
  expect_match(fieldset_html, 'data-testid="settings"', fixed = TRUE)
  expect_match(fieldset_html, 'data-variant="label"', fixed = TRUE)
  expect_match(fieldset_html, "shad-fieldset__legend--label", fixed = TRUE)
})

test_that("field constructors validate orientation and preserve nested fieldsets", {
  expect_error(
    shad_field_group(orientation = "diagonal"),
    "orientation"
  )

  html <- as.character(shad_fieldset(
    "Outer",
    shad_fieldset("Inner", shad_input("nested")),
    shad_field_separator(),
    class = "outer"
  ))
  expect_match(html, "<fieldset", fixed = TRUE)
  expect_equal(length(gregexpr("<fieldset", html, fixed = TRUE)[[1]]), 2L)
  expect_match(html, 'role="separator"', fixed = TRUE)
})

test_that("labelled separators keep visible text outside the separator node", {
  html <- as.character(shad_field_separator("Optional"))
  expect_match(html, "shad-field-separator__label", fixed = TRUE)
  expect_match(html, "Optional", fixed = TRUE)
  expect_match(html, 'aria-hidden="true"', fixed = TRUE)
})

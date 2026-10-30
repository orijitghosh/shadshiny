# Questionnaire constructor, anatomy, and state-contract tests.

test_that("question definitions are serializable and names are stable", {
  q <- shad_question(
    "direction", "What should be built?",
    type = "single",
    choices = c(data = "Server table", rtl = "RTL"),
    shortcuts = c(data = "1", rtl = "2")
  )

  expect_s3_class(q, "shad_question")
  expect_identical(q$name, "direction")
  expect_identical(q$choices[[1]], list(value = "data", label = "Server table"))
  expect_identical(q$shortcuts, c(data = "1", rtl = "2"))
})

test_that("question definitions reject unstable or contradictory inputs", {
  expect_error(shad_question("", "Prompt"), "non-empty")
  expect_error(shad_question("x", "Prompt", type = "unsupported"), "type")
  expect_error(shad_question("x", "Prompt", type = "single"), "choices")
  expect_error(
    shad_question("x", "Prompt", type = "text", choices = c(A = "a")),
    "must not have choices"
  )
  expect_error(
    shad_question(
      "x", "Prompt", type = "single",
      choices = list(list(value = "a", label = "A"),
                     list(value = "a", label = "B"))
    ),
    "unique"
  )
  expect_error(
    shad_question("x", "Prompt", type = "single", choices = c(A = "a"),
                  shortcuts = c(unknown = "1")),
    "choice value"
  )
  expect_error(
    shad_question("x", "Prompt", type = "single", choices = c(A = "a"),
                  show_if = c(other = "yes")),
    "named list"
  )
})

test_that("questionnaire renders stable semantic anatomy and initial state", {
  page <- shad_questionnaire(
    "survey",
    shad_question(
      "direction", "What should be built?",
      description = "Choose one.", type = "single",
      choices = c(data = "Server table", rtl = "RTL"),
      required = TRUE, shortcuts = c(data = "1", rtl = "2")
    ),
    shad_question(
      "details", "Tell us more", type = "text", required = FALSE,
      skippable = TRUE, show_if = list(direction = "data")
    ),
    value = list(
      active = 1L,
      answers = list(direction = "data"),
      skipped = character(),
      complete = FALSE
    )
  )
  html <- as.character(page)

  expect_match(html, 'data-shad="questionnaire"')
  expect_match(html, 'data-question-name="direction"')
  expect_match(html, 'data-question-name="details"')
  expect_match(html, '<fieldset')
  expect_match(html, '<legend')
  expect_match(html, 'role="progressbar"')
  expect_match(html, 'data-questionnaire-next')
  expect_match(html, 'data-questionnaire-submit')
  expect_match(html, 'type="radio"')
  expect_match(html, 'type="text"')
  expect_match(html, 'data-question-error')
  expect_match(html, 'data-value=')
  expect_match(html, 'data-show-if=')
  expect_match(html, 'data-shortcuts=')
})

test_that("questionnaire rejects duplicate names and malformed initial state", {
  q <- shad_question("same", "One", type = "text")
  expect_error(shad_questionnaire("survey", q, q), "duplicate")
  expect_error(
    shad_questionnaire("survey", q, value = list(active = 0L)),
    "active"
  )
  expect_error(
    shad_questionnaire("survey", q, value = list(answers = list(unknown = "x"))),
    "unknown"
  )
})

test_that("questionnaire updater validates and sends partial state", {
  s <- new_fake_session(ns_prefix = "mod")
  update_shad_questionnaire(
    "survey", active = 2L, answers = list(direction = "data"),
    errors = list(details = "Required"), session = s
  )

  expect_length(s$messages, 2L)
  expect_identical(s$messages[[1]]$type, "shadshiny:update")
  expect_identical(s$messages[[1]]$message$id, "mod-survey")
  expect_identical(s$messages[[1]]$message$value,
                   list(active = 2L, answers = list(direction = "data")))
  expect_identical(s$messages[[2]]$type, "shadshiny:invoke")
  expect_identical(s$messages[[2]]$message$method, "setErrors")

  s2 <- new_fake_session()
  update_shad_questionnaire("survey", reset = TRUE, session = s2)
  expect_identical(one_message(s2)$message$method, "reset")

  expect_error(update_shad_questionnaire("survey", active = 0, session = s), "active")
  expect_error(update_shad_questionnaire("survey", answers = list("x"), session = s), "named")
  expect_error(update_shad_questionnaire("survey", errors = list("x"), session = s), "named")
})

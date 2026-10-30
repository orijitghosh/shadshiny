task_button_test_session <- function(ns_prefix = NULL) {
  session <- new_fake_session(ns_prefix)
  session$ended_callbacks <- list()
  session$onSessionEnded <- function(callback) {
    session$ended_callbacks[[length(session$ended_callbacks) + 1L]] <- callback
    invisible(NULL)
  }
  session$end <- function() {
    callbacks <- session$ended_callbacks
    for (callback in callbacks) callback()
    invisible(NULL)
  }
  session
}

task_button_fake_task <- function(initial = "initial") {
  state <- shiny::reactiveVal(initial)
  list(
    status = state,
    result = function() stop("result() must not be called", call. = FALSE),
    set_status = state
  )
}

test_that("task states map to the existing button updater patch", {
  expect_identical(
    shadshiny:::.shad_task_button_patch("initial", "Working", "Saved", "Failed"),
    list(loading = FALSE, disabled = FALSE, label = NULL)
  )
  expect_identical(
    shadshiny:::.shad_task_button_patch("running", "Working", NULL, NULL),
    list(loading = TRUE, disabled = TRUE, label = "Working")
  )
  expect_identical(
    shadshiny:::.shad_task_button_patch("success", "Working", "Saved", NULL),
    list(loading = FALSE, disabled = FALSE, label = "Saved")
  )
  expect_identical(
    shadshiny:::.shad_task_button_patch("error", "Working", NULL, "Failed"),
    list(loading = FALSE, disabled = FALSE, label = "Failed")
  )
  expect_error(
    shadshiny:::.shad_task_button_patch("paused", "Working", NULL, NULL),
    "initial, running, success, or error"
  )
})

test_that("binding validates a callable status member without inspecting result", {
  session <- task_button_test_session("module")
  expect_error(
    bind_shad_task_button(list(status = "not callable"), "run", session = session),
    "status"
  )
  expect_error(
    bind_shad_task_button(list(result = function() NULL), "run", session = session),
    "status"
  )
})

test_that("task status changes produce namespaced button patches once", {
  task <- task_button_fake_task()
  session <- task_button_test_session("module")

  observer <- bind_shad_task_button(
    task, "run", label_busy = "Working", session = session
  )
  shiny:::flushReact()
  initial_messages <- length(session$messages)
  expect_gt(initial_messages, 0L)
  expect_true(all(vapply(session$messages, function(entry) {
    identical(entry$message$id, "module-run")
  }, logical(1))) )

  task$set_status("running")
  shiny:::flushReact()
  running_messages <- length(session$messages)
  expect_gt(running_messages, initial_messages)

  task$set_status("running")
  shiny:::flushReact()
  expect_length(session$messages, running_messages)

  observer_rebound <- bind_shad_task_button(
    task, "run", label_busy = "Working", session = session
  )
  shiny:::flushReact()
  rebound_messages <- length(session$messages)

  task$set_status("success")
  shiny:::flushReact()
  expect_equal(length(session$messages) - rebound_messages, 4L)

  session$end()
  ended_messages <- length(session$messages)
  task$set_status("error")
  shiny:::flushReact()
  expect_length(session$messages, ended_messages)

  observer$destroy()
  observer_rebound$destroy()
})

test_that("custom binding discovery is literal, unique, and option-aware", {
  source <- paste(
    'makeShadBinding("checkbox");',
    'makeShadBinding("slider", { debounce: true });',
    'makeShadBinding("dialog", { alsoOpenClose: true });',
    'makeShadBinding("calendar", { type: "shadshiny.date" });'
  )

  bindings <- contract_custom_bindings(source)

  expect_identical(
    bindings$component,
    c("checkbox", "slider", "dialog", "calendar")
  )
  expect_identical(
    bindings$binding_type,
    c(NA_character_, NA_character_, NA_character_, "shadshiny.date")
  )
  expect_identical(bindings$debounce, c(FALSE, TRUE, FALSE, FALSE))
  expect_identical(bindings$open_close, c(FALSE, FALSE, TRUE, FALSE))
})

test_that("custom binding discovery fails closed for absent registrations", {
  expect_error(
    contract_custom_bindings("const component = 'not-a-binding';"),
    "no makeShadBinding"
  )
})

test_that("custom binding discovery rejects duplicate component registrations", {
  source <- paste(
    'makeShadBinding("x");',
    'makeShadBinding("x");',
    sep = "\n"
  )

  expect_error(
    contract_custom_bindings(source),
    "duplicate.*x"
  )
})

test_that("R function parsing keeps restoreInput evidence within its function", {
  r_file <- tempfile(fileext = ".R")
  writeLines(
    c(
      "first <- function(id) shiny::restoreInput(id, FALSE)",
      "second <- function(id) FALSE"
    ),
    r_file
  )

  functions <- contract_r_functions(r_file)

  expect_setequal(names(functions), c("first", "second"))
  expect_match(functions$first, "restoreInput", fixed = TRUE)
  expect_false(grepl("restoreInput", functions$second, fixed = TRUE))
})

test_that("contract source reads are UTF-8 and fail for missing files", {
  root <- tempfile("contract-root-")
  dir.create(root)
  on.exit(unlink(root, recursive = TRUE), add = TRUE)
  writeLines(enc2utf8("caf\u00e9"), file.path(root, "source.txt"), useBytes = TRUE)

  expect_identical(contract_read("source.txt", root), "caf\u00e9")
  expect_error(contract_read("missing.txt", root), "contract source missing")
})

test_that("project root discovery resolves the R CMD check source tree", {
  check_root <- tempfile("contract-check-")
  test_root <- file.path(check_root, "tests", "testthat")
  source_root <- file.path(check_root, "00_pkg_src", "shadshiny")
  marker_root <- file.path(source_root, "inst", "assets", "shiny")
  dir.create(test_root, recursive = TRUE)
  dir.create(marker_root, recursive = TRUE)
  on.exit(unlink(check_root, recursive = TRUE), add = TRUE)
  writeLines("Package: shadshiny", file.path(source_root, "DESCRIPTION"))
  writeLines("// binding source", file.path(marker_root, "shadshiny-shiny.js"))

  expect_identical(
    contract_find_root(test_root),
    normalizePath(source_root, winslash = "/", mustWork = TRUE)
  )
})

test_that("project root discovery honors an explicit source root", {
  source_root <- tempfile("contract-explicit-")
  marker_root <- file.path(source_root, "inst", "assets", "shiny")
  dir.create(marker_root, recursive = TRUE)
  on.exit(unlink(source_root, recursive = TRUE), add = TRUE)
  writeLines("Package: shadshiny", file.path(source_root, "DESCRIPTION"))
  writeLines("// binding source", file.path(marker_root, "shadshiny-shiny.js"))
  withr::local_envvar(SHADSHINY_SOURCE_ROOT = source_root)

  expect_identical(
    contract_project_root(),
    normalizePath(source_root, winslash = "/", mustWork = TRUE)
  )
})

# CRAN's Windows check (win-builder, 2026-11-08) runs the tests with no copy of
# the package sources nearby, so the tests that read them have nothing to read.
# They skip there. With NOT_CRAN=true a missing tree is still an error, so a
# developer or CI run cannot skip them without saying so.
test_that("project root discovery skips off-tree on CRAN and fails elsewhere", {
  off_tree <- tempfile("contract-off-tree-")
  dir.create(off_tree)
  on.exit(unlink(off_tree, recursive = TRUE), add = TRUE)
  skip_if(
    !is.null(tryCatch(contract_find_root(off_tree), error = function(e) NULL)),
    "the temporary directory sits inside a shadshiny source tree"
  )
  withr::local_envvar(SHADSHINY_SOURCE_ROOT = NA, NOT_CRAN = NA)
  lenient <- tryCatch(contract_project_root(starts = off_tree), condition = identity)
  expect_s3_class(lenient, "skip")

  withr::local_envvar(NOT_CRAN = "true")
  strict <- tryCatch(contract_project_root(starts = off_tree), condition = identity)
  expect_s3_class(strict, "error")
  expect_match(conditionMessage(strict), "could not locate shadshiny source root")
})

test_that("runtime discovery appends a unique shared menu provider", {
  root <- tempfile("contract-root-")
  components <- file.path(root, "inst", "assets", "components")
  dir.create(file.path(components, "menu"), recursive = TRUE)
  dir.create(file.path(components, "consumer"), recursive = TRUE)
  on.exit(unlink(root, recursive = TRUE), add = TRUE)
  writeLines(
    c(
      "shad.__menuCore = { panel: function () {} };",
      'shad.register("menu", function (root) { return {}; });'
    ),
    file.path(components, "menu", "menu.js")
  )
  writeLines(
    c(
      'shad.register("consumer", function (root) {',
      "  return shad.__menuCore.panel(root);",
      "});"
    ),
    file.path(components, "consumer", "consumer.js")
  )

  sources <- contract_runtime_sources(root)

  expect_setequal(names(sources), c("menu", "consumer"))
  expect_match(sources$consumer, "shad.__menuCore =", fixed = TRUE)
})

test_that("native adapters are narrow and point to exported constructors", {
  native <- contract_native_bindings()

  expect_identical(
    native$component,
    c("input", "textarea", "button", "dropzone")
  )
  expect_identical(
    native$constructor,
    c("shad_input", "shad_textarea", "shad_button", "shad_dropzone")
  )
  expect_true(all(nzchar(native$mechanism)))
})

test_that("side input discovery pairs each listener with its input suffix", {
  source <- paste(
    "if (!root.matches('[data-shad=\"command\"]')) return;",
    "Shiny.setInputValue(root.id + \"_event\", {",
    "});",
    "if (!root.matches('[data-shad=\"tree\"]')) return;",
    "Shiny.setInputValue(root.id + \"_expanded\", {",
    sep = "\n"
  )

  side <- contract_side_inputs(source)

  expect_identical(side$component, c("command", "tree"))
  expect_identical(side$suffix, c("_event", "_expanded"))
  expect_error(
    contract_side_inputs('Shiny.setInputValue(root.id + "_orphan", 1);'),
    "side input.*_orphan"
  )
})

test_that("an exported updater is updater evidence for event-valued inputs too", {
  audit <- build_component_contracts()
  exports <- contract_exported_names(contract_project_root())
  exported <- paste0("update_", audit$constructor) %in% exports

  expect_identical(audit$component[exported & !audit$has_updater], character())
})

test_that("each side input is named on its constructor's help page", {
  audit <- build_component_contracts()
  side <- contract_side_inputs(contract_read(
    "inst/assets/shiny/shadshiny-shiny.js"
  ))

  expect_gt(nrow(side), 0L)
  expect_identical(
    side$component[!audit$has_documentation[match(side$component, audit$component)]],
    character()
  )
})

test_that("exception policy rejects stale and vague records", {
  discovered <- c("checkbox", "dropzone")
  stale <- data.frame(
    component = "ghost",
    dimension = "bookmark",
    reason = "not applicable",
    mechanism = "none"
  )
  expect_error(
    validate_contract_exceptions(stale, discovered),
    "undiscovered.*ghost"
  )

  vague <- data.frame(
    component = "dropzone",
    dimension = "bookmark",
    reason = "N/A",
    mechanism = "none"
  )
  expect_error(
    validate_contract_exceptions(vague, discovered),
    "meaningful reason"
  )
})

test_that("exception policy rejects duplicate and unknown dimensions", {
  duplicate <- data.frame(
    component = c("dropzone", "dropzone"),
    dimension = c("bookmark", "bookmark"),
    reason = rep("Browser security prevents restoring selected local files.", 2),
    mechanism = rep("Shiny file upload lifecycle", 2)
  )
  expect_error(
    validate_contract_exceptions(duplicate, "dropzone"),
    "duplicate.*dropzone.*bookmark"
  )

  unknown <- duplicate[1, ]
  unknown$dimension <- "imaginary"
  expect_error(
    validate_contract_exceptions(unknown, "dropzone"),
    "unknown dimension.*imaginary"
  )
})

test_that("failure formatting is compact and deterministic", {
  failures <- data.frame(
    component = c("collapsible", "resizable"),
    dimension = c("bookmark", "updater"),
    expected = c("restoreInput", "exported updater"),
    discovered = c("absent", "absent")
  )

  text <- format_component_contract_failures(failures)

  expect_match(text, "collapsible.*bookmark.*restoreInput.*absent")
  expect_match(text, "resizable.*updater.*exported updater.*absent")
})

test_that("derived population reconciles custom and native inputs exactly", {
  root <- contract_project_root()
  shiny_source <- contract_read(
    "inst/assets/shiny/shadshiny-shiny.js",
    root
  )
  custom <- contract_custom_bindings(shiny_source)
  native <- contract_native_bindings()
  audit <- build_component_contracts(root)

  expect_length(custom$component, 35L)
  expect_identical(nrow(native), 4L)
  expect_identical(nrow(audit), nrow(custom) + nrow(native))
  expect_setequal(audit$component, c(custom$component, native$component))
})

test_that("form-field remains a runtime factory but is not a Shiny input binding", {
  root <- contract_project_root()
  shiny_source <- contract_read(
    "inst/assets/shiny/shadshiny-shiny.js",
    root
  )
  custom <- contract_custom_bindings(shiny_source)
  runtime <- contract_runtime_sources(root)

  expect_false("form-field" %in% custom$component)
  expect_true("form-field" %in% names(runtime))
})

test_that("every discovered stateful component has a complete contract", {
  audit <- build_component_contracts()
  expect_gt(nrow(audit), 30L)
  expect_identical(anyDuplicated(audit$component), 0L)
  expect_true(all(c("binding_mechanism", "contract_status") %in% names(audit)))
  expect_identical(length(audit$contract_status), nrow(audit))

  expected_custom <- contract_custom_bindings(contract_read(
    "inst/assets/shiny/shadshiny-shiny.js"
  ))$component
  expect_setequal(
    audit$component[audit$binding_mechanism == "custom"],
    expected_custom
  )
  expect_identical(sum(audit$binding_mechanism == "native"), 4L)
  expect_false("form-field" %in% audit$component)

  exceptions <- contract_exceptions()
  validate_contract_exceptions(exceptions, audit$component)
  protected_repairs <- paste(
    c("collapsible", "collapsible", "resizable"),
    c("updater", "bookmark", "updater"),
    sep = "/"
  )
  exception_keys <- paste(
    exceptions$component,
    exceptions$dimension,
    sep = "/"
  )
  expect_false(any(protected_repairs %in% exception_keys))

  failures <- component_contract_failures(audit, exceptions)
  expect_true(all(audit$contract_status %in% c("pass", "justified_n_a")))
  expect_equal(
    failures,
    failures[0, ],
    info = format_component_contract_failures(failures)
  )
})

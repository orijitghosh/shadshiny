contract_find_root <- function(start) {
  current <- normalizePath(start, winslash = "/", mustWork = TRUE)
  for (depth in 0:8) {
    candidates <- c(
      current,
      file.path(current, "00_pkg_src", "shadshiny")
    )
    for (candidate in candidates) {
      if (
        file.exists(file.path(candidate, "DESCRIPTION")) &&
          file.exists(file.path(
            candidate,
            "inst",
            "assets",
            "shiny",
            "shadshiny-shiny.js"
          ))
      ) {
        return(normalizePath(
          candidate,
          winslash = "/",
          mustWork = TRUE
        ))
      }
    }

    parent <- dirname(current)
    if (identical(parent, current)) break
    current <- parent
  }
  stop("could not locate shadshiny source root from: ", start, call. = FALSE)
}

contract_project_root <- function() {
  explicit <- Sys.getenv("SHADSHINY_SOURCE_ROOT", unset = "")
  if (nzchar(explicit)) return(contract_find_root(explicit))

  starts <- unique(c(testthat::test_path(), getwd()))
  for (start in starts) {
    root <- tryCatch(contract_find_root(start), error = function(error) NULL)
    if (!is.null(root)) return(root)
  }
  stop("could not locate shadshiny source root", call. = FALSE)
}

contract_read <- function(path, root = contract_project_root()) {
  full <- file.path(root, path)
  if (!file.exists(full)) {
    stop("contract source missing: ", path, call. = FALSE)
  }
  paste(
    readLines(full, warn = FALSE, encoding = "UTF-8"),
    collapse = "\n"
  )
}

contract_custom_bindings <- function(text) {
  pattern <- paste0(
    'makeShadBinding\\("([^"]+)"',
    '([^;]*)\\);'
  )
  raw <- regmatches(text, gregexpr(pattern, text, perl = TRUE))[[1]]
  if (!length(raw)) {
    stop("no makeShadBinding registrations discovered", call. = FALSE)
  }

  component <- sub(pattern, "\\1", raw, perl = TRUE)
  options <- sub(pattern, "\\2", raw, perl = TRUE)
  duplicate <- unique(component[duplicated(component)])
  if (length(duplicate)) {
    stop(
      "duplicate makeShadBinding registration: ",
      paste(duplicate, collapse = ", "),
      call. = FALSE
    )
  }

  binding_type <- ifelse(
    grepl('type:\\s*"', options),
    sub('.*type:\\s*"([^"]+)".*', "\\1", options),
    NA_character_
  )
  data.frame(
    component = component,
    binding_type = unname(binding_type),
    debounce = grepl("debounce:\\s*true", options),
    open_close = grepl("alsoOpenClose:\\s*true", options),
    stringsAsFactors = FALSE
  )
}

contract_side_inputs <- function(text) {
  pattern <- '\\[data-shad="([a-z-]+)"\\][^{}]*?root[.]id [+] "(_[A-Za-z]+)"'
  raw <- regmatches(text, gregexpr(pattern, text, perl = TRUE))[[1]]
  side <- data.frame(
    component = sub(pattern, "\\1", raw, perl = TRUE),
    suffix = sub(pattern, "\\2", raw, perl = TRUE),
    stringsAsFactors = FALSE
  )

  suffix_pattern <- 'root[.]id [+] "(_[A-Za-z]+)"'
  suffixes <- sub(
    suffix_pattern,
    "\\1",
    regmatches(text, gregexpr(suffix_pattern, text, perl = TRUE))[[1]],
    perl = TRUE
  )
  orphan <- setdiff(suffixes, side$suffix)
  if (length(orphan)) {
    stop(
      "side input without a data-shad listener: ",
      paste(orphan, collapse = ", "),
      call. = FALSE
    )
  }
  side
}

contract_r_functions <- function(paths) {
  functions <- list()
  for (path in paths) {
    expressions <- parse(path, keep.source = FALSE)
    for (expression in expressions) {
      if (
        !is.call(expression) ||
          !identical(expression[[1]], as.name("<-")) ||
          !is.symbol(expression[[2]]) ||
          !is.call(expression[[3]]) ||
          !identical(expression[[3]][[1]], as.name("function"))
      ) {
        next
      }
      functions[[as.character(expression[[2]])]] <- paste(
        deparse(expression[[3]], width.cutoff = 500L),
        collapse = "\n"
      )
    }
  }
  functions
}

contract_runtime_sources <- function(root = contract_project_root()) {
  component_root <- file.path(root, "inst", "assets", "components")
  paths <- list.files(
    component_root,
    pattern = "[.]js$",
    recursive = TRUE,
    full.names = TRUE
  )
  if (!length(paths)) {
    stop("no component JavaScript sources discovered", call. = FALSE)
  }

  sources <- lapply(paths, function(path) {
    paste(readLines(path, warn = FALSE, encoding = "UTF-8"), collapse = "\n")
  })
  registration_pattern <- 'shad[.]register\\(\\s*"([^"]+)"'
  components <- lapply(sources, function(source) {
    raw <- regmatches(
      source,
      gregexpr(registration_pattern, source, perl = TRUE)
    )[[1]]
    if (!length(raw)) character() else sub(
      registration_pattern,
      "\\1",
      raw,
      perl = TRUE
    )
  })

  names_found <- unlist(components, use.names = FALSE)
  if (!length(names_found)) {
    stop("no shad.register registrations discovered", call. = FALSE)
  }
  duplicate <- unique(names_found[duplicated(names_found)])
  if (length(duplicate)) {
    stop(
      "duplicate shad.register registration: ",
      paste(duplicate, collapse = ", "),
      call. = FALSE
    )
  }

  runtime <- list()
  for (index in seq_along(sources)) {
    for (component in components[[index]]) {
      runtime[[component]] <- sources[[index]]
    }
  }

  uses_menu_core <- vapply(
    runtime,
    grepl,
    logical(1),
    pattern = "shad.__menuCore",
    fixed = TRUE
  )
  if (any(uses_menu_core)) {
    providers <- sources[vapply(
      sources,
      grepl,
      logical(1),
      pattern = "shad.__menuCore =",
      fixed = TRUE
    )]
    if (length(providers) != 1L) {
      stop(
        "expected one shad.__menuCore provider; discovered ",
        length(providers),
        call. = FALSE
      )
    }
    runtime[uses_menu_core] <- lapply(
      runtime[uses_menu_core],
      function(source) paste(source, providers[[1]], sep = "\n")
    )
  }

  runtime
}

contract_dimensions <- function() {
  c(
    "constructor",
    "runtime",
    "value_schema",
    "updater",
    "bookmark",
    "accessibility",
    "documentation",
    "representative_test"
  )
}

contract_native_bindings <- function() {
  data.frame(
    component = c("input", "textarea", "button", "dropzone"),
    constructor = c(
      "shad_input",
      "shad_textarea",
      "shad_button",
      "shad_dropzone"
    ),
    mechanism = c(
      "native text input",
      "native textarea",
      "action-button",
      "hidden shiny fileInput bridge"
    ),
    stringsAsFactors = FALSE
  )
}

contract_exceptions <- function() {
  records <- list()
  add <- function(components, dimensions, reason, mechanism) {
    grid <- expand.grid(
      component = components,
      dimension = dimensions,
      stringsAsFactors = FALSE
    )
    grid$reason <- reason
    grid$mechanism <- mechanism
    records[[length(records) + 1L]] <<- grid
  }

  add(
    c("dialog", "alert-dialog", "sheet", "drawer", "popover"),
    "bookmark",
    "Transient overlay visibility is intentionally not restored as input state.",
    "exported open and close helpers"
  )
  add(
    c("dropdown-menu", "context-menu", "menubar", "command"),
    "bookmark",
    "The value records the last activation event and is not persistent visible state.",
    "new user activation emits the next event"
  )
  add(
    c("dropdown-menu", "context-menu", "menubar"),
    "updater",
    "The value records the last activation event and is not persistent visible state.",
    "new user activation emits the next event"
  )
  add(
    "navigation-menu",
    c("bookmark", "updater"),
    "The open panel is transient navigation state rather than a persistent value.",
    "link or trigger interaction controls the panel"
  )
  add(
    c("carousel", "sidebar", "resizable", "data-table"),
    "bookmark",
    "Composite state has no single constructor initial-value contract to seed.",
    "application onRestored observer and existing updater where applicable"
  )
  add(
    "dropzone",
    c("bookmark", "updater"),
    "Browser security prevents restoring or programmatically selecting local files.",
    "Shiny file upload lifecycle"
  )
  add(
    "button",
    "bookmark",
    "An action-button count represents activations rather than restorable UI state.",
    "native Shiny action-button lifecycle"
  )

  do.call(rbind, records)
}

validate_contract_exceptions <- function(
  exceptions,
  discovered,
  dimensions = contract_dimensions()
) {
  required <- c("component", "dimension", "reason", "mechanism")
  missing_columns <- setdiff(required, names(exceptions))
  if (length(missing_columns)) {
    stop(
      "exception policy missing columns: ",
      paste(missing_columns, collapse = ", "),
      call. = FALSE
    )
  }

  fields <- exceptions[required]
  missing_field <- is.na(fields) | !nzchar(trimws(as.matrix(fields)))
  if (any(missing_field)) {
    stop("exception policy contains empty fields", call. = FALSE)
  }

  unknown_component <- setdiff(unique(exceptions$component), discovered)
  if (length(unknown_component)) {
    stop(
      "exception names undiscovered component: ",
      paste(unknown_component, collapse = ", "),
      call. = FALSE
    )
  }

  vague_reason <- nchar(trimws(exceptions$reason)) <= 20L |
    grepl(
      "^(N/?A|none|not applicable)$",
      trimws(exceptions$reason),
      ignore.case = TRUE
    )
  if (any(vague_reason)) {
    stop("exception policy requires a meaningful reason", call. = FALSE)
  }

  unknown_dimension <- setdiff(unique(exceptions$dimension), dimensions)
  if (length(unknown_dimension)) {
    stop(
      "unknown dimension in exception policy: ",
      paste(unknown_dimension, collapse = ", "),
      call. = FALSE
    )
  }

  key <- paste(exceptions$component, exceptions$dimension, sep = "/")
  duplicate <- unique(key[duplicated(key)])
  if (length(duplicate)) {
    stop(
      "duplicate exception records: ",
      paste(duplicate, collapse = ", "),
      call. = FALSE
    )
  }

  invisible(exceptions)
}

contract_exported_names <- function(root) {
  namespace <- contract_read("NAMESPACE", root)
  raw <- regmatches(
    namespace,
    gregexpr("(?m)^export\\(([^)]+)\\)$", namespace, perl = TRUE)
  )[[1]]
  sub("^export\\(([^)]+)\\)$", "\\1", raw)
}

contract_all_source <- function(paths) {
  if (!length(paths)) return("")
  paste(vapply(
    paths,
    function(path) paste(
      readLines(path, warn = FALSE, encoding = "UTF-8"),
      collapse = "\n"
    ),
    character(1)
  ), collapse = "\n")
}

build_component_contracts <- function(root = contract_project_root()) {
  binding_source <- contract_read(
    "inst/assets/shiny/shadshiny-shiny.js",
    root
  )
  custom <- contract_custom_bindings(binding_source)
  native <- contract_native_bindings()
  components <- c(custom$component, native$component)
  kind <- c(rep("custom", nrow(custom)), rep("native", nrow(native)))

  constructor <- paste0("shad_", gsub("-", "_", components, fixed = TRUE))
  constructor[components == "number-stepper"] <- "shad_number_input"
  constructor[components == "sidebar"] <- "shad_sidebar_layout"
  constructor[match(native$component, components)] <- native$constructor

  r_paths <- list.files(
    file.path(root, "R"),
    pattern = "[.]R$",
    full.names = TRUE
  )
  r_functions <- contract_r_functions(r_paths)
  exports <- contract_exported_names(root)
  runtime <- contract_runtime_sources(root)

  constructor_source <- vapply(
    constructor,
    function(name) r_functions[[name]] %||% "",
    character(1)
  )
  has_constructor <- constructor %in% exports & nzchar(constructor_source)

  runtime_source <- vapply(
    components,
    function(component) runtime[[component]] %||% "",
    character(1)
  )
  has_runtime <- logical(length(components))
  custom_index <- kind == "custom"
  has_runtime[custom_index] <- vapply(
    runtime_source[custom_index],
    function(source) {
      nzchar(source) &&
        grepl("getValue", source, fixed = TRUE) &&
        grepl("setValue", source, fixed = TRUE) &&
        (
          grepl("shad:change", source, fixed = TRUE) ||
            (
              grepl("shad:open", source, fixed = TRUE) &&
                grepl("shad:close", source, fixed = TRUE)
            )
        )
    },
    logical(1)
  )
  native_patterns <- c(
    input = "tags$input",
    textarea = "tags$textarea",
    button = "action-button",
    dropzone = "fileInput"
  )
  native_index <- kind == "native"
  has_runtime[native_index] <- mapply(
    function(component, source) {
      grepl(native_patterns[[component]], source, fixed = TRUE)
    },
    components[native_index],
    constructor_source[native_index],
    USE.NAMES = FALSE
  )

  readme_source <- vapply(
    components,
    function(component) {
      path <- file.path(
        "inst",
        "assets",
        "components",
        component,
        "README.md"
      )
      contract_read(path, root)
    },
    character(1)
  )
  has_value_schema <- grepl(
    "getValue|input\\$|value|action[- ]button|click.*event|file upload",
    readme_source,
    ignore.case = TRUE,
    perl = TRUE
  )

  updater <- paste0("update_", constructor)
  updater[components == "sidebar"] <- "update_shad_sidebar"
  has_updater <- updater %in% exports
  has_updater[components == "input"] <- grepl(
    "updateTextInput",
    contract_read("vignettes/server-api.Rmd", root),
    fixed = TRUE
  )
  has_updater[components == "textarea"] <- grepl(
    "updateTextAreaInput",
    contract_read("vignettes/server-api.Rmd", root),
    fixed = TRUE
  )
  overlay_components <- c("dialog", "alert-dialog", "sheet", "drawer", "popover")
  overlay_prefix <- paste0("shad_", gsub("-", "_", overlay_components))
  has_updater[match(overlay_components, components)] <- vapply(
    overlay_prefix,
    function(prefix) {
      all(paste0(prefix, c("_open", "_close")) %in% exports)
    },
    logical(1)
  )
  has_bookmark <- grepl("shiny::restoreInput", constructor_source, fixed = TRUE)

  implementation_source <- paste(constructor_source, runtime_source, sep = "\n")
  has_accessibility <- grepl(
    "aria-|role|keydown|keyup|keyCode|tags\\$input|tags\\$textarea|tags\\$button|fileInput|action-button",
    implementation_source,
    ignore.case = TRUE,
    perl = TRUE
  )

  rd_paths <- list.files(
    file.path(root, "man"),
    pattern = "[.]Rd$",
    full.names = TRUE
  )
  rd_topics <- vapply(rd_paths, contract_all_source, character(1))
  rd_source <- paste(rd_topics, collapse = "\n")
  has_documentation <- vapply(
    constructor,
    function(name) grepl(
      paste0("\\\\alias\\{", name, "\\}"),
      rd_source,
      perl = TRUE
    ),
    logical(1)
  )
  server_api <- contract_read("vignettes/server-api.Rmd", root)
  stale_otp_copy <- grepl(
    "(?s)saved but.*not seeded back.*shad_input_otp\\(\\)",
    server_api,
    perl = TRUE
  )
  if (stale_otp_copy) {
    has_documentation[components == "input-otp"] <- FALSE
  }
  # a side input (command's _event, tree's _expanded) belongs on the
  # constructor's own help page, not only in an article
  side_inputs <- contract_side_inputs(binding_source)
  for (index in seq_len(nrow(side_inputs))) {
    row <- match(side_inputs$component[[index]], components)
    if (is.na(row)) {
      stop(
        "side input for undiscovered component: ",
        side_inputs$component[[index]],
        call. = FALSE
      )
    }
    topic <- rd_topics[grepl(
      paste0("\\\\alias\\{", constructor[[row]], "\\}"),
      rd_topics,
      perl = TRUE
    )]
    if (!any(grepl(side_inputs$suffix[[index]], topic, fixed = TRUE))) {
      has_documentation[[row]] <- FALSE
    }
  }

  test_paths <- list.files(
    file.path(root, "tests", "testthat"),
    pattern = "[.]R$",
    recursive = TRUE,
    full.names = TRUE
  )
  test_paths <- test_paths[!basename(test_paths) %in% c(
    "helper-component-contracts.R",
    "test-component-contracts.R"
  )]
  test_source <- contract_all_source(test_paths)
  has_representative_test <- vapply(
    constructor,
    grepl,
    logical(1),
    x = test_source,
    fixed = TRUE
  )

  audit <- data.frame(
    component = components,
    kind = kind,
    binding_mechanism = kind,
    constructor = constructor,
    has_constructor = has_constructor,
    has_runtime = has_runtime,
    has_value_schema = has_value_schema,
    has_updater = has_updater,
    has_bookmark = has_bookmark,
    has_accessibility = has_accessibility,
    has_documentation = has_documentation,
    has_representative_test = has_representative_test,
    stringsAsFactors = FALSE
  )
  for (dimension in contract_dimensions()) {
    audit[[paste0("required_", dimension)]] <- TRUE
  }
  exceptions <- contract_exceptions()
  failures <- component_contract_failures(audit, exceptions)
  audit$contract_status <- "pass"
  audit$contract_status[audit$component %in% exceptions$component] <-
    "justified_n_a"
  audit$contract_status[audit$component %in% failures$component] <- "fail"
  audit
}

component_contract_failures <- function(audit, exceptions = contract_exceptions()) {
  dimensions <- contract_dimensions()
  validate_contract_exceptions(exceptions, audit$component, dimensions)

  required <- setNames(
    lapply(dimensions, function(dimension) {
      audit[[paste0("required_", dimension)]]
    }),
    dimensions
  )
  for (index in seq_len(nrow(exceptions))) {
    component_index <- match(exceptions$component[[index]], audit$component)
    dimension <- exceptions$dimension[[index]]
    if (isTRUE(audit[[paste0("has_", dimension)]][[component_index]])) {
      stop(
        "stale exception masks observed evidence: ",
        exceptions$component[[index]],
        "/",
        dimension,
        call. = FALSE
      )
    }
    required[[dimension]][[component_index]] <- FALSE
  }

  expected_by_dimension <- c(
    constructor = "exported constructor and input root",
    runtime = "matching value runtime and change route",
    value_schema = "documented input value shape",
    updater = "exported updater or imperative route",
    bookmark = "function-local restoreInput",
    accessibility = "semantic or keyboard implementation",
    documentation = "generated Rd and accurate server guidance",
    representative_test = "representative R test coverage"
  )
  failures <- list()
  for (row in seq_len(nrow(audit))) {
    for (dimension in dimensions) {
      if (
        isTRUE(required[[dimension]][[row]]) &&
          !isTRUE(audit[[paste0("has_", dimension)]][[row]])
      ) {
        failures[[length(failures) + 1L]] <- data.frame(
          component = audit$component[[row]],
          dimension = dimension,
          expected = unname(expected_by_dimension[[dimension]]),
          discovered = "absent",
          stringsAsFactors = FALSE
        )
      }
    }
  }

  if (!length(failures)) {
    return(data.frame(
      component = character(),
      dimension = character(),
      expected = character(),
      discovered = character(),
      stringsAsFactors = FALSE
    ))
  }
  do.call(rbind, failures)
}

format_component_contract_failures <- function(failures) {
  if (!nrow(failures)) return("component contract audit passed")
  lines <- sprintf(
    "%s | %s | %s | %s",
    failures$component,
    failures$dimension,
    failures$expected,
    failures$discovered
  )
  paste(c("component | dimension | expected | discovered", lines), collapse = "\n")
}

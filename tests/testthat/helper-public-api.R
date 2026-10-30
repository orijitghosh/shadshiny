public_api_fixture_path <- function(filename) {
  path <- testthat::test_path("fixtures", filename)
  if (!file.exists(path)) {
    stop(
      "public API baseline is missing: ",
      filename,
      call. = FALSE
    )
  }
  path
}

public_api_export_baseline <- function() {
  exports <- readLines(
    public_api_fixture_path("public-api-exports.txt"),
    warn = FALSE,
    encoding = "UTF-8"
  )
  exports <- exports[nzchar(exports)]
  if (!length(exports)) {
    stop("public API export baseline is empty", call. = FALSE)
  }
  if (anyDuplicated(exports)) {
    stop("public API export baseline contains duplicates", call. = FALSE)
  }
  if (!identical(exports, sort(exports))) {
    stop("public API export baseline must be sorted", call. = FALSE)
  }
  exports
}

public_api_formals_baseline <- function() {
  baseline <- utils::read.delim(
    public_api_fixture_path("public-api-formals.tsv"),
    quote = "",
    comment.char = "",
    check.names = FALSE,
    stringsAsFactors = FALSE
  )
  required <- c("name", "signature")
  if (!identical(names(baseline), required)) {
    stop(
      "public API formals baseline must contain name and signature columns",
      call. = FALSE
    )
  }
  if (!nrow(baseline) || any(!nzchar(baseline$name)) ||
      any(!nzchar(baseline$signature))) {
    stop("public API formals baseline contains empty values", call. = FALSE)
  }
  if (anyDuplicated(baseline$name)) {
    stop("public API formals baseline contains duplicate names", call. = FALSE)
  }
  if (!identical(baseline$name, sort(baseline$name))) {
    stop("public API formals baseline must be sorted", call. = FALSE)
  }
  baseline
}

public_api_current_exports <- function(root = contract_project_root()) {
  sort(contract_exported_names(root))
}

public_api_required_formal_names <- function(exports) {
  imperative <- grepl(
    "_(open|close|dismiss|remove)$",
    exports,
    perl = TRUE
  )
  sort(unique(c(
    exports[startsWith(exports, "update_shad_") | imperative],
    "page_shad",
    "shad_chat_server",
    "shad_chat_ui",
    "shad_col",
    "shad_command_palette",
    "shad_data_table",
    "shad_data_table_server",
    "bind_shad_task_button",
    "shad_page_navbar",
    "shad_page_sidebar",
    "shad_run_example",
    "shad_show_dialog",
    "shad_theme",
    "shad_theme_from_registry",
    "shad_theme_scope",
    "shad_tokens",
    "shad_validator"
  )))
}

public_api_formal_text <- function(value) {
  if (identical(value, quote(expr = ))) return(NULL)
  paste(deparse(value, width.cutoff = 500L), collapse = " ")
}

public_api_signature <- function(name) {
  value <- getExportedValue("shadshiny", name)
  if (!is.function(value)) {
    stop("protected public API is not a function: ", name, call. = FALSE)
  }
  formals_list <- formals(value)
  pieces <- Map(function(argument, default) {
    default_text <- public_api_formal_text(default)
    if (is.null(default_text)) argument else paste0(
      argument,
      " = ",
      default_text
    )
  }, names(formals_list), formals_list)
  paste0("function(", paste(unlist(pieces, use.names = FALSE), collapse = ", "), ")")
}

public_api_current_formals <- function(names) {
  data.frame(
    name = names,
    signature = unname(vapply(names, public_api_signature, character(1))),
    stringsAsFactors = FALSE
  )
}

format_public_api_export_changes <- function(actual, expected) {
  added <- setdiff(actual, expected)
  removed <- setdiff(expected, actual)
  paste(
    "Public API export set changed.",
    paste0("Added: ", if (length(added)) paste(added, collapse = ", ") else "none"),
    paste0(
      "Removed: ",
      if (length(removed)) paste(removed, collapse = ", ") else "none"
    ),
    "Before updating the baseline, explicitly decide whether to preserve compatibility, deprecate with a replacement, or document an intentional breaking change in NEWS/versioning.",
    "Do not refresh the baseline automatically.",
    sep = "\n"
  )
}

format_public_api_formal_changes <- function(actual, expected) {
  changed <- expected$name[actual$signature != expected$signature]
  details <- vapply(changed, function(name) {
    index <- match(name, expected$name)
    paste0(
      name,
      "\n  expected: ", expected$signature[[index]],
      "\n  actual:   ", actual$signature[[index]]
    )
  }, character(1))
  paste(
    "Protected public API formals changed.",
    paste(details, collapse = "\n"),
    "Before updating the baseline, explicitly decide whether to preserve compatibility, deprecate the old call shape, or document an intentional breaking change in NEWS/versioning.",
    "Do not refresh the baseline automatically.",
    sep = "\n"
  )
}

# The advertised component count, API totals, and experimental labels are
# derived from the source, so the documentation cannot drift from it.

# Counting rule: a component is a directory under inst/assets/components with
# an exported constructor of its own. Page wrappers, aliases, and utilities that
# share a directory (shad_kbd_group() in typography, shad_fieldset() in
# form-field) add nothing. These directories render only inside the component
# whose R file is named, so they are parts, not components.
documented_part_directories <- c(
  "chat-branch" = "R/chat-workbench.R",
  "chat-prompt" = "R/chat-workbench.R",
  "chat-source" = "R/chat-workbench.R",
  "chat-tool" = "R/chat-workbench.R",
  "date-range-presets" = "R/date-range.R"
)

# The experimental boundary named in README's "API stability" section.
documented_experimental <- c(
  "shad_theme_from_registry",
  "shad_theme_ggplot2", "shad_scale_color_shad", "shad_scale_fill_shad",
  "shad_theme_plotly", "shad_theme_echarts4r",
  "shad_data_table_server",
  "shad_questionnaire", "shad_question", "update_shad_questionnaire",
  "bind_shad_task_button",
  "shad_chat_workbench_ui", "shad_chat_workbench_server",
  "shad_fieldset", "shad_field_group", "shad_field_separator"
)

documented_text <- function(path, root) {
  text <- gsub("(?m)^#' ?", "", contract_read(path, root), perl = TRUE)
  gsub("\\s+", " ", text)
}

documented_numbers <- function(text, pattern) {
  hits <- regmatches(text, gregexpr(pattern, text, perl = TRUE))[[1]]
  as.integer(sub("^(\\d+).*", "\\1", hits))
}

test_that("the advertised component count follows the counting rule", {
  root <- contract_project_root()
  dirs <- basename(list.dirs(
    file.path(root, "inst", "assets", "components"),
    recursive = FALSE
  ))
  parts <- names(documented_part_directories)
  expect_true(all(parts %in% dirs))

  r_files <- list.files(file.path(root, "R"), pattern = "[.]R$")
  for (part in parts) {
    owners <- r_files[vapply(r_files, function(file) {
      grepl(paste0("shad-", part), contract_read(file.path("R", file), root),
            fixed = TRUE)
    }, logical(1))]
    expect_identical(
      file.path("R", owners),
      unname(documented_part_directories[part]),
      info = part
    )
  }

  count <- length(setdiff(dirs, parts))
  for (path in c("DESCRIPTION", "README.md", "R/shadshiny-package.R",
                 "man/shadshiny-package.Rd")) {
    claims <- documented_numbers(
      documented_text(path, root),
      "\\d+ accessible, themeable components"
    )
    expect_true(length(claims) > 0, info = path)
    expect_identical(unique(claims), count, info = path)
  }
})

test_that("NEWS states the current export and signature totals", {
  root <- contract_project_root()
  news <- strsplit(contract_read("NEWS.md", root), "\n(?=# shadshiny)",
                   perl = TRUE)[[1]][[1]]
  news <- gsub("\\s+", " ", news)

  exports <- documented_numbers(news, "\\d+ exported functions")
  signatures <- documented_numbers(news, "\\d+ important signatures")
  expect_true(length(exports) > 0)
  expect_true(length(signatures) > 0)
  expect_identical(unique(exports), length(contract_exported_names(root)))
  expect_identical(unique(signatures), nrow(public_api_formals_baseline()))
})

test_that("experimental functions are labelled wherever they are documented", {
  root <- contract_project_root()
  expect_true(all(documented_experimental %in% contract_exported_names(root)))

  readme <- documented_text("README.md", root)
  stability <- regmatches(
    readme,
    regexpr("## API stability.*?(?= ## )", readme, perl = TRUE)
  )
  expect_length(stability, 1)
  named <- vapply(documented_experimental, function(name) {
    grepl(paste0("`", name, "()`"), stability, fixed = TRUE)
  }, logical(1))
  expect_identical(names(named)[!named], character(), info = "README")

  rd_files <- list.files(file.path(root, "man"), pattern = "[.]Rd$")
  for (name in documented_experimental) {
    alias <- paste0("\\alias{", name, "}")
    homes <- rd_files[vapply(rd_files, function(file) {
      grepl(alias, contract_read(file.path("man", file), root), fixed = TRUE)
    }, logical(1))]
    expect_length(homes, 1)
    expect_match(contract_read(file.path("man", homes), root), "experimental",
                 ignore.case = TRUE, info = homes)
  }

  vignettes <- list.files(file.path(root, "vignettes"), pattern = "[.]Rmd$")
  for (file in vignettes) {
    text <- contract_read(file.path("vignettes", file), root)
    uses <- vapply(documented_experimental, function(name) {
      grepl(paste0(name, "("), text, fixed = TRUE)
    }, logical(1))
    if (any(uses)) {
      expect_match(text, "experimental", ignore.case = TRUE,
                   info = paste(file, "uses", toString(names(uses)[uses])))
    }
  }
})

# Smoke test for an installed shadshiny, checked against the archive it came
# from: Rscript tools/smoke-installed.R LIB ARCHIVE
#
# The package is loaded from LIB only. Counts (exports, help topics,
# vignettes) and the version come from ARCHIVE, so this checks that the
# install holds what those exact bytes ship, not what the source tree holds.

args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 2L) {
  stop("usage: Rscript tools/smoke-installed.R LIB ARCHIVE", call. = FALSE)
}
lib <- normalizePath(args[[1]], winslash = "/", mustWork = TRUE)
archive <- normalizePath(args[[2]], winslash = "/", mustWork = TRUE)

failures <- character()
check <- function(label, ok) {
  ok <- isTRUE(tryCatch(ok, error = function(error) {
    message("  ", conditionMessage(error))
    FALSE
  }))
  cat(if (ok) "ok  " else "FAIL", label, "\n")
  if (!ok) failures <<- c(failures, label)
  invisible(ok)
}

listing <- utils::untar(archive, list = TRUE)
unpacked <- tempfile("shadshiny-archive-")
utils::untar(
  archive,
  files = c("shadshiny/DESCRIPTION", "shadshiny/NAMESPACE"),
  exdir = unpacked
)
shipped <- read.dcf(file.path(unpacked, "shadshiny", "DESCRIPTION"))
namespace <- readLines(file.path(unpacked, "shadshiny", "NAMESPACE"))

loaded <- check(
  "loads from LIB",
  suppressPackageStartupMessages(
    library(shadshiny, lib.loc = lib, logical.return = TRUE)
  ) && identical(
    normalizePath(dirname(find.package("shadshiny")), winslash = "/"),
    lib
  )
)
if (!loaded) quit(status = 1)

check(
  "version matches the archive",
  identical(as.character(utils::packageVersion("shadshiny", lib.loc = lib)),
            unname(shipped[, "Version"]))
)
check(
  "exports match the archive's NAMESPACE",
  setequal(
    getNamespaceExports("shadshiny"),
    sub("^export\\((.*)\\)$", "\\1", grep("^export\\(", namespace, value = TRUE))
  )
)
check(
  "every help topic is installed",
  length(tools::Rd_db("shadshiny", lib.loc = lib)) ==
    sum(grepl("^shadshiny/man/[^/]+[.]Rd$", listing))
)
check(
  "every vignette is installed",
  nrow(utils::vignette(package = "shadshiny", lib.loc = lib)$results) ==
    sum(grepl("^shadshiny/vignettes/[^/]+[.]Rmd$", listing))
)

assets <- system.file("assets", package = "shadshiny", lib.loc = lib)
dependency <- htmltools::findDependencies(shadshiny_deps())[[1]]
check(
  "the html dependency serves the installed bundle",
  identical(dependency$stylesheet, "dist/shadshiny.min.css") &&
    identical(dependency$script, "dist/shadshiny.min.js") &&
    all(file.size(file.path(assets, c(dependency$stylesheet, dependency$script))) > 10000)
)
manifest <- jsonlite::fromJSON(file.path(assets, "dist", "manifest.json"))
check(
  "every source asset in the manifest is installed",
  all(file.exists(file.path(assets, c(manifest$css, manifest$js))))
)

render <- function(x) htmltools::renderTags(x)$html
stable <- render(page_shad(
  shad_button("Save", inputId = "save"),
  shad_form_field(shad_input("name", label = "Name"), label = "Name"),
  shad_select("fruit", "Fruit", choices = c("Apple", "Pear")),
  shad_checkbox("agree", "Agree"),
  shad_tabs("nav", shad_tab("a", "A", "first"), shad_tab("b", "B", "second")),
  shad_dialog("confirm", "Body", title = "Confirm"),
  shad_data_table("rows", data.frame(x = 1:2, y = c("a", "b"))),
  shad_table(data.frame(x = 1:2, y = c("a", "b")))
))
check(
  "stable constructors render their roots",
  all(vapply(
    c("select", "checkbox", "tabs", "dialog", "data-table"),
    function(name) grepl(sprintf('data-shad="%s"', name), stable, fixed = TRUE),
    logical(1)
  )) && grepl('id="save"', stable, fixed = TRUE) &&
    lengths(regmatches(stable, gregexpr("<td", stable, fixed = TRUE))) >= 4L
)
experimental <- render(htmltools::tagList(
  shad_questionnaire(
    "survey",
    shad_question("q1", "Pick one", choices = c("A", "B"))
  ),
  shad_chat_workbench_ui("bench"),
  shad_fieldset("Contact", shad_field_group(shad_input("email", label = "Email")))
))
check(
  "experimental constructors render their roots",
  grepl('data-shad="questionnaire"', experimental, fixed = TRUE) &&
    grepl('data-shad="chat-workbench"', experimental, fixed = TRUE) &&
    grepl("<fieldset", experimental, fixed = TRUE)
)
check(
  "server updaters run in a mock session",
  is.null(shiny::testServer(function(input, output, session) {
    update_shad_select("fruit", selected = "Pear")
    update_shad_tabs("nav", selected = "b")
  }, NULL))
)

examples <- system.file("examples", package = "shadshiny", lib.loc = lib)
example_files <- list.files(examples, pattern = "[.]R$", recursive = TRUE, full.names = TRUE)
check(
  "every example app parses",
  length(example_files) > 0L &&
    all(vapply(example_files, function(path) is.expression(parse(path)), logical(1)))
)

if (length(failures)) {
  cat(length(failures), "smoke check(s) failed\n")
  quit(status = 1)
}
cat("smoke passed\n")

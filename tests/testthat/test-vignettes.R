# R CMD check tangles each vignette and sources the code unless
# _R_CHECK_VIGNETTES_SKIP_RUN_MAYBE_ is true, its default on R 4.4.3 but not
# on R 4.3.0. Tangling never runs the setup chunk, so an `eval = FALSE` set
# there does not reach knitr::purl(): a vignette that shows code without
# running it must tangle to no code, or that check runs the code anyway.

vignette_live_code <- function(doc, engine, encoding) {
  dir <- withr::local_tempdir()
  file.copy(doc, dir)
  withr::local_dir(dir)
  tools::vignetteEngine(engine)$tangle(basename(doc), quiet = TRUE,
                                       encoding = encoding)
  code <- as.character(unlist(lapply(list.files(dir, pattern = "[.][RrSs]$"),
                                     readLines)))
  code[nzchar(trimws(code)) & !grepl("^\\s*#", code)]
}

test_that("vignettes that do not run their code tangle to no code", {
  skip_if_not_installed("knitr")
  vignettes <- tools::pkgVignettes(dir = contract_project_root())
  shown_only <- vapply(vignettes$docs, function(doc) {
    grepl("opts_chunk\\$set\\([^)]*\\beval\\s*=\\s*FALSE",
          paste(readLines(doc, warn = FALSE), collapse = "\n"))
  }, logical(1))
  expect_true(any(shown_only))

  for (i in which(shown_only)) {
    expect_identical(
      vignette_live_code(vignettes$docs[[i]], vignettes$engines[[i]],
                         vignettes$encodings[[i]]),
      character(),
      info = basename(vignettes$docs[[i]])
    )
  }
})

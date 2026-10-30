source(file.path("tools", "coverage-policy.R"), local = TRUE)

if (!requireNamespace("covr", quietly = TRUE)) {
  stop("The covr package is required to check coverage.", call. = FALSE)
}

source_root <- normalizePath(".", winslash = "/", mustWork = TRUE)
Sys.setenv(SHADSHINY_SOURCE_ROOT = source_root)

coverage <- covr::package_coverage(
  path = source_root,
  quiet = FALSE,
  clean = FALSE,
  install_path = file.path(
    normalizePath(tempdir(), winslash = "/", mustWork = TRUE),
    "shadshiny-coverage-library"
  )
)
percent <- as.numeric(covr::percent_coverage(coverage))
coverage_gate(percent)
output <- Sys.getenv("SHADSHINY_COVERAGE_OUTPUT", unset = "cobertura.xml")
covr::to_cobertura(coverage, filename = output)
cat(sprintf(
  "COVERAGE_GATE=PASS measured=%.2f required=%.2f\n",
  percent,
  SHADSHINY_COVERAGE_MIN
))

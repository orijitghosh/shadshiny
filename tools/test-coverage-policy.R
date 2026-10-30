source(file.path("tools", "coverage-policy.R"), local = TRUE)

stopifnot(identical(coverage_gate(82), 82))

below <- tryCatch(
  coverage_gate(81.99),
  error = function(error) conditionMessage(error)
)
stopifnot(grepl("below required 82.00%", below, fixed = TRUE))

invalid <- tryCatch(
  coverage_gate(NA_real_),
  error = function(error) conditionMessage(error)
)
stopifnot(grepl("finite percentage", invalid, fixed = TRUE))

cat("COVERAGE_POLICY_TEST=PASS\n")

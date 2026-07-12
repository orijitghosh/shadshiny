nc <- function(x) shadshiny:::normalize_choices(x)

test_that("named character vector maps names to labels, values to values", {
  out <- nc(c(Apple = "apple", Banana = "banana"))
  expect_equal(out, list(
    list(value = "apple", label = "Apple"),
    list(value = "banana", label = "Banana")
  ))
})

test_that("unnamed vector uses the value as its own label", {
  out <- nc(c("a", "b"))
  expect_equal(out, list(
    list(value = "a", label = "a"),
    list(value = "b", label = "b")
  ))
})

test_that("partially named vector fills blank labels with the value", {
  out <- nc(c(Apple = "apple", "banana"))
  expect_equal(out[[1]], list(value = "apple", label = "Apple"))
  expect_equal(out[[2]], list(value = "banana", label = "banana"))
})

test_that("normalized choices carry no leaked names (regression)", {
  out <- nc(c(One = "1", Two = "2"))
  expect_null(names(out))
  expect_true(all(vapply(out, function(x) is.null(names(x$value)), logical(1))))
})

test_that("named-vector choices do not leak into tag attributes (regression)", {
  html <- as.character(shad_toggle_group(
    "tg", choices = c(Left = "left", Center = "center"), type = "single"
  ))
  # the leaked-name bug rendered attributes like ` left="..."` on the root
  expect_false(grepl("\\sleft=", html))
  expect_false(grepl("\\scenter=", html))
})

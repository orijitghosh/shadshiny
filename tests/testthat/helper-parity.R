# Anatomy parity harness ------------------------------------------------------
# Compares an R-rendered tag against a fragment of the canonical anatomy file
# (inst/assets/components/<name>/<name>.html) structurally: element names,
# class sets (order-insensitive), and attributes, ignoring id-bearing attrs
# and text nodes.

# Attributes that carry ids or id cross-references: values differ between the
# static anatomy demo and R output, so we compare only presence, not value.
.parity_id_attrs <- c("id", "for", "aria-labelledby", "aria-describedby",
                      "aria-controls", "aria-owns", "name")

# Parse an anatomy file into a list of its top-level element nodes (comments
# and whitespace text nodes dropped).
anatomy_nodes <- function(component) {
  path <- system.file("assets", "components", component,
                      paste0(component, ".html"), package = "shadshiny")
  testthat::expect_true(file.exists(path), info = component)
  doc <- xml2::read_html(paste0(
    "<!DOCTYPE html><html><body>",
    paste(readLines(path, encoding = "UTF-8"), collapse = "\n"),
    "</body></html>"
  ))
  xml2::xml_find_all(doc, "/html/body/*")
}

# Parse an R tag into its single root element node.
r_node <- function(tag) {
  doc <- xml2::read_html(paste0(
    "<!DOCTYPE html><html><body>", as.character(tag), "</body></html>"
  ))
  xml2::xml_find_first(doc, "/html/body/*")
}

# Normalize one node into a comparable structure.
norm_node <- function(node) {
  attrs <- xml2::xml_attrs(node)
  class_value <- unname(attrs["class"])
  if (!length(class_value)) class_value <- ""
  classes <- sort(strsplit(trimws(class_value), "\\s+")[[1]])
  classes <- classes[nzchar(classes)]
  id_attrs <- sort(intersect(names(attrs), .parity_id_attrs))
  keep <- setdiff(names(attrs), c("class", .parity_id_attrs))
  attrs <- attrs[sort(keep)]
  children <- xml2::xml_find_all(node, "./*")
  list(
    name = xml2::xml_name(node),
    classes = classes,
    id_attrs = id_attrs,
    attrs = attrs,
    children = lapply(children, norm_node)
  )
}

`%||%` <- function(a, b) if (is.null(a)) b else a

# The assertion. `r_tag`: an R tag. `component`: anatomy dir name.
# `index`: which top-level anatomy node to compare against.
expect_anatomy_match <- function(r_tag, component, index = 1) {
  ref <- norm_node(anatomy_nodes(component)[[index]])
  got <- norm_node(r_node(r_tag))
  testthat::expect_identical(got, ref, info = component)
  invisible(TRUE)
}

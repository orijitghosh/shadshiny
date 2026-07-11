.onLoad <- function(libname, pkgname) {
  shiny::addResourcePath("shadshiny", system.file("assets", package = "shadshiny"))
  register_shad_input_handlers()
  invisible(NULL)
}

.onUnload <- function(libpath) {
  suppressWarnings(try(shiny::removeResourcePath("shadshiny"), silent = TRUE))
  invisible(NULL)
}

# Silence R CMD check note about the native pipe / global usage if needed.
utils::globalVariables(character(0))

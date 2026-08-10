# Audit the port against the live shadcn/ui registry.
#
# Answers two questions the README claims an answer to:
#   1. which upstream components have no shadshiny equivalent yet, and
#   2. which shadshiny components have no upstream counterpart (the `+` marks).
#
# Run: Rscript tools/audit-registry.R
#
# Needs network. This lives in dev/ (Rbuildignored) so the package itself never
# reaches out. Re-run it when shadcn ships components and update the markers in
# README.md, the gallery articles, and pkgdown/_pkgdown.yml to match.

index_url <- "https://ui.shadcn.com/r/index.json"

# upstream name -> the shadshiny function that covers it. NA means "upstream has
# it, we do not". Anything absent from this table is reported as unmapped so a
# new upstream component cannot slip past unnoticed.
alias <- c(
  accordion = "shad_accordion", alert = "shad_alert",
  `alert-dialog` = "shad_alert_dialog", `aspect-ratio` = "shad_aspect_ratio",
  attachment = "shad_attachment", avatar = "shad_avatar", badge = "shad_badge",
  breadcrumb = "shad_breadcrumb", bubble = "shad_bubble", button = "shad_button",
  `button-group` = "shad_button_group", calendar = "shad_calendar",
  card = "shad_card", carousel = "shad_carousel", chart = "shad_chart_container",
  checkbox = "shad_checkbox", collapsible = "shad_collapsible",
  combobox = "shad_combobox", command = "shad_command",
  `context-menu` = "shad_context_menu", dialog = "shad_dialog",
  direction = NA_character_, drawer = "shad_drawer",
  `dropdown-menu` = "shad_dropdown_menu", empty = "shad_empty",
  field = "shad_form_field", form = "shad_validator",
  `hover-card` = "shad_hover_card", input = "shad_input",
  `input-group` = "shad_input_group", `input-otp` = "shad_input_otp",
  item = "shad_item", kbd = "shad_kbd", label = "shad_label",
  marker = "shad_marker", menubar = "shad_menubar", message = "shad_message",
  `message-scroller` = "shad_message_scroller",
  `native-select` = "shad_native_select",
  `navigation-menu` = "shad_navigation_menu", pagination = "shad_pagination",
  popover = "shad_popover", progress = "shad_progress",
  questionnaire = NA_character_, `radio-group` = "shad_radio_group",
  resizable = "shad_resizable", `scroll-area` = "shad_scroll_area",
  select = "shad_select", separator = "shad_separator", sheet = "shad_sheet",
  sidebar = "shad_sidebar_layout", skeleton = "shad_skeleton",
  slider = "shad_slider", sonner = "shad_toast", spinner = "shad_spinner",
  switch = "shad_switch", table = "shad_table", tabs = "shad_tabs",
  textarea = "shad_textarea", toast = "shad_toast", toggle = "shad_toggle",
  `toggle-group` = "shad_toggle_group", tooltip = "shad_tooltip"
)

# Upstream ships these as documented recipes composed from other primitives
# rather than as their own registry entry, so they never appear in index.json.
# They still count as "shadcn has this", which is what the markers claim.
docs_only <- c(
  `date-picker` = "shad_date_picker", `data-table` = "shad_data_table",
  typography = "shad_code", `command-dialog` = "shad_command_palette",
  themes = "shad_theme"
)

# Server-side API that the README tables list alongside components. The markers
# describe components, so these are neither ported nor additions.
out_of_scope <- c("shad_show_dialog")

# Upstream components that cover more than one shadshiny function.
extra_cover <- c(form = "shad_form_message")

# The README component tables are the list the markers describe, so read them
# rather than the whole namespace: sub-parts and the server API are out of scope
# by design. Returns one row per table cell, with whether it carries a `+`.
readme_components <- function(path = "README.md") {
  lines <- readLines(path, warn = FALSE)
  cells <- unlist(strsplit(grep("^\\|", lines, value = TRUE), "|", fixed = TRUE))
  cells <- trimws(cells)
  cells <- cells[grepl("^`shad_[a-z_]+`", cells)]
  chat <- grepl("Chat / AI kit", paste(lines, collapse = "\n"))
  data.frame(
    name = sub("^`(shad_[a-z_]+)`.*", "\\1", cells),
    marked = grepl("`\\+`", cells),
    row.names = NULL
  )
}

main <- function() {
  idx <- jsonlite::fromJSON(index_url)
  upstream <- sort(idx$name[idx$type == "registry:ui"])

  unmapped <- setdiff(upstream, names(alias))
  missing <- names(alias)[is.na(alias)]
  stale <- names(alias)[!names(alias) %in% upstream]

  mapped <- alias[!is.na(alias)]
  ns <- asNamespace("shadshiny")
  broken <- mapped[!vapply(mapped, exists, logical(1), envir = ns)]

  ported <- unique(c(unname(mapped), unname(docs_only), unname(extra_cover)))
  readme <- readme_components()
  readme <- readme[!readme$name %in% out_of_scope, ]
  should_mark <- !readme$name %in% ported

  cat("upstream components:", length(upstream), "\n")
  cat("mapped to shadshiny:", length(ported), "\n")
  cat("README components:  ", nrow(readme), "\n\n")

  say <- function(title, x) {
    cat(title, "\n")
    if (!length(x)) cat("  (none)\n\n") else cat(paste0("  ", x, collapse = "\n"), "\n\n")
  }

  say("upstream, not in the registry alias table (new upstream component?):", unmapped)
  say("upstream, no shadshiny equivalent:", missing)
  say("in the alias table, gone from upstream:", stale)
  say("alias points at a function that does not exist:", names(broken))
  say("README: needs a `+` (no upstream counterpart, not marked):",
      readme$name[should_mark & !readme$marked])
  say("README: drop the `+` (upstream now ships this):",
      readme$name[!should_mark & readme$marked])
}

if (!interactive()) {
  suppressMessages(pkgload::load_all(".", quiet = TRUE))
  main()
}

# 09 – App shell: the whole-page wrappers and the pieces that go with them.
# Exercises shad_page_sidebar(), the layout primitives (shad_container(),
# shad_stack(), shad_grid(), shad_grid_item()), shad_sparkline() /
# shad_mini_donut(), shad_command_palette() + update_shad_command(), and
# shad_show_dialog() / shad_remove_dialog().
#
# The navbar shell is the same idea with a tab strip instead of a sidebar:
#
#   ui <- shad_page_navbar(
#     shad_tab("overview", "Overview", overview_ui),
#     shad_tab("reports",  "Reports",  reports_ui),
#     title = "Acme", inputId = "nav"
#   )
library(shiny)
library(shadshiny)

`%||%` <- function(a, b) if (is.null(a)) b else a

set.seed(9)
months <- month.abb
revenue <- round(cumsum(runif(12, -4, 12)) + 40)
signups <- round(runif(12, 80, 260))
churn   <- round(runif(12, 1, 6), 1)

projects <- data.frame(
  name   = c("Atlas", "Beacon", "Cinder", "Delta", "Ember"),
  owner  = c("Ada", "Grace", "Alan", "Katherine", "Barbara"),
  status = c("live", "live", "paused", "live", "archived"),
  spend  = c(12400, 8200, 1500, 24800, 300),
  stringsAsFactors = FALSE
)

# Everything the palette can reach. Values that name a view drive the sidebar;
# the rest are actions.
palette_items <- list(
  "Go to" = c(Overview = "overview", Projects = "projects", Settings = "settings"),
  "Actions" = list(
    list(value = "new", label = "New project", shortcut = "N",
         keywords = "create add"),
    list(value = "export", label = "Export spend as CSV", icon = "download"),
    list(value = "theme", label = "Toggle dark mode", icon = "moon")
  )
)

sidebar <- shad_sidebar(
  header = shad_stack(direction = "horizontal", gap = 2, align = "center",
                      shad_icon("terminal"), tags$strong("Acme")),
  shad_sidebar_group("Platform",
    shad_sidebar_item("overview", "Overview", icon = "home", active = TRUE),
    shad_sidebar_item("projects", "Projects", icon = "folder", badge = "5"),
    shad_sidebar_item("settings", "Settings", icon = "settings")),
  footer = shad_muted(style = "padding:0.25rem", "v0.2.0")
)

ui <- shad_page_sidebar(
  sidebar = sidebar,
  inputId = "shell",
  title = textOutput("page_title", inline = TRUE),
  page_title = "Acme – app shell",
  theme_preset = "violet",
  header_end = shad_stack(
    direction = "horizontal", gap = 2, align = "center",
    shad_command_trigger("palette"),
    shad_switch("dark", "Dark")
  ),

  # The shell wraps this in a shad_container() already; pass container = FALSE
  # to place content flush against the page instead.
  uiOutput("view"),

  # Lives outside any view so the hotkey works wherever you are.
  shad_command_palette("palette", items = palette_items)
)

server <- function(input, output, session) {
  view <- reactive(input$shell$active %||% "overview")

  output$page_title <- renderText({
    c(overview = "Overview", projects = "Projects", settings = "Settings")[[view()]]
  })

  observeEvent(input$dark, update_shad_theme(dark = isTRUE(input$dark)),
               ignoreInit = TRUE)

  # -- palette ---------------------------------------------------------------
  # input$palette_event, not input$palette: Shiny drops a repeat of the same
  # value, and choosing "Projects" twice has to work twice.
  observeEvent(input$palette_event, {
    value <- input$palette_event$value
    if (value %in% c("overview", "projects", "settings")) {
      update_shad_sidebar("shell", active = value)
    } else if (value == "new") {
      new_project_dialog()
    } else if (value == "theme") {
      update_shad_switch("dark", value = !isTRUE(input$dark))
      update_shad_theme(dark = !isTRUE(input$dark))
    } else if (value == "export") {
      shad_toast_success("Exported 5 rows.")
    }
  })

  # The palette can also be filled from what the session knows. Here: the
  # projects the user has actually looked at.
  seen <- reactiveVal(character())
  observeEvent(input$open_project, {
    seen(union(seen(), input$open_project))
    recents <- projects$name[projects$name %in% seen()]
    update_shad_command("palette", items = c(
      palette_items,
      if (length(recents)) list("Recent projects" = setNames(
        paste0("project:", recents), recents))
    ))
    shad_toast(paste("Opened", input$open_project))
  })

  # -- server-created dialog -------------------------------------------------
  # Nothing for this exists in the UI; it is built, shown, and removed on close.
  new_project_dialog <- function() {
    shad_show_dialog(shad_dialog(
      "new_project",
      title = "New project",
      description = "This dialog was built in the server.",
      shad_stack(
        shad_input("np_name", label = "Name", placeholder = "Atlas"),
        shad_select("np_owner", label = "Owner", selected = projects$owner[[1]],
                    choices = stats::setNames(projects$owner, projects$owner)),
        gap = 3),
      footer = tagList(shad_dialog_close_button(),
                       shad_button(inputId = "np_create", "Create"))
    ))
  }
  observeEvent(input$new_project_btn, new_project_dialog())

  # Read the dialog's inputs here: they are live while it is open and gone once
  # it closes, which is what `transient = TRUE` (the default) buys you.
  observeEvent(input$np_create, {
    name <- input$np_name %||% ""
    if (!nzchar(name)) {
      shad_toast_error("Give the project a name.")
    } else {
      shad_toast_success(paste0("Created ", name, " for ", input$np_owner, "."))
      shad_remove_dialog("new_project")
    }
  })

  observeEvent(input$archive, {
    shad_show_dialog(shad_alert_dialog(
      "confirm_archive", title = "Archive Ember?",
      description = "It will stop accruing spend. You can restore it later.",
      action = "Archive", action_variant = "destructive"))
  })
  observeEvent(input$confirm_archive_confirm, shad_toast_success("Archived."))

  # -- views -----------------------------------------------------------------
  output$view <- renderUI({
    switch(view(),
      overview = shad_stack(
        gap = 6,
        # min_width beats a breakpoint list when the cards are interchangeable
        shad_grid(
          min_width = "14rem",
          shad_value_box("$45,231", "Revenue", delta = "+20.1%",
                         icon = "credit-card",
                         sparkline = shad_sparkline(revenue, type = "area")),
          shad_value_box("2,350", "Signups", delta = "+180", icon = "users",
                         sparkline = shad_sparkline(signups, type = "bar",
                                                    color = 2)),
          # a falling churn rate is good news, so the arrow is set explicitly
          shad_value_box("2.4%", "Churn", delta = "-0.4%",
                         delta_direction = "up", icon = "activity",
                         sparkline = shad_sparkline(churn, type = "line",
                                                    color = 3))),
        shad_grid(
          cols = c(base = 1, lg = 3),
          shad_grid_item(
            span = 2,
            shad_card(
              shad_card_header(shad_card_title("Revenue"),
                               shad_card_description("Last 12 months")),
              shad_card_content(
                shad_sparkline(revenue, type = "area", height = "9rem",
                               label = "Revenue, last 12 months")))),
          shad_card(
            shad_card_header(shad_card_title("Channels")),
            shad_card_content(
              shad_stack(align = "center", gap = 3,
                shad_mini_donut(c(62, 24, 14), center = "62%"),
                shad_muted("Online · Retail · Partner")))))),

      projects = shad_stack(
        gap = 4,
        shad_stack(direction = "horizontal", justify = "between", align = "center",
          shad_h3("Projects", style = "margin:0"),
          shad_stack(direction = "horizontal", gap = 2,
            shad_button(inputId = "archive", "Archive Ember",
                        variant = "outline", size = "sm"),
            shad_button(inputId = "new_project_btn", "New project",
                        icon = "plus", size = "sm"))),
        shad_grid(
          min_width = "16rem",
          lapply(seq_len(nrow(projects)), function(i) {
            p <- projects[i, ]
            shad_card(
              shad_card_header(
                shad_card_title(p$name),
                shad_card_description(paste("Owner:", p$owner))),
              shad_card_content(
                shad_stack(direction = "horizontal", justify = "between",
                           align = "center",
                  shad_badge(p$status, variant = switch(p$status,
                    live = "default", paused = "secondary", "outline")),
                  shad_muted(sprintf("$%s", format(p$spend, big.mark = ","))))),
              shad_card_footer(
                shad_button(inputId = paste0("open_", p$name), "Open",
                            variant = "ghost", size = "sm",
                            onclick = sprintf(
                              "Shiny.setInputValue('open_project', '%s', {priority:'event'})",
                              p$name))))
          }))),

      settings = shad_container(
        size = "sm", padding = FALSE,
        shad_stack(
          gap = 5,
          shad_h3("Settings", style = "margin:0"),
          shad_card(shad_card_content(
            shad_stack(gap = 3,
              shad_switch("notify", "Email notifications", value = TRUE),
              shad_switch("beta", "Beta features"),
              shad_separator(),
              shad_muted("Press Ctrl/Cmd + K anywhere to open the palette."))))))
    )
  })
}

shinyApp(ui, server)

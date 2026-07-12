# shadshiny example 02 — Analytics dashboard ---------------------------------
# An admin/analytics console: collapsible sidebar nav, a menubar, a ⌘K command
# palette, KPI cards, a resizable chart/activity split, and a searchable team
# directory with per-row menus, hover cards, pagination and an empty state.
# Run with shadshiny::shad_run_example("02-analytics-dashboard").
#
# Components: page_shad, sidebar-layout (+sidebar/group/item/trigger/toggle),
# menubar, command (⌘K dialog), breadcrumb, tabs, card, progress, badge,
# tooltip, hover-card, dropdown-menu, context-menu, resizable, scroll-area,
# slider, select, switch, input, date-picker, calendar, skeleton, empty,
# accordion, collapsible, table, pagination, avatar (+group), code, kbd, toast.

library(shiny)
library(shadshiny)
`%||%` <- function(a, b) if (is.null(a)) b else a

members <- data.frame(
  id     = paste0("m", 1:8),
  name   = c("Olivia Martin", "Jackson Lee", "Isabella Nguyen", "William Kim",
             "Sofia Davis", "Liam Patel", "Emma Rossi", "Noah Silva"),
  email  = c("olivia@acme.io", "jackson@acme.io", "isabella@acme.io",
             "william@acme.io", "sofia@acme.io", "liam@acme.io",
             "emma@acme.io", "noah@acme.io"),
  role   = c("Owner", "Admin", "Member", "Member", "Admin", "Member",
             "Member", "Viewer"),
  status = c("active", "active", "invited", "active", "active", "away",
             "active", "invited"),
  usage  = c(92, 74, 12, 58, 88, 33, 66, 5),
  stringsAsFactors = FALSE
)
members$initials <- vapply(strsplit(members$name, " "),
  function(p) toupper(paste0(substr(p[1], 1, 1), substr(p[2], 1, 1))), "")

status_variant <- c(active = "secondary", invited = "outline", away = "default")
PAGE_SIZE <- 4L

metrics_tbl <- data.frame(
  Metric = c("Revenue", "New signups", "Active users", "Churn"),
  This_period = c("$48,210", "1,204", "8,932", "1.8%"),
  Last_period = c("$43,050", "1,090", "8,410", "2.1%"),
  Change = c("+12.0%", "+10.5%", "+6.2%", "-0.3pp"),
  check.names = FALSE, stringsAsFactors = FALSE
)

# A minimal CSS bar chart from a numeric vector.
bar_chart <- function(values, labels) {
  mx <- max(values)
  tags$div(style = "display:flex;align-items:flex-end;gap:0.5rem;height:9rem;padding-top:0.5rem",
    Map(function(v, l) {
      tags$div(style = "flex:1;display:grid;gap:0.35rem;justify-items:center;height:100%",
        tags$div(style = "flex:1;width:100%;display:flex;align-items:flex-end",
          tags$div(style = sprintf(paste0("width:100%%;height:%d%%;border-radius:",
            "var(--shad-radius-sm);background:var(--shad-primary)"),
            round(v / mx * 100)))),
        shad_small(class = "shad-muted", l))
    }, values, labels))
}

kpi_card <- function(title, value, delta, up, pct, hint) {
  shad_card(style = "flex:1;min-width:11rem",
    shad_card_header(
      shad_card_title(style = "font-size:0.8rem;font-weight:500",
        tags$span(style = "display:flex;align-items:center;gap:0.35rem",
          title,
          shad_tooltip(
            tags$span(style = "display:inline-flex;color:var(--shad-muted-foreground)",
              shad_icon("info", style = "width:0.9rem;height:0.9rem")),
            hint))),
      shad_card_action(
        shad_badge(delta, variant = if (up) "secondary" else "destructive"))),
    shad_card_content(
      tags$div(style = "font-size:1.6rem;font-weight:700;letter-spacing:-0.02em", value),
      shad_progress(pct, style = "margin-top:0.6rem")))
}

# --- Sidebar / shell ---------------------------------------------------------
app_sidebar <- shad_sidebar(
  header = tags$div(style = "display:flex;align-items:center;gap:0.5rem;padding:0.25rem",
    shad_avatar(fallback = "AC", size = "sm"), tags$strong("Acme Analytics")),
  shad_sidebar_group("Workspace",
    shad_sidebar_item("overview", "Overview", icon = "panel-left", active = TRUE),
    shad_sidebar_item("team", "Team", icon = "menu", badge = "8"),
    shad_sidebar_item("reports", "Reports", icon = "file")),
  shad_sidebar_group("Account",
    shad_sidebar_item("settings", "Settings", icon = "more-horizontal"),
    shad_sidebar_item("help", "Help", icon = "info")),
  footer = shad_muted(style = "padding:0.25rem", "v1.0.0"))

topbar <- tags$div(
  style = paste("display:flex;align-items:center;gap:0.75rem;padding:0.6rem 1rem;",
    "border-bottom:1px solid var(--shad-border);background:var(--shad-background)"),
  shad_sidebar_trigger(),
  shad_breadcrumb(
    shad_breadcrumb_item("Acme", href = "#"),
    shad_breadcrumb_separator(),
    shad_breadcrumb_item(textOutput("crumb", inline = TRUE), current = TRUE)),
  tags$div(style = "flex:1"),
  shad_menubar("appmenu",
    shad_menubar_menu("File",
      shad_menu_item("mb_new", "New report", shortcut = "⌘N"),
      shad_menu_item("mb_export", "Export data")),
    shad_menubar_menu("View",
      shad_menu_item("mb_palette", "Command palette", shortcut = "⌘K"),
      shad_menu_item("mb_sidebar", "Toggle sidebar"))),
  shad_button("Search…", inputId = "open_palette", variant = "outline",
    icon = "search"),
  shad_switch("dark", "Dark"),
  shad_dropdown_menu("acct", trigger = shad_avatar(fallback = "YOU", size = "sm"),
    align = "end",
    shad_menu_label("My account"), shad_menu_separator(),
    shad_menu_item("acct_profile", "Profile", shortcut = "⇧⌘P"),
    shad_menu_item("acct_billing", "Billing"),
    shad_menu_separator(),
    shad_menu_item("acct_logout", "Log out")))

ui <- page_shad(
  title = "Acme Analytics",
  theme_preset = "blue",

  # Command palette (hidden until ⌘K or the Search button).
  shad_command("cmdk", dialog = TRUE, placeholder = "Type a command…",
    shad_command_group("Navigation",
      shad_command_item("go_overview", "Go to Overview", keywords = "home"),
      shad_command_item("go_team", "Go to Team", keywords = "members"),
      shad_command_item("go_reports", "Go to Reports", keywords = "metrics")),
    shad_command_separator(),
    shad_command_group("Actions",
      shad_command_item("cmd_refresh", "Refresh data", shortcut = "⌘R"),
      shad_command_item("cmd_new", "New report", shortcut = "⌘N"))),

  tags$div(style = "height:100vh",
    shad_sidebar_layout("shell", sidebar = app_sidebar,
      main = tags$div(style = "display:flex;flex-direction:column;height:100%",
        topbar,
        shad_scroll_area(height = "calc(100vh - 3.4rem)",
          tags$div(style = "padding:1.25rem;max-width:64rem;margin:0 auto",
            shad_tabs("view",
              # ---- Overview ------------------------------------------
              shad_tab("overview", "Overview",
                tags$div(style = "display:grid;gap:1.25rem;margin-top:1rem",
                  tags$div(style = "display:flex;flex-wrap:wrap;gap:1rem",
                    uiOutput("kpis", style = "display:contents")),
                  tags$div(style = "display:flex;flex-wrap:wrap;gap:1rem;align-items:center",
                    tags$div(style = "min-width:16rem",
                      shad_date_picker("range", label = "Date range",
                        mode = "range")),
                    tags$div(style = "width:14rem",
                      shad_select("metric", label = "Metric", selected = "rev",
                        choices = list(
                          shad_select_group("Financial",
                            shad_select_item("rev", "Revenue"),
                            shad_select_item("arr", "ARR")),
                          shad_select_separator(),
                          shad_select_group("Product",
                            shad_select_item("signup", "Signups"),
                            shad_select_item("active", "Active users"))))),
                    tags$div(style = "align-self:flex-end",
                      shad_button("Refresh", inputId = "refresh",
                        variant = "outline", icon = "loader"))),
                  shad_resizable("split", style = "height:20rem",
                    shad_resizable_panel(default_size = 62,
                      shad_card(style = "height:100%;margin-right:0.5rem",
                        shad_card_header(shad_card_title("Weekly revenue"),
                          shad_card_description("Last 7 days")),
                        shad_card_content(uiOutput("chart")))),
                    shad_resizable_handle(),
                    shad_resizable_panel(default_size = 38,
                      shad_card(style = "height:100%;margin-left:0.5rem",
                        shad_card_header(shad_card_title("Activity")),
                        shad_card_content(style = "padding:0",
                          shad_scroll_area(height = "14rem",
                            uiOutput("activity")))))))),
              # ---- Team ----------------------------------------------
              shad_tab("team", "Team",
                tags$div(style = "display:grid;gap:1rem;margin-top:1rem",
                  tags$div(style = "display:flex;flex-wrap:wrap;gap:0.75rem;align-items:center",
                    tags$div(style = "flex:1;min-width:14rem",
                      shad_input_group(block = TRUE,
                        shad_input_group_addon(shad_icon("search"),
                          align = "inline-start"),
                        shad_input("team_q", placeholder = "Search members…"))),
                    tags$div(style = "width:15rem",
                      shad_slider("min_usage", label = "Min usage %", value = 0)),
                    shad_dropdown_menu("sortmenu", align = "end",
                      trigger = shad_button("Sort", variant = "outline",
                        icon = "chevrons-up-down", icon_position = "right"),
                      shad_menu_label("Sort by"),
                      shad_menu_radio_group("name",
                        shad_menu_radio_item("name", "Name"),
                        shad_menu_radio_item("usage", "Usage"),
                        shad_menu_radio_item("role", "Role")),
                      shad_menu_separator(),
                      shad_menu_checkbox_item("invited_only", "Invited only"),
                      shad_menu_separator(),
                      shad_menu_sub("Export",
                        shad_menu_item("exp_csv", "As CSV"),
                        shad_menu_item("exp_json", "As JSON"))),
                    shad_button("Invite", inputId = "invite", icon = "plus")),
                  shad_context_menu("team_ctx",
                    target = uiOutput("team_list"),
                    shad_menu_item("ctx_refresh", "Refresh"),
                    shad_menu_item("ctx_export", "Export CSV"),
                    shad_menu_separator(),
                    shad_menu_item("ctx_invite", "Invite member")),
                  tags$div(style = "display:flex;justify-content:center",
                    shad_pagination("team_pg", pages = 2, selected = 1)))),
              # ---- Reports -------------------------------------------
              shad_tab("reports", "Reports",
                tags$div(style = "display:grid;gap:1.25rem;margin-top:1rem",
                  shad_card(
                    shad_card_header(shad_card_title("Period comparison"),
                      shad_card_description("Current vs. previous period")),
                    shad_card_content(
                      shad_table(metrics_tbl, striped = TRUE, hover = TRUE))),
                  shad_accordion("faq",
                    shad_accordion_item("a1", "How is revenue calculated?",
                      shad_p("Gross booked revenue minus refunds, in USD.")),
                    shad_accordion_item("a2", "Where does the data come from?",
                      shad_p("Synced hourly from the billing warehouse.")),
                    value = "a1"),
                  shad_collapsible("api",
                    trigger = shad_button("API example", variant = "ghost",
                      icon = "chevrons-up-down", icon_position = "right"),
                    tags$div(style = "margin-top:0.5rem",
                      shad_code(paste("GET /v1/metrics?from=2026-07-01",
                        "&to=2026-07-07"))),
                    open = TRUE),
                  shad_card(style = "width:20rem",
                    shad_card_header(shad_card_title("Schedule delivery")),
                    shad_card_content(
                      shad_calendar("deliver", value = Sys.Date())))))))))))
)

server <- function(input, output, session) {
  observeEvent(input$dark, update_shad_theme(dark = isTRUE(input$dark)),
    ignoreInit = TRUE)

  active_tab <- reactiveVal("overview")
  loading <- reactiveVal(FALSE)
  sort_by <- reactiveVal("name")
  invited_only <- reactiveVal(FALSE)

  observeEvent(input$sortmenu, {
    v <- input$sortmenu
    if (v %in% c("name", "usage", "role")) sort_by(v)
    else if (v == "invited_only") invited_only(!invited_only())
    else if (v %in% c("exp_csv", "exp_json"))
      shad_toast_loading(paste0("Exporting ", toupper(sub("exp_", "", v)), "…"))
  }, ignoreInit = TRUE)

  output$crumb <- renderText(
    c(overview = "Overview", team = "Team", reports = "Reports")[active_tab()])

  # -- KPI cards -------------------------------------------------------
  output$kpis <- renderUI({
    tagList(
      kpi_card("Revenue", "$48,210", "+12%", TRUE, 72,
        "Gross booked revenue this period."),
      kpi_card("Active users", "8,932", "+6.2%", TRUE, 64,
        "Users active in the last 7 days."),
      kpi_card("Conversion", "3.4%", "+0.4pp", TRUE, 34,
        "Signup-to-paid conversion rate."),
      kpi_card("Churn", "1.8%", "-0.3pp", FALSE, 18,
        "Monthly logo churn."))
  })

  output$chart <- renderUI({
    if (loading()) {
      return(tags$div(style = "display:flex;gap:0.5rem;align-items:flex-end;height:9rem",
        lapply(c(60, 40, 80, 55, 90, 70, 45), function(h)
          shad_skeleton(width = "100%", height = paste0(h, "%")))))
    }
    bar_chart(c(32, 28, 41, 37, 48, 44, 39),
      c("Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"))
  })

  output$activity <- renderUI({
    if (loading()) {
      return(tags$div(style = "padding:1rem;display:grid;gap:0.75rem",
        lapply(1:5, function(i) shad_skeleton(variant = "text", width = "90%"))))
    }
    events <- list(
      c("Olivia", "closed a $12k deal", "2m"),
      c("Jackson", "invited 3 members", "18m"),
      c("Isabella", "exported the Q3 report", "1h"),
      c("William", "upgraded to Team", "3h"),
      c("Sofia", "resolved 5 tickets", "5h"))
    shad_item_group(
      lapply(events, function(e)
        shad_item(tags$span(tags$strong(e[1]), " ", e[2]),
          description = paste(e[3], "ago"),
          media = tags$span(substr(e[1], 1, 1)), media_variant = "icon",
          size = "sm")))
  })

  observeEvent(input$refresh, {
    loading(TRUE)
    id <- shad_toast_loading("Refreshing data…")
    # Deferred callback runs outside the reactive domain — restore it so the
    # reactiveVal write flushes to the client.
    later::later(function() {
      shiny::withReactiveDomain(session, {
        loading(FALSE)
        shad_toast_update(id, message = "Data up to date", variant = "success",
          session = session)
      })
    }, delay = 1.2)
  })

  # -- Team directory --------------------------------------------------
  filtered <- reactive({
    df <- members
    q <- tolower(input$team_q %||% "")
    if (nzchar(q)) {
      df <- df[grepl(q, tolower(df$name)) | grepl(q, tolower(df$email)), ]
    }
    df <- df[df$usage >= (input$min_usage %||% 0), , drop = FALSE]
    if (invited_only()) df <- df[df$status == "invited", , drop = FALSE]
    ord <- switch(sort_by(),
      usage = order(-df$usage),
      role  = order(df$role, df$name),
      order(df$name))
    df[ord, , drop = FALSE]
  })

  # Keep pagination page-count in sync with the filtered result.
  observe({
    pages <- max(1L, ceiling(nrow(filtered()) / PAGE_SIZE))
    cur <- input$team_pg %||% 1
    if (cur > pages) update_shad_pagination("team_pg", pages)
  })

  output$team_list <- renderUI({
    df <- filtered()
    if (nrow(df) == 0) {
      return(shad_empty("No members found", media = "search",
        media_variant = "icon",
        description = "Try a different search or lower the usage filter.",
        content = shad_button("Clear filters", inputId = "clear_team",
          variant = "outline")))
    }
    page <- min(input$team_pg %||% 1, ceiling(nrow(df) / PAGE_SIZE))
    rows <- df[((page - 1) * PAGE_SIZE + 1):min(page * PAGE_SIZE, nrow(df)), ]
    shad_item_group(
      lapply(seq_len(nrow(rows)), function(i) {
        m <- rows[i, ]
        name_hc <- shad_hover_card(
          tags$span(style = "font-weight:500;cursor:default", m$name),
          tags$div(style = "display:flex;gap:0.75rem;align-items:center",
            shad_avatar(fallback = m$initials),
            tags$div(shad_p(style = "margin:0;font-weight:600", m$name),
              shad_muted(m$email))))
        shad_item(name_hc,
          description = m$email,
          media = tags$span(m$initials), media_variant = "icon",
          header = shad_badge(m$role, variant = "outline"),
          footer = shad_badge(m$status,
            variant = status_variant[[m$status]]),
          actions = shad_dropdown_menu(paste0("rmnu_", m$id), align = "end",
            trigger = shad_button(icon = "more-horizontal", size = "icon",
              variant = "ghost", aria_label = "Actions"),
            shad_menu_item("message", "Message"),
            shad_menu_item("edit", "Edit role"),
            shad_menu_separator(),
            shad_menu_item("remove", "Remove")),
          variant = "outline")
      }))
  })

  # Pre-register finite per-row action observers (members is fixed).
  lapply(members$id, function(mid) {
    observeEvent(input[[paste0("rmnu_", mid)]], {
      action <- input[[paste0("rmnu_", mid)]]
      nm <- members$name[members$id == mid]
      if (identical(action, "remove")) {
        shad_toast_error(paste("Removed", nm))
      } else {
        shad_toast(paste0(tools::toTitleCase(action), ": ", nm))
      }
    }, ignoreInit = TRUE)
  })

  observeEvent(input$clear_team, {
    update_shad_slider("min_usage", 0)
    shad_toast("Filters cleared.")
  })
  observeEvent(input$invite, shad_toast_success("Invitation sent."))

  # -- Menubar / palette / nav ----------------------------------------
  go <- function(tab) { update_shad_tabs("view", tab); active_tab(tab) }

  observeEvent(input$view, active_tab(input$view), ignoreInit = TRUE)
  observeEvent(input$shell, {           # sidebar item click
    sel <- input$shell
    if (sel %in% c("overview", "team", "reports")) go(sel)
    else shad_toast(paste0("’", tools::toTitleCase(sel), "’ is not in this demo."))
  }, ignoreInit = TRUE)

  observeEvent(input$cmdk, {
    switch(input$cmdk,
      go_overview = go("overview"),
      go_team = go("team"),
      go_reports = go("reports"),
      cmd_refresh = ,
      cmd_new = shad_toast(paste0("Command: ", input$cmdk)))
  }, ignoreInit = TRUE)

  observeEvent(input$mb_sidebar, shad_sidebar_toggle("shell"))
  observeEvent(input$mb_palette,
    shad_toast("Press ⌘K (or Ctrl+K) to open the palette."))
  observeEvent(input$mb_new, shad_toast_success("New report created."))
  observeEvent(input$mb_export, shad_toast_loading("Preparing export…"))
  observeEvent(input$open_palette,
    shad_toast("Press ⌘K / Ctrl+K to open the command palette."))

  observeEvent(input$acct_logout, shad_toast("Logged out."))
  observeEvent(input$ctx_export, shad_toast_loading("Exporting CSV…"))
  observeEvent(input$ctx_invite, shad_toast_success("Invitation sent."))
  observeEvent(input$ctx_refresh, shad_toast("Refreshed team list."))

  # Team tab is inactive at startup; render its list anyway so it's ready.
  outputOptions(output, "team_list", suspendWhenHidden = FALSE)
}

shinyApp(ui, server)

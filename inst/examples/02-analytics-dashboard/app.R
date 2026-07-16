# shadshiny example 02 — Analytics dashboard ---------------------------------
# A working admin/analytics console. Every control does something: the metric
# select redraws the chart, the date range updates the period, the command
# palette opens from the server, and the team directory is fully mutable —
# invite adds a member, remove deletes one, edit changes a role, all through
# real dialogs and sheets. New reports accumulate in the Reports tab.
# Run with shadshiny::shad_run_example("02-analytics-dashboard").
#
# Components: page_shad, sidebar-layout (+group/item/trigger/toggle), menubar,
# command (⌘K dialog, opened via server invoke), breadcrumb, tabs, card,
# progress, badge, tooltip, hover-card, dropdown-menu, context-menu, dialog,
# sheet, resizable, scroll-area, slider, select (+group), switch, input,
# date-picker, calendar, skeleton, empty, accordion, collapsible, table,
# pagination, avatar (+group), item (+group), code, kbd, toast.

library(shiny)
library(shadshiny)
`%||%` <- function(a, b) if (is.null(a)) b else a

seed_members <- data.frame(
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
make_initials <- function(name) vapply(strsplit(name, " "),
  function(p) toupper(paste0(substr(p[1], 1, 1),
    if (length(p) > 1) substr(p[2], 1, 1) else "")), "")
seed_members$initials <- make_initials(seed_members$name)

ROLES <- c("Owner", "Admin", "Member", "Viewer")
status_variant <- c(active = "secondary", invited = "outline",
  away = "default", inactive = "destructive")
PAGE_SIZE <- 4L

# Per-metric weekly series that the chart + card react to.
METRICS <- list(
  rev    = list(label = "Revenue",      unit = "$",
    vals = c(32, 28, 41, 37, 48, 44, 39)),
  arr    = list(label = "ARR",          unit = "$k",
    vals = c(210, 214, 219, 223, 228, 231, 236)),
  signup = list(label = "Signups",      unit = "",
    vals = c(120, 98, 145, 132, 170, 160, 150)),
  active = list(label = "Active users", unit = "",
    vals = c(880, 905, 890, 930, 950, 940, 962))
)

metrics_tbl <- data.frame(
  Metric = c("Revenue", "New signups", "Active users", "Churn"),
  This_period = c("$48,210", "1,204", "8,932", "1.8%"),
  Last_period = c("$43,050", "1,090", "8,410", "2.1%"),
  Change = c("+12.0%", "+10.5%", "+6.2%", "-0.3pp"),
  check.names = FALSE, stringsAsFactors = FALSE)

WEEKDAYS <- c("Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun")

# A minimal CSS bar chart from a numeric vector.
bar_chart <- function(values, labels, unit = "") {
  mx <- max(values)
  tags$div(style = "display:flex;align-items:flex-end;gap:0.5rem;height:9rem;padding-top:0.5rem",
    Map(function(v, l) {
      h <- max(2L, round(v / mx * 116))
      tags$div(
        style = paste0("flex:1;display:flex;flex-direction:column;align-items:center;",
                       "justify-content:flex-end;gap:0.35rem;height:100%"),
        tags$div(
          title = paste0(l, ": ", unit, format(v, big.mark = ",")),
          style = sprintf(paste0("width:100%%;height:%dpx;border-radius:var(--shad-radius-sm);",
                                  "background:var(--shad-primary)"), h)),
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

  # Command palette (opened by ⌘K, the Search button, or the View menu).
  shad_command("cmdk", dialog = TRUE, placeholder = "Type a command…",
    shad_command_group("Navigation",
      shad_command_item("go_overview", "Go to Overview", keywords = "home"),
      shad_command_item("go_team", "Go to Team", keywords = "members"),
      shad_command_item("go_reports", "Go to Reports", keywords = "metrics")),
    shad_command_separator(),
    shad_command_group("Actions",
      shad_command_item("cmd_refresh", "Refresh data", shortcut = "⌘R"),
      shad_command_item("cmd_invite", "Invite member"),
      shad_command_item("cmd_new", "New report", shortcut = "⌘N"))),

  # Invite dialog.
  shad_dialog("invite_dlg", title = "Invite a member",
    description = "They'll get an email invitation.",
    tags$div(style = "display:grid;gap:1rem",
      shad_form_field(shad_input("inv_name", placeholder = "Jane Cooper"),
        label = "Full name", required = TRUE),
      shad_form_field(
        shad_input_group(block = TRUE,
          shad_input_group_addon(shad_icon("mail"), align = "inline-start"),
          shad_input("inv_email", type = "email", placeholder = "jane@acme.io")),
        label = "Email", required = TRUE),
      shad_select("inv_role", label = "Role", choices = ROLES,
        selected = "Member")),
    footer = tagList(
      shad_dialog_close_button("Cancel"),
      shad_button("Send invite", inputId = "invite_send"))),

  # Edit-role dialog.
  shad_dialog("edit_dlg", title = "Edit role",
    description = textOutput("edit_who", inline = TRUE),
    shad_select("edit_role", label = "Role", choices = ROLES, selected = "Member"),
    footer = tagList(
      shad_dialog_close_button("Cancel"),
      shad_button("Save", inputId = "edit_save"))),

  # New-report dialog.
  shad_dialog("report_dlg", title = "New report",
    description = "Give it a name and a primary metric.",
    tags$div(style = "display:grid;gap:1rem",
      shad_form_field(shad_input("rep_name", placeholder = "Q3 revenue review"),
        label = "Report name", required = TRUE),
      shad_select("rep_metric", label = "Metric",
        choices = c("Revenue" = "rev", "ARR" = "arr", "Signups" = "signup",
          "Active users" = "active"), selected = "rev")),
    footer = tagList(
      shad_dialog_close_button("Cancel"),
      shad_button("Create report", inputId = "report_create"))),

  # Profile dialog.
  shad_dialog("profile_dlg", title = "Your profile",
    tags$div(style = "display:grid;gap:1rem;justify-items:center;text-align:center",
      shad_avatar(fallback = "YOU", size = "xl"),
      tags$div(shad_h4("You", style = "margin:0"),
        shad_muted("you@acme.io")),
      shad_badge("Owner", variant = "secondary")),
    footer = shad_dialog_close_button("Close")),

  # Message sheet (per-member).
  shad_sheet("msg_sheet", side = "right", title = "New message",
    description = textOutput("msg_who", inline = TRUE),
    tags$div(style = "display:grid;gap:1rem;padding:1rem 0",
      shad_textarea("msg_body", placeholder = "Write a message…", rows = 6)),
    footer = tagList(
      shad_button("Cancel", inputId = "msg_cancel", variant = "outline"),
      shad_button("Send", inputId = "msg_send", icon = "arrow-right",
        icon_position = "right"))),

  # Billing sheet.
  shad_sheet("billing_sheet", side = "right", title = "Billing",
    description = "Manage your plan and invoices.",
    tags$div(style = "display:grid;gap:1rem;padding:1rem 0",
      shad_item(tags$span(style = "font-weight:600", "Team plan"),
        description = "$49 / month · renews Aug 1",
        footer = shad_badge("Active", variant = "secondary"), variant = "outline"),
      shad_item("Payment method", description = "Visa •••• 4242",
        variant = "outline"),
      shad_h4("Recent invoices"),
      shad_item_group(
        shad_item("Jul 2026", description = "$49.00",
          footer = shad_badge("Paid", variant = "secondary"), size = "sm"),
        shad_item("Jun 2026", description = "$49.00",
          footer = shad_badge("Paid", variant = "secondary"), size = "sm"),
        shad_item("May 2026", description = "$49.00",
          footer = shad_badge("Paid", variant = "secondary"), size = "sm"))),
    footer = shad_button("Update plan", inputId = "billing_update",
      style = "width:100%")),

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
                        shad_card_header(
                          shad_card_title(textOutput("chart_title", inline = TRUE)),
                          shad_card_description(textOutput("chart_sub", inline = TRUE))),
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
                  tags$div(style = "display:flex;gap:0.75rem;flex-wrap:wrap",
                    shad_badge(textOutput("team_count", inline = TRUE),
                      variant = "outline")),
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
                  tags$div(style = "display:flex;justify-content:space-between;align-items:center",
                    shad_h3("Reports", style = "margin:0;border:0;padding:0"),
                    shad_button("New report", inputId = "rep_new_btn",
                      icon = "plus")),
                  shad_card(
                    shad_card_header(shad_card_title("Saved reports")),
                    shad_card_content(style = "padding:0",
                      uiOutput("reports_list"))),
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
  members <- reactiveVal(seed_members)
  reports <- reactiveVal(data.frame(
    name = c("Weekly revenue", "Signup funnel"),
    metric = c("rev", "signup"),
    when = c("Jul 8", "Jul 5"), stringsAsFactors = FALSE))
  edit_target <- reactiveVal(NULL)
  msg_target <- reactiveVal(NULL)
  next_id <- reactiveVal(9L)

  open_palette <- function()
    session$sendCustomMessage("shadshiny:invoke", list(id = "cmdk", method = "open"))

  observeEvent(input$sortmenu, {
    v <- input$sortmenu
    if (v %in% c("name", "usage", "role")) sort_by(v)
    else if (v == "invited_only") invited_only(!invited_only())
    else if (v %in% c("exp_csv", "exp_json")) do_export(sub("exp_", "", v))
  }, ignoreInit = TRUE)

  output$crumb <- renderText(
    c(overview = "Overview", team = "Team", reports = "Reports")[active_tab()])

  # -- KPI cards + period ---------------------------------------------
  period_label <- reactive({
    r <- input$range
    if (is.null(r) || length(r) < 2 || any(!nzchar(as.character(r))))
      return("last 7 days")
    paste(r[[1]], "→", r[[2]])
  })

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

  # -- Metric-driven chart --------------------------------------------
  cur_metric <- reactive(METRICS[[input$metric %||% "rev"]])
  output$chart_title <- renderText(paste("Weekly", tolower(cur_metric()$label)))
  output$chart_sub <- renderText(paste("Showing", period_label()))

  output$chart <- renderUI({
    if (loading()) {
      return(tags$div(style = "display:flex;gap:0.5rem;align-items:flex-end;height:9rem",
        lapply(c(60, 40, 80, 55, 90, 70, 45), function(h)
          shad_skeleton(width = "100%", height = paste0(h, "%")))))
    }
    m <- cur_metric()
    bar_chart(m$vals, WEEKDAYS, unit = m$unit)
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

  do_refresh <- function() {
    loading(TRUE)
    id <- shad_toast_loading("Refreshing data…")
    later::later(function() {
      shiny::withReactiveDomain(session, {
        loading(FALSE)
        shad_toast_update(id, message = "Data up to date", variant = "success",
          session = session)
      })
    }, delay = 1.2)
  }
  observeEvent(input$refresh, do_refresh())

  # -- Export (shared) -------------------------------------------------
  do_export <- function(fmt) {
    id <- shad_toast_loading(paste0("Exporting ", toupper(fmt), "…"))
    n <- nrow(members())
    later::later(function() {
      shiny::withReactiveDomain(session, {
        shad_toast_update(id,
          message = paste0(n, " members exported as ", toupper(fmt)),
          variant = "success", session = session)
      })
    }, delay = 1.0)
  }

  # -- Team directory (mutable) ---------------------------------------
  filtered <- reactive({
    df <- members()
    q <- tolower(input$team_q %||% "")
    if (nzchar(q)) {
      df <- df[grepl(q, tolower(df$name)) | grepl(q, tolower(df$email)), ]
    }
    df <- df[df$usage >= (input$min_usage %||% 0), , drop = FALSE]
    if (invited_only()) df <- df[df$status == "invited", , drop = FALSE]
    ord <- switch(sort_by(),
      usage = order(-df$usage),
      role  = order(match(df$role, ROLES), df$name),
      order(df$name))
    df[ord, , drop = FALSE]
  })

  output$team_count <- renderText({
    n <- nrow(filtered()); tot <- nrow(members())
    if (n == tot) paste(tot, "members")
    else paste(n, "of", tot, "members")
  })
  outputOptions(output, "team_count", suspendWhenHidden = FALSE)

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
            variant = status_variant[[m$status]] %||% "default"),
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
  outputOptions(output, "team_list", suspendWhenHidden = FALSE)

  # Register a per-row observer for each member id, once. next_id only grows,
  # so ids are never reused; new invitees get a fresh observer here.
  registered <- new.env(parent = emptyenv())
  ensure_row_observer <- function(mid) {
    if (!is.null(registered[[mid]])) return()
    registered[[mid]] <- TRUE
    observeEvent(input[[paste0("rmnu_", mid)]], {
      handle_row(mid, input[[paste0("rmnu_", mid)]])
    }, ignoreInit = TRUE)
  }
  observe(lapply(members()$id, ensure_row_observer))

  handle_row <- function(mid, action) {
    df <- members(); m <- df[df$id == mid, ]
    if (nrow(m) == 0) return()
    if (identical(action, "remove")) {
      members(df[df$id != mid, , drop = FALSE])
      shad_toast_error(paste("Removed", m$name))
    } else if (identical(action, "edit")) {
      edit_target(mid)
      update_shad_select("edit_role", m$role)
      shad_dialog_open("edit_dlg")
    } else if (identical(action, "message")) {
      msg_target(mid)
      updateTextAreaInput(session, "msg_body", value = "")
      shad_sheet_open("msg_sheet")
    }
  }

  # Edit role -----
  output$edit_who <- renderText({
    mid <- edit_target()
    if (is.null(mid)) return("")
    nm <- members()$name[members()$id == mid]
    paste("Change the role for", nm)
  })
  outputOptions(output, "edit_who", suspendWhenHidden = FALSE)
  observeEvent(input$edit_save, {
    mid <- edit_target(); if (is.null(mid)) return()
    df <- members(); df$role[df$id == mid] <- input$edit_role %||% "Member"
    members(df)
    shad_dialog_close("edit_dlg")
    shad_toast_success(paste0("Role updated to ", input$edit_role, "."))
  })

  # Message -----
  output$msg_who <- renderText({
    mid <- msg_target()
    if (is.null(mid)) return("")
    paste("To", members()$name[members()$id == mid])
  })
  outputOptions(output, "msg_who", suspendWhenHidden = FALSE)
  observeEvent(input$msg_cancel, shad_sheet_close("msg_sheet"))
  observeEvent(input$msg_send, {
    if (!nzchar(trimws(input$msg_body %||% ""))) {
      shad_toast_error("Write a message first."); return()
    }
    shad_sheet_close("msg_sheet")
    shad_toast_success(paste("Message sent to",
      members()$name[members()$id == msg_target()]))
  })

  # Invite -----
  open_invite <- function() {
    updateTextInput(session, "inv_name", value = "")
    updateTextInput(session, "inv_email", value = "")
    update_shad_select("inv_role", "Member")
    shad_dialog_open("invite_dlg")
  }
  observeEvent(input$invite, open_invite())
  observeEvent(input$ctx_invite, open_invite())
  observeEvent(input$cmd_invite, open_invite())
  observeEvent(input$invite_send, {
    name <- trimws(input$inv_name %||% "")
    email <- trimws(input$inv_email %||% "")
    if (!nzchar(name) || !nzchar(email)) {
      shad_toast_error("Name and email are required."); return()
    }
    id <- paste0("m", next_id()); next_id(next_id() + 1L)
    row <- data.frame(id = id, name = name, email = email,
      role = input$inv_role %||% "Member", status = "invited", usage = 0L,
      initials = make_initials(name), stringsAsFactors = FALSE)
    members(rbind(members(), row))
    shad_dialog_close("invite_dlg")
    shad_toast_success(paste("Invitation sent to", name))
  })

  observeEvent(input$clear_team, {
    update_shad_slider("min_usage", 0)
    updateTextInput(session, "team_q", value = "")
    invited_only(FALSE)
    shad_toast("Filters cleared.")
  })

  observeEvent(input$ctx_export, do_export("csv"))
  observeEvent(input$ctx_refresh, shad_toast("Refreshed team list."))

  # -- Reports (grow the list) ----------------------------------------
  metric_label <- c(rev = "Revenue", arr = "ARR", signup = "Signups",
    active = "Active users")
  output$reports_list <- renderUI({
    df <- reports()
    if (nrow(df) == 0)
      return(shad_empty("No reports yet", media = "file", media_variant = "icon",
        description = "Create one from the New report button."))
    shad_item_group(
      lapply(seq_len(nrow(df)), function(i) {
        r <- df[i, ]
        shad_item(tags$span(style = "font-weight:500", r$name),
          description = paste("Created", r$when),
          media = "file", media_variant = "icon",
          footer = shad_badge(metric_label[[r$metric]] %||% r$metric,
            variant = "secondary"),
          variant = "outline")
      }))
  })
  outputOptions(output, "reports_list", suspendWhenHidden = FALSE)

  open_report <- function() {
    updateTextInput(session, "rep_name", value = "")
    update_shad_select("rep_metric", "rev")
    shad_dialog_open("report_dlg")
  }
  observeEvent(input$mb_new, open_report())
  observeEvent(input$cmd_new, open_report())
  observeEvent(input$rep_new_btn, open_report())
  observeEvent(input$report_create, {
    nm <- trimws(input$rep_name %||% "")
    if (!nzchar(nm)) { shad_toast_error("Give the report a name."); return() }
    row <- data.frame(name = nm, metric = input$rep_metric %||% "rev",
      when = format(Sys.Date(), "%b %d"), stringsAsFactors = FALSE)
    reports(rbind(row, reports()))
    shad_dialog_close("report_dlg")
    shad_toast_success(paste0("Report “", nm, "” created."))
  })

  observeEvent(input$deliver,
    shad_toast_success(paste("Delivery scheduled for", input$deliver)),
    ignoreInit = TRUE)

  # -- Menubar / palette / nav ----------------------------------------
  go <- function(tab) { update_shad_tabs("view", tab); active_tab(tab) }

  observeEvent(input$view, active_tab(input$view), ignoreInit = TRUE)
  observeEvent(input$shell$active, {
    sel <- input$shell$active
    if (is.null(sel) || !nzchar(sel)) return()
    if (sel %in% c("overview", "team", "reports")) go(sel)
    else if (sel == "settings") shad_dialog_open("profile_dlg")
    else if (sel == "help") open_palette()
  }, ignoreInit = TRUE)

  observeEvent(input$cmdk, {
    switch(input$cmdk,
      go_overview = go("overview"),
      go_team = go("team"),
      go_reports = go("reports"),
      cmd_refresh = { go("overview"); do_refresh() },
      cmd_invite = open_invite(),
      cmd_new = open_report())
  }, ignoreInit = TRUE)

  observeEvent(input$mb_sidebar, shad_sidebar_toggle("shell"))
  observeEvent(input$mb_palette, open_palette())
  observeEvent(input$open_palette, open_palette())
  observeEvent(input$mb_export, do_export("csv"))

  observeEvent(input$acct_profile, shad_dialog_open("profile_dlg"))
  observeEvent(input$acct_billing, shad_sheet_open("billing_sheet"))
  observeEvent(input$acct_logout, shad_toast("Logged out."))
  observeEvent(input$billing_update, {
    shad_sheet_close("billing_sheet"); shad_toast_success("Plan updated.")
  })
}

shinyApp(ui, server)

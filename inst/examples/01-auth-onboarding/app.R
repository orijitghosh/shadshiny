# shadshiny example 01 — Auth & onboarding ------------------------------------
# A working sign-in / create-account flow: tabbed auth card that validates
# against demo accounts, a 4-step onboarding wizard with a live progress bar and
# input-OTP 2FA, password reveal, a forgot-password dialog, simulated social
# sign-in, and a signed-in workspace view. Every control does something.
# Run with shadshiny::shad_run_example("01-auth-onboarding").
#
# Components: page_shad, tabs, card, input, input-group (+addon/text/button),
# form-field, label, checkbox, switch, button, button-group (+separator),
# input-otp, radio-group, select, native-select, combobox, progress, alert,
# dialog, toast, avatar (+group), badge, separator, spinner, kbd, aspect-ratio,
# item (+group), typography, icon.

library(shiny)
library(shadshiny)

`%||%` <- function(a, b) if (is.null(a)) b else a

# Demo directory the sign-in form validates against (email = password).
DEMO_USERS <- c("ada@acme.io" = "password", "grace@acme.io" = "shadshiny")

countries <- c("United States" = "us", "United Kingdom" = "uk",
  "Germany" = "de", "India" = "in", "Japan" = "jp", "Brazil" = "br")
zones <- list(
  Americas = c("New York" = "America/New_York", "Sao Paulo" = "America/Sao_Paulo"),
  Europe   = c("London" = "Europe/London", "Berlin" = "Europe/Berlin"),
  Asia     = c("Tokyo" = "Asia/Tokyo", "Kolkata" = "Asia/Kolkata")
)
roles <- c("Engineering" = "eng", "Design" = "design", "Product" = "product",
  "Marketing" = "marketing", "Operations" = "ops", "Sales" = "sales")
plans <- c(free = "Free", pro = "Pro — $12/mo", team = "Team — $49/mo")

WIZARD_STEPS <- c("Account", "Profile", "Verify", "Done")

# --- Onboarding step bodies (server-rendered) --------------------------------
step_account <- function() {
  tags$div(style = "display:grid;gap:1rem",
    shad_form_field(
      shad_input("ob_name", placeholder = "Ada Lovelace"),
      label = "Full name", required = TRUE),
    shad_form_field(
      shad_input_group(block = TRUE,
        shad_input_group_addon(shad_icon("mail"), align = "inline-start"),
        shad_input("ob_email", type = "email", placeholder = "you@example.com")),
      label = "Work email", required = TRUE,
      description = "We'll send a verification code here."),
    shad_form_field(
      shad_input_group(block = TRUE,
        shad_input("ob_pw", type = "password", placeholder = "8+ characters"),
        shad_input_group_addon(
          shad_input_group_button("Show", inputId = "ob_pw_show"),
          align = "inline-end")),
      label = "Password", required = TRUE,
      description = "Use at least 8 characters."))
}

step_profile <- function() {
  tags$div(style = "display:grid;gap:1.25rem",
    shad_radio_group("ob_plan", label = "Choose a plan",
      choices = c("Free — for individuals" = "free",
        "Pro — $12/mo" = "pro", "Team — $49/mo" = "team"),
      selected = "pro"),
    tags$div(style = "display:grid;grid-template-columns:1fr 1fr;gap:1rem",
      shad_select("ob_country", label = "Country", choices = countries,
        selected = "us"),
      shad_form_field(
        shad_native_select("ob_tz", choices = zones,
          selected = "America/New_York", label = "Time zone"),
        label = "Time zone")),
    shad_combobox("ob_role", label = "Primary role", choices = roles,
      placeholder = "Pick a role"),
    shad_switch("ob_news", "Send me product updates", value = TRUE))
}

step_verify <- function() {
  tags$div(style = "display:grid;gap:1rem;justify-items:center;text-align:center",
    shad_muted("Enter the 6-digit code we sent to your email."),
    shad_input_otp("ob_otp", length = 6, groups = c(3, 3)),
    tags$div(style = "display:flex;gap:0.5rem;align-items:center",
      shad_muted("Demo code:"), shad_kbd("1"), shad_kbd("2"), shad_kbd("3"),
      shad_kbd("4"), shad_kbd("5"), shad_kbd("6")),
    shad_button("Resend code", inputId = "ob_resend", variant = "ghost",
      size = "sm"),
    uiOutput("ob_otp_msg"))
}

# Final review step — echoes back everything the user picked.
step_done <- function(name, plan, country, tz, role, news) {
  who <- if (nzchar(name)) name else "there"
  row <- function(label, value) shad_item(
    tags$span(style = "font-weight:500", value %||% "—"),
    header = shad_muted(label), size = "sm", variant = "outline")
  tags$div(style = "display:grid;gap:1rem;justify-items:center;text-align:center",
    shad_avatar(fallback = toupper(substr(who, 1, 2)), size = "xl"),
    shad_h3(paste0("Welcome, ", who, "!")),
    shad_badge("Ready to launch", variant = "secondary", icon = "check"),
    shad_muted("Review your details, then enter your workspace."),
    tags$div(style = "width:100%;text-align:left",
      shad_item_group(
        row("Plan", plans[[plan %||% "pro"]]),
        row("Country", names(countries)[match(country %||% "us", countries)]),
        row("Timezone", tz %||% "—"),
        row("Role", if (!is.null(role) && nzchar(role))
          names(roles)[match(role, roles)] else "Not set"),
        row("Product updates", if (isTRUE(news)) "On" else "Off"))))
}

# --- Signed-in workspace stub ------------------------------------------------
workspace_view <- function() {
  tags$div(style = "width:100%;max-width:30rem;display:grid;gap:1rem",
    tags$div(style = "display:flex;justify-content:space-between;align-items:center",
      shad_switch("dark", "Dark"),
      shad_button("Sign out", inputId = "sign_out", variant = "outline",
        icon = "arrow-left")),
    shad_card(
      shad_card_header(
        shad_card_title(textOutput("ws_greeting", inline = TRUE)),
        shad_card_description("Your workspace is ready."),
        shad_card_action(uiOutput("ws_plan_badge"))),
      shad_card_content(style = "display:grid;gap:1rem",
        uiOutput("ws_loading"),
        uiOutput("ws_details")),
      shad_card_footer(style = "display:grid;gap:0.75rem",
        shad_button("Open dashboard", inputId = "ws_open",
          icon = "arrow-right", icon_position = "right", style = "width:100%"),
        shad_button_group(style = "width:100%",
          shad_button("Invite team", inputId = "ws_invite",
            variant = "outline", style = "flex:1"),
          shad_button_group_separator(),
          shad_button("Settings", inputId = "ws_settings",
            variant = "outline", style = "flex:1")))))
}

# --- Auth (logged-out) panel -------------------------------------------------
auth_view <- function() {
  tags$div(style = "width:100%;max-width:26rem;display:grid;gap:1rem",
    tags$div(style = "display:flex;justify-content:flex-end",
      shad_switch("dark", "Dark")),
    shad_tabs("auth_tab",
      shad_tab("signin", "Sign in",
        shad_card(
          shad_card_header(shad_card_title("Welcome back"),
            shad_card_description("Sign in to your account.")),
          shad_card_content(style = "display:grid;gap:1rem",
            shad_alert(title = "Demo accounts",
              description = tags$span("Try ", tags$strong("ada@acme.io"),
                " / ", tags$strong("password"), "."),
              icon = "info"),
            uiOutput("signin_alert"),
            shad_form_field(
              shad_input_group(block = TRUE,
                shad_input_group_addon(shad_icon("mail"), align = "inline-start"),
                shad_input("si_email", type = "email",
                  placeholder = "you@example.com")),
              label = "Email"),
            shad_form_field(
              shad_input_group(block = TRUE,
                shad_input("si_pw", type = "password", placeholder = "Password"),
                shad_input_group_addon(
                  shad_input_group_button("Show", inputId = "si_pw_show"),
                  align = "inline-end")),
              label = "Password"),
            tags$div(style = "display:flex;justify-content:space-between;align-items:center",
              shad_checkbox("si_remember", "Remember me", value = TRUE),
              shad_button("Forgot password?", inputId = "forgot_open",
                variant = "link", size = "sm",
                style = "height:auto;padding:0"))),
          shad_card_footer(style = "display:grid;gap:0.75rem",
            shad_button("Sign in", inputId = "do_signin",
              icon = "arrow-right", icon_position = "right",
              style = "width:100%"),
            tags$div(style = "display:flex;align-items:center;gap:0.75rem",
              shad_separator(style = "flex:1"),
              shad_small(class = "shad-muted", "OR"),
              shad_separator(style = "flex:1")),
            shad_button_group(aria_label = "Social sign-in",
              style = "width:100%",
              shad_button("Continue with Google", inputId = "oauth_google",
                variant = "outline", style = "flex:1"),
              shad_button_group_separator(),
              shad_button("GitHub", inputId = "oauth_github",
                variant = "outline", style = "flex:1"))))),
      shad_tab("register", "Create account",
        shad_card(
          shad_card_header(
            shad_card_title(textOutput("ob_title", inline = TRUE)),
            shad_card_description(textOutput("ob_subtitle", inline = TRUE)),
            shad_card_action(
              shad_badge(textOutput("ob_step_badge", inline = TRUE),
                variant = "outline"))),
          shad_card_content(style = "display:grid;gap:1rem",
            shad_progress(0, inputId = "ob_progress"),
            uiOutput("ob_body")),
          shad_card_footer(style = "display:flex;justify-content:space-between",
            shad_button("Back", inputId = "ob_back", variant = "ghost",
              icon = "arrow-left"),
            shad_button("Next", inputId = "ob_next", icon = "arrow-right",
              icon_position = "right"))))))
}

ui <- page_shad(
  title = "Acme — Sign in",
  theme_preset = "violet",

  tags$head(tags$style(htmltools::HTML(paste(
    "@media (max-width: 860px) {",
    "  .auth-grid { grid-template-columns: 1fr !important; }",
    "  .auth-brand { display: none !important; }",
    "}", sep = "\n")))),

  # Forgot-password dialog (opened from the server).
  shad_dialog("forgot_dlg", title = "Reset your password",
    description = "Enter your email and we'll send a reset link.",
    shad_form_field(
      shad_input_group(block = TRUE,
        shad_input_group_addon(shad_icon("mail"), align = "inline-start"),
        shad_input("forgot_email", type = "email",
          placeholder = "you@example.com")),
      label = "Email"),
    footer = tagList(
      shad_dialog_close_button("Cancel"),
      shad_button("Send reset link", inputId = "forgot_send"))),

  tags$div(class = "auth-grid",
    style = paste("min-height:100vh;display:grid;",
      "grid-template-columns:1fr 1fr;background:var(--shad-background)"),

    # -- Brand panel (hidden on narrow screens) --------------------------
    tags$div(class = "auth-brand",
      style = paste("position:relative;display:grid;align-content:center;",
        "gap:1.5rem;padding:3rem;color:white;overflow:hidden;",
        "background:linear-gradient(135deg,var(--shad-primary),#4c1d95)"),
      tags$div(style = "display:flex;align-items:center;gap:0.6rem",
        shad_icon("terminal"), tags$strong(style = "font-size:1.1rem", "Acme Inc")),
      shad_h1("Build faster. Ship calmer.", class = "shad-h1",
        style = "color:white;border:0"),
      shad_lead(style = "color:rgba(255,255,255,0.8)",
        "The all-in-one workspace trusted by 30,000 teams."),
      tags$div(style = "display:flex;gap:0.75rem;margin-top:1rem",
        shad_avatar_group(
          shad_avatar(fallback = "AB"), shad_avatar(fallback = "CD"),
          shad_avatar(fallback = "EF"), shad_avatar(fallback = "GH"), max = 3)),
      tags$div(style = "width:60%",
        shad_aspect_ratio(ratio = 16 / 9,
          tags$div(style = paste("width:100%;height:100%;border-radius:1rem;",
            "background:rgba(255,255,255,0.12);display:grid;place-items:center"),
            shad_muted(style = "color:rgba(255,255,255,0.85)", "Dashboard preview"))))),

    # -- Right panel: auth when logged out, workspace when logged in -----
    tags$div(style = "display:grid;align-content:center;justify-items:center;padding:2rem",
      uiOutput("panel")))
)

server <- function(input, output, session) {
  observeEvent(input$dark, update_shad_theme(dark = isTRUE(input$dark)),
    ignoreInit = TRUE)

  authed <- reactiveVal(NULL)   # signed-in user's email, or NULL

  # Whole right panel swaps between the auth flow and the workspace.
  output$panel <- renderUI(if (is.null(authed())) auth_view() else workspace_view())

  # -- Password reveal (flip the native input type) --------------------
  pw_shown <- reactiveValues(si_pw = FALSE, ob_pw = FALSE)
  toggle_pw <- function(field, btn) {
    pw_shown[[field]] <- !pw_shown[[field]]
    session$sendCustomMessage("shadshiny:attr", list(id = field, attr = "type",
      value = if (pw_shown[[field]]) "text" else "password"))
    update_shad_button(btn, label = if (pw_shown[[field]]) "Hide" else "Show")
  }
  observeEvent(input$si_pw_show, toggle_pw("si_pw", "si_pw_show"))
  observeEvent(input$ob_pw_show, toggle_pw("ob_pw", "ob_pw_show"))

  # -- Sign in ---------------------------------------------------------
  signin_err <- reactiveVal(NULL)
  output$signin_alert <- renderUI({
    msg <- signin_err()
    if (is.null(msg)) return(NULL)
    shad_alert(title = "Sign-in failed", description = msg,
      variant = "destructive", icon = "circle-alert")
  })
  do_sign_in <- function(email) {
    signin_err(NULL)
    authed(email)
    shad_toast_success(paste0("Signed in as ", email))
  }
  observeEvent(input$do_signin, {
    email <- tolower(trimws(input$si_email %||% ""))
    pw <- input$si_pw %||% ""
    if (!nzchar(email) || !nzchar(pw)) {
      signin_err("Enter both your email and password.")
    } else if (is.na(DEMO_USERS[email]) || !identical(DEMO_USERS[[email]], pw)) {
      signin_err("Unknown email or wrong password. Try ada@acme.io / password.")
    } else {
      if (isTRUE(input$si_remember)) shad_toast("We'll keep you signed in.")
      do_sign_in(email)
    }
  })

  # -- Forgot password -------------------------------------------------
  observeEvent(input$forgot_open, {
    updateTextInput(session, "forgot_email", value = input$si_email %||% "")
    shad_dialog_open("forgot_dlg")
  })
  observeEvent(input$forgot_send, {
    email <- trimws(input$forgot_email %||% "")
    if (!nzchar(email)) {
      shad_toast_error("Enter your email first.")
    } else {
      shad_dialog_close("forgot_dlg")
      shad_toast_success(paste0("Reset link sent to ", email, "."))
    }
  })

  # -- Social sign-in (simulated round-trip) ---------------------------
  social <- function(provider, email) {
    id <- shad_toast_loading(paste0("Redirecting to ", provider, "…"))
    later::later(function() {
      shiny::withReactiveDomain(session, {
        shad_toast_update(id, message = paste0("Connected to ", provider),
          variant = "success", session = session)
        do_sign_in(email)
      })
    }, delay = 1.2)
  }
  observeEvent(input$oauth_google, social("Google", "ada@acme.io"))
  observeEvent(input$oauth_github, social("GitHub", "grace@acme.io"))

  # -- Onboarding wizard ----------------------------------------------
  step <- reactiveVal(1L)
  n <- length(WIZARD_STEPS)

  output$ob_title <- renderText(
    if (step() == n) "You're all set" else "Create your account")
  output$ob_subtitle <- renderText(sprintf("Step %d of %d — %s",
    step(), n, WIZARD_STEPS[step()]))
  output$ob_step_badge <- renderText(WIZARD_STEPS[step()])

  observe(update_shad_progress("ob_progress",
    round((step() - 1) / (n - 1) * 100)))

  output$ob_body <- renderUI({
    switch(step(),
      step_account(), step_profile(), step_verify(),
      step_done(input$ob_name %||% "", input$ob_plan, input$ob_country,
        input$ob_tz, input$ob_role, input$ob_news))
  })

  output$ob_otp_msg <- renderUI({
    code <- input$ob_otp %||% ""
    if (nchar(code) < 6) return(NULL)
    if (identical(code, "123456")) {
      shad_alert(title = "Verified", description = "Code accepted.", icon = "check")
    } else {
      shad_alert(title = "Wrong code", description = "Try 123456 for this demo.",
        variant = "destructive", icon = "circle-alert")
    }
  })

  observeEvent(input$ob_resend, shad_toast("New code sent — it's 123456."))

  observeEvent(input$ob_back, if (step() > 1) step(step() - 1L))

  observeEvent(input$ob_next, {
    s <- step()
    if (s == 1L) {
      if (!nzchar(input$ob_name %||% "") || !nzchar(input$ob_email %||% "")) {
        shad_toast_error("Fill in your name and email first.")
        return()
      }
      if (nchar(input$ob_pw %||% "") < 8) {
        shad_toast_error("Password must be at least 8 characters.")
        return()
      }
    }
    if (s == 3L && !identical(input$ob_otp %||% "", "123456")) {
      shad_toast_error("Enter the demo code 123456 to verify.")
      return()
    }
    if (s == n) {                       # final step → enter workspace
      authed(tolower(trimws(input$ob_email %||% "new@acme.io")))
      shad_toast_success("Account created — welcome aboard!")
      return()
    }
    if (s == 3L) shad_toast_success("Email verified.")
    step(s + 1L)
  })

  outputOptions(output, "ob_body", suspendWhenHidden = FALSE)
  outputOptions(output, "ob_otp_msg", suspendWhenHidden = FALSE)

  observe(update_shad_button("ob_next",
    label = if (step() >= n) "Enter workspace" else "Next"))

  # -- Workspace (signed-in) ------------------------------------------
  ws_ready <- reactiveVal(FALSE)
  observeEvent(authed(), {              # simulate loading on sign-in
    if (is.null(authed())) return()
    ws_ready(FALSE)
    later::later(function() shiny::withReactiveDomain(session, ws_ready(TRUE)),
      delay = 0.9)
  })

  output$ws_greeting <- renderText({
    who <- strsplit(authed() %||% "", "@")[[1]][1]
    paste0("Hi, ", tools::toTitleCase(who), " 👋")
  })
  output$ws_plan_badge <- renderUI(
    shad_badge(plans[[input$ob_plan %||% "pro"]], variant = "secondary"))

  output$ws_loading <- renderUI(
    if (ws_ready()) NULL else tags$div(
      style = "display:flex;gap:0.6rem;align-items:center;color:var(--shad-muted-foreground)",
      shad_spinner(size = "sm"), "Loading your workspace…"))

  output$ws_details <- renderUI({
    if (!ws_ready()) return(NULL)
    row <- function(label, value, badge = NULL) shad_item(
      tags$span(style = "font-weight:500", value),
      header = shad_muted(label), footer = badge, size = "sm")
    shad_item_group(
      row("Signed in as", authed()),
      row("Plan", plans[[input$ob_plan %||% "pro"]],
        shad_badge("Active", variant = "secondary", icon = "check")),
      row("Timezone", input$ob_tz %||% "America/New_York"),
      row("Two-factor", "Enabled",
        shad_badge("Secure", variant = "outline")))
  })
  outputOptions(output, "ws_details", suspendWhenHidden = FALSE)
  outputOptions(output, "ws_loading", suspendWhenHidden = FALSE)

  observeEvent(input$ws_open, shad_toast("Opening dashboard…"))
  observeEvent(input$ws_invite, shad_toast_success("Invite link copied."))
  observeEvent(input$ws_settings, shad_toast("Settings are demo-only here."))
  observeEvent(input$sign_out, {
    authed(NULL)
    step(1L)
    signin_err(NULL)
    shad_toast("Signed out.")
  })
}

shinyApp(ui, server)

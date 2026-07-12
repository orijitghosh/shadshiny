# shadshiny example 01 — Auth & onboarding ------------------------------------
# A real sign-in / create-account flow: tabbed auth card, a 4-step onboarding
# wizard with a live progress bar, 2FA via input-OTP, and social sign-in.
# Run with shadshiny::shad_run_example("01-auth-onboarding").
#
# Components: page_shad, tabs, card, input, input-group (+addon/text/button),
# form-field, label, checkbox, switch, button, button-group (+separator),
# input-otp, radio-group, select, native-select, combobox, progress, alert,
# toast, avatar, badge, separator, spinner, kbd, aspect-ratio, typography, icon.

library(shiny)
library(shadshiny)

# tiny null-coalescing helper (mirrors the package internal)
`%||%` <- function(a, b) if (is.null(a)) b else a

countries <- c("United States" = "us", "United Kingdom" = "uk",
  "Germany" = "de", "India" = "in", "Japan" = "jp", "Brazil" = "br")
zones <- list(
  Americas = c("New York" = "America/New_York", "Sao Paulo" = "America/Sao_Paulo"),
  Europe   = c("London" = "Europe/London", "Berlin" = "Europe/Berlin"),
  Asia     = c("Tokyo" = "Asia/Tokyo", "Kolkata" = "Asia/Kolkata")
)
roles <- c("Engineering" = "eng", "Design" = "design", "Product" = "product",
  "Marketing" = "marketing", "Operations" = "ops", "Sales" = "sales")

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
      label = "Password", required = TRUE))
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
      shad_native_select("ob_tz", choices = zones,
        selected = "America/New_York")),
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
    uiOutput("ob_otp_msg"))
}

step_done <- function(name) {
  who <- if (nzchar(name)) name else "there"
  tags$div(style = "display:grid;gap:1rem;justify-items:center;text-align:center",
    shad_avatar(fallback = toupper(substr(who, 1, 2)), size = "xl"),
    shad_h3(paste0("Welcome, ", who, "!")),
    shad_badge("Account verified", variant = "secondary", icon = "check"),
    shad_muted("Your workspace is ready."))
}

ui <- page_shad(
  title = "Acme — Sign in",
  theme_preset = "violet",

  tags$head(tags$style(htmltools::HTML(paste(
    "@media (max-width: 860px) {",
    "  .auth-grid { grid-template-columns: 1fr !important; }",
    "  .auth-brand { display: none !important; }",
    "}", sep = "\n")))),

  tags$div(class = "auth-grid",
    style = paste("min-height:100vh;display:grid;",
      "grid-template-columns:1fr 1fr;background:var(--shad-background)"),

    # -- Brand panel (hidden on narrow screens via CSS below) ------------
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

    # -- Form panel ------------------------------------------------------
    tags$div(style = "display:grid;align-content:center;justify-items:center;padding:2rem",
      tags$div(style = "width:100%;max-width:26rem;display:grid;gap:1rem",
        tags$div(style = "display:flex;justify-content:flex-end",
          shad_switch("dark", "Dark")),
        shad_tabs("auth_tab",
          shad_tab("signin", "Sign in",
            shad_card(
              shad_card_header(shad_card_title("Welcome back"),
                shad_card_description("Sign in to your account.")),
              shad_card_content(style = "display:grid;gap:1rem",
                uiOutput("signin_alert"),
                shad_form_field(
                  shad_input_group(block = TRUE,
                    shad_input_group_addon(shad_icon("mail"), align = "inline-start"),
                    shad_input("si_email", type = "email",
                      placeholder = "you@example.com")),
                  label = "Email"),
                shad_form_field(
                  shad_input("si_pw", type = "password", placeholder = "Password"),
                  label = "Password"),
                tags$div(style = "display:flex;justify-content:space-between;align-items:center",
                  shad_checkbox("si_remember", "Remember me", value = TRUE),
                  tags$a(href = "#", class = "shad-small", "Forgot password?"))),
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
                  icon_position = "right"))))))))
)

server <- function(input, output, session) {
  observeEvent(input$dark, update_shad_theme(dark = isTRUE(input$dark)),
    ignoreInit = TRUE)

  # -- Sign in ---------------------------------------------------------
  signin_err <- reactiveVal(NULL)
  output$signin_alert <- renderUI({
    msg <- signin_err()
    if (is.null(msg)) return(NULL)
    shad_alert(title = "Sign-in failed", description = msg,
      variant = "destructive", icon = "circle-alert")
  })
  observeEvent(input$do_signin, {
    if (!nzchar(input$si_email %||% "") || !nzchar(input$si_pw %||% "")) {
      signin_err("Enter both your email and password.")
    } else {
      signin_err(NULL)
      shad_toast_success(paste0("Signed in as ", input$si_email))
    }
  })
  observeEvent(input$oauth_google, shad_toast_loading("Redirecting to Google…"))
  observeEvent(input$oauth_github, shad_toast_loading("Redirecting to GitHub…"))

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
      step_done(input$ob_name %||% ""))
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

  observeEvent(input$ob_pw_show, shad_toast("Password reveal is demo-only."))

  observeEvent(input$ob_back, {
    if (step() > 1) step(step() - 1L)
  })

  observeEvent(input$ob_next, {
    s <- step()
    # Per-step validation before advancing.
    if (s == 1L) {
      if (!nzchar(input$ob_name %||% "") || !nzchar(input$ob_email %||% "")) {
        shad_toast_error("Fill in your name and email first.")
        return()
      }
    }
    if (s == 3L && !identical(input$ob_otp %||% "", "123456")) {
      shad_toast_error("Enter the demo code 123456 to verify.")
      return()
    }
    if (s == n) {
      shad_toast_success("Redirecting to your workspace…")
      return()
    }
    if (s == 3L) shad_toast_success("Email verified.")
    step(s + 1L)
  })

  # These outputs live inside inactive tabs; render them anyway so the content
  # is present the moment the user switches tabs (custom tabs don't notify
  # Shiny's hidden-output tracking).
  outputOptions(output, "ob_body", suspendWhenHidden = FALSE)
  outputOptions(output, "ob_otp_msg", suspendWhenHidden = FALSE)

  # Relabel the primary button on the final step.
  observe({
    if (step() >= n) {
      update_shad_button("ob_next", label = "Go to workspace")
    } else {
      update_shad_button("ob_next", label = "Next")
    }
  })
}

shinyApp(ui, server)

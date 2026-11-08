# shadshiny example 05 – Account settings ------------------------------------
# A full settings surface with vertical tabs: profile editing, notification
# preferences, a live theme/appearance panel, and a security section with a
# 2FA dialog and destructive alert-dialogs.
# Run with shadshiny::shad_run_example("05-settings-profile").
#
# Components: page_shad, tabs (vertical), form-field, input, input-group,
# textarea, select, native-select, combobox, radio-group, checkbox, switch,
# toggle, toggle-group, slider, date-picker, calendar, dialog, sheet, popover,
# tooltip, alert-dialog, input-otp, button-group, card, badge, avatar,
# separator, label, kbd, item (+group), toast.

library(shiny)
library(shadshiny)
`%||%` <- function(a, b) if (is.null(a)) b else a

langs   <- c("English" = "en", "Español" = "es", "Deutsch" = "de",
             "日本語" = "ja", "हिन्दी" = "hi")
zones   <- list(  # grouped: for native-select optgroups
  Americas = c("New York" = "America/New_York", "Sao Paulo" = "America/Sao_Paulo"),
  Europe   = c("London" = "Europe/London", "Berlin" = "Europe/Berlin"),
  Asia     = c("Tokyo" = "Asia/Tokyo", "Kolkata" = "Asia/Kolkata"))
zones_flat <- c("New York" = "America/New_York", "Sao Paulo" = "America/Sao_Paulo",
  "London" = "Europe/London", "Berlin" = "Europe/Berlin",
  "Tokyo" = "Asia/Tokyo", "Kolkata" = "Asia/Kolkata")  # flat: for combobox
datefmts <- c("2026-07-12" = "iso", "07/12/2026" = "us", "12.07.2026" = "eu")
presets  <- c("Default" = "default", "Slate" = "slate", "Stone" = "stone",
              "Zinc" = "zinc", "Mauve" = "mauve", "Olive" = "olive",
              "Mist" = "mist", "Taupe" = "taupe", "Blue" = "blue",
              "Green" = "green", "Rose" = "rose", "Violet" = "violet",
              "Orange" = "orange")

sessions <- data.frame(
  id     = c("s1", "s2", "s3"),
  device = c("MacBook Pro · Chrome", "iPhone 15 · Safari", "Windows · Edge"),
  where  = c("San Francisco, US · current", "San Francisco, US · 2h ago",
             "Berlin, DE · 3d ago"),
  cur    = c(TRUE, FALSE, FALSE),
  stringsAsFactors = FALSE)

help <- function(text) shad_tooltip(
  tags$span(style = "display:inline-flex;color:var(--shad-muted-foreground);cursor:help",
    shad_icon("info", style = "width:0.85rem;height:0.85rem")), text)

setting_card <- function(title, desc, ...) {
  shad_card(style = "max-width:38rem",
    shad_card_header(shad_card_title(title), shad_card_description(desc)),
    shad_card_content(style = "display:grid;gap:1.1rem", ...))
}

ui <- page_shad(
  title = "Settings",
  theme_preset = "slate",

  tags$div(style = "max-width:60rem;margin:0 auto;padding:1.5rem",
    # Header
    tags$div(style = "display:flex;align-items:center;gap:1rem;margin-bottom:1.5rem",
      shad_avatar(fallback = "AL", size = "lg"),
      tags$div(style = "flex:1",
        tags$div(style = "display:flex;align-items:center;gap:0.5rem",
          shad_h2("Ada Lovelace", style = "margin:0;border:0;font-size:1.4rem"),
          shad_badge("Pro", variant = "secondary")),
        shad_muted("ada@analytical.dev")),
      shad_button("View profile", inputId = "view_profile", variant = "outline")),

    shad_tabs("settings", orientation = "vertical",

      # ================= Profile =================
      shad_tab("profile", "Profile",
        setting_card("Public profile", "This is how others see you.",
          shad_form_field(
            shad_input("name", value = "Ada Lovelace"),
            label = "Display name", required = TRUE),
          shad_form_field(
            shad_input_group(block = TRUE,
              shad_input_group_addon(shad_input_group_text("@"),
                align = "inline-start"),
              shad_input("username", value = "ada"),
              shad_input_group_addon(
                shad_input_group_button("Check", inputId = "check_user"),
                align = "inline-end")),
            label = "Username",
            description = "Your public handle. Try 'admin' to see it taken."),
          uiOutput("user_status"),
          tags$div(style = "display:grid;gap:0.4rem",
            tags$div(style = "display:flex;align-items:center;gap:0.4rem",
              shad_label("Bio", for_id = "bio"), help("Max 160 characters.")),
            shad_toggle_group("bio_fmt", type = "multiple", variant = "outline",
              choices = c("B" = "bold", "I" = "italic", "U" = "underline")),
            shad_textarea("bio", value = "Mathematician. First programmer.",
              autosize = TRUE)),
          shad_toggle("public_email", "Show email on public profile"),
          tags$div(style = "display:grid;grid-template-columns:1fr 1fr;gap:1rem",
            shad_select("lang", label = "Language", choices = langs,
              selected = "en"),
            shad_combobox("tz", label = "Timezone", choices = zones_flat,
              selected = "Europe/London")),
          shad_button_group(
            shad_button("Save changes", inputId = "save_profile"),
            shad_button("Cancel", inputId = "cancel_profile",
              variant = "outline")))),

      # ================= Account =================
      shad_tab("account", "Account",
        setting_card("Account details", "Manage your account information.",
          shad_form_field(shad_input("email", type = "email",
            value = "ada@analytical.dev"), label = "Email"),
          tags$div(style = "display:grid;grid-template-columns:1fr 1fr;gap:1rem",
            shad_form_field(
              shad_native_select("datefmt", choices = datefmts, selected = "iso",
                width = "100%", label = "Date format"),
              label = "Date format"),
            shad_date_picker("dob", label = "Date of birth")),
          shad_separator(),
          tags$div(style = "display:flex;align-items:center;justify-content:space-between",
            tags$div(shad_label("Email receipts"),
              shad_muted(style = "display:block", "Get a receipt for each payment.")),
            shad_switch("receipts", value = TRUE)),
          shad_button("Update account", inputId = "save_account"))),

      # ================= Notifications =================
      shad_tab("notif", "Notifications",
        setting_card("Notifications", "Choose what you want to hear about.",
          tags$div(style = "display:grid;gap:0.9rem",
            shad_switch("n_email", "Email notifications", value = TRUE),
            shad_switch("n_push", "Push notifications", value = TRUE),
            shad_switch("n_sms", "SMS notifications")),
          shad_separator(),
          shad_radio_group("n_freq", label = "Email digest frequency",
            choices = c("Real-time" = "rt", "Daily" = "daily", "Weekly" = "weekly"),
            selected = "daily"),
          shad_separator(),
          tags$div(shad_label("Notify me about"),
            tags$div(style = "display:grid;gap:0.6rem;margin-top:0.5rem",
              shad_checkbox("c_mentions", "Mentions & replies", value = TRUE),
              shad_checkbox("c_team", "Team activity", value = TRUE),
              shad_checkbox("c_product", "Product updates"),
              shad_checkbox("c_marketing", "Marketing", value = FALSE))),
          shad_button("Save preferences", inputId = "save_notif"))),

      # ================= Appearance =================
      shad_tab("appear", "Appearance",
        setting_card("Appearance", "Customise how the app looks. Changes apply live.",
          tags$div(style = "display:flex;align-items:center;justify-content:space-between",
            tags$div(shad_label("Dark mode"),
              shad_muted(style = "display:block", "Switch between light and dark.")),
            shad_switch("dark", "Dark")),
          shad_select("preset", label = "Color theme", choices = presets,
            selected = "slate"),
          tags$div(style = "display:grid;gap:0.4rem",
            shad_label("Density"),
            shad_toggle_group("density", type = "single", variant = "outline",
              choices = c("Compact" = "compact", "Comfortable" = "cozy",
                "Spacious" = "roomy"), selected = "cozy")),
          shad_slider("fontsize", label = "Base font size (px)", value = 16,
            min = 12, max = 20, step = 1,
            marks = c("12" = 12, "16" = 16, "20" = 20)),
          tags$div(style = "display:grid;gap:0.4rem",
            tags$div(style = "display:flex;align-items:center;gap:0.4rem",
              shad_label("Accent"),
              shad_popover("accent_pop", side = "right",
                trigger = shad_button("Pick", inputId = "accent_btn",
                  size = "sm", variant = "outline"),
                title = "Accent color",
                shad_radio_group("accent", orientation = "horizontal",
                  choices = c("Violet" = "violet", "Blue" = "blue",
                    "Green" = "green", "Rose" = "rose"), selected = "violet")))),
          tags$div(style = "display:grid;gap:0.4rem",
            shad_label("Week starts on"),
            shad_calendar("weekstart", value = Sys.Date())))),

      # ================= Security =================
      shad_tab("security", "Security",
        tags$div(style = "display:grid;gap:1.25rem",
          setting_card("Password & 2FA",
            "Keep your account secure.",
            tags$div(style = "display:flex;align-items:center;justify-content:space-between",
              tags$div(shad_label("Password"),
                shad_muted(style = "display:block", "Last changed 3 months ago.")),
              shad_dialog("pwdlg",
                trigger = shad_button("Change password", variant = "outline"),
                title = "Change password",
                description = "Enter your new password and the 6-digit code.",
                shad_input("pw_new", label = "New password", type = "password"),
                tags$div(style = "display:grid;gap:0.4rem;justify-items:center",
                  shad_label("Authenticator code"),
                  shad_input_otp("pw_otp", length = 6, groups = c(3, 3)),
                  shad_muted("Demo code: 123456")),
                footer = tagList(shad_dialog_close_button(),
                  shad_button("Update", inputId = "pw_update")))),
            shad_separator(),
            tags$div(style = "display:flex;align-items:center;justify-content:space-between",
              tags$div(shad_label("Two-factor authentication"),
                shad_muted(style = "display:block", "Require a code at sign-in.")),
              shad_switch("twofa", value = TRUE)),
            tags$div(style = "display:flex;align-items:center;gap:0.4rem",
              shad_muted("Recovery shortcut:"), shad_kbd("⌘"), shad_kbd("."),
              help("Opens the recovery panel in the real app."))),

          setting_card("Active sessions",
            "Devices currently signed in to your account.",
            shad_item_group(
              lapply(seq_len(nrow(sessions)), function(i) {
                s <- sessions[i, ]
                shad_item(s$device, description = s$where,
                  media = tags$span("PC"), media_variant = "icon",
                  variant = "outline",
                  footer = if (s$cur) shad_badge("This device",
                    variant = "secondary") else
                    shad_button("Revoke", size = "sm", variant = "outline",
                      onclick = sprintf(
                        "Shiny.setInputValue('revoke','%s',{priority:'event'})",
                        s$id)))
              }))))),

      # ================= Danger =================
      shad_tab("danger", "Danger zone",
        shad_card(style = "max-width:38rem;border-color:var(--shad-destructive)",
          shad_card_header(
            shad_card_title("Danger zone"),
            shad_card_description("Irreversible and destructive actions.")),
          shad_card_content(style = "display:grid;gap:1rem",
            tags$div(style = "display:flex;align-items:center;justify-content:space-between;gap:1rem",
              tags$div(tags$strong("Deactivate account"),
                shad_muted(style = "display:block",
                  "Your profile is hidden until you sign back in.")),
              shad_alert_dialog("deact",
                trigger = shad_button("Deactivate", variant = "outline"),
                title = "Deactivate your account?",
                description = "You can reactivate any time by signing in.",
                action = "Deactivate")),
            shad_separator(),
            tags$div(style = "display:flex;align-items:center;justify-content:space-between;gap:1rem",
              tags$div(tags$strong("Delete account"),
                shad_muted(style = "display:block",
                  "Permanently remove your account and all data.")),
              shad_alert_dialog("del",
                trigger = shad_button("Delete account", variant = "destructive"),
                title = "Are you absolutely sure?",
                description = paste("This cannot be undone. This will permanently",
                  "delete your account and remove your data from our servers."),
                action = "Delete account", action_variant = "destructive")))))))
)

server <- function(input, output, session) {
  # -- Live appearance -------------------------------------------------
  observeEvent(input$dark, update_shad_theme(dark = isTRUE(input$dark)),
    ignoreInit = TRUE)
  observeEvent(input$preset, update_shad_theme(preset = input$preset),
    ignoreInit = TRUE)
  observeEvent(input$accent, {
    update_shad_theme(preset = input$accent)
    update_shad_select("preset", input$accent)
  }, ignoreInit = TRUE)
  observeEvent(input$fontsize,
    shad_toast(paste0("Base font size set to ", input$fontsize, "px.")),
    ignoreInit = TRUE)

  # -- Username availability ------------------------------------------
  taken <- c("admin", "root", "support", "ada_")
  output$user_status <- renderUI({
    u <- tolower(trimws(input$username %||% ""))
    if (!nzchar(u)) return(NULL)
    if (u %in% taken) {
      shad_alert(title = "Username taken",
        description = paste0("'", u, "' is not available."),
        variant = "destructive", icon = "circle-alert")
    } else {
      tags$div(style = "display:flex;align-items:center;gap:0.4rem;color:var(--shad-primary)",
        shad_icon("circle-check", style = "width:1rem;height:1rem"),
        shad_small(paste0("'", u, "' is available.")))
    }
  })
  observeEvent(input$check_user, {
    u <- tolower(trimws(input$username %||% ""))
    if (u %in% taken) shad_toast_error("That username is taken.")
    else shad_toast_success("Username is available.")
  })

  # -- Saves -----------------------------------------------------------
  observeEvent(input$save_profile, shad_toast_success("Profile saved."))
  observeEvent(input$cancel_profile, shad_toast("Changes discarded."))
  observeEvent(input$save_account, shad_toast_success("Account updated."))
  observeEvent(input$save_notif, shad_toast_success("Preferences saved."))
  observeEvent(input$view_profile, shad_toast("Opening public profile…"))

  # -- Security --------------------------------------------------------
  observeEvent(input$pw_update, {
    if (!identical(input$pw_otp %||% "", "123456")) {
      shad_toast_error("Enter the demo code 123456.")
    } else if (nchar(input$pw_new %||% "") < 8) {
      shad_toast_error("Password must be at least 8 characters.")
    } else {
      shad_dialog_close("pwdlg")
      shad_toast_success("Password updated.")
    }
  })
  observeEvent(input$twofa,
    shad_toast(if (isTRUE(input$twofa)) "2FA enabled." else "2FA disabled."),
    ignoreInit = TRUE)
  observeEvent(input$revoke, {
    dev <- sessions$device[sessions$id == input$revoke]
    shad_toast_warning(paste("Signed out:", dev))
  })

  # -- Danger zone (alert-dialog confirms) -----------------------------
  observeEvent(input$deact_confirm, shad_toast_warning("Account deactivated."))
  observeEvent(input$del_confirm, shad_toast_error("Account deleted."))
}

shinyApp(ui, server)

# shadshiny kitchen-sink -------------------------------------------------------
# Flagship demo: every component instantiated, a theme toolbar, and a
# server round-trip panel exercising update_*, overlay helpers, and toasts.
# Run with shadshiny::shad_run_example().

library(shiny)
library(shadshiny)

# A titled section wrapper.
section <- function(id, title, ...) {
  tags$section(
    id = id, style = "scroll-margin-top:5rem;margin-bottom:2.5rem",
    shad_h3(title),
    tags$div(style = "display:flex;flex-wrap:wrap;gap:1rem;align-items:flex-start;margin-top:0.75rem", ...)
  )
}

fruits <- c("Apple" = "apple", "Banana" = "banana", "Blueberry" = "blueberry")

ui <- page_shad(
  title = "shadshiny — kitchen sink",

  # -- sticky theme toolbar --------------------------------------------------
  tags$div(
    style = paste(
      "position:sticky;top:0;z-index:50;display:flex;gap:1rem;align-items:center;",
      "padding:0.75rem 1rem;margin-bottom:1.5rem;",
      "background:var(--shad-background);border-bottom:1px solid var(--shad-border)"
    ),
    shad_h4("shadshiny", class = "shad-h4"),
    tags$div(style = "flex:1"),
    tags$div(style = "width:12rem",
      shad_select("preset", choices = c("Default" = "default", "Slate" = "slate",
        "Stone" = "stone", "Blue" = "blue", "Green" = "green", "Rose" = "rose",
        "Violet" = "violet", "Orange" = "orange"), selected = "default",
        placeholder = "Theme preset")),
    shad_switch("dark", "Dark")
  ),

  tags$div(style = "max-width:60rem;margin:0 auto;padding:0 1rem 6rem",

    # -- Tier 1: display -----------------------------------------------------
    shad_h2("Tier 1 — display"),
    section("s-button", "Button",
      shad_button("Default"), shad_button("Secondary", variant = "secondary"),
      shad_button("Destructive", variant = "destructive"),
      shad_button("Outline", variant = "outline"),
      shad_button("Ghost", variant = "ghost"), shad_button("Link", variant = "link"),
      shad_button("Loading", loading = TRUE), shad_button("Icon", icon = "plus")),
    section("s-badge", "Badge",
      shad_badge("Default"), shad_badge("Secondary", variant = "secondary"),
      shad_badge("Destructive", variant = "destructive"),
      shad_badge("Outline", variant = "outline")),
    section("s-card", "Card",
      shad_card(style = "width:20rem",
        shad_card_header(shad_card_title("Card title"),
          shad_card_description("Card description.")),
        shad_card_content(shad_p("Card body content.")),
        shad_card_footer(shad_button("Action")))),
    section("s-alert", "Alert",
      tags$div(style = "width:100%;max-width:32rem;display:grid;gap:0.75rem",
        shad_alert(title = "Heads up!", description = "This is an alert.", icon = "info"),
        shad_alert(title = "Error", description = "Something failed.",
          variant = "destructive", icon = "circle-alert"))),
    section("s-avatar", "Avatar",
      shad_avatar(fallback = "CN"),
      shad_avatar_group(shad_avatar(fallback = "AB"), shad_avatar(fallback = "CD"),
        shad_avatar(fallback = "EF"), max = 2)),
    section("s-breadcrumb", "Breadcrumb",
      shad_breadcrumb(items = c("Home" = "#", "Library" = "#", "Data" = NA))),
    section("s-separator", "Separator / skeleton / spinner / progress",
      tags$div(style = "width:100%;display:grid;gap:1rem",
        shad_separator(),
        shad_skeleton(width = "12rem", height = "1rem"),
        shad_spinner(),
        shad_progress(60, inputId = "prog"))),
    section("s-typography", "Typography",
      tags$div(style = "width:100%",
        shad_h1("H1 heading"), shad_lead("A lead paragraph."),
        shad_p("Body text with ", shad_code("inline code"), " and a ",
          shad_kbd("Ctrl"), " key."),
        shad_blockquote("A blockquote."), shad_muted("Muted text."))),
    section("s-table", "Table",
      shad_table(head(mtcars[, 1:4], 4), striped = TRUE)),
    section("s-item", "Item / empty",
      tags$div(style = "display:grid;gap:1.5rem;max-width:26rem",
        shad_item_group(
          shad_item("Inbox", description = "24 unread", media = "mail",
            media_variant = "icon",
            actions = shad_button("Open", size = "sm", variant = "outline")),
          shad_item_separator(),
          shad_item("Reminders", description = "3 due today", media = "clock",
            media_variant = "icon")),
        shad_empty("No results", media = "search", media_variant = "icon",
          description = "Try a different search term.",
          content = shad_button("Clear filters", variant = "outline")))),
    section("s-button-group", "Button group",
      tags$div(style = "display:flex;gap:1rem;flex-wrap:wrap;align-items:start",
        shad_button_group(aria_label = "Text alignment",
          shad_button("Left", variant = "outline"),
          shad_button("Center", variant = "outline"),
          shad_button("Right", variant = "outline")),
        shad_button_group(
          shad_button_group_text("https://"),
          shad_button("example.com", variant = "outline"),
          shad_button_group_separator(),
          shad_button("Copy", variant = "outline", icon = "check")))),

    # -- Tier 2: form inputs -------------------------------------------------
    shad_h2("Tier 2 — form inputs"),
    section("s-input", "Input / textarea",
      tags$div(style = "display:grid;gap:1rem;width:20rem",
        shad_input("txt", label = "Name", placeholder = "Pedro Duarte"),
        shad_textarea("area", label = "Bio", autosize = TRUE))),
    section("s-checks", "Checkbox / switch / radio",
      tags$div(style = "display:grid;gap:1rem",
        shad_checkbox("cb", "Accept terms", value = TRUE),
        shad_switch("sw", "Wi-Fi", value = TRUE),
        shad_radio_group("rg", label = "Plan",
          choices = c(Free = "free", Pro = "pro"), selected = "pro"))),
    section("s-slider", "Slider",
      tags$div(style = "width:20rem;display:grid;gap:1.5rem",
        shad_slider("sld", label = "Volume", value = 50),
        shad_slider("sld2", value = c(25, 75), step = 5,
          marks = c("0" = 0, "50" = 50, "100" = 100)))),
    section("s-toggle", "Toggle / toggle-group",
      shad_toggle("tg", "Bold", value = TRUE),
      shad_toggle_group("tgg", choices = c(Left = "left", Center = "center",
        Right = "right"), selected = "center", type = "single", variant = "outline")),
    section("s-select", "Select / combobox / native select",
      shad_select("sel", choices = fruits, selected = "banana", width = "12rem"),
      shad_native_select("nsel", choices = fruits, selected = "banana",
        width = "12rem"),
      shad_combobox("cbx", choices = fruits, width = "14rem"),
      shad_combobox("cbxm", choices = fruits, multiple = TRUE, selected = "apple",
        width = "16rem")),
    section("s-input-group", "Input group",
      tags$div(style = "display:grid;gap:1rem;max-width:24rem",
        shad_input_group(block = TRUE,
          shad_input_group_addon(shad_icon("search"), align = "inline-start"),
          shad_input("search", placeholder = "Search…"),
          shad_input_group_addon(shad_kbd("/"), align = "inline-end")),
        shad_input_group(block = TRUE,
          shad_input_group_addon(shad_input_group_text("https://"),
            align = "inline-start"),
          shad_input("url", value = "example.com"),
          shad_input_group_addon(
            shad_input_group_button("Copy", inputId = "ig_copy"),
            align = "inline-end")))),
    section("s-otp", "Input OTP",
      shad_input_otp("otp", length = 6, groups = c(3, 3))),
    section("s-date", "Calendar / date picker",
      shad_calendar("cal", value = Sys.Date()),
      shad_date_picker("dp", label = "Pick a date")),

    # -- Tier 3: overlays ----------------------------------------------------
    shad_h2("Tier 3 — overlays"),
    section("s-overlays", "Dialog / sheet / drawer / alert / popover / menus",
      shad_dialog("dlg", trigger = shad_button("Dialog", variant = "outline"),
        title = "Edit profile", description = "Make changes here.",
        shad_input("dlg_name", label = "Name", value = "Pedro"),
        footer = tagList(shad_dialog_close_button(), shad_button("Save"))),
      shad_sheet("sht", trigger = shad_button("Sheet", variant = "outline"),
        side = "right", title = "Sheet", shad_p("Side panel content.")),
      shad_drawer("drw", trigger = shad_button("Drawer", variant = "outline"),
        title = "Drawer", shad_p("Bottom drawer content.")),
      shad_alert_dialog("alrt", title = "Are you sure?",
        description = "This cannot be undone.", action = "Delete",
        action_variant = "destructive",
        trigger = shad_button("Alert", variant = "destructive")),
      shad_popover("pop", trigger = shad_button("Popover", variant = "outline"),
        shad_p("Popover content.")),
      shad_tooltip(shad_button("Tooltip", variant = "outline"), "A tooltip"),
      shad_hover_card(tags$a(href = "#", "@hover"), shad_p("Hover card preview.")),
      shad_dropdown_menu("ddm", trigger = shad_button("Dropdown", variant = "outline"),
        shad_menu_label("My Account"), shad_menu_separator(),
        shad_menu_item("profile", "Profile", shortcut = "⇧⌘P"),
        shad_menu_item("billing", "Billing"),
        shad_menu_checkbox_item("statusbar", "Status Bar", checked = TRUE),
        shad_menu_separator(),
        shad_menu_radio_group("top",
          shad_menu_radio_item("top", "Top"), shad_menu_radio_item("bottom", "Bottom")),
        shad_menu_sub("More", shad_menu_item("email", "Email"))),
      shad_context_menu("ctx",
        target = tags$div(class = "shad-muted",
          style = "display:grid;place-items:center;height:6rem;width:14rem;border:1px dashed var(--shad-border);border-radius:var(--shad-radius-md)",
          "Right click here"),
        shad_menu_item("back", "Back"), shad_menu_item("reload", "Reload"))),
    section("s-menubar", "Menubar",
      shad_menubar("mbar",
        shad_menubar_menu("File", shad_menu_item("newtab", "New Tab"),
          shad_menu_item("newwin", "New Window")),
        shad_menubar_menu("Edit", shad_menu_item("undo", "Undo"),
          shad_menu_item("redo", "Redo")))),

    # -- Tier 3: navigation & structure -------------------------------------
    shad_h2("Tier 3 — navigation & structure"),
    section("s-tabs", "Tabs",
      tags$div(style = "width:100%;max-width:30rem",
        shad_tabs("tabs",
          shad_tab("account", "Account",
            shad_card(shad_card_content(shad_p("Account settings.")))),
          shad_tab("password", "Password",
            shad_card(shad_card_content(shad_p("Password settings."))))))),
    section("s-accordion", "Accordion",
      tags$div(style = "width:100%;max-width:30rem",
        shad_accordion("acc",
          shad_accordion_item("i1", "Is it accessible?", "Yes."),
          shad_accordion_item("i2", "Is it styled?", "Yes."),
          value = "i1"))),
    section("s-collapsible", "Collapsible",
      shad_collapsible("col", trigger = shad_button("Toggle", variant = "ghost",
        icon = "chevrons-up-down", size = "icon", aria_label = "Toggle"),
        shad_p("Collapsible content."), open = TRUE)),
    section("s-pagination", "Pagination",
      shad_pagination("pag", pages = 10, selected = 2)),
    section("s-scroll", "Scroll area",
      shad_scroll_area(height = "10rem", style = "width:16rem",
        tags$div(style = "padding:1rem",
          lapply(1:20, function(i) tags$div(paste("Item", i)))))),
    section("s-resizable", "Resizable",
      shad_resizable("rsz",
        shad_resizable_panel(tags$div(style = "padding:1rem", "One"), default_size = 50),
        shad_resizable_handle(),
        shad_resizable_panel(tags$div(style = "padding:1rem", "Two"), default_size = 50),
        class = "", style = "height:8rem;max-width:24rem;border:1px solid var(--shad-border);border-radius:var(--shad-radius-lg)")),
    section("s-nav", "Navigation menu",
      shad_navigation_menu("nav",
        shad_navigation_menu_item("Getting started",
          tags$a(href = "#", class = "shad-nav-menu__card",
            tags$div(class = "shad-nav-menu__card-title", "Introduction"),
            tags$div(class = "shad-nav-menu__card-desc", "Vanilla CSS + JS."))),
        shad_navigation_menu_item("Docs", href = "#"))),
    section("s-command", "Command",
      shad_command("cmd",
        shad_command_group("Suggestions",
          shad_command_item("calendar", "Calendar", keywords = "date"),
          shad_command_item("emoji", "Search Emoji")),
        shad_command_separator(),
        shad_command_group("Settings",
          shad_command_item("profile", "Profile", shortcut = "⌘P")))),
    section("s-carousel", "Carousel",
      tags$div(style = "max-width:16rem;margin-inline:3rem",
        do.call(shad_carousel, c(list("car"), lapply(1:5, function(i)
          shad_carousel_item(shad_card(shad_card_content(
            style = "display:grid;place-items:center;aspect-ratio:1;font-size:2rem", i)))))))),
    section("s-sidebar", "Sidebar layout",
      tags$div(style = "width:100%;height:18rem;border:1px solid var(--shad-border);border-radius:var(--shad-radius-lg);overflow:hidden",
        shad_sidebar_layout("sbar",
          sidebar = shad_sidebar(
            header = shad_small("Acme Inc"),
            shad_sidebar_group("Platform",
              shad_sidebar_item("home", "Home", active = TRUE),
              shad_sidebar_item("inbox", "Inbox", badge = "24"),
              shad_sidebar_item("settings", "Settings"))),
          main = tags$div(
            tags$div(style = "display:flex;gap:0.5rem;align-items:center;padding:0.75rem;border-bottom:1px solid var(--shad-border)",
              shad_sidebar_trigger(), shad_small("Dashboard")),
            tags$div(style = "padding:1rem", shad_muted("Main content.")))))),

    # -- Chat / AI kit -------------------------------------------------------
    shad_h2("Chat / AI kit"),
    section("s-chat", "Messages / bubbles / markers",
      shad_message_scroller("chat", height = "20rem",
        shad_message_scroller_item(
          shad_marker("Today", variant = "separator"), anchor = TRUE),
        shad_message_scroller_item(
          shad_message("Hey — can you summarise the Q3 report?",
            align = "end", avatar = "ME")),
        shad_message_scroller_item(
          shad_message(
            "Sure. Revenue rose 12% QoQ, driven by the new plan tiers.",
            sender = "Assistant", meta = "9:41", avatar = "AI",
            footer = shad_bubble_group(align = "start",
              shad_bubble("Q3-report.pdf", variant = "outline")))),
        shad_message_scroller_item(
          shad_message(align = "start", avatar = "AI", state = "typing")))),
    section("s-attachment", "Attachments",
      tags$div(style = "display:grid;gap:0.75rem;max-width:22rem",
        shad_attachment("Q3-report.pdf", description = "2.4 MB · PDF",
          media = "file",
          actions = shad_attachment_action("x", "Remove"), state = "done"),
        shad_attachment("dataset.csv", description = "Uploading…",
          media = "file", state = "uploading"))),

    # -- Server round-trip panel --------------------------------------------
    shad_h2("Server round-trip"),
    shad_card(
      shad_card_header(shad_card_title("Live input values"),
        shad_card_description("A representative subset of bound inputs.")),
      shad_card_content(verbatimTextOutput("vals")),
      shad_card_footer(style = "display:flex;flex-wrap:wrap;gap:0.5rem",
        shad_button(inputId = "toast_default", "Toast"),
        shad_button(inputId = "toast_success", "Success", variant = "secondary"),
        shad_button(inputId = "toast_error", "Error", variant = "destructive"),
        shad_button(inputId = "toast_loading", "Loading→update"),
        shad_button(inputId = "set_slider", "Slider→80", variant = "outline"),
        shad_button(inputId = "open_dialog", "Open dialog", variant = "outline"),
        shad_button(inputId = "toggle_sidebar", "Toggle sidebar", variant = "outline")))
  )
)

server <- function(input, output, session) {
  # Theme toolbar.
  observeEvent(input$preset, update_shad_theme(preset = input$preset), ignoreInit = TRUE)
  observeEvent(input$dark, update_shad_theme(dark = isTRUE(input$dark)), ignoreInit = TRUE)

  output$vals <- renderPrint({
    str(list(
      txt = input$txt, checkbox = input$cb, switch = input$sw, radio = input$rg,
      slider = input$sld, range = input$sld2, select = input$sel,
      combobox = input$cbx, tabs = input$tabs, accordion = input$acc,
      pagination = input$pag, calendar = input$cal, dialog_open = input$dlg,
      menu = input$ddm, sidebar = input$sbar
    ))
  })

  observeEvent(input$toast_default, shad_toast("Event has been created."))
  observeEvent(input$toast_success, shad_toast_success("Saved successfully."))
  observeEvent(input$toast_error, shad_toast_error("Something went wrong."))
  observeEvent(input$toast_loading, {
    id <- shad_toast_loading("Uploading…")
    later::later(function() shad_toast_update(id, message = "Uploaded",
      variant = "success"), delay = 1.5)
  })
  observeEvent(input$set_slider, update_shad_slider("sld", 80))
  observeEvent(input$open_dialog, shad_dialog_open("dlg"))
  observeEvent(input$toggle_sidebar, shad_sidebar_toggle("sbar"))

  # Alert-dialog confirm hook.
  observeEvent(input$alrt_confirm, shad_toast_error("Deleted."))
}

shinyApp(ui, server)

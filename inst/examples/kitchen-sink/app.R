# shadshiny kitchen-sink -------------------------------------------------------
# Flagship demo: every component with its full variant / size / state matrix, a
# theme toolbar, and a server round-trip panel exercising update_*, overlay
# helpers, and toasts. Run with shadshiny::shad_run_example().

library(shiny)
library(shadshiny)

# A titled section wrapper. Children flow in a wrapping flex row.
section <- function(id, title, ...) {
  tags$section(
    id = id, style = "scroll-margin-top:5rem;margin-bottom:2.5rem",
    shad_h3(title),
    tags$div(style = "display:flex;flex-wrap:wrap;gap:1rem;align-items:flex-start;margin-top:0.75rem", ...)
  )
}
# A labelled sub-group, so a section can show several clusters of variants.
cluster <- function(label, ...) {
  tags$div(style = "display:grid;gap:0.5rem",
    shad_small(label, class = "shad-muted"),
    tags$div(style = "display:flex;flex-wrap:wrap;gap:0.75rem;align-items:center", ...))
}

fruits <- c("Apple" = "apple", "Banana" = "banana", "Blueberry" = "blueberry")
# A tiny inline image so avatar/item image demos work fully offline.
av_src <- paste0(
  "data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='64' ",
  "height='64'%3E%3Crect width='64' height='64' rx='8' fill='%237c3aed'/%3E",
  "%3Ctext x='32' y='40' font-size='24' fill='white' text-anchor='middle' ",
  "font-family='sans-serif'%3ECN%3C/text%3E%3C/svg%3E"
)
tz <- list(
  Americas = c("New York" = "America/New_York", "Sao Paulo" = "America/Sao_Paulo"),
  Europe   = c("London" = "Europe/London", "Berlin" = "Europe/Berlin")
)

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

    # =====================================================================
    # Tier 1 — display
    # =====================================================================
    shad_h2("Tier 1 — display"),

    section("s-button", "Button",
      cluster("Variants",
        shad_button("Default"), shad_button("Secondary", variant = "secondary"),
        shad_button("Destructive", variant = "destructive"),
        shad_button("Outline", variant = "outline"),
        shad_button("Ghost", variant = "ghost"),
        shad_button("Link", variant = "link")),
      cluster("Sizes",
        shad_button("Small", size = "sm"), shad_button("Default"),
        shad_button("Large", size = "lg"),
        shad_button(icon = "plus", size = "icon", aria_label = "Add")),
      cluster("With icon / state",
        shad_button("Continue", icon = "arrow-right", icon_position = "right"),
        shad_button("Mail", icon = "mail"),
        shad_button("Loading", loading = TRUE),
        shad_button("Disabled", disabled = TRUE),
        shad_button("Link out", href = "#", variant = "outline"))),

    section("s-badge", "Badge",
      shad_badge("Default"), shad_badge("Secondary", variant = "secondary"),
      shad_badge("Destructive", variant = "destructive"),
      shad_badge("Outline", variant = "outline"),
      shad_badge("Verified", icon = "check")),

    section("s-avatar", "Avatar",
      cluster("Sizes",
        shad_avatar(fallback = "SM", size = "sm"),
        shad_avatar(fallback = "MD"),
        shad_avatar(fallback = "LG", size = "lg"),
        shad_avatar(fallback = "XL", size = "xl")),
      cluster("Image / fallback / group",
        shad_avatar(src = av_src, alt = "CN"),
        shad_avatar(fallback = "AB"),
        shad_avatar_group(shad_avatar(fallback = "AB"), shad_avatar(fallback = "CD"),
          shad_avatar(fallback = "EF"), shad_avatar(fallback = "GH"), max = 3))),

    section("s-card", "Card",
      shad_card(style = "width:22rem",
        shad_card_header(shad_card_title("Card title"),
          shad_card_description("Card description."),
          shad_card_action(shad_button("Act", size = "sm", variant = "ghost"))),
        shad_card_content(shad_p("Card body content.")),
        shad_card_footer(shad_button("Save"),
          shad_button("Cancel", variant = "outline")))),

    section("s-alert", "Alert",
      tags$div(style = "width:100%;max-width:32rem;display:grid;gap:0.75rem",
        shad_alert(title = "Heads up!", description = "This is an alert.", icon = "info"),
        shad_alert(title = "Error", description = "Something failed.",
          variant = "destructive", icon = "circle-alert"))),

    section("s-separator", "Separator",
      tags$div(style = "width:100%;display:grid;gap:0.75rem",
        shad_p("Above"), shad_separator(), shad_p("Below")),
      tags$div(style = "display:flex;align-items:center;gap:0.75rem;height:2rem",
        "Left", shad_separator(orientation = "vertical"), "Right")),

    section("s-skeleton", "Skeleton",
      shad_skeleton(variant = "circle", width = "3rem", height = "3rem"),
      tags$div(style = "display:grid;gap:0.5rem;flex:1;min-width:12rem",
        shad_skeleton(variant = "text", width = "80%"),
        shad_skeleton(variant = "text", width = "60%"),
        shad_skeleton(height = "3rem"))),

    section("s-spinner", "Spinner",
      shad_spinner(size = "sm"), shad_spinner(),
      shad_spinner(size = "lg"), shad_spinner(muted = TRUE)),

    section("s-aspect", "Aspect ratio",
      tags$div(style = "width:16rem",
        shad_aspect_ratio(ratio = 16 / 9,
          tags$div(style = "width:100%;height:100%;display:grid;place-items:center;background:var(--shad-muted);border-radius:var(--shad-radius-md)",
            shad_muted("16 / 9")))),
      tags$div(style = "width:8rem",
        shad_aspect_ratio(ratio = 1,
          tags$img(src = av_src, alt = "square",
            style = "width:100%;height:100%;object-fit:cover;border-radius:var(--shad-radius-md)")))),

    section("s-label", "Label",
      shad_label("Email address", for_id = "noop"),
      shad_label("Disabled label", disabled = TRUE)),

    section("s-progress", "Progress",
      tags$div(style = "width:100%;display:grid;gap:1rem",
        shad_progress(0), shad_progress(40, inputId = "prog"),
        shad_progress(80), shad_progress(indeterminate = TRUE))),

    section("s-breadcrumb", "Breadcrumb",
      shad_breadcrumb(
        shad_breadcrumb_item("Home", href = "#"),
        shad_breadcrumb_separator(),
        shad_breadcrumb_ellipsis(),
        shad_breadcrumb_separator(),
        shad_breadcrumb_item("Components", href = "#"),
        shad_breadcrumb_separator(),
        shad_breadcrumb_item("Breadcrumb", current = TRUE))),

    section("s-kbd-code", "Kbd / code",
      cluster("Kbd", shad_kbd("Ctrl"), shad_kbd("⌘"), shad_kbd("Shift"),
        shad_kbd("Enter")),
      cluster("Code", shad_code("npm install"), shad_code("shad_button()"))),

    section("s-typography", "Typography",
      tags$div(style = "width:100%",
        shad_h1("H1 heading"), shad_h2("H2 heading"), shad_h3("H3 heading"),
        shad_h4("H4 heading"), shad_lead("A lead paragraph introduces a section."),
        shad_p("Body text with ", shad_code("inline code"), " and a ",
          shad_kbd("Ctrl"), " key."),
        shad_blockquote("A blockquote for emphasis."),
        shad_list(tags$li("First item"), tags$li("Second item")),
        shad_large("Large text"), tags$br(), shad_small("Small text"),
        tags$br(), shad_muted("Muted text."))),

    section("s-table", "Table",
      shad_table(head(mtcars[, 1:4], 4), striped = TRUE, hover = TRUE,
        caption = "A subset of mtcars.")),

    section("s-item", "Item",
      tags$div(style = "display:grid;gap:1.5rem;width:100%;max-width:28rem",
        cluster("Variants",
          tags$div(style = "display:grid;gap:0.75rem;width:100%",
            shad_item("Default", description = "Transparent row", media = "circle",
              media_variant = "icon"),
            shad_item("Outline", description = "Bordered row", variant = "outline",
              media = "circle", media_variant = "icon"),
            shad_item("Muted", description = "Filled row", variant = "muted",
              media = "circle", media_variant = "icon"))),
        cluster("Media / actions / link",
          shad_item_group(
            shad_item("Olivia Martin", description = "olivia@example.com",
              media = tags$img(src = av_src, alt = ""), media_variant = "image",
              actions = shad_button("Add", size = "sm", variant = "outline")),
            shad_item_separator(),
            shad_item("Open docs", description = "Follows the link",
              media = "arrow-right", media_variant = "icon", href = "#"))))),

    section("s-empty", "Empty",
      tags$div(style = "display:grid;gap:1.5rem;grid-template-columns:1fr 1fr;width:100%",
        shad_empty("No results", media = "search", media_variant = "icon",
          description = "Try a different search term.",
          content = shad_button("Clear filters", variant = "outline")),
        shad_empty("Your inbox is empty", media = "mail", media_variant = "icon",
          description = "New messages will appear here."))),

    section("s-button-group", "Button group",
      cluster("Horizontal + text + separator",
        shad_button_group(aria_label = "Text alignment",
          shad_button("Left", variant = "outline"),
          shad_button("Center", variant = "outline"),
          shad_button("Right", variant = "outline")),
        shad_button_group(
          shad_button_group_text("https://"),
          shad_button("example.com", variant = "outline"),
          shad_button_group_separator(),
          shad_button("Copy", variant = "outline", icon = "check"))),
      cluster("Vertical",
        shad_button_group(orientation = "vertical", aria_label = "Zoom",
          shad_button("Zoom in", variant = "outline"),
          shad_button("Reset", variant = "outline"),
          shad_button("Zoom out", variant = "outline")))),

    # =====================================================================
    # Tier 2 — form inputs
    # =====================================================================
    shad_h2("Tier 2 — form inputs"),

    section("s-input", "Input",
      tags$div(style = "display:grid;gap:1rem;width:22rem",
        shad_input("txt", label = "Name", placeholder = "Pedro Duarte"),
        shad_input("inp_email", label = "Email", type = "email",
          placeholder = "you@example.com", description = "We never share it."),
        shad_input("inp_pw", label = "Password", type = "password", value = "secret"),
        shad_input("inp_num", label = "Age", type = "number", value = "30"),
        shad_input("inp_file", label = "Resume", type = "file"),
        shad_input("inp_inv", label = "Invalid", value = "bad", invalid = TRUE),
        shad_input("inp_dis", label = "Disabled", value = "nope", disabled = TRUE))),

    section("s-textarea", "Textarea",
      tags$div(style = "display:grid;gap:1rem;width:22rem",
        shad_textarea("area", label = "Bio", autosize = TRUE,
          placeholder = "Tell us about yourself"),
        shad_textarea("area_inv", label = "Invalid", value = "too short",
          invalid = TRUE),
        shad_textarea("area_dis", label = "Disabled", value = "read only",
          disabled = TRUE))),

    section("s-checks", "Checkbox / switch / radio",
      cluster("Checkbox",
        tags$div(style = "display:grid;gap:0.75rem",
          shad_checkbox("cb", "Accept terms", value = TRUE),
          shad_checkbox("cb_un", "Unchecked"),
          shad_checkbox("cb_ind", "Indeterminate", indeterminate = TRUE),
          shad_checkbox("cb_dis", "Disabled", disabled = TRUE))),
      cluster("Switch",
        tags$div(style = "display:grid;gap:0.75rem",
          shad_switch("sw", "Wi-Fi", value = TRUE),
          shad_switch("sw_off", "Bluetooth"),
          shad_switch("sw_dis", "Airplane (disabled)", disabled = TRUE))),
      cluster("Radio group",
        shad_radio_group("rg", label = "Plan",
          choices = c(Free = "free", Pro = "pro", Team = "team"), selected = "pro"),
        shad_radio_group("rg_h", label = "Layout", orientation = "horizontal",
          choices = c(Grid = "grid", List = "list"), selected = "grid"))),

    section("s-slider", "Slider",
      tags$div(style = "width:22rem;display:grid;gap:1.75rem",
        shad_slider("sld", label = "Volume", value = 50),
        shad_slider("sld2", label = "Range", value = c(25, 75), step = 5,
          marks = c("0" = 0, "50" = 50, "100" = 100)),
        shad_slider("sld_dis", label = "Disabled", value = 30, disabled = TRUE))),

    section("s-toggle", "Toggle / toggle group",
      cluster("Toggle",
        shad_toggle("tg", "Bold", value = TRUE),
        shad_toggle("tg_out", "Italic", variant = "outline"),
        shad_toggle("tg_sm", "Sm", size = "sm"),
        shad_toggle("tg_lg", "Lg", size = "lg"),
        shad_toggle("tg_icon", icon = "check", aria_label = "Check")),
      cluster("Toggle group",
        shad_toggle_group("tgg", choices = c(Left = "left", Center = "center",
          Right = "right"), selected = "center", type = "single", variant = "outline"),
        shad_toggle_group("tgg_m", choices = c(B = "bold", I = "italic",
          U = "underline"), selected = c("bold", "underline"), type = "multiple"))),

    section("s-select", "Select / native select / combobox",
      cluster("Select (flat + grouped)",
        shad_select("sel", choices = fruits, selected = "banana", width = "12rem"),
        shad_select("sel_grp", width = "14rem", selected = "America/New_York",
          choices = list(
            shad_select_group("Americas",
              shad_select_item("America/New_York", "New York"),
              shad_select_item("America/Sao_Paulo", "Sao Paulo")),
            shad_select_separator(),
            shad_select_group("Europe",
              shad_select_item("Europe/London", "London"),
              shad_select_item("Europe/Berlin", "Berlin", disabled = TRUE))))),
      cluster("Native select",
        shad_native_select("nsel", choices = fruits, selected = "banana",
          width = "10rem"),
        shad_native_select("nsel_grp", choices = tz, width = "12rem"),
        shad_native_select("nsel_sm", choices = fruits, size = "sm", width = "8rem"),
        shad_native_select("nsel_lg", choices = fruits, size = "lg", width = "8rem"),
        shad_native_select("nsel_inv", choices = fruits, invalid = TRUE, width = "8rem"),
        shad_native_select("nsel_dis", choices = fruits, disabled = TRUE, width = "8rem")),
      cluster("Combobox",
        shad_combobox("cbx", choices = fruits, width = "14rem"),
        shad_combobox("cbxm", choices = fruits, multiple = TRUE, selected = "apple",
          width = "16rem"))),

    section("s-otp", "Input OTP",
      cluster("6 digits (3 + 3)", shad_input_otp("otp", length = 6, groups = c(3, 3))),
      cluster("4 digits", shad_input_otp("otp4", length = 4))),

    section("s-form-field", "Form field",
      tags$div(style = "width:22rem",
        shad_form_field(
          shad_input("ff_input", placeholder = "you@example.com"),
          label = "Email", required = TRUE,
          description = "Used for sign-in and receipts.",
          error = "Enter a valid email address."))),

    section("s-date", "Calendar / date picker",
      cluster("Calendar (single + range)",
        shad_calendar("cal", value = Sys.Date()),
        shad_calendar("cal_r", mode = "range")),
      cluster("Date picker", shad_date_picker("dp", label = "Pick a date"))),

    section("s-input-group", "Input group",
      tags$div(style = "display:grid;gap:1rem;width:100%;max-width:26rem",
        shad_input_group(block = TRUE,
          shad_input_group_addon(shad_icon("search"), align = "inline-start"),
          shad_input("ig_search", placeholder = "Search…"),
          shad_input_group_addon(shad_kbd("/"), align = "inline-end")),
        shad_input_group(block = TRUE,
          shad_input_group_addon(shad_input_group_text("https://"),
            align = "inline-start"),
          shad_input("ig_url", value = "example.com"),
          shad_input_group_addon(
            shad_input_group_button("Copy", inputId = "ig_copy"),
            align = "inline-end")),
        shad_input_group(block = TRUE, invalid = TRUE,
          shad_input_group_addon(shad_icon("circle-alert"), align = "inline-start"),
          shad_input("ig_inv", value = "invalid")),
        shad_input_group(block = TRUE,
          shad_textarea("ig_msg", placeholder = "Write a message…"),
          shad_input_group_addon(align = "block-end",
            shad_input_group_text("Markdown supported"),
            tags$span(style = "flex:1"),
            shad_input_group_button("Send", inputId = "ig_send",
              variant = "default"))))),

    # =====================================================================
    # Tier 3 — overlays
    # =====================================================================
    shad_h2("Tier 3 — overlays"),

    section("s-dialog", "Dialog / alert dialog",
      shad_dialog("dlg", trigger = shad_button("Dialog", variant = "outline"),
        title = "Edit profile", description = "Make changes here.",
        shad_input("dlg_name", label = "Name", value = "Pedro"),
        footer = tagList(shad_dialog_close_button(), shad_button("Save"))),
      shad_alert_dialog("alrt", title = "Are you sure?",
        description = "This cannot be undone.", action = "Delete",
        action_variant = "destructive",
        trigger = shad_button("Delete…", variant = "destructive")),
      shad_alert_dialog("alrt2", title = "Publish this post?",
        description = "It will be visible to everyone.", action = "Publish",
        trigger = shad_button("Publish…", variant = "outline"))),

    section("s-sheet", "Sheet (4 sides)",
      shad_sheet("sht_r", trigger = shad_button("Right", variant = "outline"),
        side = "right", title = "Right sheet", shad_p("Content.")),
      shad_sheet("sht_l", trigger = shad_button("Left", variant = "outline"),
        side = "left", title = "Left sheet", shad_p("Content.")),
      shad_sheet("sht_t", trigger = shad_button("Top", variant = "outline"),
        side = "top", title = "Top sheet", shad_p("Content.")),
      shad_sheet("sht_b", trigger = shad_button("Bottom", variant = "outline"),
        side = "bottom", title = "Bottom sheet", shad_p("Content."))),

    section("s-drawer", "Drawer",
      shad_drawer("drw", trigger = shad_button("Open drawer", variant = "outline"),
        title = "Drawer", description = "Drag the handle to dismiss.",
        shad_p("Bottom drawer content."))),

    section("s-popover", "Popover / tooltip / hover card",
      cluster("Popover",
        shad_popover("pop", trigger = shad_button("Bottom", variant = "outline"),
          side = "bottom", title = "Dimensions", shad_p("Set the layout.")),
        shad_popover("pop_r", trigger = shad_button("Right", variant = "outline"),
          side = "right", shad_p("Right-aligned popover."))),
      cluster("Tooltip (sides)",
        shad_tooltip(shad_button("Top", variant = "outline"), "Top", side = "top"),
        shad_tooltip(shad_button("Right", variant = "outline"), "Right", side = "right"),
        shad_tooltip(shad_button("Bottom", variant = "outline"), "Bottom", side = "bottom"),
        shad_tooltip(shad_button("Left", variant = "outline"), "Left", side = "left")),
      cluster("Hover card",
        shad_hover_card(tags$a(href = "#", "@shadshiny"),
          shad_p("Framework-free shadcn/ui for Shiny.")))),

    section("s-menus", "Dropdown / context menu",
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

    section("s-command", "Command",
      shad_command("cmd",
        shad_command_group("Suggestions",
          shad_command_item("calendar", "Calendar", keywords = "date"),
          shad_command_item("emoji", "Search Emoji")),
        shad_command_separator(),
        shad_command_group("Settings",
          shad_command_item("profile", "Profile", shortcut = "⌘P")))),

    # =====================================================================
    # Tier 3 — navigation & structure
    # =====================================================================
    shad_h2("Tier 3 — navigation & structure"),

    section("s-tabs", "Tabs",
      tags$div(style = "width:100%;max-width:30rem;display:grid;gap:1.5rem",
        shad_tabs("tabs",
          shad_tab("account", "Account",
            shad_card(shad_card_content(shad_p("Account settings.")))),
          shad_tab("password", "Password",
            shad_card(shad_card_content(shad_p("Password settings."))))),
        shad_tabs("tabs_v", orientation = "vertical",
          shad_tab("general", "General", shad_p("General.")),
          shad_tab("advanced", "Advanced", shad_p("Advanced."))))),

    section("s-accordion", "Accordion",
      tags$div(style = "width:100%;max-width:30rem;display:grid;gap:1.5rem",
        cluster("Single",
          shad_accordion("acc",
            shad_accordion_item("i1", "Is it accessible?", "Yes."),
            shad_accordion_item("i2", "Is it styled?", "Yes."), value = "i1")),
        cluster("Multiple",
          shad_accordion("acc_m", type = "multiple",
            shad_accordion_item("m1", "First", "One."),
            shad_accordion_item("m2", "Second", "Two."),
            value = c("m1", "m2"))))),

    section("s-collapsible", "Collapsible",
      shad_collapsible("col", trigger = shad_button("Toggle", variant = "ghost",
        icon = "chevrons-up-down", size = "icon", aria_label = "Toggle"),
        shad_p("Collapsible content."), open = TRUE)),

    section("s-pagination", "Pagination",
      shad_pagination("pag", pages = 10, selected = 2)),

    section("s-scroll", "Scroll area",
      cluster("Vertical",
        shad_scroll_area(height = "10rem", style = "width:14rem",
          tags$div(style = "padding:1rem;display:grid;gap:0.5rem",
            lapply(1:20, function(i) tags$div(paste("Item", i)))))),
      cluster("Horizontal",
        shad_scroll_area(orientation = "horizontal", style = "width:16rem",
          tags$div(style = "display:flex;gap:0.5rem;padding:1rem",
            lapply(1:12, function(i)
              shad_card(style = "min-width:6rem",
                shad_card_content(style = "padding:1rem", paste("Card", i)))))))),

    section("s-resizable", "Resizable",
      cluster("Horizontal",
        shad_resizable("rsz",
          shad_resizable_panel(tags$div(style = "padding:1rem", "One"), default_size = 50),
          shad_resizable_handle(),
          shad_resizable_panel(tags$div(style = "padding:1rem", "Two"), default_size = 50),
          style = "height:8rem;width:24rem;border:1px solid var(--shad-border);border-radius:var(--shad-radius-lg)")),
      cluster("Vertical",
        shad_resizable("rsz_v", orientation = "vertical",
          shad_resizable_panel(tags$div(style = "padding:1rem", "Top"), default_size = 50),
          shad_resizable_handle(),
          shad_resizable_panel(tags$div(style = "padding:1rem", "Bottom"), default_size = 50),
          style = "height:12rem;width:16rem;border:1px solid var(--shad-border);border-radius:var(--shad-radius-lg)"))),

    section("s-nav", "Navigation menu",
      shad_navigation_menu("nav",
        shad_navigation_menu_item("Getting started",
          tags$a(href = "#", class = "shad-nav-menu__card",
            tags$div(class = "shad-nav-menu__card-title", "Introduction"),
            tags$div(class = "shad-nav-menu__card-desc", "Vanilla CSS + JS."))),
        shad_navigation_menu_item("Docs", href = "#"))),

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

    # =====================================================================
    # Chat / AI kit
    # =====================================================================
    shad_h2("Chat / AI kit"),

    section("s-bubble", "Bubble",
      cluster("Variants",
        shad_bubble("Default", variant = "default"),
        shad_bubble("Secondary", variant = "secondary"),
        shad_bubble("Muted", variant = "muted"),
        shad_bubble("Tinted", variant = "tinted"),
        shad_bubble("Outline", variant = "outline"),
        shad_bubble("Ghost", variant = "ghost"),
        shad_bubble("Destructive", variant = "destructive")),
      cluster("Align + reactions",
        tags$div(style = "width:100%;display:grid;gap:0.5rem",
          shad_bubble_group(align = "end",
            shad_bubble("Sent message", align = "end")),
          shad_bubble_group(align = "start",
            shad_bubble("Reply", align = "start", variant = "muted",
              reactions = c("👍 3", "🎉 1")))))),

    section("s-message", "Message",
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
          shad_message("Generating chart…", sender = "Assistant", avatar = "AI",
            state = "in-progress", footer = shad_message_spinner())),
        shad_message_scroller_item(
          shad_message("Failed to send.", align = "end", avatar = "ME",
            state = "failed")),
        shad_message_scroller_item(
          shad_message(align = "start", avatar = "AI", state = "typing")))),

    section("s-attachment", "Attachment",
      cluster("Upload states",
        tags$div(style = "display:grid;gap:0.75rem;width:22rem",
          shad_attachment("brief.docx", description = "Queued", media = "file",
            state = "idle"),
          shad_attachment("dataset.csv", description = "Uploading…", media = "file",
            state = "uploading"),
          shad_attachment("video.mp4", description = "Processing…", media = "file",
            state = "processing"),
          shad_attachment("broken.zip", description = "Upload failed", media = "file",
            state = "error", actions = shad_attachment_action("x", "Retry")),
          shad_attachment("Q3-report.pdf", description = "2.4 MB · PDF",
            media = "file", state = "done",
            actions = shad_attachment_action("x", "Remove")))),
      cluster("Vertical",
        shad_attachment_group(
          shad_attachment("photo.png", orientation = "vertical", media = "file",
            state = "done"),
          shad_attachment("scan.pdf", orientation = "vertical", media = "file",
            state = "done")))),

    section("s-marker", "Marker",
      shad_marker("Default", icon = "circle-check"),
      shad_marker("Border", variant = "border", icon = "info"),
      shad_marker("Separator", variant = "separator"),
      shad_marker("Streaming…", streaming = TRUE, icon = "loader")),

    # =====================================================================
    # Server round-trip
    # =====================================================================
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
        shad_button(inputId = "scroll_chat", "Scroll chat", variant = "outline"),
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
      native_select = input$nsel, combobox = input$cbx, toggle_group = input$tgg,
      tabs = input$tabs, accordion = input$acc, pagination = input$pag,
      calendar = input$cal, dialog_open = input$dlg, menu = input$ddm,
      sidebar = input$sbar
    ))
  })

  observeEvent(input$toast_default, shad_toast("Event has been created."))
  observeEvent(input$toast_success, shad_toast_success("Saved successfully."))
  observeEvent(input$toast_error, shad_toast_error("Something went wrong."))
  observeEvent(input$toast_loading, {
    id <- shad_toast_loading("Uploading…")
    # later::later() fires outside the reactive domain, so capture `session`
    # here — getDefaultReactiveDomain() would be NULL inside the callback.
    later::later(function() shad_toast_update(id, message = "Uploaded",
      variant = "success", session = session), delay = 1.5)
  })
  observeEvent(input$set_slider, update_shad_slider("sld", 80))
  observeEvent(input$open_dialog, shad_dialog_open("dlg"))
  observeEvent(input$scroll_chat, shad_message_scroller_to_bottom("chat"))
  observeEvent(input$toggle_sidebar, shad_sidebar_toggle("sbar"))

  # Alert-dialog confirm hooks.
  observeEvent(input$alrt_confirm, shad_toast_error("Deleted."))
  observeEvent(input$alrt2_confirm, shad_toast_success("Published."))
}

shinyApp(ui, server)

# shadshiny example 06 — Documentation site ---------------------------------
# A docs/knowledge-base reader: sidebar navigation, a ⌘K search palette, a
# resizable article / table-of-contents split, rich typography, tabbed code
# examples, a props table, FAQ accordion, and prev/next pagination.
# Run with shadshiny::shad_run_example("06-docs-reader").
#
# Components: page_shad, sidebar-layout, command (⌘K), breadcrumb, resizable,
# scroll-area, tabs, accordion, collapsible, hover-card, tooltip, popover,
# table, code, kbd, badge, separator, aspect-ratio, pagination, spinner,
# typography (h1-h4, p, lead, large, blockquote, list, muted), toast.

library(shiny)
library(shadshiny)
`%||%` <- function(a, b) if (is.null(a)) b else a

# Ordered docs pages.
PAGES <- c(intro = "Introduction", install = "Installation",
           button = "Button", theming = "Theming")
SECTION <- c(intro = "Getting started", install = "Getting started",
             button = "Components", theming = "Guides")

glossary <- function(term, def) shad_hover_card(
  tags$span(style = "text-decoration:underline dotted;cursor:help", term),
  tags$div(style = "max-width:16rem",
    tags$strong(term), shad_p(style = "margin:0.25rem 0 0", def)))

code_block <- function(id, code) {
  tags$div(style = "position:relative",
    tags$pre(style = paste("background:var(--shad-muted);padding:1rem;",
      "border-radius:var(--shad-radius-md);overflow-x:auto;margin:0"),
      tags$code(style = "font-family:var(--shad-font-mono,monospace);font-size:0.85rem",
        code)),
    tags$div(style = "position:absolute;top:0.5rem;right:0.5rem",
      shad_tooltip(
        shad_button(icon = "file", size = "icon", variant = "ghost",
          aria_label = "Copy",
          onclick = sprintf("Shiny.setInputValue('copy','%s',{priority:'event'})", id)),
        "Copy")))
}

props_tbl <- data.frame(
  Prop = c("variant", "size", "disabled", "loading", "icon"),
  Type = c("character", "character", "logical", "logical", "character"),
  Default = c('"default"', '"default"', "FALSE", "FALSE", "NULL"),
  check.names = FALSE, stringsAsFactors = FALSE)

# --- Page bodies -------------------------------------------------------------
page_intro <- function() tagList(
  shad_lead(paste("shadshiny is a framework-free port of shadcn/ui for Shiny —",
    "no npm, no React, no build step.")),
  shad_p("It ships every component as a single bundled HTML dependency. Style",
    " comes from plain CSS custom properties; behaviour from vanilla JS."),
  shad_large("Everything is a normal Shiny input."),
  shad_p("Values flow through a generic binding, so ",
    glossary("reactivity", "Shiny's automatic recomputation when inputs change."),
    " works exactly as you'd expect."),
  shad_blockquote(paste("“Design systems shouldn't require a toolchain.”")),
  shad_h3("Why?"),
  shad_list(
    tags$li("Drop into any existing Shiny or bslib app."),
    tags$li("Theme with OKLCH tokens and seven presets."),
    tags$li("Full dark-mode support out of the box.")))

page_install <- function() tagList(
  shad_p("Install from the R console:"),
  code_block("install", 'remotes::install_github("orijitghosh/shadshiny")'),
  shad_p("Then load it alongside Shiny and wrap your UI in ",
    shad_code("page_shad()"), ":"),
  code_block("usage", paste(
    "library(shiny)", "library(shadshiny)", "",
    "ui <- page_shad(", '  shad_button("Click me", inputId = "go")', ")",
    sep = "\n")),
  shad_p("Press ", shad_kbd("⌘"), " ", shad_kbd("K"),
    " any time to search these docs."))

page_button <- function() tagList(
  shad_p("Buttons trigger actions. ", shad_code("shad_button()"),
    " is a normal Shiny action button."),
  shad_tabs("btn_ex",
    shad_tab("code", "Code",
      tags$div(style = "margin-top:0.75rem",
        code_block("btn", 'shad_button("Save", inputId = "save",\n  variant = "default")'))),
    shad_tab("preview", "Preview",
      tags$div(style = "margin-top:0.75rem;display:flex;gap:0.5rem",
        shad_button("Default"), shad_button("Secondary", variant = "secondary"),
        shad_button("Outline", variant = "outline")))),
  shad_h3("Props"),
  shad_table(props_tbl, striped = TRUE, hover = TRUE),
  shad_h3("FAQ"),
  shad_accordion("btn_faq",
    shad_accordion_item("f1", "How do I show a loading spinner?",
      shad_p("Pass ", shad_code("loading = TRUE"),
        " or toggle it from the server.")),
    shad_accordion_item("f2", "Can I use an icon-only button?",
      shad_p("Yes — set ", shad_code('size = "icon"'),
        " and pass ", shad_code("icon="), ".")),
    value = "f1"),
  shad_collapsible("btn_adv",
    trigger = shad_button("Advanced usage", variant = "ghost",
      icon = "chevrons-up-down", icon_position = "right"),
    tags$div(style = "padding:0.5rem 0",
      shad_muted("Compose buttons with shad_button_group() for segmented controls.")),
    open = FALSE))

page_theming <- function() tagList(
  shad_lead("Theme the whole app with CSS custom properties."),
  shad_p("Every color is an ",
    glossary("OKLCH", "A perceptually-uniform color space with lightness, chroma and hue."),
    " token. Switch presets at runtime with ", shad_code("update_shad_theme()"), "."),
  code_block("theme", 'page_shad(theme_preset = "violet", dark = TRUE)'),
  shad_h3("Live preview"),
  shad_p("This embed simulates a themed dashboard:"),
  tags$div(style = "max-width:28rem",
    shad_aspect_ratio(ratio = 16 / 9,
      tags$div(style = paste("width:100%;height:100%;border-radius:",
        "var(--shad-radius-lg);display:grid;place-items:center;",
        "background:var(--shad-muted)"),
        uiOutput("embed")))))

TOC <- list(
  intro = c("Why?"), install = character(),
  button = c("Props", "FAQ"), theming = c("Live preview"))

app_sidebar <- shad_sidebar(
  header = tags$div(style = "display:flex;align-items:center;gap:0.5rem;padding:0.25rem",
    shad_icon("terminal"), tags$strong("shadshiny docs")),
  shad_sidebar_group("Getting started",
    shad_sidebar_item("intro", "Introduction", active = TRUE),
    shad_sidebar_item("install", "Installation")),
  shad_sidebar_group("Components",
    shad_sidebar_item("button", "Button", badge = "new")),
  shad_sidebar_group("Guides",
    shad_sidebar_item("theming", "Theming")),
  footer = shad_muted(style = "padding:0.25rem", "v1.0.0"))

ui <- page_shad(
  title = "shadshiny — Docs",
  theme_preset = "violet",

  shad_command("docs_cmd", dialog = TRUE, placeholder = "Search docs…",
    shad_command_group("Pages",
      shad_command_item("intro", "Introduction", keywords = "start overview"),
      shad_command_item("install", "Installation", keywords = "setup"),
      shad_command_item("button", "Button", keywords = "action click"),
      shad_command_item("theming", "Theming", keywords = "color dark preset"))),

  tags$div(style = "height:100vh",
    shad_sidebar_layout("docs", sidebar = app_sidebar,
      main = tags$div(style = "display:flex;flex-direction:column;height:100%",
        # Topbar
        tags$div(style = paste("display:flex;align-items:center;gap:0.75rem;",
          "padding:0.6rem 1rem;border-bottom:1px solid var(--shad-border)"),
          shad_sidebar_trigger(),
          shad_breadcrumb(
            shad_breadcrumb_item("Docs", href = "#"),
            shad_breadcrumb_separator(),
            shad_breadcrumb_item(textOutput("crumb_section", inline = TRUE),
              href = "#"),
            shad_breadcrumb_separator(),
            shad_breadcrumb_item(textOutput("crumb_page", inline = TRUE),
              current = TRUE)),
          tags$div(style = "flex:1"),
          shad_button("Search  ⌘K", inputId = "search_hint", variant = "outline",
            icon = "search"),
          shad_badge("v1.0.0", variant = "outline"),
          shad_popover("share", side = "bottom", align = "end",
            trigger = shad_button("Share", variant = "outline"),
            title = "Share this page",
            tags$div(style = "display:grid;gap:0.35rem;min-width:11rem",
              shad_button("Copy link", inputId = "share_copy", variant = "ghost",
                icon = "file", style = "justify-content:flex-start"),
              shad_button("Open in new tab", inputId = "share_tab",
                variant = "ghost", icon = "arrow-right",
                style = "justify-content:flex-start"))),
          shad_switch("dark", "Dark")),

        # Article + TOC
        shad_scroll_area(height = "calc(100vh - 3.4rem)",
          shad_resizable("layout", style = "min-height:calc(100vh - 3.4rem)",
            shad_resizable_panel(default_size = 74,
              tags$article(style = "padding:2rem 2.5rem;max-width:48rem",
                shad_h1(textOutput("page_title", inline = TRUE),
                  style = "margin-top:0"),
                uiOutput("article"),
                shad_separator(style = "margin:2.5rem 0 1.5rem"),
                uiOutput("prevnext"))),
            shad_resizable_handle(),
            shad_resizable_panel(default_size = 26,
              tags$nav(style = "padding:2rem 1rem",
                shad_small(class = "shad-muted", "ON THIS PAGE"),
                uiOutput("toc", style = "display:block;margin-top:0.5rem"))))))))
)

server <- function(input, output, session) {
  observeEvent(input$dark, update_shad_theme(dark = isTRUE(input$dark)),
    ignoreInit = TRUE)

  page <- reactiveVal("intro")

  output$page_title    <- renderText(PAGES[[page()]])
  output$crumb_page    <- renderText(PAGES[[page()]])
  output$crumb_section <- renderText(SECTION[[page()]])

  output$article <- renderUI({
    switch(page(),
      intro = page_intro(), install = page_install(),
      button = page_button(), theming = page_theming())
  })

  # A spinner standing in for a live-loading themed embed.
  output$embed <- renderUI(shad_spinner(size = "lg"))

  output$toc <- renderUI({
    items <- TOC[[page()]]
    if (length(items) == 0) return(shad_muted("No sections."))
    shad_item_group(
      lapply(items, function(s)
        shad_item(s, size = "xs", style = "cursor:pointer",
          onclick = "Shiny.setInputValue('toc_click', Math.random(), {priority:'event'})")))
  })

  output$prevnext <- renderUI({
    ids <- names(PAGES)
    i <- match(page(), ids)
    tags$div(style = "display:flex;justify-content:space-between;gap:1rem",
      if (i > 1) shad_button(paste0("← ", PAGES[[ids[i - 1]]]),
        inputId = "prev_pg", variant = "outline") else tags$span(),
      if (i < length(ids)) shad_button(paste0(PAGES[[ids[i + 1]]], " →"),
        inputId = "next_pg", variant = "outline") else tags$span())
  })

  # Navigation sources: sidebar, command palette, prev/next.
  observeEvent(input$docs, if (input$docs %in% names(PAGES)) page(input$docs),
    ignoreInit = TRUE)
  observeEvent(input$docs_cmd, if (input$docs_cmd %in% names(PAGES))
    page(input$docs_cmd), ignoreInit = TRUE)
  observeEvent(input$prev_pg, {
    ids <- names(PAGES); i <- match(page(), ids)
    if (i > 1) page(ids[i - 1])
  })
  observeEvent(input$next_pg, {
    ids <- names(PAGES); i <- match(page(), ids)
    if (i < length(ids)) page(ids[i + 1])
  })

  # Misc actions.
  observeEvent(input$copy, shad_toast_success("Code copied to clipboard."))
  observeEvent(input$search_hint,
    shad_toast("Press ⌘K / Ctrl+K to search the docs."))
  observeEvent(input$share_copy, shad_toast_success("Link copied."))
  observeEvent(input$share_tab, shad_toast("Opening in a new tab…"))
  observeEvent(input$toc_click, shad_toast("Jumped to section."))
}

shinyApp(ui, server)

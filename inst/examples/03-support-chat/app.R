# shadshiny example 03 – Support chat / AI assistant -------------------------
# A working messaging UI: a conversation list, a stick-to-bottom transcript
# built from the chat/AI kit, a composer with attachments, and a simulated
# assistant that "types" before replying.
# Run with shadshiny::shad_run_example("03-support-chat").
#
# Components: page_shad, message-scroller (+item/to-bottom), message (+spinner),
# bubble (+group), marker, attachment (+group/action), textarea, input-group
# (+addon/button), popover, dropdown-menu, sheet, drawer, dialog, tooltip,
# item (+group), avatar, badge, separator, spinner, button, toast, select.

library(shiny)
library(shadshiny)
`%||%` <- function(a, b) if (is.null(a)) b else a

convos <- data.frame(
  id      = c("c1", "c2", "c3", "c4"),
  name    = c("AI Assistant", "Olivia Martin", "Design team", "Billing bot"),
  last    = c("Sure – here's the summary.", "Can you review the deck?",
              "Sofia: shipped the icons 🎉", "Your invoice is ready."),
  unread  = c(0, 2, 0, 1),
  online  = c(TRUE, TRUE, FALSE, TRUE),
  stringsAsFactors = FALSE
)
convos$initials <- c("AI", "OM", "DT", "BB")

seed_msgs <- list(
  c1 = list(
    list(role = "assistant", text = "Hi! I'm your assistant. Ask me anything about your workspace."),
    list(role = "user", text = "Summarise the Q3 report."),
    list(role = "assistant",
      text = "Revenue rose 12% QoQ, driven by the new plan tiers. Churn fell to 1.8%.",
      attach = "Q3-report.pdf")),
  c2 = list(
    list(role = "assistant", sender = "Olivia Martin",
      text = "Can you review the deck before the 3pm call?"),
    list(role = "user", text = "On it – give me 10 minutes.")),
  c3 = list(
    list(role = "assistant", sender = "Sofia Davis",
      text = "Shipped the new icon set 🎉", attach = "icons-v2.zip")),
  c4 = list(
    list(role = "assistant", sender = "Billing bot",
      text = "Your July invoice ($49.00) is ready.", attach = "invoice-jul.pdf"))
)

msg_avatar <- function(m, convo) if (identical(m$role, "user")) "ME" else convo$initials

# Build one scroller item from a message record.
render_msg <- function(m, convo) {
  align <- if (identical(m$role, "user")) "end" else "start"
  footer <- if (!is.null(m$attach)) {
    shad_bubble_group(align = align,
      shad_attachment(m$attach, description = "Tap to open", media = "file",
        state = "done", size = "sm"))
  }
  shad_message_scroller_item(
    shad_message(m$text, align = align, avatar = msg_avatar(m, convo),
      sender = m$sender, footer = footer))
}

ui <- page_shad(
  title = "Acme Chat",
  theme_preset = "green",

  tags$div(style = "display:grid;grid-template-columns:20rem 1fr;height:100vh",

    # -- Conversation list --------------------------------------------
    tags$aside(style = "border-right:1px solid var(--shad-border);display:flex;flex-direction:column;min-height:0",
      tags$div(style = "display:flex;align-items:center;gap:0.5rem;padding:0.85rem",
        shad_h4("Chats", style = "margin:0;flex:1"),
        shad_tooltip(
          shad_button(inputId = "new_chat", icon = "plus", size = "icon",
            variant = "ghost", aria_label = "New chat"),
          "New chat")),
      tags$div(style = "padding:0 0.85rem 0.5rem",
        shad_input_group(block = TRUE,
          shad_input_group_addon(shad_icon("search"), align = "inline-start"),
          shad_input("convo_q", placeholder = "Search chats…"))),
      shad_separator(),
      shad_scroll_area(height = "1px", style = "flex:1",
        tags$div(style = "padding:0.5rem", uiOutput("convo_list")))),

    # -- Chat pane ----------------------------------------------------
    tags$section(style = "display:flex;flex-direction:column;min-height:0",
      # Header
      tags$div(style = paste("display:flex;align-items:center;gap:0.75rem;",
        "padding:0.7rem 1rem;border-bottom:1px solid var(--shad-border)"),
        uiOutput("chat_header", style = "display:contents"),
        tags$div(style = "flex:1"),
        tags$div(style = "width:9rem",
          shad_select("model", choices = c("Assistant Pro" = "pro",
            "Assistant Lite" = "lite", "Assistant Max" = "max"), selected = "pro")),
        shad_tooltip(
          shad_button(inputId = "open_details", icon = "info", size = "icon",
            variant = "ghost", aria_label = "Details"), "Details"),
        shad_dropdown_menu("chat_menu", align = "end",
          trigger = shad_button(icon = "more-vertical", size = "icon",
            variant = "ghost", aria_label = "Menu"),
          shad_menu_item("mute", "Mute notifications"),
          shad_menu_item("search_msg", "Search in chat"),
          shad_menu_separator(),
          shad_menu_item("clear", "Clear messages"))),

      # Transcript
      tags$div(style = "flex:1;min-height:0;padding:1rem",
        uiOutput("thread_wrap", style = "display:block;height:100%")),

      # Composer
      tags$div(style = "padding:0.85rem 1rem;border-top:1px solid var(--shad-border)",
        uiOutput("quick_replies"),
        uiOutput("attach_preview"),
        shad_input_group(block = TRUE,
          shad_input_group_addon(align = "block-start",
            shad_popover("attach_pop", side = "top",
              trigger = shad_button(icon = "plus", size = "icon",
                variant = "ghost", aria_label = "Attach"),
              tags$div(style = "display:grid;gap:0.25rem;min-width:9rem",
                shad_button("Photo", inputId = "attach_photo", variant = "ghost",
                  icon = "file", style = "justify-content:flex-start"),
                shad_button("Document", inputId = "attach_doc", variant = "ghost",
                  icon = "folder", style = "justify-content:flex-start"))),
            tags$span(style = "flex:1"),
            shad_muted(style = "font-size:0.75rem", "Enter to send")),
          shad_textarea("composer", placeholder = "Message…", autosize = TRUE),
          shad_input_group_addon(align = "block-end",
            tags$span(style = "flex:1"),
            shad_input_group_button("Send", inputId = "send",
              variant = "default")))))),

  # -- Details drawer (contact info) ----------------------------------
  shad_drawer("details", title = "Details",
    description = "Shared files and info.",
    uiOutput("details_body"))
)

server <- function(input, output, session) {
  selected <- reactiveVal("c1")
  threads  <- reactiveValues()
  for (id in names(seed_msgs)) threads[[id]] <- seed_msgs[[id]]
  pending  <- reactiveVal(FALSE)
  attach   <- reactiveVal(NULL)

  cur_convo <- reactive(convos[convos$id == selected(), ])

  # -- Conversation list -----------------------------------------------
  output$convo_list <- renderUI({
    q <- tolower(input$convo_q %||% "")
    df <- convos
    if (nzchar(q)) df <- df[grepl(q, tolower(df$name)), ]
    if (nrow(df) == 0) {
      return(shad_empty("No chats", media = "search", media_variant = "icon",
        description = "No conversations match your search."))
    }
    shad_item_group(
      lapply(seq_len(nrow(df)), function(i) {
        c <- df[i, ]
        badge <- if (c$unread > 0) shad_badge(as.character(c$unread)) else NULL
        shad_item(c$name, description = c$last,
          media = tags$span(c$initials), media_variant = "icon",
          footer = badge,
          variant = if (c$id == selected()) "muted" else "default",
          style = "cursor:pointer",
          onclick = sprintf(
            "Shiny.setInputValue('pick', '%s', {priority:'event'})", c$id))
      }))
  })

  observeEvent(input$pick, {
    selected(input$pick)
    shad_message_scroller_to_bottom("thread")
  })

  # -- Header ----------------------------------------------------------
  output$chat_header <- renderUI({
    c <- cur_convo()
    tagList(
      shad_avatar(fallback = c$initials),
      tags$div(
        tags$div(style = "font-weight:600;line-height:1.1", c$name),
        shad_small(class = "shad-muted",
          if (c$online) "Online" else "Last seen recently")),
      if (c$online) shad_badge("Active", variant = "secondary"))
  })

  # -- Transcript ------------------------------------------------------
  output$thread_wrap <- renderUI({
    c <- cur_convo()
    items <- c(
      list(shad_message_scroller_item(
        shad_marker("Today", variant = "separator"), anchor = TRUE)),
      lapply(threads[[selected()]], render_msg, convo = c))
    if (pending()) {
      items <- c(items, list(shad_message_scroller_item(
        shad_message(align = "start", avatar = c$initials, state = "typing"))))
    }
    do.call(shad_message_scroller,
      c(list("thread", height = "100%"), items))
  })

  # Auto-scroll whenever the thread changes. later::later() runs outside the
  # reactive domain, so capture `session` for the deferred call.
  observeEvent(list(selected(), pending(), threads[[selected()]]), {
    later::later(
      function() shad_message_scroller_to_bottom("thread", session = session),
      0.1)
  }, ignoreInit = FALSE)

  # -- Suggested replies (shad_bubble chips) ---------------------------
  output$quick_replies <- renderUI({
    if (!selected() %in% c("c1")) return(NULL)
    chips <- c("Summarise this", "Show an example", "Thanks!")
    shad_bubble_group(align = "start", style = "flex-wrap:wrap;margin-bottom:0.5rem",
      lapply(chips, function(t)
        shad_bubble(t, variant = "outline", style = "cursor:pointer",
          onclick = sprintf("Shiny.setInputValue('quick', %s, {priority:'event'})",
            jsonlite::toJSON(t, auto_unbox = TRUE)))))
  })
  observeEvent(input$quick, send_text(input$quick))

  # -- Composer / send -------------------------------------------------
  send_text <- function(txt) {
    txt <- trimws(txt %||% "")
    if (!nzchar(txt) && is.null(attach())) return()
    id <- selected()
    msg <- list(role = "user", text = if (nzchar(txt)) txt else "(sent a file)")
    if (!is.null(attach())) msg$attach <- attach()
    threads[[id]] <- c(threads[[id]], list(msg))
    updateTextAreaInput(session, "composer", value = "")
    attach(NULL)

    # Simulate an assistant reply for the AI/bot conversations.
    if (id %in% c("c1", "c4")) {
      pending(TRUE)
      # Deferred work runs outside the reactive domain: restore it so reactive
      # reads/writes are legal, and isolate the reactiveValues read.
      later::later(function() {
        shiny::withReactiveDomain(session, {
          reply <- if (id == "c1")
            "Got it. I've noted that and can dig deeper if you'd like." else
            "Thanks! A support agent will follow up shortly."
          isolate(threads[[id]] <- c(threads[[id]],
            list(list(role = "assistant", text = reply))))
          pending(FALSE)
        })
      }, delay = 1.1)
    }
  }
  observeEvent(input$send, send_text(input$composer))

  observeEvent(input$attach_photo, {
    attach("photo.png"); shad_popover_close("attach_pop")
  })
  observeEvent(input$attach_doc, {
    attach("document.pdf"); shad_popover_close("attach_pop")
  })
  output$attach_preview <- renderUI({
    f <- attach()
    if (is.null(f)) return(NULL)
    tags$div(style = "margin-bottom:0.5rem;max-width:16rem",
      shad_attachment(f, description = "Ready to send", media = "file",
        state = "done", size = "sm",
        actions = shad_attachment_action("x", "Remove",
          onclick = "Shiny.setInputValue('attach_remove', Math.random(), {priority:'event'})")))
  })
  observeEvent(input$attach_remove, attach(NULL))

  # -- Header menu -----------------------------------------------------
  observeEvent(input$mute, shad_toast("Notifications muted."))
  observeEvent(input$search_msg, shad_toast("Search is demo-only."))
  observeEvent(input$clear, {
    threads[[selected()]] <- list()
    shad_toast_success("Messages cleared.")
  })
  observeEvent(input$new_chat, shad_toast("Starting a new chat…"))

  # -- Details drawer --------------------------------------------------
  observeEvent(input$open_details, shad_drawer_open("details"))
  output$details_body <- renderUI({
    c <- cur_convo()
    tags$div(style = "display:grid;gap:1rem;justify-items:center;padding:0.5rem",
      shad_avatar(fallback = c$initials, size = "xl"),
      shad_h4(c$name, style = "margin:0"),
      shad_badge(if (c$online) "Online" else "Offline",
        variant = if (c$online) "secondary" else "outline"),
      shad_separator(),
      tags$div(style = "width:100%",
        shad_marker("Shared files", variant = "border", icon = "folder"),
        shad_attachment_group(style = "margin-top:0.5rem",
          shad_attachment("Q3-report.pdf", orientation = "vertical",
            media = "file", state = "done"),
          shad_attachment("icons-v2.zip", orientation = "vertical",
            media = "file", state = "done"))))
  })

  observeEvent(input$model, shad_toast(paste0("Model: ", input$model)),
    ignoreInit = TRUE)

  # The drawer body is hidden until opened; render it up front.
  outputOptions(output, "details_body", suspendWhenHidden = FALSE)
}

shinyApp(ui, server)

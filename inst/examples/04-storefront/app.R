# shadshiny example 04 — Storefront / product page --------------------------
# A working e-commerce product detail page: image carousel, variant pickers,
# a live quantity stepper, an add-to-cart sheet with an empty state, tabbed
# description / specs / reviews, and a related-products carousel.
# Run with shadshiny::shad_run_example("04-storefront").
#
# Components: page_shad, navigation-menu, carousel, aspect-ratio, sheet, dialog,
# popover, tooltip, hover-card, radio-group, toggle-group, select, input-group,
# input (number), button-group, alert, tabs, accordion, collapsible, table,
# pagination, blockquote, list, empty, badge, avatar, progress, card, toast.

library(shiny)
library(shadshiny)
`%||%` <- function(a, b) if (is.null(a)) b else a

PRICE <- 129
colors <- c("Graphite" = "graphite", "Sand" = "sand", "Sky" = "sky")
color_hex <- c(graphite = "#3f3f46", sand = "#d6c7a1", sky = "#7dd3fc")
sizes <- c("S", "M", "L", "XL")

# A colored panel standing in for a product photo.
photo <- function(hex, label) {
  shad_aspect_ratio(ratio = 1,
    tags$div(style = sprintf(paste0("width:100%%;height:100%%;border-radius:",
      "var(--shad-radius-lg);display:grid;place-items:center;color:white;",
      "font-weight:600;background:linear-gradient(135deg,%s,#0006)"), hex),
      label))
}

specs_tbl <- data.frame(
  Spec = c("Material", "Weight", "Battery", "Water resistance", "Warranty"),
  Value = c("Recycled aluminium", "212 g", "Up to 30h", "IP67", "2 years"),
  stringsAsFactors = FALSE
)

reviews <- list(
  list(who = "Olivia M.", initials = "OM", stars = 5,
    text = "Genuinely the best purchase I've made this year. Battery lasts forever."),
  list(who = "Jackson L.", initials = "JL", stars = 4,
    text = "Great build quality. Wish it came in more colors."),
  list(who = "Isabella N.", initials = "IN", stars = 5,
    text = "Comfortable and light. The case feels premium."),
  list(who = "William K.", initials = "WK", stars = 3,
    text = "Good, but the app could use some work."),
  list(who = "Sofia D.", initials = "SD", stars = 5,
    text = "Exceeded expectations. Shipping was fast too."))
REVIEWS_PER_PAGE <- 2L

stars_row <- function(n) {
  tags$span(style = "color:#f59e0b;letter-spacing:1px",
    paste0(strrep("★", n), strrep("☆", 5 - n)))
}

navbar <- tags$div(
  style = paste("display:flex;align-items:center;gap:1rem;padding:0.6rem 1.25rem;",
    "border-bottom:1px solid var(--shad-border);position:sticky;top:0;z-index:40;",
    "background:var(--shad-background)"),
  tags$strong(style = "font-size:1.05rem", "NORTHWIND"),
  shad_navigation_menu("nav",
    shad_navigation_menu_item("Shop",
      tags$div(style = "display:grid;gap:0.5rem;padding:0.5rem;width:20rem",
        tags$a(href = "#", class = "shad-nav-menu__card",
          tags$div(class = "shad-nav-menu__card-title", "New arrivals"),
          tags$div(class = "shad-nav-menu__card-desc", "Fresh drops this week.")),
        tags$a(href = "#", class = "shad-nav-menu__card",
          tags$div(class = "shad-nav-menu__card-title", "Best sellers"),
          tags$div(class = "shad-nav-menu__card-desc", "What everyone's buying.")))),
    shad_navigation_menu_item("Collections", href = "#"),
    shad_navigation_menu_item("About", href = "#")),
  tags$div(style = "flex:1"),
  tags$div(style = "width:14rem",
    shad_input_group(block = TRUE,
      shad_input_group_addon(shad_icon("search"), align = "inline-start"),
      shad_input("q", placeholder = "Search products…"))),
  shad_switch("dark", "Dark"),
  uiOutput("cart_btn", style = "display:contents"),
  shad_avatar(fallback = "YOU", size = "sm"))

ui <- page_shad(
  title = "Northwind — Aero Headphones",
  theme_preset = "stone",
  navbar,

  tags$div(style = "max-width:64rem;margin:0 auto;padding:1.25rem",
    shad_breadcrumb(
      shad_breadcrumb_item("Home", href = "#"),
      shad_breadcrumb_separator(),
      shad_breadcrumb_item("Audio", href = "#"),
      shad_breadcrumb_separator(),
      shad_breadcrumb_item("Aero Headphones", current = TRUE)),

    tags$div(style = "display:grid;grid-template-columns:1fr 1fr;gap:2rem;margin-top:1rem;align-items:start",
      # -- Gallery -----------------------------------------------------
      shad_carousel("gallery",
        shad_carousel_item(photo("#3f3f46", "Front")),
        shad_carousel_item(photo("#52525b", "Side")),
        shad_carousel_item(photo("#27272a", "Detail")),
        shad_carousel_item(photo("#71717a", "In use"))),

      # -- Buy box -----------------------------------------------------
      tags$div(style = "display:grid;gap:1rem",
        tags$div(style = "display:flex;align-items:center;gap:0.5rem",
          shad_badge("Sale", variant = "destructive"),
          shad_badge("New", variant = "secondary")),
        shad_h1("Aero Headphones", style = "margin:0;font-size:1.9rem"),
        tags$div(style = "display:flex;align-items:center;gap:0.75rem",
          stars_row(5),
          shad_hover_card(
            tags$a(href = "#", class = "shad-small", "128 reviews"),
            tags$div(style = "display:grid;gap:0.4rem",
              tags$strong("4.6 out of 5"),
              shad_muted("Based on 128 verified purchases."),
              shad_progress(92))),
          shad_muted("·"), shad_muted("SKU AH-204")),
        tags$div(style = "display:flex;align-items:baseline;gap:0.6rem",
          tags$span(style = "font-size:1.6rem;font-weight:700", paste0("$", PRICE)),
          tags$span(style = "text-decoration:line-through;color:var(--shad-muted-foreground)",
            "$169")),

        shad_alert(title = "Almost gone", description = "Only 3 left in stock.",
          icon = "triangle-alert"),

        # Color
        shad_radio_group("color", label = "Color", orientation = "horizontal",
          choices = colors, selected = "graphite"),
        # Size + guide
        tags$div(style = "display:grid;gap:0.4rem",
          tags$div(style = "display:flex;justify-content:space-between;align-items:center",
            shad_label("Size", for_id = "size"),
            shad_dialog("guide",
              trigger = tags$a(href = "#", class = "shad-small", "Size guide"),
              title = "Size guide", description = "All measurements in cm.",
              shad_table(data.frame(Size = sizes,
                Head = c("52-54", "54-56", "56-58", "58-60"),
                check.names = FALSE)))),
          shad_toggle_group("size", type = "single", variant = "outline",
            choices = setNames(sizes, sizes), selected = "M")),

        # Quantity + add to cart
        tags$div(style = "display:flex;gap:0.75rem;align-items:end",
          tags$div(style = "width:9rem",
            shad_label("Qty", for_id = "qty"),
            shad_input_group(
              shad_input_group_button("−", inputId = "qty_dec", variant = "outline"),
              shad_input("qty", value = "1", type = "number"),
              shad_input_group_button("+", inputId = "qty_inc", variant = "outline"))),
          shad_button("Add to cart", inputId = "add", icon = "plus",
            style = "flex:1"),
          shad_tooltip(
            shad_button(inputId = "wishlist", icon = "circle", size = "icon",
              variant = "outline", aria_label = "Save"),
            "Save for later")),
        shad_button("Buy it now", inputId = "buy", variant = "secondary",
          style = "width:100%"),

        shad_separator(),
        shad_list(
          tags$li("Free 2-day shipping over $50"),
          tags$li("30-day returns"),
          tags$li("Carbon-neutral delivery")))),

    # -- Detail tabs ---------------------------------------------------
    tags$div(style = "margin-top:2.5rem",
      shad_tabs("detail",
        shad_tab("desc", "Description",
          tags$div(style = "max-width:44rem;margin-top:1rem",
            shad_lead("Studio-grade sound, all day comfort."),
            shad_p(paste("The Aero blends 40mm drivers with adaptive noise",
              "cancellation and a 30-hour battery, wrapped in recycled",
              "aluminium.")),
            shad_blockquote("“The most comfortable headphones we tested this year.” — Audio Weekly"))),
        shad_tab("specs", "Specifications",
          tags$div(style = "max-width:40rem;margin-top:1rem",
            shad_table(specs_tbl, striped = TRUE, hover = TRUE))),
        shad_tab("reviews", "Reviews",
          tags$div(style = "max-width:44rem;margin-top:1rem;display:grid;gap:1rem",
            tags$div(style = "display:flex;gap:2rem;align-items:center",
              tags$div(style = "text-align:center",
                tags$div(style = "font-size:2.5rem;font-weight:700", "4.6"),
                stars_row(5), shad_muted(style = "display:block", "128 reviews")),
              tags$div(style = "flex:1;display:grid;gap:0.35rem",
                lapply(5:1, function(s)
                  tags$div(style = "display:flex;align-items:center;gap:0.5rem",
                    shad_small(paste0(s, "★")),
                    shad_progress(c(72, 20, 5, 2, 1)[6 - s], style = "flex:1"))))),
            shad_separator(),
            uiOutput("reviews"),
            tags$div(style = "display:flex;justify-content:center",
              shad_pagination("rev_pg",
                pages = ceiling(length(reviews) / REVIEWS_PER_PAGE), selected = 1)))),
        shad_tab("shipping", "Shipping",
          tags$div(style = "max-width:40rem;margin-top:1rem",
            shad_accordion("ship",
              shad_accordion_item("s1", "Delivery options",
                shad_p("Standard (2-4 days) or Express (next day).")),
              shad_accordion_item("s2", "Returns & warranty",
                shad_p("Free 30-day returns. 2-year limited warranty.")),
              value = "s1"),
            shad_collapsible("intl",
              trigger = shad_button("International shipping", variant = "ghost",
                icon = "chevrons-up-down", icon_position = "right"),
              tags$div(style = "padding:0.5rem 0",
                shad_muted("Ships to 40+ countries. Duties calculated at checkout.")),
              open = FALSE))))),

    # -- Related -------------------------------------------------------
    tags$div(style = "margin-top:2.5rem",
      shad_h3("You might also like"),
      tags$div(style = "margin:0 3rem",
        do.call(shad_carousel, c(list("related"),
          lapply(c("Aero Case", "Aero Buds", "Cable Kit", "Stand", "Adapter"),
            function(nm) shad_carousel_item(
              shad_card(style = "margin:0 0.25rem",
                shad_card_content(style = "display:grid;gap:0.5rem;padding:0.75rem",
                  photo("#a1a1aa", nm),
                  tags$strong(nm), shad_muted("$39")))))))))),

  # -- Cart sheet ------------------------------------------------------
  shad_sheet("cart", side = "right", title = "Your cart",
    description = "Review your items before checkout.",
    footer = tags$div(style = "display:grid;gap:0.5rem",
      uiOutput("cart_total"),
      shad_button("Checkout", inputId = "checkout", icon = "arrow-right",
        icon_position = "right", style = "width:100%")),
    uiOutput("cart_body"))
)

server <- function(input, output, session) {
  observeEvent(input$dark, update_shad_theme(dark = isTRUE(input$dark)),
    ignoreInit = TRUE)

  cart <- reactiveVal(list())

  # -- Quantity stepper ------------------------------------------------
  qty <- reactive({
    q <- suppressWarnings(as.integer(input$qty %||% 1))
    if (length(q) == 0 || is.na(q)) q <- 1L
    max(1L, q)
  })
  observeEvent(input$qty_dec,
    updateNumericInput(session, "qty", value = max(1, qty() - 1)))
  observeEvent(input$qty_inc,
    updateNumericInput(session, "qty", value = qty() + 1))

  # -- Cart button (with live count) -----------------------------------
  cart_count <- reactive(sum(vapply(cart(), function(i) i$qty, numeric(1))))
  output$cart_btn <- renderUI({
    n <- cart_count()
    lbl <- if (n > 0) paste0("Cart · ", n) else "Cart"
    shad_button(lbl, inputId = "open_cart", variant = "outline", icon = "folder")
  })
  observeEvent(input$open_cart, shad_sheet_open("cart"))

  # -- Add to cart -----------------------------------------------------
  observeEvent(input$add, {
    col <- names(colors)[colors == (input$color %||% "graphite")]
    line <- sprintf("Aero Headphones (%s, %s)", col, input$size %||% "M")
    items <- cart()
    hit <- which(vapply(items, function(i) i$name == line, logical(1)))
    if (length(hit)) {
      items[[hit]]$qty <- items[[hit]]$qty + qty()
    } else {
      items <- c(items, list(list(name = line, price = PRICE, qty = qty())))
    }
    cart(items)
    shad_toast_success(paste0("Added ", qty(), " × Aero Headphones"))
    shad_sheet_open("cart")
  })
  observeEvent(input$buy, {
    if (length(cart()) == 0) shad_toast("Add an item first.")
    else shad_toast_loading("Taking you to checkout…")
  })

  # Fixed max cart lines → pre-register removers (cap at 20 distinct lines).
  lapply(1:20, function(k) {
    observeEvent(input[[paste0("rm_", k)]], {
      items <- cart()
      if (k <= length(items)) { items[[k]] <- NULL; cart(items) }
    }, ignoreInit = TRUE)
  })

  output$cart_body <- renderUI({
    items <- cart()
    if (length(items) == 0) {
      return(shad_empty("Your cart is empty", media = "folder",
        media_variant = "icon",
        description = "Add something you love to get started."))
    }
    shad_item_group(
      lapply(seq_along(items), function(k) {
        it <- items[[k]]
        shad_item(it$name,
          description = paste0("$", it$price, " · qty ", it$qty),
          media = tags$span("AH"), media_variant = "icon", variant = "outline",
          actions = shad_button(icon = "x", size = "icon", variant = "ghost",
            aria_label = "Remove",
            onclick = sprintf(
              "Shiny.setInputValue('rm_%d', Math.random(), {priority:'event'})", k)))
      }))
  })
  output$cart_total <- renderUI({
    total <- sum(vapply(cart(), function(i) i$price * i$qty, numeric(1)))
    tags$div(style = "display:flex;justify-content:space-between;font-weight:600",
      tags$span("Total"), tags$span(paste0("$", format(total, big.mark = ","))))
  })
  observeEvent(input$checkout, {
    if (length(cart()) == 0) shad_toast_error("Your cart is empty.")
    else shad_toast_success("Order placed! 🎉")
  })

  # -- Variant feedback ------------------------------------------------
  observeEvent(input$color, shad_toast(paste0("Color: ",
    names(colors)[colors == input$color])), ignoreInit = TRUE)

  # -- Reviews ---------------------------------------------------------
  output$reviews <- renderUI({
    page <- input$rev_pg %||% 1
    idx <- ((page - 1) * REVIEWS_PER_PAGE + 1):min(page * REVIEWS_PER_PAGE, length(reviews))
    tags$div(style = "display:grid;gap:1rem",
      lapply(reviews[idx], function(r)
        shad_card(shad_card_content(style = "display:grid;gap:0.5rem;padding:1rem",
          tags$div(style = "display:flex;align-items:center;gap:0.6rem",
            shad_avatar(fallback = r$initials, size = "sm"),
            tags$strong(r$who),
            shad_badge("Verified", variant = "outline", icon = "check"),
            tags$span(style = "flex:1"), stars_row(r$stars)),
          shad_blockquote(r$text)))))
  })

  # Reviews tab + cart sheet are hidden at startup; render them anyway.
  outputOptions(output, "reviews", suspendWhenHidden = FALSE)
  outputOptions(output, "cart_body", suspendWhenHidden = FALSE)
  outputOptions(output, "cart_total", suspendWhenHidden = FALSE)
}

shinyApp(ui, server)

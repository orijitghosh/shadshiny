# 07 – Data explorer: data table + value boxes + chart theming + custom theme.
# Exercises shad_data_table(), shad_value_box(), shad_chart_container(),
# shad_theme_ggplot2(), and runtime theming.
library(shiny)
library(shadshiny)

has_ggplot <- requireNamespace("ggplot2", quietly = TRUE)

# a small, self-contained dataset
set.seed(1)
sales <- data.frame(
  order   = sprintf("ORD-%03d", 1:120),
  region  = sample(c("North", "South", "East", "West"), 120, replace = TRUE),
  channel = sample(c("Online", "Retail", "Partner"), 120, replace = TRUE),
  status  = sample(c("paid", "pending", "refunded"), 120, replace = TRUE,
                   prob = c(.7, .2, .1)),
  amount  = round(runif(120, 20, 2000), 2),
  date    = as.Date("2026-01-01") + sample(0:180, 120, replace = TRUE),
  stringsAsFactors = FALSE
)

ui <- page_shad(
  theme_preset = "blue",
  title = "Data explorer",
  shad_h2("Sales explorer"),
  div(
    style = "display:grid;grid-template-columns:repeat(auto-fit,minmax(12rem,1fr));gap:1rem;margin:1rem 0;",
    uiOutput("kpis")
  ),
  shad_chart_container(
    plotOutput("trend", height = "260px"),
    title = "Revenue by region", description = "Filtered by the table below",
    aspect = "auto"
  ),
  div(style = "margin-top:1.5rem;",
    shad_data_table(
      "tbl", sales,
      selection = "multiple", filter = "both", column_visibility = TRUE,
      page_size = 10,
      columns = list(
        amount = shad_col("Amount", format = shad_fmt_number(2, prefix = "$")),
        date   = shad_col("Date", format = shad_fmt_date("%b %d")),
        status = shad_col("Status", format = shad_fmt_badge(
          c(paid = "default", pending = "secondary", refunded = "destructive")))
      )
    )
  )
)

server <- function(input, output, session) {
  # rows currently matching the table's filter/selection state
  filtered <- reactive({
    st <- input$tbl
    df <- sales
    if (!is.null(st$selected) && length(st$selected)) {
      df <- df[as.integer(st$selected), , drop = FALSE]
    }
    df
  })

  output$kpis <- renderUI({
    df <- filtered()
    tagList(
      shad_value_box(sprintf("$%s", format(round(sum(df$amount)), big.mark = ",")),
                     "Total revenue", icon = "activity"),
      shad_value_box(nrow(df), "Orders", delta = sprintf("of %d", nrow(sales)),
                     delta_direction = "neutral"),
      shad_value_box(sprintf("$%s", format(round(mean(df$amount)), big.mark = ",")),
                     "Avg order")
    )
  })

  output$trend <- renderPlot({
    df <- filtered()
    th <- shad_current_theme()
    if (has_ggplot) {
      agg <- aggregate(amount ~ region, df, sum)
      ggplot2::ggplot(agg, ggplot2::aes(region, amount, fill = region)) +
        ggplot2::geom_col() +
        shad_scale_fill_shad(th$preset, th$dark) +
        shad_theme_ggplot2(th$preset, th$dark) +
        ggplot2::labs(x = NULL, y = NULL)
    } else {
      ink <- if (th$dark) "#A1A1A1" else "#737373"
      op <- par(fg = ink, col.axis = ink)
      on.exit(par(op), add = TRUE)
      barplot(tapply(df$amount, df$region, sum),
              col = shad_chart_colors(4, th$preset, th$dark), border = NA)
    }
  }, bg = "transparent")
}

shinyApp(ui, server)

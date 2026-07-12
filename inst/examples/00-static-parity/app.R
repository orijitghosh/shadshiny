# Static-parity harness (Phase 1 acceptance).
#
# Renders the canonical hand-written anatomy demo (inst/assets/demo/
# kitchen-sink.html) exactly as authored, so you can eyeball the raw CSS/JS
# port against shadcn/ui *before* any R wrappers are involved. Put this window
# side by side with `shad_run_example("kitchen-sink")` (the R-built demo) and
# work through CHECKLIST.md.
library(shiny)

asset_root <- system.file("assets", package = "shadshiny")
addResourcePath("shadassets", asset_root)

ui <- fluidPage(
  tags$style(HTML(
    "html,body{margin:0;height:100%} .parity-frame{border:0;width:100%;height:100vh}"
  )),
  tags$iframe(class = "parity-frame", src = "shadassets/demo/kitchen-sink.html")
)

server <- function(input, output, session) {}

shinyApp(ui, server)

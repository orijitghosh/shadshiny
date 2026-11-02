# 08 — Streaming chat. Runs fully offline with a fake token-streaming "LLM".
# Swap the handler's generator for ellmer's `chat$stream(prompt)` to go live.
library(shiny)
library(shadshiny)

# A fake streaming LLM: yields the reply word-by-word with a small delay, so the
# transcript visibly streams. Returns a chunk-yielding closure (the simple
# streaming protocol shad_chat_server() understands).
fake_llm <- function(prompt, history) {
  reply <- paste0(
    "Thanks for your message. You said: “", prompt, "”. ",
    "This demo streams a canned reply token by token so you can see the ",
    "**stick-to-bottom** transcript and Markdown rendering in action."
  )
  words <- strsplit(reply, " ")[[1]]
  i <- 0L
  function() {
    i <<- i + 1L
    if (i > length(words)) return(NULL)
    paste0(if (i > 1) " " else "", words[i])
  }
  # --- live version (requires the 'ellmer' package + an API key) --------------
  # chat <- ellmer::chat_openai(model = "gpt-4o-mini")
  # chat$stream(prompt)
}

ui <- page_shad(
  title = "Streaming chat",
  div(style = "max-width:44rem;margin:0 auto;",
    shad_h2("Assistant"),
    shad_chat_ui(
      "chat", height = "60vh",
      placeholder = "Ask me anything...",
      welcome = shad_empty(
        title = "Start the conversation",
        description = "Type a message below and press Enter."
      )
    ),
    div(style = "margin-top:.5rem;display:flex;gap:.5rem;",
      shad_button("Clear", inputId = "clear", variant = "outline", size = "sm"))
  )
)

server <- function(input, output, session) {
  chat <- shad_chat_server("chat", handler = fake_llm)
  observeEvent(input$clear, chat$clear())
}

shinyApp(ui, server)

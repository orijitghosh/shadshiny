# Chat UI

The UI half of a streaming chat module: a stick-to-bottom transcript
plus a composer (auto-sizing textarea + send button). Pair with
[`shad_chat_server()`](https://orijitghosh.github.io/shadshiny/reference/shad_chat_server.md).

## Usage

``` r
shad_chat_ui(
  id,
  placeholder = "Message...",
  height = "60vh",
  welcome = NULL,
  send_label = "Send"
)
```

## Arguments

- id:

  Module id.

- placeholder:

  Composer placeholder text.

- height:

  Transcript height (CSS unit).

- welcome:

  Optional tags shown before the first message (empty state).

- send_label:

  Accessible label for the send button.

## Value

A chat UI tag.

## See also

Other shadshiny chat:
[`shad_chat_server()`](https://orijitghosh.github.io/shadshiny/reference/shad_chat_server.md)

## Examples

``` r
shad_chat_ui("chat", height = "60vh", welcome = "How can I help?")
#> <div class="shad-chat">
#>   <div class="shad-message-scroller" data-shad="message-scroller" id="chat-scroller" data-auto-scroll data-default-position="end" style="height:60vh;">
#>     <div class="shad-message-scroller__viewport" aria-live="polite" tabindex="0">
#>       <div class="shad-message-scroller__content">
#>         <div class="shiny-html-output shad-chat__transcript" id="chat-transcript"></div>
#>         <div class="shad-chat__welcome">How can I help?</div>
#>       </div>
#>     </div>
#>     <button type="button" class="shad-message-scroller__button" aria-label="Jump to latest">
#>       <svg class="shad-icon shad-icon--sm" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M12 5v14"/><path d="m19 12-7 7-7-7"/></svg>
#>       Jump to latest
#>     </button>
#>   </div>
#>   <div class="shad-chat__composer">
#>     <div class="shad-input-group shad-input-group--block" role="group">
#>       <textarea id="chat-text" class="shad-textarea" placeholder="Message..." rows="1"></textarea>
#>       <button type="button" id="chat-send" class="shad-btn shad-btn--default shad-btn--sm shad-input-group__button action-button">Send</button>
#>     </div>
#>   </div>
#> </div>
#> <script>(function(){var t=document.getElementById('chat-text');if(!t)return;t.addEventListener('keydown',function(e){if(e.key==='Enter'&&!e.shiftKey){e.preventDefault();var b=document.getElementById('chat-send');if(b)b.click();}});})();</script>
```

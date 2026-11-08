# Structured chat workbench UI

Experimental, provider-neutral UI for structured chat events. Pair with
[`shad_chat_workbench_server()`](https://orijitghosh.github.io/shadshiny/reference/shad_chat_workbench_server.md).
Native uploads are handled by Shiny; no server-side file paths are
rendered into this UI.

## Usage

``` r
shad_chat_workbench_ui(
  id,
  placeholder = "Message...",
  height = "60vh",
  welcome = NULL,
  send_label = "Send",
  accept = NULL,
  multiple = TRUE
)
```

## Arguments

- id:

  Module id.

- placeholder:

  Composer placeholder text.

- height:

  Transcript height.

- welcome:

  Optional content before the first message.

- send_label:

  Send button label.

- accept:

  Native file-input accept value.

- multiple:

  Whether native upload accepts multiple files.

## Value

A workbench UI tag.

## Examples

``` r
shad_chat_workbench_ui("assistant", welcome = "Ask me anything.")
#> <div id="assistant-root" class="shad-chat-workbench" data-shad="chat-workbench">
#>   <div class="shad-message-scroller" data-shad="message-scroller" id="assistant-scroller" data-auto-scroll data-default-position="end" style="height:60vh;">
#>     <div class="shad-message-scroller__viewport" aria-live="polite" tabindex="0">
#>       <div class="shad-message-scroller__content">
#>         <div class="shiny-html-output shad-chat-workbench__transcript" id="assistant-transcript"></div>
#>       </div>
#>     </div>
#>     <button type="button" class="shad-message-scroller__button" aria-label="Jump to latest">
#>       <svg class="shad-icon shad-icon--sm" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M12 5v14"/><path d="m19 12-7 7-7-7"/></svg>
#>       Jump to latest
#>     </button>
#>   </div>
#>   <div class="shad-chat-workbench__welcome">Ask me anything.</div>
#>   <div class="shad-chat-prompt" data-shad="chat-prompt">
#>     <div class="form-group shiny-input-container">
#>       <label class="control-label" id="assistant-files-label" for="assistant-files">Attach files</label>
#>       <div class="input-group">
#>         <label class="input-group-btn input-group-prepend">
#>           <span class="btn btn-default btn-file">
#>             Browse...
#>             <input id="assistant-files" class="shiny-input-file" name="assistant-files" type="file" style="position: absolute !important; top: -99999px !important; left: -99999px !important;" multiple="multiple"/>
#>           </span>
#>         </label>
#>         <input type="text" class="form-control" placeholder="No file selected" readonly="readonly"/>
#>       </div>
#>       <div id="assistant-files_progress" class="progress active shiny-file-input-progress">
#>         <div class="progress-bar"></div>
#>       </div>
#>     </div>
#>     <textarea id="assistant-text" class="shad-textarea" placeholder="Message..." rows="1"></textarea>
#>     <button type="button" id="assistant-submit" class="shad-btn shad-btn--default shad-chat-prompt__send action-button">Send</button>
#>     <button type="button" id="assistant-cancel" class="shad-btn shad-btn--outline shad-chat-prompt__cancel action-button" disabled>Cancel</button>
#>   </div>
#> </div>
```

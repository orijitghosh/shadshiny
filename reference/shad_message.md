# Chat message

A full conversation row: avatar, header (sender + meta), a
[`shad_bubble()`](https://orijitghosh.github.io/shadshiny/reference/shad_bubble.md)
surface, and a footer (status, actions). Part of the chat/AI kit. Group
consecutive same-sender rows with `shad_message_group()`.

## Usage

``` r
shad_message(
  ...,
  align = c("start", "end"),
  avatar = NULL,
  sender = NULL,
  meta = NULL,
  footer = NULL,
  state = NULL,
  bubble_variant = "muted",
  class = NULL
)

shad_message_group(..., class = NULL)
```

## Arguments

- ...:

  The message body – placed inside the bubble content. For
  `state = "typing"` the body is replaced by an animated typing
  indicator.

- align:

  `"start"` (received) or `"end"` (sent).

- avatar:

  Optional avatar: a tag (e.g.
  [`shad_avatar()`](https://orijitghosh.github.io/shadshiny/reference/shad_avatar.md)
  or an `<img>`) or a short string of initials.

- sender:

  Optional sender name (shown in the header).

- meta:

  Optional header meta (time, badge) shown after the sender.

- footer:

  Optional footer content (status text, a retry button). Pair with
  `state = "in-progress"` to show a spinner.

- state:

  Optional `"typing"`, `"in-progress"`, or `"failed"`.

- bubble_variant:

  [`shad_bubble()`](https://orijitghosh.github.io/shadshiny/reference/shad_bubble.md)
  variant for the surface (default `"muted"`).

- class:

  Extra CSS classes.

## Value

A message tag.

## See also

Other shadshiny chat components:
[`shad_attachment()`](https://orijitghosh.github.io/shadshiny/reference/shad_attachment.md),
[`shad_bubble()`](https://orijitghosh.github.io/shadshiny/reference/shad_bubble.md),
[`shad_marker()`](https://orijitghosh.github.io/shadshiny/reference/shad_marker.md),
[`shad_message_spinner()`](https://orijitghosh.github.io/shadshiny/reference/shad_message_spinner.md)

## Examples

``` r
shad_message("Did the model finish training?", sender = "Ada K.",
             meta = "9:41 AM", avatar = "AK")
#> <div class="shad-message shad-message--start">
#>   <div class="shad-message__avatar" aria-hidden="true">AK</div>
#>   <div class="shad-message__content">
#>     <div class="shad-message__header">
#>       <span class="shad-message__sender">Ada K.</span>
#>       <span>9:41 AM</span>
#>     </div>
#>     <div class="shad-bubble shad-bubble--muted">
#>       <div class="shad-bubble__content">Did the model finish training?</div>
#>     </div>
#>   </div>
#> </div>
shad_message(align = "end", avatar = "ME", state = "typing")
#> <div class="shad-message shad-message--end" data-state="typing">
#>   <div class="shad-message__avatar" aria-hidden="true">ME</div>
#>   <div class="shad-message__content">
#>     <div class="shad-bubble shad-bubble--muted" role="status">
#>       <div class="shad-bubble__content">
#>         <span class="shad-message__typing" aria-hidden="true">
#>           <span></span>
#>           <span></span>
#>           <span></span>
#>         </span>
#>       </div>
#>     </div>
#>   </div>
#> </div>
```

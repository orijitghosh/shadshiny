# A spinner glyph for a message footer (in-progress state)

A spinner glyph for a message footer (in-progress state)

## Usage

``` r
shad_message_spinner()
```

## Value

A spinner span for use in
[`shad_message()`](https://orijitghosh.github.io/shadshiny/reference/shad_message.md)'s
`footer`.

## See also

Other shadshiny chat components:
[`shad_attachment()`](https://orijitghosh.github.io/shadshiny/reference/shad_attachment.md),
[`shad_bubble()`](https://orijitghosh.github.io/shadshiny/reference/shad_bubble.md),
[`shad_marker()`](https://orijitghosh.github.io/shadshiny/reference/shad_marker.md),
[`shad_message()`](https://orijitghosh.github.io/shadshiny/reference/shad_message.md)

## Examples

``` r
shad_message(shad_message_spinner(), sender = "Assistant")
#> <div class="shad-message shad-message--start">
#>   <div class="shad-message__content">
#>     <div class="shad-message__header">
#>       <span class="shad-message__sender">Assistant</span>
#>     </div>
#>     <div class="shad-bubble shad-bubble--muted">
#>       <div class="shad-bubble__content">
#>         <span class="shad-message__spinner" aria-hidden="true">
#>           <svg class="shad-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M21 12a9 9 0 1 1-6.219-8.56"/></svg>
#>         </span>
#>       </div>
#>     </div>
#>   </div>
#> </div>
```

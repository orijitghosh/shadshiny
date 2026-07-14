# Combobox

A shadcn combobox (searchable select). `input$<inputId>` is a
string/`NULL` (single) or a character vector (multiple, chips rendered
client-side).

## Usage

``` r
shad_combobox(
  inputId,
  label = NULL,
  choices,
  selected = NULL,
  multiple = FALSE,
  placeholder = "Select...",
  search_placeholder = "Search...",
  empty_text = "No results.",
  disabled = FALSE,
  width = NULL,
  class = NULL,
  ...
)
```

## Arguments

- inputId:

  Input id.

- label:

  Optional label (wraps in
  [`shad_form_field()`](https://orijitghosh.github.io/shadshiny/reference/shad_form_field.md)).

- choices:

  A named/unnamed vector or a list of
  [`shad_select_item()`](https://orijitghosh.github.io/shadshiny/reference/shad_select.md)-style
  specs (`list(value=, label=, disabled=)`).

- selected:

  Initially selected value(s).

- multiple:

  If `TRUE`, allow multiple selection.

- placeholder:

  Trigger placeholder text.

- search_placeholder:

  Search-input placeholder.

- empty_text:

  Text shown when no item matches the search.

- disabled:

  If `TRUE`, disables the control.

- width:

  CSS width.

- class:

  Extra CSS classes.

- ...:

  Extra attributes on the combobox root.

## Value

A combobox tag.

## See also

Other shadshiny tier-2 components:
[`shad_calendar()`](https://orijitghosh.github.io/shadshiny/reference/shad_calendar.md),
[`shad_checkbox()`](https://orijitghosh.github.io/shadshiny/reference/shad_checkbox.md),
[`shad_date_picker()`](https://orijitghosh.github.io/shadshiny/reference/shad_date_picker.md),
[`shad_form_field()`](https://orijitghosh.github.io/shadshiny/reference/shad_form_field.md),
[`shad_input()`](https://orijitghosh.github.io/shadshiny/reference/shad_input.md),
[`shad_input_group()`](https://orijitghosh.github.io/shadshiny/reference/shad_input_group.md),
[`shad_input_otp()`](https://orijitghosh.github.io/shadshiny/reference/shad_input_otp.md),
[`shad_native_select()`](https://orijitghosh.github.io/shadshiny/reference/shad_native_select.md),
[`shad_radio_group()`](https://orijitghosh.github.io/shadshiny/reference/shad_radio_group.md),
[`shad_select()`](https://orijitghosh.github.io/shadshiny/reference/shad_select.md),
[`shad_slider()`](https://orijitghosh.github.io/shadshiny/reference/shad_slider.md),
[`shad_switch()`](https://orijitghosh.github.io/shadshiny/reference/shad_switch.md),
[`shad_textarea()`](https://orijitghosh.github.io/shadshiny/reference/shad_textarea.md),
[`shad_toggle()`](https://orijitghosh.github.io/shadshiny/reference/shad_toggle.md),
[`shad_toggle_group()`](https://orijitghosh.github.io/shadshiny/reference/shad_toggle_group.md)

## Examples

``` r
shad_combobox("fw", choices = c("Next.js" = "next", "Astro" = "astro"))
#> <div class="shad-combobox" data-shad="combobox" id="fw" data-state="closed">
#>   <button type="button" class="shad-combobox__trigger" data-placeholder>
#>     <span class="shad-combobox__value">Select...</span>
#>     <svg class="shad-combobox__chevrons" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m7 15 5 5 5-5"/><path d="m7 9 5-5 5 5"/></svg>
#>   </button>
#>   <div class="shad-combobox__content shad-anim-pop" hidden>
#>     <div class="shad-combobox__search">
#>       <svg class="shad-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="11" cy="11" r="8"/><path d="m21 21-4.3-4.3"/></svg>
#>       <input class="shad-combobox__input" type="text" placeholder="Search..." autocomplete="off" autocorrect="off" spellcheck="false"/>
#>     </div>
#>     <div class="shad-combobox__list">
#>       <div class="shad-combobox__item" data-value="next" data-state="unchecked">
#>         <svg class="shad-combobox__item-check" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M20 6 9 17l-5-5"/></svg>
#>         Next.js
#>       </div>
#>       <div class="shad-combobox__item" data-value="astro" data-state="unchecked">
#>         <svg class="shad-combobox__item-check" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M20 6 9 17l-5-5"/></svg>
#>         Astro
#>       </div>
#>     </div>
#>     <div class="shad-combobox__empty" hidden>No results.</div>
#>   </div>
#> </div>
```

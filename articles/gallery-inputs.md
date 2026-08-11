# Gallery: form inputs

Every component here is a **bound Shiny input**: pass an `inputId`, then
read the value with `input$id` and set it from the server with the
matching `update_shad_*()` helper. The previews below are live — you can
type, toggle and open them — but with no Shiny server attached they
won’t echo values. See [Forms &
validation](https://orijitghosh.github.io/shadshiny/articles/forms.md)
for the reactive side, and the [Server
API](https://orijitghosh.github.io/shadshiny/articles/server-api.md)
guide for updating inputs.

## Text input

[`shad_input()`](https://orijitghosh.github.io/shadshiny/reference/shad_input.md)
renders a real `<input>` and uses Shiny’s native text binding, so
[`updateTextInput()`](https://rdrr.io/pkg/shiny/man/updateTextInput.html)
works on it. `type` accepts any HTML input type.

Email

Password

At least 8 characters.

Username

That name is unavailable.

Code


    shad_input("email", label = "Email", type = "email", placeholder = "you@example.com")
    shad_input("pw", label = "Password", type = "password", description = "At least 8 characters.")
    shad_input("bad", label = "Username", value = "taken", invalid = TRUE, description = "That name is unavailable.")

## Textarea

[`shad_textarea()`](https://orijitghosh.github.io/shadshiny/reference/shad_textarea.md)
with optional `autosize` and a fixed `rows` height.

Bio

Code


    shad_textarea("bio", label = "Bio", rows = 3, placeholder = "Tell us about yourself…")

## Checkbox & switch

Both hold a single logical.
[`shad_checkbox()`](https://orijitghosh.github.io/shadshiny/reference/shad_checkbox.md)
also supports an `indeterminate` third state.

![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC1jaGVja2JveF9faW5kaWNhdG9yIHNoYWQtY2hlY2tib3hfX2luZGljYXRvci0tY2hlY2siIHZpZXdib3g9IjAgMCAyNCAyNCIgZmlsbD0ibm9uZSIgc3Ryb2tlPSJjdXJyZW50Q29sb3IiIHN0cm9rZS13aWR0aD0iMyIgc3Ryb2tlLWxpbmVjYXA9InJvdW5kIiBzdHJva2UtbGluZWpvaW49InJvdW5kIiBhcmlhLWhpZGRlbj0idHJ1ZSI+PHBhdGggcGF0aGxlbmd0aD0iMSIgZD0iTTIwIDYgOSAxN2wtNS01IiAvPjwvc3ZnPg==)![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC1jaGVja2JveF9faW5kaWNhdG9yIHNoYWQtY2hlY2tib3hfX2luZGljYXRvci0tbWludXMiIHZpZXdib3g9IjAgMCAyNCAyNCIgZmlsbD0ibm9uZSIgc3Ryb2tlPSJjdXJyZW50Q29sb3IiIHN0cm9rZS13aWR0aD0iMyIgc3Ryb2tlLWxpbmVjYXA9InJvdW5kIiBhcmlhLWhpZGRlbj0idHJ1ZSI+PHBhdGggZD0iTTUgMTJoMTQiIC8+PC9zdmc+)

I accept the terms

![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC1jaGVja2JveF9faW5kaWNhdG9yIHNoYWQtY2hlY2tib3hfX2luZGljYXRvci0tY2hlY2siIHZpZXdib3g9IjAgMCAyNCAyNCIgZmlsbD0ibm9uZSIgc3Ryb2tlPSJjdXJyZW50Q29sb3IiIHN0cm9rZS13aWR0aD0iMyIgc3Ryb2tlLWxpbmVjYXA9InJvdW5kIiBzdHJva2UtbGluZWpvaW49InJvdW5kIiBhcmlhLWhpZGRlbj0idHJ1ZSI+PHBhdGggcGF0aGxlbmd0aD0iMSIgZD0iTTIwIDYgOSAxN2wtNS01IiAvPjwvc3ZnPg==)![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC1jaGVja2JveF9faW5kaWNhdG9yIHNoYWQtY2hlY2tib3hfX2luZGljYXRvci0tbWludXMiIHZpZXdib3g9IjAgMCAyNCAyNCIgZmlsbD0ibm9uZSIgc3Ryb2tlPSJjdXJyZW50Q29sb3IiIHN0cm9rZS13aWR0aD0iMyIgc3Ryb2tlLWxpbmVjYXA9InJvdW5kIiBhcmlhLWhpZGRlbj0idHJ1ZSI+PHBhdGggZD0iTTUgMTJoMTQiIC8+PC9zdmc+)

Select all

Email notifications

We'll only email about account activity.

Code


    shad_checkbox("tos", label = "I accept the terms", value = TRUE)
    shad_checkbox("mix", label = "Select all", indeterminate = TRUE)
    shad_switch("notify", label = "Email notifications", value = TRUE, description = "We'll only email about account activity.")

## Radio group

One value from a set. `choices` is a named vector (label = value) or a
list of
[`shad_radio_item()`](https://orijitghosh.github.io/shadshiny/reference/shad_radio_group.md)s
when you need per-item descriptions.

Plan

Free

Pro

Team

Code


    shad_radio_group("plan", label = "Plan", choices = c(Free = "free", Pro = "pro", Team = "team"), selected = "pro")

## Toggle & toggle group

A
[`shad_toggle()`](https://orijitghosh.github.io/shadshiny/reference/shad_toggle.md)
is a two-state button; a
[`shad_toggle_group()`](https://orijitghosh.github.io/shadshiny/reference/shad_toggle_group.md)
is a segmented control that holds one value (`type = "single"`) or
several (`"multiple"`).

![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC1pY29uIiB2aWV3Ym94PSIwIDAgMjQgMjQiIGZpbGw9Im5vbmUiIHN0cm9rZT0iY3VycmVudENvbG9yIiBzdHJva2Utd2lkdGg9IjIiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCIgYXJpYS1oaWRkZW49InRydWUiPjxwYXRoIGQ9Ik01IDEyaDE0IiAvPjxwYXRoIGQ9Ik0xMiA1djE0IiAvPjwvc3ZnPg==)
Bold

Left

Center

Right

Code


    shad_toggle("bold", label = "Bold", icon = "plus")
    shad_toggle_group("align", type = "single", selected = "left", choices = c(Left = "left", Center = "center", Right = "right"))

## Slider

A numeric slider with optional `marks`.

Volume

Max price

Code


    shad_slider("vol", label = "Volume", min = 0, max = 100, value = 40)
    shad_slider("price", label = "Max price", min = 0, max = 1000, value = 250, step = 50)

## Select

A styled dropdown that opens a listbox popover. Use
[`shad_select_item()`](https://orijitghosh.github.io/shadshiny/reference/shad_select.md)s
or a named vector for `choices`, and
[`shad_select_group()`](https://orijitghosh.github.io/shadshiny/reference/shad_select.md)
to label sections.

Favourite fruit

Banana
![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC1zZWxlY3RfX2NoZXZyb24iIHZpZXdib3g9IjAgMCAyNCAyNCIgZmlsbD0ibm9uZSIgc3Ryb2tlPSJjdXJyZW50Q29sb3IiIHN0cm9rZS13aWR0aD0iMiIgc3Ryb2tlLWxpbmVjYXA9InJvdW5kIiBzdHJva2UtbGluZWpvaW49InJvdW5kIiBhcmlhLWhpZGRlbj0idHJ1ZSI+PHBhdGggZD0ibTYgOSA2IDYgNi02IiAvPjwvc3ZnPg==)

![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC1pY29uIiB2aWV3Ym94PSIwIDAgMjQgMjQiIGZpbGw9Im5vbmUiIHN0cm9rZT0iY3VycmVudENvbG9yIiBzdHJva2Utd2lkdGg9IjIiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCI+PHBhdGggZD0ibTE4IDE1LTYtNi02IDYiIC8+PC9zdmc+)

![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC1zZWxlY3RfX2l0ZW0tY2hlY2siIHZpZXdib3g9IjAgMCAyNCAyNCIgZmlsbD0ibm9uZSIgc3Ryb2tlPSJjdXJyZW50Q29sb3IiIHN0cm9rZS13aWR0aD0iMiIgc3Ryb2tlLWxpbmVjYXA9InJvdW5kIiBzdHJva2UtbGluZWpvaW49InJvdW5kIiBhcmlhLWhpZGRlbj0idHJ1ZSI+PHBhdGggZD0iTTIwIDYgOSAxN2wtNS01IiAvPjwvc3ZnPg==)
Apple

![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC1zZWxlY3RfX2l0ZW0tY2hlY2siIHZpZXdib3g9IjAgMCAyNCAyNCIgZmlsbD0ibm9uZSIgc3Ryb2tlPSJjdXJyZW50Q29sb3IiIHN0cm9rZS13aWR0aD0iMiIgc3Ryb2tlLWxpbmVjYXA9InJvdW5kIiBzdHJva2UtbGluZWpvaW49InJvdW5kIiBhcmlhLWhpZGRlbj0idHJ1ZSI+PHBhdGggZD0iTTIwIDYgOSAxN2wtNS01IiAvPjwvc3ZnPg==)
Banana

![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC1zZWxlY3RfX2l0ZW0tY2hlY2siIHZpZXdib3g9IjAgMCAyNCAyNCIgZmlsbD0ibm9uZSIgc3Ryb2tlPSJjdXJyZW50Q29sb3IiIHN0cm9rZS13aWR0aD0iMiIgc3Ryb2tlLWxpbmVjYXA9InJvdW5kIiBzdHJva2UtbGluZWpvaW49InJvdW5kIiBhcmlhLWhpZGRlbj0idHJ1ZSI+PHBhdGggZD0iTTIwIDYgOSAxN2wtNS01IiAvPjwvc3ZnPg==)
Cherry

![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC1pY29uIiB2aWV3Ym94PSIwIDAgMjQgMjQiIGZpbGw9Im5vbmUiIHN0cm9rZT0iY3VycmVudENvbG9yIiBzdHJva2Utd2lkdGg9IjIiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCI+PHBhdGggZD0ibTYgOSA2IDYgNi02IiAvPjwvc3ZnPg==)

Code


    shad_select("fruit", label = "Favourite fruit", choices = c(Apple = "apple", Banana = "banana", Cherry = "cherry"), selected = "banana", placeholder = "Pick one")

[`shad_native_select()`](https://orijitghosh.github.io/shadshiny/reference/shad_native_select.md)
is the same look over a real `<select>` — better on mobile and inside
dense forms.

United States India
Germany![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC1pY29uIHNoYWQtbmF0aXZlLXNlbGVjdF9fY2hldnJvbiIgdmlld2JveD0iMCAwIDI0IDI0IiBmaWxsPSJub25lIiBzdHJva2U9ImN1cnJlbnRDb2xvciIgc3Ryb2tlLXdpZHRoPSIyIiBzdHJva2UtbGluZWNhcD0icm91bmQiIHN0cm9rZS1saW5lam9pbj0icm91bmQiIGFyaWEtaGlkZGVuPSJ0cnVlIj48cGF0aCBkPSJtNiA5IDYgNiA2LTYiIC8+PC9zdmc+)

Code


    shad_native_select("country", label = "Country", choices = c(`United States` = "us", India = "in", Germany = "de"))

## Combobox

A searchable select. Set `multiple = TRUE` for tag-style multi-select.

Language

Search languages…
![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC1jb21ib2JveF9fY2hldnJvbnMiIHZpZXdib3g9IjAgMCAyNCAyNCIgZmlsbD0ibm9uZSIgc3Ryb2tlPSJjdXJyZW50Q29sb3IiIHN0cm9rZS13aWR0aD0iMiIgc3Ryb2tlLWxpbmVjYXA9InJvdW5kIiBzdHJva2UtbGluZWpvaW49InJvdW5kIiBhcmlhLWhpZGRlbj0idHJ1ZSI+PHBhdGggZD0ibTcgMTUgNSA1IDUtNSIgLz48cGF0aCBkPSJtNyA5IDUtNSA1IDUiIC8+PC9zdmc+)

![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC1pY29uIiB2aWV3Ym94PSIwIDAgMjQgMjQiIGZpbGw9Im5vbmUiIHN0cm9rZT0iY3VycmVudENvbG9yIiBzdHJva2Utd2lkdGg9IjIiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCIgYXJpYS1oaWRkZW49InRydWUiPjxjaXJjbGUgY3g9IjExIiBjeT0iMTEiIHI9IjgiPjwvY2lyY2xlPjxwYXRoIGQ9Im0yMSAyMS00LjMtNC4zIiAvPjwvc3ZnPg==)

![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC1jb21ib2JveF9faXRlbS1jaGVjayIgdmlld2JveD0iMCAwIDI0IDI0IiBmaWxsPSJub25lIiBzdHJva2U9ImN1cnJlbnRDb2xvciIgc3Ryb2tlLXdpZHRoPSIyIiBzdHJva2UtbGluZWNhcD0icm91bmQiIHN0cm9rZS1saW5lam9pbj0icm91bmQiIGFyaWEtaGlkZGVuPSJ0cnVlIj48cGF0aCBkPSJNMjAgNiA5IDE3bC01LTUiIC8+PC9zdmc+)
R

![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC1jb21ib2JveF9faXRlbS1jaGVjayIgdmlld2JveD0iMCAwIDI0IDI0IiBmaWxsPSJub25lIiBzdHJva2U9ImN1cnJlbnRDb2xvciIgc3Ryb2tlLXdpZHRoPSIyIiBzdHJva2UtbGluZWNhcD0icm91bmQiIHN0cm9rZS1saW5lam9pbj0icm91bmQiIGFyaWEtaGlkZGVuPSJ0cnVlIj48cGF0aCBkPSJNMjAgNiA5IDE3bC01LTUiIC8+PC9zdmc+)
Python

![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC1jb21ib2JveF9faXRlbS1jaGVjayIgdmlld2JveD0iMCAwIDI0IDI0IiBmaWxsPSJub25lIiBzdHJva2U9ImN1cnJlbnRDb2xvciIgc3Ryb2tlLXdpZHRoPSIyIiBzdHJva2UtbGluZWNhcD0icm91bmQiIHN0cm9rZS1saW5lam9pbj0icm91bmQiIGFyaWEtaGlkZGVuPSJ0cnVlIj48cGF0aCBkPSJNMjAgNiA5IDE3bC01LTUiIC8+PC9zdmc+)
Julia

![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC1jb21ib2JveF9faXRlbS1jaGVjayIgdmlld2JveD0iMCAwIDI0IDI0IiBmaWxsPSJub25lIiBzdHJva2U9ImN1cnJlbnRDb2xvciIgc3Ryb2tlLXdpZHRoPSIyIiBzdHJva2UtbGluZWNhcD0icm91bmQiIHN0cm9rZS1saW5lam9pbj0icm91bmQiIGFyaWEtaGlkZGVuPSJ0cnVlIj48cGF0aCBkPSJNMjAgNiA5IDE3bC01LTUiIC8+PC9zdmc+)
JavaScript

![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC1jb21ib2JveF9faXRlbS1jaGVjayIgdmlld2JveD0iMCAwIDI0IDI0IiBmaWxsPSJub25lIiBzdHJva2U9ImN1cnJlbnRDb2xvciIgc3Ryb2tlLXdpZHRoPSIyIiBzdHJva2UtbGluZWNhcD0icm91bmQiIHN0cm9rZS1saW5lam9pbj0icm91bmQiIGFyaWEtaGlkZGVuPSJ0cnVlIj48cGF0aCBkPSJNMjAgNiA5IDE3bC01LTUiIC8+PC9zdmc+)
Rust

No results.

Code


    shad_combobox("lang", label = "Language", choices = c("R", "Python", "Julia", "JavaScript", "Rust"), placeholder = "Search languages…")

## Input OTP

A segmented one-time-code field. `groups` splits the digits with a
separator.

Verification code

![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC1pY29uIiB2aWV3Ym94PSIwIDAgMjQgMjQiIGZpbGw9Im5vbmUiIHN0cm9rZT0iY3VycmVudENvbG9yIiBzdHJva2Utd2lkdGg9IjIiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCI+PHBhdGggZD0iTTUgMTJoMTQiIC8+PC9zdmc+)

Code


    shad_input_otp("code", length = 6, groups = c(3, 3), label = "Verification code")

## Date picker

[`shad_date_picker()`](https://orijitghosh.github.io/shadshiny/reference/shad_date_picker.md)
opens a calendar popover; `mode = "range"` selects a span.
[`shad_calendar()`](https://orijitghosh.github.io/shadshiny/reference/shad_calendar.md)
embeds the same calendar inline.

Due date

![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC1pY29uIiB2aWV3Ym94PSIwIDAgMjQgMjQiIGZpbGw9Im5vbmUiIHN0cm9rZT0iY3VycmVudENvbG9yIiBzdHJva2Utd2lkdGg9IjIiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCIgYXJpYS1oaWRkZW49InRydWUiPjxwYXRoIGQ9Ik04IDJ2NCIgLz48cGF0aCBkPSJNMTYgMnY0IiAvPjxyZWN0IHdpZHRoPSIxOCIgaGVpZ2h0PSIxOCIgeD0iMyIgeT0iNCIgcng9IjIiIC8+PHBhdGggZD0iTTMgMTBoMTgiIC8+PC9zdmc+)Pick
a date

Trip

![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC1pY29uIiB2aWV3Ym94PSIwIDAgMjQgMjQiIGZpbGw9Im5vbmUiIHN0cm9rZT0iY3VycmVudENvbG9yIiBzdHJva2Utd2lkdGg9IjIiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCIgYXJpYS1oaWRkZW49InRydWUiPjxwYXRoIGQ9Ik04IDJ2NCIgLz48cGF0aCBkPSJNMTYgMnY0IiAvPjxyZWN0IHdpZHRoPSIxOCIgaGVpZ2h0PSIxOCIgeD0iMyIgeT0iNCIgcng9IjIiIC8+PHBhdGggZD0iTTMgMTBoMTgiIC8+PC9zdmc+)Start
– end

Code


    shad_date_picker("due", label = "Due date", placeholder = "Pick a date")
    shad_date_picker("span", label = "Trip", mode = "range", placeholder = "Start – end")

The header steps one month at a time, which is fine for a due date and
painful for a birth date. `caption_layout = "dropdown"` swaps the month
and year for selects, and `year_range` bounds the year list (defaults:
the years of `min`/`max`, else 100 back and 10 forward).

Date of birth

![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC1pY29uIiB2aWV3Ym94PSIwIDAgMjQgMjQiIGZpbGw9Im5vbmUiIHN0cm9rZT0iY3VycmVudENvbG9yIiBzdHJva2Utd2lkdGg9IjIiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCIgYXJpYS1oaWRkZW49InRydWUiPjxwYXRoIGQ9Ik04IDJ2NCIgLz48cGF0aCBkPSJNMTYgMnY0IiAvPjxyZWN0IHdpZHRoPSIxOCIgaGVpZ2h0PSIxOCIgeD0iMyIgeT0iNCIgcng9IjIiIC8+PHBhdGggZD0iTTMgMTBoMTgiIC8+PC9zdmc+)Pick
a date

Code


    shad_date_picker("dob", label = "Date of birth", caption_layout = "dropdown", year_range = c(1900, 2026))
    shad_calendar("born", month = "1993-06", caption_layout = "dropdown-years", year_range = c(1900, 2026))

## Form field & input group

[`shad_form_field()`](https://orijitghosh.github.io/shadshiny/reference/shad_form_field.md)
wraps any control with a label, description, required marker and error
slot.
[`shad_input_group()`](https://orijitghosh.github.io/shadshiny/reference/shad_input_group.md)
fuses affixes — icons, text, buttons — onto an input.

Website \*

No https:// needed.

\$ USD

Go

Code


    shad_form_field(shad_input("site", placeholder = "example.com"), label = "Website", description = "No https:// needed.", required = TRUE)
    shad_input_group(shad_input_group_addon("$"), shad_input("amount", placeholder = "0.00"), shad_input_group_addon("USD", align = "inline-end"))
    shad_input_group(shad_input("q", placeholder = "Search…"), shad_input_group_button("Go", variant = "default"))

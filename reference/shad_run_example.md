# Run a bundled shadshiny example app

Run a bundled shadshiny example app

## Usage

``` r
shad_run_example(example = "kitchen-sink")
```

## Arguments

- example:

  Example app directory name under `inst/examples`. One of:

  `"kitchen-sink"`

  :   (default) the full R-built demo of every component.

  `"00-static-parity"`

  :   hand-written anatomy reference, for visual parity checks.

  `"01-auth-onboarding"`

  :   sign-in / create-account flow with a 4-step onboarding wizard, 2FA
      (input-OTP) and social sign-in.

  `"02-analytics-dashboard"`

  :   admin console: sidebar, menubar, command palette, KPI cards,
      resizable chart split and a searchable team directory.

  `"03-support-chat"`

  :   support inbox with a stick-to-bottom transcript, quick replies,
      attachment popover and a simulated assistant.

  `"04-storefront"`

  :   product page: carousel, variant pickers, add-to-cart sheet, tabbed
      details and reviews pagination.

  `"05-settings-profile"`

  :   account settings with live theming, availability checks, 2FA and
      destructive alert-dialogs.

  `"06-docs-reader"`

  :   documentation site: sidebar nav, ⌘K search, resizable article/TOC
      split, rich typography and tabbed code examples.

  `"07-data-explorer"`

  :   [`shad_data_table()`](https://orijitghosh.github.io/shadshiny/reference/shad_data_table.md)
      with KPI value boxes and theme-following plots.

  `"08-llm-chat"`

  :   streaming
      [`shad_chat_server()`](https://orijitghosh.github.io/shadshiny/reference/shad_chat_server.md);
      swap the handler for an ellmer stream to go live (experimental).

  `"09-app-shell"`

  :   [`shad_page_sidebar()`](https://orijitghosh.github.io/shadshiny/reference/shad_page_sidebar.md)
      with the layout primitives, sparklines, a ⌘K palette that drives
      navigation, and dialogs built in the server.

  The numbered apps are real-world examples that together exercise the
  whole component library.

## Value

Called for its side effect (launches a Shiny app).

## See also

Other shadshiny utilities:
[`shad_icon()`](https://orijitghosh.github.io/shadshiny/reference/shad_icon.md),
[`shad_icon_names()`](https://orijitghosh.github.io/shadshiny/reference/shad_icon_names.md),
[`shad_icon_raw()`](https://orijitghosh.github.io/shadshiny/reference/shad_icon_raw.md),
[`shadshiny_deps()`](https://orijitghosh.github.io/shadshiny/reference/shadshiny_deps.md)

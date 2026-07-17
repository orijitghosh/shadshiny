<!-- FILE: inst/assets/components/accordion/README.md -->
# accordion (Tier 3)

## Anatomy
```
div[data-shad=accordion][data-type=single|multiple][data-collapsible?]
└─ div.shad-accordion__item[data-value][data-open?] ×n
   ├─ button.shad-accordion__trigger (+ svg.shad-accordion__chevron)
   └─ div.shad-accordion__content
      └─ div.shad-accordion__content-inner   (padding lives here, not on the animated box)
```

## Data-attribute API
`data-type` single (default) / multiple · `data-collapsible` (single mode: open item may be closed) · `data-open` initial open item(s) · `data-value` item id · `data-state` open/closed (runtime, on item/trigger/content).

## Height animation
JS measures `scrollHeight` into `--shad-collapsible-height`, then `shad-collapse-down`/`-up` keyframes run; Presence hides after the exit finishes.

## Methods / Events
`getValue()` → single: `value|null`; multiple: `string[]`. `setValue(v)` (string or array). `destroy()`. `shad:change {value}`.

## Keyboard
↑/↓ move across triggers (no loop), Home/End, Enter/Space toggles.

## A11y
`aria-expanded` on triggers, content `role=region` + `aria-labelledby`, chevron rotates via `data-state`.

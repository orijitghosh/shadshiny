<!-- FILE: inst/assets/components/collapsible/README.md -->
# collapsible (Tier 3)

## Anatomy
```
div[data-shad=collapsible][data-open?]
├─ *.shad-collapsible__trigger        (anywhere inside root)
└─ div.shad-collapsible__content
```

## Data-attribute API
`data-open` initial state · `data-state="open|closed"` on root + content (runtime).

## Methods / Events
`getValue()/setValue(bool)/open()/close()/isOpen/destroy()`; `shad:open`/`shad:close`/`shad:change {value:bool}`.

## Keyboard / A11y
Enter/Space on trigger toggles (native button). `aria-expanded` + `aria-controls`. Height animates via `--shad-collapsible-height` + collapse keyframes.

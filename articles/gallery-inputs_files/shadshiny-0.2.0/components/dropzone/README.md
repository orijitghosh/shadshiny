<!-- FILE: inst/assets/components/dropzone/README.md -->
# dropzone (Tier 2, V2)

Drag-and-drop file picker. **No upload logic** — emits `shad:files` with the raw `File` objects; the host (Shiny binding / FileReader) does the transfer and drives per-file lifecycle via `setState()`. File rows **compose attachment/** (load `attachment.css` first).

## Anatomy
```
div.shad-dropzone[data-shad=dropzone]
│    [data-multiple] [data-accept=".csv,image/*"] [data-max-size=bytes] [data-disabled]
│    [data-drag (transient, while dragging over)]
├─ div.shad-dropzone__zone[tabindex=0][role=button][aria-label]
│  ├─ span.shad-dropzone__icon > svg
│  ├─ div.shad-dropzone__hint  (<strong> = the "browse" emphasis)
│  └─ div.shad-dropzone__meta  (optional constraints line)
├─ input[type=file].shad-dropzone__input   (visually hidden; mirrors multiple/accept)
└─ div.shad-dropzone__files                (JS-filled attachment rows)
   └─ div.shad-attachment.shad-attachment--sm[data-name][data-state?]
      (…standard attachment anatomy; remove action included)
```

## Data-attribute API
| Attribute | On | Effect |
|---|---|---|
| `data-multiple` | root | multi-file; without it a new file replaces the current one |
| `data-accept` | root | comma list: `.ext`, `type/*`, or full MIME |
| `data-max-size` | root | per-file byte cap |
| `data-disabled` | root | inert zone (also `disabled` the input + `tabindex=-1`) |

Rejected files (type/size/duplicate) render as `data-state="error"` rows with the reason in the description — they are NOT in the value.

## Methods / Events
| Member | Description |
|---|---|
| `getValue()` | accepted file names `[]` |
| `getFiles()` | raw `File[]` |
| `setState(name, state, desc)` | drive a row through `uploading` / `processing` / `error` / `null` (done) + description text |
| `clear()` | empty the list |
| `destroy()` | unbind |
| `shad:files` | `{files: [{name,size,type,file}], rejected: [{name,size,type,reason}]}` — fires per add |
| `shad:change` | `{value: acceptedNames}` — fires on add/remove/clear |

## Keyboard
Zone is a `role=button` tab stop; Enter/Space opens the native picker. Row remove buttons are standard tabbable buttons.

## A11y
Zone carries a descriptive `aria-label`; the native input stays in the DOM (visually hidden) as the actual picker. Drag feedback is visual (`data-drag`); the click/keyboard path is fully equivalent. Upload states reuse attachment's animated `data-state` styling (reduced-motion aware).

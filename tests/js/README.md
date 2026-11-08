# JS unit tests

Unit tests for `inst/assets` – the runtime and the component behaviours – run
in jsdom with [vitest](https://vitest.dev).

```bash
npm install
npm test          # or: npm run test:watch
```

Node is a **development** dependency. It is not in `DESCRIPTION`, it is not
needed to install or use the R package, and everything here is excluded from
the build tarball via `.Rbuildignore`.

## How the harness works

The assets are plain scripts that assign to `window.shad` – no modules, no build
step. `helpers.js` does what a `<script>` tag does: reads the file and evaluates
it in the current jsdom window. So a test reads like the real page:

```js
const shad = loadRuntime("command");        // runtime + one component
const root = mount('<div data-shad="command">…</div>');
const inst = shad.get(root);
```

Each test file gets a fresh window, which matters: the runtime holds
module-level state (the component registry, the dismiss stack).

## What belongs here, and what does not

jsdom has no layout engine. `getBoundingClientRect()` returns zeros,
`offsetWidth` is 0, and `scrollIntoView` is a stub. Use `rect(el, box)` to stub
a box when the logic under test reads geometry – that is enough for
"is this out of view" arithmetic, but not for anything that depends on real
layout, painting, or animation timing.

Those belong in the `shinytest2` suites (`tests/testthat/test-shinytest2-*.R`),
which drive real Chrome through a real Shiny app.

Split roughly:

| here (jsdom)                                   | shinytest2 (Chrome)                  |
|------------------------------------------------|--------------------------------------|
| value in/out, `shad:change` payloads            | Shiny input bindings end to end      |
| keyboard maps, aria wiring, `data-state`        | real focus, real scrolling, animation|
| lifecycle: init, destroy, insert, move          | server round trips, `update_*()`     |

<!-- FILE: inst/assets/components/questionnaire/README.md -->
# questionnaire (experimental)

An accessible, bookmarkable sequence of native `fieldset` questions. The R
wrapper is `shad_questionnaire()` and each definition is `shad_question()`.
The input value is `{active, answers, skipped, complete}` with a 1-based active
question index and named answer list.

## Anatomy

```text
div.shad-questionnaire[data-shad=questionnaire]
├─ div.shad-questionnaire__progress[role=progressbar]
├─ div.shad-questionnaire__questions
│  └─ fieldset.shad-questionnaire__question[data-questionnaire-question]
│     ├─ legend
│     ├─ div.shad-questionnaire__description (optional)
│     ├─ native radio/checkbox inputs or native text input
│     └─ div[data-question-error][role=alert]
├─ div[data-questionnaire-status][role=status]
└─ div.shad-questionnaire__actions
   ├─ button[data-questionnaire-previous]
   ├─ button[data-questionnaire-next]
   ├─ button[data-questionnaire-skip]
   └─ button[data-questionnaire-submit]
```

All questions render once. Conditions are named equality data in
`data-show-if`; hidden questions are `hidden` and `inert`, retain their answer,
and do not count toward visible progress or validation. Text is inserted through
native controls and `textContent`; the runtime evaluates no user code.

The public updater is `update_shad_questionnaire()` and uses the generic
`makeShadBinding("questionnaire")` contract. Its `reset` operation invokes the
instance reset method; the application remains responsible for persistence and
transport.

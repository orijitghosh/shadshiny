# Questionnaire input

A bookmarkable, accessible sequence of single-choice, multiple-choice,
and freeform questions. The bound Shiny value is a JSON-safe list with
`active` (1-based index), `answers` (named list), `skipped` (question
names), and `complete` (logical). All questions remain in the DOM;
inactive or conditionally hidden questions are hidden and inert.

## Usage

``` r
shad_questionnaire(
  inputId,
  ...,
  value = NULL,
  progress_label = "Question %s of %s",
  previous_label = "Previous",
  next_label = "Next",
  skip_label = "Skip",
  submit_label = "Submit",
  class = NULL
)
```

## Arguments

- inputId:

  Input id.

- ...:

  [`shad_question()`](https://orijitghosh.github.io/shadshiny/reference/shad_question.md)
  definitions.

- value:

  Initial or restored state, shaped as
  `list(active, answers, skipped, complete)`.

- progress_label:

  Text format with two `%s` values: current visible question and visible
  question count.

- previous_label:

  Previous-button label.

- next_label:

  Next-button label.

- skip_label:

  Skip-button label.

- submit_label:

  Submit-button label.

- class:

  Extra CSS classes.

## Value

A questionnaire tag, bound as a Shiny input.

## See also

[`update_shad_questionnaire()`](https://orijitghosh.github.io/shadshiny/reference/update_shad_questionnaire.md)

Other shadshiny questionnaire:
[`shad_question()`](https://orijitghosh.github.io/shadshiny/reference/shad_question.md),
[`update_shad_questionnaire()`](https://orijitghosh.github.io/shadshiny/reference/update_shad_questionnaire.md)

## Examples

``` r
shad_questionnaire(
  "onboarding",
  shad_question("plan", "Choose a plan", choices = c(Free = "free", Pro = "pro")),
  shad_question("notes", "Anything else?", type = "text", required = FALSE)
)
#> <div class="shad-questionnaire" id="onboarding" data-shad="questionnaire" data-active="1" data-value="{&quot;active&quot;:1,&quot;answers&quot;:[],&quot;skipped&quot;:[],&quot;complete&quot;:false}" data-progress-label="Question %s of %s" data-previous-label="Previous" data-next-label="Next" data-skip-label="Skip" data-submit-label="Submit">
#>   <div class="shad-questionnaire__progress-wrap">
#>     <div class="shad-questionnaire__progress" role="progressbar" aria-valuemin="0" aria-valuemax="2" aria-valuenow="1" aria-label="Question 1 of 2">
#>       <span class="shad-questionnaire__progress-label">Question 1 of 2</span>
#>     </div>
#>   </div>
#>   <div class="shad-questionnaire__questions">
#>     <fieldset class="shad-questionnaire__question" id="onboarding-plan-question" data-questionnaire-question data-question-name="plan" data-question-index="1" data-question-type="single" data-required>
#>       <legend id="onboarding-plan-legend" tabindex="-1">Choose a plan</legend>
#>       <div class="shad-questionnaire__choices">
#>         <label class="shad-questionnaire__choice-label" for="onboarding-plan-1">
#>           <input class="shad-questionnaire__choice" id="onboarding-plan-1" type="radio" name="onboarding-plan" value="Free" aria-describedby="onboarding-plan-error"/>
#>           <span class="shad-questionnaire__choice-text">free</span>
#>         </label>
#>         <label class="shad-questionnaire__choice-label" for="onboarding-plan-2">
#>           <input class="shad-questionnaire__choice" id="onboarding-plan-2" type="radio" name="onboarding-plan" value="Pro" aria-describedby="onboarding-plan-error"/>
#>           <span class="shad-questionnaire__choice-text">pro</span>
#>         </label>
#>       </div>
#>       <div id="onboarding-plan-error" class="shad-questionnaire__error" data-question-error role="alert" hidden></div>
#>     </fieldset>
#>     <fieldset class="shad-questionnaire__question" id="onboarding-notes-question" data-questionnaire-question data-question-name="notes" data-question-index="2" data-question-type="text" hidden inert>
#>       <legend id="onboarding-notes-legend" tabindex="-1">Anything else?</legend>
#>       <input class="shad-questionnaire__text shad-input" id="onboarding-notes" type="text" name="onboarding-notes" value="" aria-labelledby="onboarding-notes-legend" aria-describedby="onboarding-notes-error"/>
#>       <div id="onboarding-notes-error" class="shad-questionnaire__error" data-question-error role="alert" hidden></div>
#>     </fieldset>
#>   </div>
#>   <div class="shad-questionnaire__status" data-questionnaire-status role="status" aria-live="polite" aria-atomic="true"></div>
#>   <div class="shad-questionnaire__actions">
#>     <button type="button" class="shad-btn shad-btn--outline" data-questionnaire-previous>Previous</button>
#>     <button type="button" class="shad-btn shad-btn--default" data-questionnaire-next>Next</button>
#>     <button type="button" class="shad-btn shad-btn--ghost" data-questionnaire-skip>Skip</button>
#>     <button type="button" class="shad-btn shad-btn--default" data-questionnaire-submit hidden>Submit</button>
#>   </div>
#> </div>
```

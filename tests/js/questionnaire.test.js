import { describe, expect, test, beforeEach } from "vitest";
import { loadRuntime, mount, key } from "./helpers.js";

let shad;

beforeEach(() => {
  document.body.innerHTML = "";
  delete window.shad;
  shad = loadRuntime("questionnaire");
});

function questionMarkup(value = {}) {
  return `<div id="survey" data-shad="questionnaire"
      data-value='${JSON.stringify({
        active: 1, answers: {}, skipped: [], complete: false, ...value
      })}' data-progress-label="Question %s of %s">
    <div class="shad-questionnaire__progress" role="progressbar"></div>
    <div class="shad-questionnaire__questions">
      <fieldset data-questionnaire-question data-question-name="direction"
                data-question-type="single" data-required="true"
                data-shortcuts='{"data":"1","rtl":"2"}'>
        <legend tabindex="-1">What should be built?</legend>
        <label><input type="radio" name="direction" value="data">Server table</label>
        <label><input type="radio" name="direction" value="rtl">RTL</label>
        <div data-question-error role="alert" hidden></div>
      </fieldset>
      <fieldset data-questionnaire-question data-question-name="details"
                data-question-type="text" data-required="false" data-skippable>
        <legend tabindex="-1">Tell us more</legend>
        <input type="text" name="details" aria-label="Tell us more">
        <div data-question-error role="alert" hidden></div>
      </fieldset>
    </div>
    <div data-questionnaire-status role="status" aria-live="polite"></div>
    <button type="button" data-questionnaire-previous>Previous</button>
    <button type="button" data-questionnaire-next>Next</button>
    <button type="button" data-questionnaire-skip>Skip</button>
    <button type="button" data-questionnaire-submit>Submit</button>
  </div>`;
}

describe("questionnaire state machine", () => {
  test("blocks required navigation and focuses the first answer", () => {
    const root = mount(questionMarkup());
    root.querySelector("[data-questionnaire-next]").click();

    expect(root.querySelector("[data-question-error]").hidden).toBe(false);
    expect(document.activeElement.name).toBe("direction");
    expect(root.querySelector('input[value="data"]').getAttribute("aria-invalid")).toBe("true");
    expect(shad.get(root).getValue()).toEqual({
      active: 1, answers: {}, skipped: [], complete: false
    });
  });

  test("supports text answer and completion", () => {
    const root = mount(questionMarkup());
    const instance = shad.get(root);
    root.querySelector('input[value="data"]').click();
    root.querySelector("[data-questionnaire-next]").click();
    root.querySelector('input[name="details"]').value = "Details";
    root.querySelector('input[name="details"]').dispatchEvent(
      new window.Event("input", { bubbles: true })
    );
    root.querySelector("[data-questionnaire-submit]").click();

    expect(instance.getValue()).toEqual({
      active: 2,
      answers: { direction: "data", details: "Details" },
      skipped: [], complete: true
    });
    expect(root.querySelector("[data-questionnaire-status]").textContent).toMatch(/complete/i);
  });

  test("stores multiple checkbox answers as a JSON-safe array", () => {
    const root = mount(`
      <div data-shad="questionnaire" data-value='{"active":1,"answers":{},"skipped":[],"complete":false}'>
        <fieldset data-questionnaire-question data-question-name="topics"
                  data-question-type="multiple" data-required>
          <legend tabindex="-1">Topics</legend>
          <label><input type="checkbox" name="topics" value="data">Data</label>
          <label><input type="checkbox" name="topics" value="rtl">RTL</label>
          <div data-question-error role="alert" hidden></div>
        </fieldset>
        <button type="button" data-questionnaire-previous>Previous</button>
        <button type="button" data-questionnaire-next>Next</button>
        <button type="button" data-questionnaire-skip>Skip</button>
        <button type="button" data-questionnaire-submit>Submit</button>
      </div>`);
    const instance = shad.get(root);
    root.querySelector('input[value="data"]').click();
    root.querySelector('input[value="rtl"]').click();
    expect(instance.getValue().answers.topics).toEqual(["data", "rtl"]);
  });

  test("explicit skip records the question and completes optional flow", () => {
    const root = mount(questionMarkup());
    const instance = shad.get(root);
    root.querySelector('input[value="data"]').click();
    root.querySelector("[data-questionnaire-next]").click();
    root.querySelector("[data-questionnaire-skip]").click();
    expect(instance.getValue().skipped).toEqual(["details"]);
    expect(instance.getValue().complete).toBe(true);
  });

  test("shortcut activation selects a choice and conditions preserve hidden answers", () => {
    const root = mount(questionMarkup());
    const instance = shad.get(root);
    key(root, "1");
    expect(instance.getValue().answers.direction).toBe("data");

    root.querySelector("[data-questionnaire-next]").click();
    root.querySelector('input[name="details"]').value = "kept";
    root.querySelector('input[name="details"]').dispatchEvent(
      new window.Event("input", { bubbles: true })
    );
    instance.setValue({ active: 1, answers: { direction: "rtl", details: "kept" } });
    expect(root.querySelector('[data-question-name="details"]').hidden).toBe(true);
    expect(instance.getValue().answers.details).toBe("kept");
  });

  test("setErrors, reset, previous navigation, and teardown are exposed", () => {
    const root = mount(questionMarkup({ answers: { direction: "data" }, active: 2 }));
    const instance = shad.get(root);
    instance.setErrors({ details: "Custom error" });
    expect(root.querySelector('[data-question-name="details"] [data-question-error]').textContent)
      .toBe("Custom error");
    expect(root.querySelector('[data-question-name="details"] input').getAttribute("aria-invalid"))
      .toBe("true");
    instance.setErrors({ details: "<img src=x onerror=alert(1)>" });
    const unsafeError = root.querySelector('[data-question-name="details"] [data-question-error]');
    expect(unsafeError.textContent).toBe("<img src=x onerror=alert(1)>");
    expect(unsafeError.innerHTML).toBe("&lt;img src=x onerror=alert(1)&gt;");
    instance.goTo(1);
    expect(instance.getValue().active).toBe(1);
    instance.reset();
    expect(instance.getValue()).toEqual({ active: 1, answers: {}, skipped: [], complete: false });
    shad.destroy(root);
    expect(shad.get(root)).toBeNull();
  });
});

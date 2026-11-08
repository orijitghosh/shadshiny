/* shadshiny – questionnaire behavior.
   The root contains every fieldset once. The reducer owns answer state and
   every user action goes through dispatch(), so Shiny receives one stable
   JSON-safe value shape: {active, answers, skipped, complete}. */
(function () {
  "use strict";

  shad.register("questionnaire", function (root) {
    var questions = Array.from(root.querySelectorAll("[data-questionnaire-question]"));
    var progress = root.querySelector(".shad-questionnaire__progress");
    var progressLabel = root.querySelector(".shad-questionnaire__progress-label");
    var status = root.querySelector("[data-questionnaire-status]");
    var previous = root.querySelector("[data-questionnaire-previous]");
    var next = root.querySelector("[data-questionnaire-next]");
    var skip = root.querySelector("[data-questionnaire-skip]");
    var submit = root.querySelector("[data-questionnaire-submit]");
    var listeners = [];
    var errors = {};
    var destroyed = false;

    function parseJson(value, fallback) {
      if (!value) return fallback;
      try { return JSON.parse(value); } catch (e) { return fallback; }
    }

    function questionInfo(panel) {
      return {
        panel: panel,
        name: panel.getAttribute("data-question-name") || "",
        type: panel.getAttribute("data-question-type") || "single",
        required: panel.hasAttribute("data-required") &&
          panel.getAttribute("data-required") !== "false",
        skippable: panel.hasAttribute("data-skippable") &&
          panel.getAttribute("data-skippable") !== "false",
        showIf: parseJson(panel.getAttribute("data-show-if"), {}),
        shortcuts: parseJson(panel.getAttribute("data-shortcuts"), {})
      };
    }

    var info = questions.map(questionInfo);
    var initial = parseJson(root.getAttribute("data-value"), {});
    var state = {
      active: Number.isInteger(Number(initial.active)) ? Number(initial.active) : 1,
      answers: initial.answers && typeof initial.answers === "object" ? initial.answers : {},
      skipped: Array.isArray(initial.skipped) ? initial.skipped.slice() : [],
      complete: initial.complete === true
    };

    function cloneAnswers(answers) {
      var copy = {};
      Object.keys(answers || {}).forEach(function (name) {
        copy[name] = Array.isArray(answers[name]) ? answers[name].slice() : answers[name];
      });
      return copy;
    }

    function valueFor(question) {
      return state.answers[question.name];
    }

    function matches(actual, expected) {
      if (actual === null || typeof actual === "undefined") return false;
      if (Array.isArray(actual)) return actual.map(String).indexOf(String(expected)) !== -1;
      return String(actual) === String(expected);
    }

    function isVisible(question) {
      var conditions = question.showIf || {};
      return Object.keys(conditions).every(function (name) {
        var parent = info.find(function (item) { return item.name === name; });
        return parent && matches(state.answers[name], conditions[name]);
      });
    }

    function visibleIndices() {
      return info.map(function (question, index) {
        return isVisible(question) ? index : -1;
      }).filter(function (index) { return index >= 0; });
    }

    function activeIndex(visible) {
      var wanted = Math.max(0, Math.min(info.length - 1, state.active - 1));
      if (visible.indexOf(wanted) !== -1) return wanted;
      return visible.length ? visible[Math.min(visible.length - 1, wanted)] : 0;
    }

    function answered(question) {
      var answer = valueFor(question);
      return question.type === "multiple"
        ? Array.isArray(answer) && answer.length > 0
        : answer !== null && typeof answer !== "undefined" && String(answer).length > 0;
    }

    function formatProgress(current, total) {
      var label = root.getAttribute("data-progress-label") || "Question %s of %s";
      return label.replace("%s", String(current)).replace("%s", String(total));
    }

    function focusQuestion(index, invalid) {
      var panel = info[index] && info[index].panel;
      if (!panel) return;
      var target = invalid
        ? panel.querySelector("input:not([disabled])")
        : panel.querySelector("legend") || panel.querySelector("input:not([disabled])");
      if (target && typeof target.focus === "function") target.focus({ preventScroll: true });
    }

    function setError(question, message) {
      if (message) errors[question.name] = String(message);
      else delete errors[question.name];
    }

    function validate(question) {
      if (!question.required || state.skipped.indexOf(question.name) !== -1) {
        setError(question, null);
        return true;
      }
      if (answered(question)) {
        setError(question, null);
        return true;
      }
      setError(question, "This question is required.");
      return false;
    }

    function validateVisible(visible) {
      for (var i = 0; i < visible.length; i += 1) {
        var question = info[visible[i]];
        if (!validate(question)) return visible[i];
      }
      return -1;
    }

    function emitChange() {
      if (destroyed) return;
      shad.util.emit(root, "shad:change", { value: getValue() });
    }

    function getValue() {
      return {
        active: state.active,
        answers: cloneAnswers(state.answers),
        skipped: state.skipped.slice(),
        complete: state.complete
      };
    }

    function render() {
      if (destroyed) return;
      var visible = visibleIndices();
      var active = activeIndex(visible);
      state.active = active + 1;
      info.forEach(function (question, index) {
        var current = index === active && isVisible(question);
        var panel = question.panel;
        panel.hidden = !current;
        panel.toggleAttribute("inert", !current);
        panel.setAttribute("data-state", current ? "active" : "inactive");
        if (errors[question.name]) panel.setAttribute("data-invalid", "");
        else panel.removeAttribute("data-invalid");

        panel.querySelectorAll("input").forEach(function (input) {
          if (errors[question.name]) input.setAttribute("aria-invalid", "true");
          else input.removeAttribute("aria-invalid");
        });

        var answer = valueFor(question);
        panel.querySelectorAll('input[type="radio"]').forEach(function (input) {
          input.checked = question.type === "single" && String(input.value) === String(answer);
        });
        panel.querySelectorAll('input[type="checkbox"]').forEach(function (input) {
          input.checked = question.type === "multiple" && Array.isArray(answer) &&
            answer.map(String).indexOf(String(input.value)) !== -1;
        });
        panel.querySelectorAll('input[type="text"]').forEach(function (input) {
          input.value = answer === null || typeof answer === "undefined" ? "" : String(answer);
        });
        var error = panel.querySelector("[data-question-error]");
        if (error) {
          error.textContent = errors[question.name] || "";
          error.hidden = !errors[question.name];
        }
      });

      var position = visible.indexOf(active) + 1;
      var total = visible.length;
      if (progress) {
        progress.setAttribute("aria-valuemax", String(total));
        progress.setAttribute("aria-valuenow", String(position));
        progress.setAttribute("aria-label", formatProgress(position, total));
      }
      if (progressLabel) progressLabel.textContent = formatProgress(position, total);
      if (previous) {
        previous.textContent = root.getAttribute("data-previous-label") || "Previous";
        previous.disabled = position <= 1;
      }
      if (next) {
        next.textContent = root.getAttribute("data-next-label") || "Next";
        next.hidden = state.complete || position >= total;
      }
      if (skip) {
        skip.textContent = root.getAttribute("data-skip-label") || "Skip";
        skip.hidden = state.complete || !info[active] || !info[active].skippable;
      }
      if (submit) {
        submit.textContent = root.getAttribute("data-submit-label") || "Submit";
        submit.hidden = state.complete || position !== total;
      }
      if (status && state.complete) status.textContent = "Complete";
      root.setAttribute("data-active", String(state.active));
      root.setAttribute("data-value", JSON.stringify(getValue()));
    }

    function dispatch(action, emit) {
      if (destroyed) return;
      var question;
      var visible;
      var current;
      switch (action.type) {
        case "answer":
          question = info.find(function (item) { return item.name === action.name; });
          if (!question) break;
          state.answers[question.name] = question.type === "multiple"
            ? Array.from(new Set((action.value || []).map(String)))
            : String(action.value);
          state.skipped = state.skipped.filter(function (name) { return name !== question.name; });
          state.complete = false;
          setError(question, null);
          render();
          break;
        case "goTo":
          visible = visibleIndices();
          if (!visible.length) break;
          current = Math.max(1, Math.min(info.length, Number(action.index) || 1)) - 1;
          if (visible.indexOf(current) === -1) {
            current = visible[Math.max(0, Math.min(visible.length - 1, current))];
          }
          state.active = current + 1;
          state.complete = false;
          render();
          if (action.focus !== false) focusQuestion(current, false);
          break;
        case "skip":
          current = activeIndex(visibleIndices());
          question = info[current];
          if (!question || !question.skippable) break;
          if (state.skipped.indexOf(question.name) === -1) state.skipped.push(question.name);
          setError(question, null);
          visible = visibleIndices();
          var nextIndex = visible.find(function (index) { return index > current; });
          if (typeof nextIndex === "undefined") {
            state.complete = validateVisible(visible) === -1;
          } else {
            state.active = nextIndex + 1;
          }
          render();
          if (nextIndex !== undefined) focusQuestion(nextIndex, false);
          break;
        case "submit":
          visible = visibleIndices();
          current = validateVisible(visible);
          if (current !== -1) {
            render();
            focusQuestion(current, true);
            break;
          }
          state.complete = true;
          render();
          if (status && typeof status.focus === "function") {
            status.setAttribute("tabindex", "-1");
            status.focus({ preventScroll: true });
          }
          break;
        case "setValue":
          if (action.value && typeof action.value === "object") {
            if (Object.prototype.hasOwnProperty.call(action.value, "active")) {
              state.active = Number(action.value.active) || 1;
            }
            if (Object.prototype.hasOwnProperty.call(action.value, "answers") &&
                action.value.answers && typeof action.value.answers === "object") {
              state.answers = cloneAnswers(action.value.answers);
            }
            if (Array.isArray(action.value.skipped)) state.skipped = action.value.skipped.slice();
            if (Object.prototype.hasOwnProperty.call(action.value, "complete")) {
              state.complete = action.value.complete === true;
            }
          }
          render();
          break;
        case "setErrors":
          errors = action.value && typeof action.value === "object" ? { ...action.value } : {};
          render();
          break;
        case "reset":
          state = { active: 1, answers: {}, skipped: [], complete: false };
          errors = {};
          render();
          break;
        default:
          break;
      }
      if (emit) emitChange();
    }

    function listen(element, event, handler) {
      if (!element) return;
      element.addEventListener(event, handler);
      listeners.push([element, event, handler]);
    }

    info.forEach(function (question) {
      question.panel.querySelectorAll("input").forEach(function (input) {
        listen(input, question.type === "text" ? "input" : "change", function () {
          var value = question.type === "multiple"
            ? Array.from(question.panel.querySelectorAll('input[type="checkbox"]:checked')).map(function (item) { return item.value; })
            : input.value;
          dispatch({ type: "answer", name: question.name, value: value }, true);
        });
      });
    });

    listen(root, "keydown", function (event) {
      var active = activeIndex(visibleIndices());
      var question = info[active];
      if (!question || !question.shortcuts) return;
      var match = Object.keys(question.shortcuts).find(function (value) {
        return String(question.shortcuts[value]) === String(event.key);
      });
      if (typeof match === "undefined") return;
      event.preventDefault();
      if (question.type === "multiple") {
        var current = Array.isArray(valueFor(question)) ? valueFor(question).slice() : [];
        var at = current.indexOf(match);
        if (at === -1) current.push(match); else current.splice(at, 1);
        dispatch({ type: "answer", name: question.name, value: current }, true);
      } else {
        dispatch({ type: "answer", name: question.name, value: match }, true);
      }
    });
    listen(previous, "click", function () {
      var visible = visibleIndices();
      var current = activeIndex(visible);
      if (current <= visible[0]) return;
      dispatch({ type: "goTo", index: visible[visible.indexOf(current) - 1] + 1 }, true);
    });
    listen(next, "click", function () {
      var visible = visibleIndices();
      var current = activeIndex(visible);
      if (!validate(info[current])) {
        render();
        focusQuestion(current, true);
        return;
      }
      var nextIndex = visible.find(function (index) { return index > current; });
      if (typeof nextIndex === "undefined") dispatch({ type: "submit" }, true);
      else dispatch({ type: "goTo", index: nextIndex + 1 }, true);
    });
    listen(skip, "click", function () { dispatch({ type: "skip" }, true); });
    listen(submit, "click", function () { dispatch({ type: "submit" }, true); });

    render();

    return {
      getValue: getValue,
      setValue: function (value) { dispatch({ type: "setValue", value: value }, true); },
      goTo: function (index) { dispatch({ type: "goTo", index: index }, false); },
      setErrors: function (value) { dispatch({ type: "setErrors", value: value }, false); },
      reset: function () { dispatch({ type: "reset" }, true); },
      destroy: function () {
        destroyed = true;
        listeners.forEach(function (entry) { entry[0].removeEventListener(entry[1], entry[2]); });
        listeners = [];
      }
    };
  });
})();

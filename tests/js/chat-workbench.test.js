import { beforeEach, describe, expect, test } from "vitest";
import { key, loadRuntime, mount } from "./helpers.js";

let shad;

beforeEach(() => {
  document.body.innerHTML = "";
  delete window.shad;
  shad = loadRuntime("chat-prompt", "chat-branch");
});

describe("chat workbench browser controls", () => {
  test("Enter submits once while Shift+Enter and IME composition do not", () => {
    const root = mount(`
      <div data-shad="chat-prompt">
        <textarea></textarea><button type="button">Send</button>
      </div>`);
    let submits = 0;
    root.querySelector("button").addEventListener("click", () => { submits += 1; });
    const textarea = root.querySelector("textarea");

    key(textarea, "Enter");
    key(textarea, "Enter", { shiftKey: true });
    key(textarea, "Enter", { isComposing: true });
    expect(submits).toBe(1);
    shad.destroy(root);
  });

  test("branch controls emit a namespaced version selection event", () => {
    const root = mount(`
      <div data-shad="chat-branch" data-message-id="answer-1" data-version="2">
        <button data-chat-branch="previous">Previous response</button>
        <button data-chat-branch="next">Next response</button>
      </div>`);
    const events = [];
    root.addEventListener("shad:chat-version", (event) => events.push(event.detail));
    root.querySelector('[data-chat-branch="previous"]').click();
    root.querySelector('[data-chat-branch="next"]').click();
    expect(events).toEqual([
      { messageId: "answer-1", version: 1 },
      { messageId: "answer-1", version: 3 }
    ]);
  });

  test("branch controls do not emit from disabled boundaries", () => {
    const root = mount(`
      <div data-shad="chat-branch" data-message-id="answer-1" data-version="1">
        <button disabled data-chat-branch="previous">Previous response</button>
        <button data-chat-branch="next">Next response</button>
      </div>`);
    const events = [];
    root.addEventListener("shad:chat-version", (event) => events.push(event.detail));
    root.querySelector('[data-chat-branch="previous"]').click();
    root.querySelector('[data-chat-branch="next"]').click();
    expect(events).toEqual([{ messageId: "answer-1", version: 2 }]);
  });
});

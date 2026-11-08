/* Command: filtering, keyboard, activation, dialog mode, and the page-scroll
   regression that sent the kitchen sink to "Tier 3" on load. */
import { describe, test, expect, beforeEach, vi } from "vitest";
import { loadRuntime, mount, rect, key, record } from "./helpers.js";

const MARKUP = (attrs = "") => `
  <div data-shad="command" id="cmd" ${attrs}>
    <div class="shad-command__header">
      <input class="shad-command__input" type="text">
    </div>
    <div class="shad-command__list">
      <div class="shad-command__empty">No results found.</div>
      <div class="shad-command__group">
        <div class="shad-command__group-heading">Go to</div>
        <button class="shad-command__item" data-value="calendar"
                data-keywords="date">Calendar</button>
        <button class="shad-command__item" data-value="emoji">Search Emoji</button>
      </div>
      <div class="shad-command__separator"></div>
      <div class="shad-command__group">
        <div class="shad-command__group-heading">Settings</div>
        <button class="shad-command__item" data-value="profile">Profile</button>
        <button class="shad-command__item" data-value="off" data-disabled>Disabled</button>
      </div>
    </div>
  </div>`;

let shad, root, input, list;
beforeEach(() => {
  document.body.innerHTML = "";
  delete window.shad;
  shad = loadRuntime("command");
});

function setup(attrs) {
  root = mount(MARKUP(attrs));
  input = root.querySelector(".shad-command__input");
  list = root.querySelector(".shad-command__list");
  return shad.get(root);
}

const visible = () =>
  [...list.querySelectorAll(".shad-command__item")]
    .filter((i) => !i.hidden).map((i) => i.dataset.value);

const highlighted = () =>
  (list.querySelector("[data-highlighted]") || {}).dataset?.value;

function type(text) {
  input.value = text;
  input.dispatchEvent(new window.Event("input", { bubbles: true }));
}

describe("filtering", () => {
  test("matches item text and data-keywords, case-insensitively", () => {
    setup();
    type("EMOJ");
    expect(visible()).toEqual(["emoji"]);

    type("date");                       // keyword only, not in the label
    expect(visible()).toEqual(["calendar"]);
  });

  test("hides a group when all its items are filtered out", () => {
    setup();
    type("profile");
    const groups = [...root.querySelectorAll(".shad-command__group")];
    expect(groups.map((g) => g.hidden)).toEqual([true, false]);
  });

  test("shows the empty state only when nothing matches", () => {
    setup();
    const empty = root.querySelector(".shad-command__empty");
    expect(empty.hidden).toBe(true);
    type("zzzz");
    expect(empty.hidden).toBe(false);
    expect(highlighted()).toBeUndefined();
    type("");
    expect(empty.hidden).toBe(true);
  });
});

describe("keyboard", () => {
  test("arrows skip disabled items and stop at the ends", () => {
    setup();
    expect(highlighted()).toBe("calendar");   // first item is pre-highlighted

    key(input, "ArrowDown");
    expect(highlighted()).toBe("emoji");
    key(input, "ArrowDown");
    expect(highlighted()).toBe("profile");
    key(input, "ArrowDown");
    expect(highlighted()).toBe("profile");    // "off" is disabled; clamp here

    key(input, "ArrowUp");
    expect(highlighted()).toBe("emoji");
  });

  test("Home and End jump to the ends of the filtered list", () => {
    setup();
    key(input, "End");
    expect(highlighted()).toBe("profile");
    key(input, "Home");
    expect(highlighted()).toBe("calendar");
  });

  test("Enter activates the highlighted item", () => {
    const inst = setup();
    const changes = record(root, "shad:change");
    key(input, "ArrowDown");
    key(input, "Enter");
    expect(changes).toEqual([{ value: "emoji" }]);
    expect(inst.getValue()).toBe("emoji");
  });
});

describe("activation", () => {
  test("clicking an item reports its value; a disabled item reports nothing", () => {
    setup();
    const changes = record(root, "shad:change");
    list.querySelector('[data-value="profile"]').click();
    list.querySelector('[data-value="off"]').click();
    expect(changes).toEqual([{ value: "profile" }]);
  });

  test("aria wiring follows the highlight", () => {
    setup();
    const first = list.querySelector('[data-value="calendar"]');
    expect(list.getAttribute("role")).toBe("listbox");
    expect(first.getAttribute("role")).toBe("option");
    expect(first.getAttribute("aria-selected")).toBe("true");
    expect(input.getAttribute("aria-activedescendant")).toBe(first.id);

    key(input, "ArrowDown");
    expect(first.hasAttribute("aria-selected")).toBe(false);
  });
});

describe("page scroll (regression)", () => {
  /* An inline palette is ordinary document flow. highlight() used
     scrollIntoView(), which scrolls EVERY scrollable ancestor, so a page
     containing one jumped down to the palette on load and again on every
     keystroke -- which is what opened the kitchen sink at "Tier 3 – overlays".
     The highlight now scrolls only the list. */
  function watchScrolling() {
    const seen = [];
    for (const el of document.querySelectorAll("*")) {
      el.scrollIntoView = () => seen.push(el);
    }
    return seen;
  }

  test("nothing calls scrollIntoView on init, filter, or arrow keys", () => {
    setup();
    const scrolled = watchScrolling();

    shad.get(root).refresh();
    type("e");
    key(input, "ArrowDown");
    key(input, "End");

    expect(scrolled).toEqual([]);
  });

  test("the highlight scrolls the list itself when an item is out of view", () => {
    setup();
    // give the list a viewport and put the third item below its bottom edge
    rect(list, { top: 0, bottom: 100, height: 100 });
    const target = list.querySelector('[data-value="profile"]');
    rect(target, { top: 130, bottom: 150, height: 20 });
    list.scrollTop = 0;

    key(input, "End");
    expect(list.scrollTop).toBe(50);   // exactly enough to reveal it
  });
});

describe("dialog mode", () => {
  test("data-hotkey hides the palette and mod+K toggles it", () => {
    const inst = setup('data-hotkey="mod+k"');
    expect(root.hidden).toBe(true);
    expect(root.classList.contains("shad-command--dialog")).toBe(true);
    expect(root.getAttribute("role")).toBe("dialog");
    expect(inst.isOpen).toBe(false);

    key(document, "k", { ctrlKey: true });
    expect(inst.isOpen).toBe(true);
    expect(root.hidden).toBe(false);

    key(document, "k", { metaKey: true });   // mod is either modifier
    expect(inst.isOpen).toBe(false);
  });

  test("data-dialog alone is enough – no hotkey needed", () => {
    // shad_command(dialog = TRUE, hotkey = FALSE): opened from a trigger or the
    // server. Without data-dialog this rendered as a visible inline palette.
    const inst = setup("data-dialog");
    expect(root.hidden).toBe(true);
    expect(inst.isOpen).toBe(false);
    inst.open();
    expect(inst.isOpen).toBe(true);
  });

  test("an inline palette is always open and ignores open()/close()", () => {
    const inst = setup();
    expect(root.hidden).toBe(false);
    expect(inst.isOpen).toBe(true);
    inst.close();
    expect(inst.isOpen).toBe(true);
  });

  test("activating an item closes the dialog but not an inline palette", () => {
    const dlg = setup('data-hotkey="mod+k"');
    dlg.open();
    list.querySelector('[data-value="profile"]').click();
    expect(dlg.isOpen).toBe(false);
  });

  test("[data-shad-command-open] opens the palette it names", () => {
    const inst = setup('data-hotkey="mod+k"');
    const trigger = document.createElement("button");
    trigger.setAttribute("data-shad-command-open", "cmd");
    document.body.appendChild(trigger);

    trigger.click();
    expect(inst.isOpen).toBe(true);
  });

  test("destroy unbinds the hotkey", () => {
    const inst = setup('data-hotkey="mod+k"');
    const open = vi.spyOn(inst, "open");
    shad.destroy(root);
    key(document, "k", { ctrlKey: true });
    expect(open).not.toHaveBeenCalled();
  });
});

describe("refresh", () => {
  test("re-reads items swapped in by the server", () => {
    const inst = setup();
    list.innerHTML =
      '<div class="shad-command__empty" hidden>None</div>' +
      '<button class="shad-command__item" data-value="q3">Recent Q3</button>';
    inst.refresh();

    expect(visible()).toEqual(["q3"]);
    expect(highlighted()).toBe("q3");   // ready for Enter
  });
});

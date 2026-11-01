/* The shared runtime: registry lifecycle, DismissLayer, FocusTrap, Presence,
   ScrollLock, Portal. Every component sits on these, so a break here is a
   break everywhere. */
import { describe, test, expect, beforeEach, vi } from "vitest";
import { loadRuntime, mount, rect, key, press } from "./helpers.js";

let shad;
beforeEach(() => {
  document.body.innerHTML = "";
  delete window.shad;
  shad = loadRuntime();
});

describe("registry", () => {
  test("init wires a registered component once and caches the instance", () => {
    const factory = vi.fn(() => ({ getValue: () => 1 }));
    shad.register("demo", factory);

    const el = mount('<div data-shad="demo"></div>');
    expect(factory).toHaveBeenCalledTimes(1);
    expect(shad.get(el).getValue()).toBe(1);

    shad.init(document); // idempotent
    expect(factory).toHaveBeenCalledTimes(1);
  });

  test("get resolves from a descendant, not just the root", () => {
    shad.register("demo", () => ({}));
    const el = mount('<div data-shad="demo"><span id="kid">x</span></div>');
    expect(shad.get(document.getElementById("kid"))).toBe(shad.get(el));
  });

  test("an unregistered name is skipped, and a throwing factory is contained", () => {
    const el = mount('<div data-shad="never-registered"></div>');
    expect(shad.get(el)).toBeNull();

    const err = vi.spyOn(console, "error").mockImplementation(() => {});
    shad.register("boom", () => { throw new Error("nope"); });
    const bad = mount('<div data-shad="boom"></div><div data-shad="boom"></div>');
    expect(shad.get(bad)).toBeNull();
    expect(err).toHaveBeenCalled();
  });

  test("destroy runs the instance hook and clears the cache", () => {
    const destroy = vi.fn();
    shad.register("demo", () => ({ destroy }));
    const el = mount('<div data-shad="demo"></div>');
    shad.destroy(el);
    expect(destroy).toHaveBeenCalledTimes(1);
    expect(shad.get(el)).toBeNull();
  });
});

describe("autoInit observer", () => {
  test("wires inserted components and tears down removed ones", async () => {
    const destroy = vi.fn();
    shad.register("demo", () => ({ destroy }));
    const stop = shad.autoInit();

    const el = document.createElement("div");
    el.setAttribute("data-shad", "demo");
    document.body.appendChild(el);
    await Promise.resolve();          // MutationObserver runs as a microtask
    expect(shad.get(el)).not.toBeNull();

    el.remove();
    await Promise.resolve();
    expect(destroy).toHaveBeenCalledTimes(1);
    stop();
  });

  test("a MOVE is not a teardown", async () => {
    // Regression: shad.portal() moves a panel -- and, for a command dialog, the
    // root itself -- to <body>. Reading that removal as an unmount destroyed
    // the component in the middle of opening it.
    const destroy = vi.fn();
    shad.register("demo", () => ({ destroy }));
    const host = mount('<div id="host"><div data-shad="demo" id="movable"></div></div>');
    const el = document.getElementById("movable");
    const stop = shad.autoInit();
    const before = shad.get(el);

    document.body.appendChild(el); // moved out of host, still in the document
    await Promise.resolve();

    expect(destroy).not.toHaveBeenCalled();
    expect(shad.get(el)).toBe(before);
    expect(host.contains(el)).toBe(false);
    stop();
  });
});

describe("init-time attributes for server-created overlays", () => {
  test("data-shad-open opens the instance once the task settles", async () => {
    const open = vi.fn();
    shad.register("demo", () => ({ open }));
    mount('<div data-shad="demo" data-shad-open></div>');

    // deferred deliberately: Shiny binds the fragment in the same task, and
    // opening earlier would portal inputs out from under bindAll
    expect(open).not.toHaveBeenCalled();
    await new Promise((r) => setTimeout(r, 0));
    expect(open).toHaveBeenCalledTimes(1);
  });

  test("data-shad-transient removes the element after it closes", async () => {
    vi.useFakeTimers();
    const destroy = vi.fn();
    shad.register("demo", () => ({ destroy }));
    const el = mount('<div data-shad="demo" data-shad-transient></div>');

    shad.util.emit(el, "shad:close", {});
    expect(el.isConnected).toBe(true);   // still animating out

    vi.advanceTimersByTime(600);
    expect(destroy).toHaveBeenCalledTimes(1);
    expect(el.isConnected).toBe(false);
    vi.useRealTimers();
  });

  test("neither attribute fires without opting in", async () => {
    const open = vi.fn();
    shad.register("demo", () => ({ open, destroy() {} }));
    const el = mount('<div data-shad="demo"></div>');
    await new Promise((r) => setTimeout(r, 0));
    expect(open).not.toHaveBeenCalled();
    expect(el.isConnected).toBe(true);
  });
});

describe("DismissLayer", () => {
  test("Escape dismisses only the topmost layer", () => {
    const outer = mount('<div id="outer"></div>');
    const inner = document.createElement("div");
    document.body.appendChild(inner);
    const onOuter = vi.fn(), onInner = vi.fn();

    shad.dismiss.push({ el: outer, onDismiss: onOuter });
    const closeInner = shad.dismiss.push({ el: inner, onDismiss: onInner });

    key(document, "Escape");
    expect(onInner).toHaveBeenCalledTimes(1);
    expect(onOuter).not.toHaveBeenCalled();

    closeInner();
    key(document, "Escape");
    expect(onOuter).toHaveBeenCalledTimes(1);
  });

  test("a press inside the layer (or its extras) does not dismiss it", () => {
    const el = mount('<div id="panel"><button id="in">x</button></div>');
    const extra = document.createElement("button");
    document.body.appendChild(extra);
    const onDismiss = vi.fn();
    shad.dismiss.push({ el, onDismiss, extraElements: [extra] });

    press(document.getElementById("in"));
    press(extra);
    expect(onDismiss).not.toHaveBeenCalled();

    press(document.body);
    expect(onDismiss).toHaveBeenCalledWith("outside");
  });

  test("closeOnEscape / closeOnOutside opt out", () => {
    const el = mount("<div></div>");
    const onDismiss = vi.fn();
    shad.dismiss.push({ el, onDismiss, closeOnEscape: false, closeOnOutside: false });

    key(document, "Escape");
    press(document.body);
    expect(onDismiss).not.toHaveBeenCalled();
  });
});

describe("FocusTrap", () => {
  test("Tab wraps at the ends and release restores focus", async () => {
    const before = document.createElement("button");
    document.body.appendChild(before);
    before.focus();

    const panel = document.createElement("div");
    panel.innerHTML = '<button id="a">a</button><button id="b">b</button>';
    document.body.appendChild(panel);
    const a = document.getElementById("a"), b = document.getElementById("b");
    // jsdom reports zero-size boxes, and tabbables() filters on them
    rect(a, { width: 10, height: 10 });
    rect(b, { width: 10, height: 10 });

    const release = shad.focusTrap(panel);
    await new Promise((r) => setTimeout(r, 20)); // initial focus is deferred
    expect(document.activeElement).toBe(a);

    b.focus();
    key(b, "Tab");
    expect(document.activeElement).toBe(a);      // forward off the end

    key(a, "Tab", { shiftKey: true });
    expect(document.activeElement).toBe(b);      // backward off the start

    release();
    expect(document.activeElement).toBe(before);
  });

  test("tabbables() leaves out what Tab skips, so Shift+Tab never wraps onto it", () => {
    // a command palette's options are buttons with tabindex=-1, reached with
    // the arrows; a roving group's inactive items are the same
    const panel = document.createElement("div");
    panel.innerHTML = '<input id="q"><button id="opt" tabindex="-1">opt</button>' +
      '<a id="link" href="#" tabindex="-1">link</a><button id="last">last</button>';
    document.body.appendChild(panel);
    for (const id of ["q", "opt", "link", "last"]) {
      rect(document.getElementById(id), { width: 10, height: 10 });
    }
    expect(shad.util.tabbables(panel).map((el) => el.id)).toEqual(["q", "last"]);
  });

  test("initial focus prefers [data-shad-autofocus]", async () => {
    const panel = document.createElement("div");
    panel.innerHTML = '<button id="a">a</button>' +
      '<button id="b" data-shad-autofocus>b</button>';
    document.body.appendChild(panel);
    rect(document.getElementById("a"), { width: 10, height: 10 });

    shad.focusTrap(panel);
    await new Promise((r) => setTimeout(r, 20));
    expect(document.activeElement.id).toBe("b");
  });
});

describe("Presence", () => {
  test("show reveals immediately; hide waits for the exit animation", () => {
    const el = mount("<div hidden></div>");
    shad.presence.show(el);
    expect(el.hidden).toBe(false);
    expect(el.getAttribute("data-state")).toBe("open");

    const done = vi.fn();
    shad.presence.hide(el, done);
    expect(el.getAttribute("data-state")).toBe("closed");
    expect(el.hidden).toBe(false);   // still animating
    expect(done).not.toHaveBeenCalled();

    el.dispatchEvent(new window.Event("animationend"));
    expect(el.hidden).toBe(true);
    expect(done).toHaveBeenCalledTimes(1);
  });

  test("hide falls back to a timer when nothing animates", () => {
    vi.useFakeTimers();
    const el = mount("<div></div>");
    const done = vi.fn();
    shad.presence.hide(el, done);
    vi.advanceTimersByTime(600);
    expect(el.hidden).toBe(true);
    expect(done).toHaveBeenCalledTimes(1);
    vi.useRealTimers();
  });

  test("hiding an already-hidden element still calls back", () => {
    const el = mount("<div hidden></div>");
    const done = vi.fn();
    shad.presence.hide(el, done);
    expect(done).toHaveBeenCalledTimes(1);
  });
});

describe("ScrollLock", () => {
  test("is reference counted, so nested overlays do not unlock early", () => {
    shad.scrollLock.lock();
    shad.scrollLock.lock();
    expect(document.body.style.overflow).toBe("hidden");

    shad.scrollLock.unlock();
    expect(document.body.style.overflow).toBe("hidden"); // one holder left

    shad.scrollLock.unlock();
    expect(document.body.style.overflow).not.toBe("hidden");
  });
});

describe("Portal", () => {
  test("moves an element to body and puts it back where it was", () => {
    mount('<div id="host"><span id="a">a</span><em id="panel">p</em><span id="b">b</span></div>');
    const panel = document.getElementById("panel");
    const host = document.getElementById("host");

    const restore = shad.portal(panel);
    expect(panel.parentElement).toBe(document.body);

    restore();
    expect(panel.parentElement).toBe(host);
    // back in its original slot, between a and b
    expect([...host.children].map((e) => e.id)).toEqual(["a", "panel", "b"]);
  });
});

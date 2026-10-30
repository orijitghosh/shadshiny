/* Portal direction is part of the shared runtime contract. Portaled content
   must retain the direction and language of its logical owner while open,
   including when Shiny or bslib changes the page direction at runtime. */
import { describe, test, expect, beforeEach } from "vitest";
import { loadRuntime, mount } from "./helpers.js";

let shad;
beforeEach(() => {
  document.body.innerHTML = "";
  document.documentElement.removeAttribute("dir");
  document.documentElement.removeAttribute("lang");
  delete window.shad;
  shad = loadRuntime();
});

describe("portal direction synchronization", () => {
  test("copies the nearest direction and language and follows changes", async () => {
    const root = mount(
      '<div id="scope" dir="rtl" lang="ar"><span id="anchor"></span>' +
      '<div id="panel">محتوى</div></div>', { init: false });
    const panel = root.querySelector("#panel");

    const restore = shad.portal(panel);
    expect(panel.getAttribute("dir")).toBe("rtl");
    expect(panel.getAttribute("lang")).toBe("ar");

    root.setAttribute("dir", "ltr");
    await Promise.resolve();
    expect(panel.getAttribute("dir")).toBe("ltr");

    restore();
    expect(panel.hasAttribute("dir")).toBe(false);
    expect(panel.hasAttribute("lang")).toBe(false);
  });

  test("preserves auto direction for mixed user content", () => {
    const root = mount(
      '<div dir="auto"><div id="panel" dir="auto">שלום / English</div></div>',
      { init: false });
    const panel = root.querySelector("#panel");

    const restore = shad.portal(panel);
    expect(panel.getAttribute("dir")).toBe("auto");
    restore();
    expect(panel.getAttribute("dir")).toBe("auto");
  });

  test("falls back to the document direction", () => {
    document.documentElement.setAttribute("dir", "rtl");
    const panel = mount('<div id="panel">محتوى</div>', { init: false });
    const restore = shad.portal(panel);
    expect(panel.getAttribute("dir")).toBe("rtl");
    restore();
  });

  test("horizontal roving navigation follows RTL visual order", () => {
    shad.register("rtl-roving", (root) => ({
      rove: shad.roving(root, {
        selector: "button", orientation: "horizontal"
      }),
      destroy() { this.rove.destroy(); }
    }));
    const root = mount(
      '<div data-shad="rtl-roving" dir="rtl">' +
      '<button id="first">الأول</button><button id="second">الثاني</button>' +
      '<button id="third">الثالث</button></div>'
    );
    document.getElementById("first").focus();
    const ev = new window.KeyboardEvent("keydown", {
      key: "ArrowRight", bubbles: true, cancelable: true
    });
    root.dispatchEvent(ev);
    expect(document.activeElement.id).toBe("third");
  });
});

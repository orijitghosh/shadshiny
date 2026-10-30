import { beforeEach, afterEach, describe, expect, test, vi } from "vitest";
import { readFileSync } from "node:fs";
import { resolve } from "node:path";
import { loadRuntime, mount } from "./helpers.js";

const runtimePath = resolve("inst/assets/core/shad-runtime.js");
const baseCssPath = resolve("inst/assets/core/shad-base.css");
const animationCssPath = resolve("inst/assets/core/shad-animations.css");

function codeMarkup() {
  return `
    <figure data-shad-code-block>
      <pre><code></code></pre>
      <button type="button" data-shad-copy-code aria-label="Copy code">Copy</button>
      <span data-shad-copy-status role="status" aria-live="polite" aria-atomic="true"></span>
    </figure>`;
}

function setClipboard(writeText) {
  Object.defineProperty(navigator, "clipboard", {
    configurable: true,
    value: { writeText }
  });
}

let shad;

beforeEach(() => {
  document.body.innerHTML = "";
  delete window.shad;
  shad = loadRuntime();
});

afterEach(() => {
  vi.useRealTimers();
});

describe("delegated code-block copy", () => {
  test("copies exact code.textContent and retains focus on success", async () => {
    const writeText = vi.fn().mockResolvedValue(undefined);
    setClipboard(writeText);
    const root = mount(codeMarkup());
    const code = root.querySelector("code");
    const button = root.querySelector("button");
    const status = root.querySelector('[role="status"]');
    code.textContent = "  first\nsecond\n";

    button.focus();
    button.click();
    await Promise.resolve();

    expect(writeText).toHaveBeenCalledTimes(1);
    expect(writeText).toHaveBeenCalledWith("  first\nsecond\n");
    expect(status.textContent).toBe("Copied");
    expect(document.activeElement).toBe(button);
  });

  test("announces repeatable success and deterministic failure without moving focus", async () => {
    const writeText = vi.fn().mockResolvedValue(undefined);
    setClipboard(writeText);
    const root = mount(codeMarkup());
    const button = root.querySelector("button");
    const status = root.querySelector('[role="status"]');
    const announcements = [];
    const observer = new MutationObserver(() => announcements.push(status.textContent));
    observer.observe(status, { childList: true, characterData: true, subtree: true });

    button.focus();
    button.click();
    await Promise.resolve();
    await new Promise((resolve) => setTimeout(resolve, 0));
    button.click();
    await Promise.resolve();
    await new Promise((resolve) => setTimeout(resolve, 0));
    expect(status.textContent).toBe("Copied");
    expect(announcements.filter((value) => value === "Copied").length).toBe(2);
    expect(document.activeElement).toBe(button);

    setClipboard(vi.fn().mockRejectedValue(new Error("denied")));
    button.click();
    await Promise.resolve();
    await new Promise((resolve) => setTimeout(resolve, 0));
    expect(status.textContent).toBe("Copy failed");
    expect(document.activeElement).toBe(button);
    observer.disconnect();
  });

  test("is idempotent when initialization is repeated", async () => {
    const writeText = vi.fn().mockResolvedValue(undefined);
    setClipboard(writeText);
    const root = mount(codeMarkup());
    const button = root.querySelector("button");

    shad.autoInit();
    shad.autoInit();
    button.click();
    await Promise.resolve();

    expect(writeText).toHaveBeenCalledTimes(1);
  });

  test("ignores late clipboard completion after the block is removed", async () => {
    let resolveCopy;
    setClipboard(vi.fn(() => new Promise((resolve) => { resolveCopy = resolve; })));
    const root = mount(codeMarkup());
    const button = root.querySelector("button");

    button.click();
    root.remove();
    expect(() => resolveCopy()).not.toThrow();
    await Promise.resolve();

    expect(root.isConnected).toBe(false);
  });

  test("uses CSS masks for fades and has no utility scroll observer/listener", () => {
    const base = readFileSync(baseCssPath, "utf8");
    const animations = readFileSync(animationCssPath, "utf8");
    const runtime = readFileSync(runtimePath, "utf8");

    expect(base).toContain(".shad-scroll-fade");
    expect(base).toContain("mask-image");
    expect(base).toContain("-webkit-mask-image");
    expect(animations).toContain(".shad-shimmer[data-active]");
    expect(animations).toContain("prefers-reduced-motion: reduce");
    expect(base).toContain("forced-colors: active");
    expect(runtime).not.toMatch(/shad-scroll-fade[\s\S]{0,2000}(?:addEventListener|MutationObserver)/);
  });
});

const fixtures = Object.freeze({
  rtl: Object.freeze({ spec: "rtl.spec.js", app: "rtl-app" }),
  questionnaire: Object.freeze({
    spec: "questionnaire.spec.js",
    app: "questionnaire-app",
  }),
  "field-family": Object.freeze({
    spec: "field-family.spec.js",
    app: "field-family",
  }),
  "chat-workbench": Object.freeze({
    spec: "chat-workbench.spec.js",
    app: "chat-workbench-app",
  }),
  "server-data-table": Object.freeze({
    spec: "server-data-table.spec.js",
    app: "server-data-table",
  }),
  "utility-elements": Object.freeze({
    spec: "utility-elements.spec.js",
    app: "utility-elements",
  }),
});

export function browserFixtureNames() {
  return Object.keys(fixtures);
}

export function resolveBrowserFixture(name) {
  const fixture = fixtures[name];
  if (!fixture) throw new Error(`Unknown browser fixture: ${name}`);
  return { name, spec: fixture.spec, app: fixture.app };
}

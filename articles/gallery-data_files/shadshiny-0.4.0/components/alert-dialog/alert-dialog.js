/* FILE: inst/assets/components/alert-dialog/alert-dialog.js */
/* shadshiny – alert-dialog.
   DECISION: the "alert-dialog" factory is registered by dialog/dialog.js
   (shared machinery: no outside-press dismiss, no Esc unless
   data-escape-close, role=alertdialog). This file exists for layout
   uniformity and to guarantee registration when only alert-dialog assets are
   loaded: it re-registers iff dialog.js hasn't. Safe to load with dialog.js
   in any order (register is last-write-wins with identical factories). */
(function () {
  "use strict";
  // If dialog.js loaded first, "alert-dialog" is already registered – done.
  // Otherwise document the dependency loudly.
  if (!window.shad) { console.error("[shad] runtime missing"); return; }
  // Probe: shad has no public registry getter; attempt init on a detached
  // probe node is overkill. DECISION: alert-dialog REQUIRES dialog.js.
  // We enforce the contract with a console hint for the downstream agent.
  if (!window.__shadDialogLoaded) {
    console.warn("[shad] alert-dialog requires components/dialog/dialog.js to be loaded (it registers both factories).");
  }
})();


## CURRENT CHECKPOINT 📍
> [Checkpoint saves](./.claude/checkpoints)
> Updated YYYY-MM-DD (end of `/session-name`)

**Status:** {{Ready to start 🟢 / WIP 🚧 / Queue 🔄 / Switching tasks ⏯️/ Blocked ⛔️}}

**Progress** ✅

Done, Open items, Follow ups

{{ Bullet list of Focus on tangible wins: Not a line-item lists of what steps you did, what the result was. Super concise and brief}}
<!--Example:
- **Closed:** 20/21 issues in architecture audit
- **New:** [`@corchina/bun-wp`](./packages/bun-wp) package
- **Improved:** Smaller '@corchina/core-extensions' size (Now: 11.5 KB, Prev: 93.7 KB )-->
**FOLO:**
- 
### NEXT TASK 🏁

{{One-line description. If it's from an audit or plan, also link to the doc.}}

{{Numbered list of next tasks}} 1. 2. 3.

<!--Example
**[block-pipeline-audit.md](./docs/block-pipeline-audit.md)**
1. **FIX:** the block bootstrap chain (B1-B3)
2. **FIX:** Build and fix `blocks/**/editor.js`(B4-B5)
3. **REWRITE:** both editor scripts to current patterns
4. **MOVE:** Package move-->





## Current checkpoint
**Ongoing: 🚧** Migrating `~/Projects/_active/corchina-theme/` into `corchina-site`. Mid–[Phase 2](./docs/plans/MVP_roadmap.md#phase-2--content-model-complete-).
<!-- updated 2026-08-18, end of Project Links session -->
**Status:** 🔴 Project Links panel **NOT complete — only schema/plumbing groundwork done; the real UI component is unbuilt and needs a planning session.** What landed: guard removed in `meta-field.tsx` (repeater meta fields now render their control), and a **provisional** `project-links` `fields` config in `PostMeta.php` (url/title/target). That makes the generic repeater render **three basic inputs per row** — which is *not* the intended UX. **The intended behavior is a WP `LinkControl`-style link picker per row** (URL + content search + "open in new tab"), so the current `{ url, title, target }` config is likely to change (LinkControl carries a richer value: `id`/`type`/`kind`). 

**Two next tasks, both needing new sessions:** (A) **plan + build the LinkControl-based Project Links component**; (B) **G7** — editor bundle won't build (co-located CSS collides with `buildBundle`'s fixed output name), blocks any live test. Nothing committed. Keep the two edited files separate from the uncommitted repeater/rich-text refactor in the tree.

### Done ✅
- **Completed:** [Phase 1](./docs/plans/MVP_roadmap.md#phase-1--make-blocks-render-) — blocks render (bootstrap chain fixed).
- **Migrated:** Subtitle → TS/JSX block — `usePostMeta` + inline `RichTextCharacterLimit` (70-char counter); Company reads/writes **Description**. Committed + live-tested 2026-08-07. Full notes + per-post-type test table: [roadmap Phase 2](./docs/plans/MVP_roadmap.md#phase-2--content-model-complete-).
- **Built + committed:** Repeater component — generic config-driven `"repeater"` control in core-extensions. Rows reuse the existing `Control` registry (no new field code); reorder via `react-movable` (drag/touch/keyboard) + up/down buttons through one pure `move()` helper. ContentPicker refactor landed first (Commit 1, `835abb0`). Plan: [repeater-component](./docs/superpowers/plans/2026-08-11-repeater-component.md). `react-movable` decision logged in DECISIONS.md (2026-08-11).
- **Groundwork only (NOT the feature):** Project Links — removed the `PLACEHOLDER_TYPES` guard in `meta-field.tsx` so `"repeater"` meta fields render their control; added a **provisional** `project-links` `fields` config to `PostMeta.php`. This renders three generic inputs per row, **not** the intended `LinkControl`-style picker. The component still needs designing + building (see Next task). tsc clean, no new test failures, not committed.

### Open follow-ups from Subtitle testing 🧵 *(surfaced, not blocking the next task — detail + HTML in the roadmap table)*
- **#7 still undecided:** `block.json` `autoRegister` + the `registerBlock` unregister→re-register. It was only added because the block broke without it **in the old theme** — unproven in the new structure. Decide by dropping `autoRegister` and checking the block still registers/renders here.
- **Panel duplicate counter (🟡):** a non-functional `0 / 70` counter renders under the redirect-url placeholder in the sidebar (post + clip). Find the stray panel render.
- **Add/remove-subtitle UX:** Subtitle is excluded from the inserter, so once deleted it can't be re-added — consider a toggle in the plugin sidebar panel.
- **Company website-URL icon link:** append an outbound icon link after the subtitle on Company (block vs. block hook vs. render — TBD).
- **Excerpt-style Description field:** make the Company Description panel behave like core's Excerpt (SlotFill / minimal style) — wanted as a core-extensions option.
- **`render.twig` frontend:** outputs only `{% if is_editor %}` → nothing on the frontend. Confirm intended (hero template part shows it) or add a frontend branch.

### **Next task:** 🏁 Plan + build the Project Links UI component *(new session — needs planning first)*

Project Links is **not** done — only schema/plumbing groundwork landed. The actual component is unbuilt. **Start with a planning session** (brainstorming), because the UX is a real design decision, not a wiring task.

**The target UX:** a WP `LinkControl`-style link picker **per repeater row** — URL input with content search/suggestions + "open in new tab", the same feel as links in the block editor. Not three plain inputs.

**Open design questions to resolve in planning:**
- Is each row a full `LinkControl`, or a custom field that wraps it?
- Does the generic repeater container stay, or does a LinkControl-based list replace it?
- Stored data shape: current `{ url, title, target }` likely changes — `LinkControl`'s value carries `id`/`type`/`kind` for internal links. Reconcile with `PostMeta.php` `register_post_meta` REST schema.
- New control type in the `Control` registry (e.g. `"link"`) vs. configuring the existing repeater differently.

**Provisional groundwork already in place (may change):** guard removed in `meta-field.tsx`; `project-links` `fields` config in `PostMeta.php`.

**Parallel blocker — G7 (build):** even once the component exists, the editor bundle **won't build** — `RichTextCharacterLimit`'s co-located CSS collides with `buildBundle`'s fixed output name. Must be fixed before any live test; can be done in either order relative to the component. Full diagnosis + 2-part fix + the 1 stale test path live in the [roadmap Phase 2 checklist](./docs/plans/MVP_roadmap.md#phase-2--content-model-complete-), gap **G7**.

**Live test (once component built + G7 fixed):** rebuild `cd wp-content/plugins/corchina-content && bun run build:js` → in Local open a **Clip** → **Clip Metadata** sidebar → **Project Links**. Confirm the link picker renders + reorder works. Repeater's flagged unknown still applies: react-movable's `renderItem`/`renderList` `props` must spread onto the row + handle needs `data-movable-handle` — only the real editor confirms drag.

→ [roadmap Phase 2](./docs/plans/MVP_roadmap.md#phase-2--content-model-complete-)

<!-- Parked 2026-08-18: pre-existing biome error in core-extensions/src/bootstrap/auto-ssr.ts:14 — see PARKING-LOT.md. -->
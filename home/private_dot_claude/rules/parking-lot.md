# Parking Lot

Every project gets a `PARKING-LOT.md` in its root. This file is created at the project start, not when the first task is parked.

**See:** `templates/PARKING-LOT.md` for doc template.

## 1. Parking lot criteria (MUST)

**Items to park:**
- **Nice-to-haves:** Enhancing an existing feature that doesn't have a major impact on shipping
- DX improvements that do NOT slow down the user from getting things done faster.
- **Refactors that don't improve the outcome of existing code:** For example, extracting a module that allows us to drop a dependency IMPROVES the outcome of code.

**NEVER PARK:** 
- Decisions that I need to make. Those belong in the `DECISIONS.md` log. See: `/rules/decisions.md`
- **Refactoring an existing project that doesn't match architecture patterns or code style:** This needs to be bumped to the next task if mid-feature. See: `/rules/existing-projects.md`, `/rules/architecture.md`, `/rules/code-style.md`
- DX improvements or workflow improvements I raise that explicitly make things easier for me or reduce cognitive overload. That's a priority-bump to the next task if mid-feature.


## Rules

- Parking lot items are **append** or **update**, new items first.
- Always remove parking lot items that were moved or completed at the end of every session.
- One doc per project.
- Items should be grouped by top-level module, then date. If the project is a monorepo, group by `package --> top-level modules --> date`
- If multiple items are parked for the same module on the same date, do not duplicate the date—append to the list.
- Entries must always link to the feature file and any supporting reference docs.
- **ALWAYS:** Keep it concise.

## Format

A single entry:
<example>

```markdown
---
### YYYY-MM-DD
---

- [ ] **[Parking lot item. It should be a concise, one-line descriptor in sentence case.]**
  - **What** [The task or work item to park. Include the 'why' (the benefit).]
  - **When:** [The session name this was flagged, who flagged or suggested it, what were we working on]
  - **Type:** [A tentative conventional commit tag this may fall under]
  - **Revisit if:** [Condition under which to prioritize this item]

---
```

Grouping by module:

<example>

```markdown
## [Module name `(./path/to/module)`](./link/to/module/directory)

<!-- group parked items by date, newest first-->

### YYYY-MM-DD

---

- [ ] **[Parking lot item. It should be a concise, one-line descriptor in sentence case.]**
  - **What** [The task or work item to park. Include the 'why' (the benefit).]
  - **When:** [The session name this was flagged, who flagged or suggested it, what were we working on]
  - **Type:** [A tentative conventional commit tag this may fall under]
  - **Revisit if:** [Condition under which to prioritize this item]

---

<!--Append items parked on the same day for the same module. Here's a practical example of an entry--->

- [ ] **Extract and export theme.json fragment definitions and token-to-WP-mappings**
- **What** Extract theme.json fragment models and preset definitions as an exportable module. These are hardcoded and scattered across [foundation](./packages/foundation/) and [monorepo-level tools](./tools) and are inconsistent.
- **When:** User noticed when reading through code outside of a session. Raised it during `/some-session-name`
- **Type:** `refactor` / `feat`
- **Revisit if:** Errors or bugs occur when running [theme-json regeneration script](./packages/foundation/tokens/scripts/generate-theme-json.js) inside a theme, plugin, or another package.

---
```

</instructions>

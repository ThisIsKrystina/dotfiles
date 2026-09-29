---
description: The template to use for any project's CLAUDE.md file. Use when starting a new project or updating an existing CLAUDE.md file.
paths:
  - ./
  - ./packages/*/
  - ./wp-content/*/
---

# Project: {{Project Name}}

**Quick links:** 🔗
**[PARKING LOT](./.claude/PARKING-LOT.md)** 🅿️ | **[DECISIONS](./.claude/DECISIONS.md)** 🧑‍⚖️ | [Reports](./.claude/docs/tmp/) 📁 | [Plans](/.claude/docs/plans) 📁
{{ Project purpose and goal }}

## Constraints

- {{ Known constraints for the project Bulleted only }}

## Stack (do not re-ask)

- {{Bullet list of project stack, no versions included because it'll be old}}

## Quick start

`Project commands here`

## Gotchas (learned the hard way)

- {{ Bullet list, should be mistakes or 'big oops'/catastrophes that we did that we don't ever want to repeat again }}

---

## CURRENT CHECKPOINT 📍
> [Checkpoint saves](./.claude/checkpoints)
Updated YYYY-MM-DD (end of `/session-name`)
**Status:** {{Ready to start 🟢 / WIP 🚧 / Queue 🔄 / Switching tasks ⏯️/ Blocked ⛔️}}

**Progress** ✅
{{ Bullet list of Focus on tangible wins: Not a line-item lists of what steps you did, what the result was. Super concise and brief}}
<!--Example:
- **Closed:** 20/21 issues in architecture audit
- **New:** [`@corchina/bun-wp`](./packages/bun-wp) package
- **Improved:** Smaller '@corchina/core-extensions' size (Now: 11.5 KB, Prev: 93.7 KB )-->

### NEXT TASK 🏁

{{One-line description. If it's from an audit or plan, also link to the doc.}}
{{Numbered list of next tasks}} 1. 2. 3.

<!--Example
**[block-pipeline-audit.md](./docs/block-pipeline-audit.md)**
1. **FIX:** the block bootstrap chain (B1-B3)
2. **FIX:** Build and fix `blocks/**/editor.js`(B4-B5)
3. **REWRITE:** both editor scripts to current patterns
4. **MOVE:** Package move-->

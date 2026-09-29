# Existing Code Rules

Applies when entering a codebase that already has history — legacy projects, ongoing projects, or any project where code exists before the session starts.

---

## 1. Read Before Touch [MUST]

**MUST:**
- Before modifying any file, read it fully. Not the relevant section — the whole file.
- Before modifying a module, understand how it connects to the rest of the system.
- Before adding a dependency, check what is already being used for similar purposes.

Do not assume you understand a file from its name or a partial read.

---

## 2. Understand the Pattern First [MUST]

Every codebase has established patterns — naming conventions, error handling style, folder structure, abstraction levels. These exist for reasons that may not be obvious. If you're not sure, ASK.

**MUST:**
- Identify the existing patterns before writing new code.
- Refactor existing code in an existing project IF pattern and coding conventions do not align with `architecture.md` patterns or `code-style.md` rules. You MUST ask first.
- Follow existing patterns even if you would have made different choices. 
- If an existing pattern is wrong, flag it separately — do not silently "fix" it while implementing a feature.

**MUST NOT:**
- Introduce a new pattern alongside an existing one without flagging the inconsistency and getting approval.
- Rename things to match your preference while implementing something else.
- Refactor and add features in the same change. 

---

## 3a. Separate Refactoring from Features [MUST]

Refactoring and feature work are separate commits, separate conversations. (See #3b)

**MUST NOT** do both in the same change. 
Reasons:
- Mixed changes are impossible to review or revert cleanly
- Bugs introduced in refactoring are invisible when mixed with feature changes
- "I cleaned this up while I was in there" is how regressions happen

**SHOULD:**
- **Add required doc blocks that are missing from code comments**: Add the doc blocks as you go. This doesn't need to be a separate commit or separate refactoring task.

## 3b. Follow the Refactor vs Feature protocol. [RECOMMENDED]
If you see something that needs refactoring while working on a feature, you must follow this process: 
1.  Stop and capture the current status and state of the feature in `CLAUDE.md`. The status entry MUST include the date and time, plus reason for pausing work. 
2. Propose the refactoring as a separate task.
3. Add the refactoring as a next task item in the project's `CLAUDE.md`. Also add the refactoring task to any relevant plan documentation, if applicable. 
4. Refactor first if: The current code violates architecture patterns, is a dependency for multiple parts of the code base, or directly affects implementing the new feature.
5. Otherwise: Ask first. 

---

## 4. Understand Before Deleting [MUST]

**MUST NOT** delete code without understanding why it exists.

Code that looks unused may be:
- Called via reflection or dynamic dispatch
- A workaround for a bug in a dependency
- Dead code that is safe to remove — but you need to verify this, not assume it
- Code is unfinished. 

If you want to delete code, confirm it is unreachable first. If unsure, comment it out and note why before removing.

---

## 5. Incremental Changes [SHOULD]

**SHOULD:**
- Make the smallest change that achieves the goal.
- Large rewrites of existing code require explicit user approval before starting.
- If a "small fix" grows into a larger refactor mid-implementation, stop and ask.

---

## 6. Surface Hidden Assumptions [SHOULD]

Existing code often encodes decisions that are not documented. When you discover them, surface them.

**SHOULD:**
- When you find a non-obvious pattern or constraint, note it in `DECISIONS.md` if it is not already documented. If `DECISIONS.md` does not exist, add it to the `Context` section of `CLAUDE.md` or create `DECISIONS.md`.
- When you change something that might break an undocumented assumption, flag it explicitly before making the change.
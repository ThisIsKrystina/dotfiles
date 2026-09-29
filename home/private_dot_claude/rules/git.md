---
description: Applies to every solo, personal project.
---

## 1. Branch Strategy 

**Every project has two branches [MUST]:**
- **`dev`** : primary working branch. Most work will be done here.
- **`prod`**: protected branch with **only** merge commits from `dev`.
  - **Merge-only exceptions:** one-off minor `style` or `doc` fix, changes so minute it's not worth the hassle switching branches.

**New worktrees need a new feature branch [MUST]:**
- **Branch naming convention:** lowercase, hyphenated, max 50 characters. `{{conventional commit type}}/{{work-slug}}`
- Delete feature branches and worktrees after merge: local and remote.

## 2. Commit Messages — Conventional Commits [MUST]

```
<type>: (<scope>) <short description> # Note:(<scope>) after <type>: is more scannable

[optional body]

[optional footer]
```

| Type           | When to Use                                                                                  | Example                                                                                                   |
| -------------- | -------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------- |
| **`feat`**     | Adding new features/services                                                                 | `feat: (nocodb) added NocoDB container`                                                                   |
| **`fix`**      | Fixing bugs or issues                                                                        | `fix: (monitoring) corrected Prometheus port`                                                             |
| **`docs`**     | Documentation only                                                                           | `docs: updated backup setup guide`                                                                        |
| **`refactor`** | Code/config improvements                                                                     | `refactor: (monitoring) reorganized Prometheus labels`                                                    |
| **`chore`**    | Maintenance tasks, merge commits, housekeeping (e.g pre-commit hooks, issue templates, etc.) | `chore: merge dev into prod - (optional context)`                                                         |
| **`style`**    | Formatting changes                                                                           | `style: fixed indentation in docker-compose`                                                              |
| **`perf`**     | Performance improvements                                                                     | `perf: (grafana) optimized query intervals`                                                               |
| **`build`**    | Updates/changes to build tools, dependencies, project version.                               | `build: (stylelint) Config setup`                                                                         |
| **`ci`**       | Deployment scripts, CI/CD workflows                                                          |                                                                                                           |
| **`test`**     | New/updated tests                                                                            |                                                                                                           |
| `!`            | Breaking change; append to `fix or feat`                                                     | `feat!: Standalone block theme`<br><br>`BREAKING CHANGE: Child theme converted to standalone block theme` |

**Rules:**
- Description is lowercase, imperative tense, no period at the end
- Max 72 characters on the first line
- Body explains *why*, not *what* — the diff already shows that
- Voice: For a non-developer audience. A human reads these, so sound like one!

## 3. .gitignored files 

**ALWAYS `.gitignore`:**
- **Internal docs:** Project plans, specs, CLAUDE.md, docs in ./.claude
- **Environment files:** `.env`, `env.local`, `env.*.local`
- **OS-specific files:** `.DS_Store`, etc
- Logs
- **IDE-specific files:** UNLESS the project is specifically backing up IDE settings as part of dotfiles

Never commit .env files. If this happens, treat it as a credentials leak. Rotate the credentials, dont just remove the file in the next commit. Also clean it from the commit history.

**SHOULD commit:**
- Example .env files (e.g. `.env.example`) instead of `.env` files.
- **Public-facing documentation:** How-tos, such as how to use a feature, extending a feature. 
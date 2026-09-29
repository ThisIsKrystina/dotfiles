---
description: 'Applies to any project with a UI. CMS and stack-agnostic rules'
---

# Frontend Rules

## 1. No Inline Anything [MUST]

Inline styles, inline colors, inline fonts — all forbidden. (See Wordpress-specific rules for exceptions.)

**MUST create before writing the first component:**

```bash
|--/assets # Global assets (e.g. fonts, global CSS, JS)
|--/views # Reusable atom, partials, and template patterns (E.g. HTML, Twig, etc)
|--/components # Reusable component library
----|-/component # Co-locate component-level CSS, metadata/token definition, and template within each component directory
```


---

## 2. Intentional Design [MUST]

Every visual decision must be intentional. The failure mode is not using a "wrong" font or color — it is making choices without thinking.

**MUST:**
- Before writing a single component, define the visual direction in one sentence. ("Dense developer tool, dark, monospace-heavy" is enough.)
- Commit to that direction. Do not drift toward safe/generic mid-implementation.

**SHOULD:**
- Avoid defaulting to the same palette, layout, and component patterns across every project. Each project has a different context — the design should reflect it.
- When no design brief is given, ask for one. Even one sentence changes the output significantly.

There is nothing wrong with Inter, Roboto, or system fonts when they are the right choice for the context. There is something wrong with using them because you did not think about it.

---

## 3. Theme Before Components [MUST]

Strict order:
1. Define theme tokens (colors, typography, spacing) 
2. Build primitive components (Button, Text, Input) using tokens
3. Build feature components on top of primitives

Never skip step 1 or 2 to get to step 3 faster.

---

## 4. Text Management [SHOULD]

**SHOULD:**
- No hardcoded strings scattered across components.
- Maintain a centralized strings/copy file from day one, even if not localizing.

## Defaults (Don't ask, just do it)
- DO: Use Utopia.fyi for generating spacing, grid, and font size primitive tokens, if new ones are needed. Otherwise, use the existing primitives from @corchina/foundation/tokens. 
- DO: Use Harmonizer to generate accessible color palettes in OKLCH for themes. 
- DO: Use an existing UI or color library for internal tooling/internal interfaces. (E.g. DaisyUI, Catppuccin, etc.)
- DO: Use variable web fonts.
- DONT: Use Inter. We're not basic.  
- NEVER: Use Tailwind CSS. The classes are atrocious. 
- MAY: Use a Tailwind plugin (e.g. DaisyUI) if it can be used without Tailwind.
- NEVER: Use Webpack. Bun is the default bundler, builder, and runtime. 
- NEVER: Load fonts remotely.
- NEVER: Use Material Icons or Material UI
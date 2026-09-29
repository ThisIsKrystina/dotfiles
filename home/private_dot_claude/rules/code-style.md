---
description: Universal code style rules to follow for the entire project.
---

# Code Style

## Defaults (Don't ask, just do it)

- **Functions should do one thing:** If you need the word "and" to describe it, split it. - **Keep functions small:** A single function should never exceed 50 lines, MAX. If it gets near that point, split it into reusable functions. 
- **Names must be concise yet clear:** Name variables after what they contain, functions after what they do.
- **Don't abbreviate names.** `getUserProfile` not `getUsrProf`. Clarity beats brevity.
- **Handle errors explicitly:** Don't swallow exceptions or ignore error returns.
- **Imports go at the top, grouped:** stdlib, external packages, internal modules.
- **Don't Repeat Yourself (DRY):** Don't write the same function twice. If a similar one already exists in another file, directory, or subrepo, extract it and adapt it for reusability. 
- **Composition over inheritance:** Chain small, reusable functions to compose complex behaviors. Modular reuse for functions.
- **No syntactical drift code:** Use consistent syntax. Stick with the same pattern. Prioritize readability and user comprehension.
- **Do not hard-code paths in code can be changed by the user later:** Use a config file if there are preferences a user may change later, or if it can be extracted as a reusable module/function. 

## Formatting
<!---- If a file is growing (300+ lines), extract a module.-->
- **Group imports at the top first:** stdlib, internal modules, packages.
- **Return early on functions:** Handle error conditions, invalid inputs, and edge cases at the start of a function.
- **Code must be self-documenting.** Comment blocks MUST use doc blocks and tags.
- **Keep file sizes under control:** Follow the `architecture.md` rules first. If a file is growing (300+ lines), see what can be extracted. Architecture pattern, maintainability, and reusability trumps line limits.
- Use inline comments for comprehension & labelling gotchas 

## Language-specific rules

**TypeScript:** Use explicit return types on exported functions.

**Javascript:**
- Use explicit import and export statements. 
- Exported functions that will ship externally must distribute a `*.d.ts`.
- Use JSDoc doc blocks in code comment blocks to auto-generate `*.d.ts`. 
 
**PHP:** 
- Inside the namespace: Use camel case for function and variable names.
- Outside the namespace: use kebab case for function and variable names.
- Twig: Callable Twig functions use kebab case for function names.
- Use bracket syntax for arrays.
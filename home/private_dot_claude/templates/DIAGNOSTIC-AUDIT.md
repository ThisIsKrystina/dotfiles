---
description: The template to use for structured analysis after 2 failed debug attempts, or when deeper analysis is needed on a failure chain.
paths:
  - ./
  - ./packages/*/
  - ./wp-content/*/
---

# Headline

- **Date:**{{YYYY-MM-DD}}
- **Scope:** {{hyperlinked filepath}}

> [!BUG] ISSUE
> No more than three sentences describing the behavior

Jump ahead:
<!--TOC----->

1. [The failure chain](#the-failure-chain)
2. [Suggested sequence](#suggested-sequence)

---

## The failure chain

<!---Always include a diagram for illustrating chains, dependency breakdowns, knockdown effects-->

```mermaid
flowchart LR
A--->B--->C
```

<!--Table summary of the issues. ALWAYS be explicit about what's been verified, tested, proven, and what's a hypothesis, test, or not verified.---->

| #        | Defect                                    | Status    | File                      | Effect today |
| -------- | ----------------------------------------- | --------- | ------------------------- | ------------ |
| **##NN** | [Statement of defect](#defect-from-table) | PROVEN ✅ | {{link to file and line}} |              | {{One-line explainer}} |

**Defects:**

1. [Defect H3]({{link to relevant H3}})
2. [Defect](link to relevant section)

---

### {{Defect from table}}

{{Deeper dive into issue, if needed. Use short sentences and paragraphs, 3-4 sentences per paragraph.}}

### {{Another issue from table}}

## Suggested sequence

<!--Suggested order for tackling the fix -->

| Step | Work                                      | Scale                                             | Verifiable by                     |
| ---- | ----------------------------------------- | ------------------------------------------------- | --------------------------------- |
| 1    | [Issue](hyperlink/to/item/in/table/above) | {{Indicate how large the work is, emojis work! }} | {{One-sentence statement of fix}} | {{What will prove this has been solved}} |

{{Any further context needed here must be in bullet points}}

---

<!--Optional, if relevant and related to this work---->
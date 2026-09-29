# Decision Logging Rules

Every project gets a `DECISIONS.md` in its root. This file is created at project start, not when the first decision is made. 

---
## 1. Log high impact decisions AND pending decisions (MUST)

**Always log:**
- Why this language / framework / library
- Why this architecture (monolith vs microservice, REST vs GraphQL, etc.)
- Why this data model
- Why a library was rejected
- Why a simpler approach was chosen over a more correct one
- Any decision made under time pressure or uncertainty

**Never log:**
- Implementation details (how to write a function)
- Decisions with only one reasonable option
- Stylistic choices already covered by rules

## 2. Prompt and accurate logging (MUST)

**ALWAYS:**
- Log the decision at the time it's made, not retroactively.
- Be clear when the user made the decision without being prompted. Log it as "User decision:" so the context is clear.

**NEVER:**
- Log retroactively.
- Be vague about the reasoning when logging a decision. "It's the most popular option" is not a reason. Be specific.
- Edit existing entries UNLESS moving decisions from `Pending` to `Made`
---
## 3. Log pending decisions separately in the same doc (MUST)

The same rules apply. 
1. Pending decisions must be in a separate table from decisions already made. 
2. Once a decision is made, move the pending decision to the Decisions Made table

**ALWAYS:**
Log the pending decision at the time it's needed AND not decided on. 

**NEVER:**
- Put pending decisions in `PARKING-LOT.md`. See `/rules/parking-lot.md`


## Formatting

- Add a new decision to the existing table. If no table exists, create one. 
- If there are entries already, but they're not in the correct format, fix it.
- ALWAYS: Anchor link an entry to expanded details below for easy navigation.

- **Order:** Pending Decisions first, Decisions Made second. 
- **Sort:** Newest date first.

```markdown
## Pending Decisions
<!---Existing decision table below-->
| **Date** | **Decision Needed** | **Why** |**Impact Level**| **At Stake** |
|--|--|--|--|
|{{YYYY-MM-DD}} |{{Short title of decision}}|{{Be specific about the current state and why the decision matters.}}[Notes](#anchor/to/expanded/notes)|{{Impact Level:Use an emoji}}|{{What's depending on this decision, any associated risks}}|

## Decisions Made
<!---Existing decision table below-->
| **Date** | **Decision** | **Why** | **Revisit if** |
|--|--|--|--|
|{{YYYY-MM-DD}} |{{Short title of decision}}|{{Focus on the decision only: Why was it the best option over the others}} }[Notes](#anchor/to/expanded/notes)|{{Condition under which this should be reconsidered}}|


---
```

Further down, add an entry to expand on any details. This applies to both Pending and Decisions Made

```markdown
<a href="/this-doc/anchor-link"></a>
<details><summary>{{YYYY-MM-DD}}: {{ Decision}}</summary>
- **Chosen:** [What was decided]  
- **Why:** [Full reasoning - do not be generic. Focus on the decision only: Why was it the best option over the others]  
- **Trade-offs:** [What is lost or risked with this choice, if applicable.]
- **Alternatives:** [What else was considered. Be concise: The option and why it was declined.]


</details>
```


---


# Output Template

Fill this exact structure once the interview (Steps 1-5 in SKILL.md) is complete. Replace the bracketed text. Do not include brackets or instructions in the final output shown to the user - this file is for your reference only.

---

## Template

```markdown
### Prompt

[Write the outcome the task should reach, in prose. One or two paragraphs max.
State what "done" looks like. Do NOT number this as steps.]

**Guardrails:** [What must not be touched or broken. If the user said "nothing,"
write "No guardrails specified."]

**Verification:** [Exactly how Claude should confirm its own work is correct -
the test suite, diff method, or rubric defined in Step 3. This must be concrete,
never "check that it looks right."]

### Execution mode: [Single agent | Dynamic workflow | Loop | Routine]

**Why:** [One line tying the recommendation back to the user's Step 2/2a/2b answers.]

### Invocation

[Use the matching block below based on the execution mode chosen.]
```

---

## Invocation snippets by mode

**Single agent** (small, one-time):

```
[Paste the Prompt + Guardrails + Verification text above directly as the message to Claude Code. No special invocation needed.]
```

**Dynamic workflow** (large, one-time, multi-stage):

```
[Paste the Prompt + Guardrails + Verification text above], and append:

"Use a workflow."
```

**Loop** (recurring, must run locally):

```
Cadence: [e.g., every day at 9am / every hour]
Runs: locally (requires the machine to stay on)

[Paste the Prompt + Guardrails + Verification text above as the recurring instruction.]

NOTE: This is a draft. Set up the actual local scheduled loop yourself in
Claude Code - this skill does not create or schedule it for you.
```

**Routine** (recurring, can run in the cloud):

```
Cadence: [e.g., every day / every week on Monday]
Runs: in the cloud (machine can be off)

[Paste the Prompt + Guardrails + Verification text above as the recurring instruction.]

NOTE: This is a draft. Set up the actual cloud routine yourself in Claude Code -
this skill does not create or schedule it for you.
```

---

## If Step 5 was "yes" (an existing prompt/CLAUDE.md entry already covers this)

Append this block at the end of the output, after Invocation:

```markdown
### Before you use this

You said an existing prompt/CLAUDE.md entry already covers this task. Don't add
the prompt above on top of it. Instead:

1. Remove or comment out the existing instruction.
2. Run the task with only the new prompt above.
3. Only add back a piece of the old instruction if you observe the same failure
   repeat - not preemptively.
```

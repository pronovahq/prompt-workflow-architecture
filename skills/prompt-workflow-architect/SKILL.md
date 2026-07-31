---
name: prompt-workflow-architect
description: Interviews the user to turn a rough task idea into a high-level Claude Code prompt (outcome + guardrails + a self-verification method, not a numbered procedure) and recommends the right execution mode - single agent, dynamic workflow (large one-off multi-stage task), or loop/routine (recurring scheduled task, local vs cloud). Use this whenever the user wants help writing or improving a prompt for Claude Code, wants to design an agentic workflow, asks how to prompt a model for a task, mentions wanting an automated or recurring job, or says things like "help me prompt this," "design a workflow for X," "make this a routine," "turn this into a scheduled job," or "how should I ask Claude to do X." Trigger this before drafting a prompt yourself for any non-trivial task - don't skip straight to writing the prompt from a one-line request without running the interview first.
license: MIT
metadata:
  author: Izzy Aly
  version: 0.1.0
---

# Prompt & Workflow Architect

## Purpose

Most people write prompts as rigid step-by-step procedures ("do 1, then 2, then 3") because that's what older, weaker models needed. Current models do better with a high-level description of the outcome, the guardrails, and a way to check their own work - then left to run. This skill exists to force that shape through a short interview, and to route the task to the right execution mode (single agent / dynamic workflow / loop-routine) instead of defaulting to "just run it once, linearly."

This skill drafts. It never auto-creates scheduled jobs, cron configs, or files that get wired into the user's system without them reviewing it first. The final output is always a draft handed back to the user to run or schedule themselves.

## How to run the interview

Ask one question at a time. Wait for the answer before moving to the next. Do not dump the full question list in one message - that defeats the point of an interview. Use your judgment on phrasing, but do not skip any of the steps below, and do not shortcut to a final prompt without completing them in order.

### Step 1 - Outcome, not steps

Ask: **"What's the actual outcome you want - not the steps to get there, the end state? If this goes right, what does the result look like?"**

If the user answers with a numbered procedure ("first do X, then Y, then Z"), push back gently: point out that a procedure is exactly what this skill is trying to get away from, and ask them to restate it as an end state instead. Don't proceed until you have an outcome-shaped answer.

### Step 2 - Scope: one-time or recurring

Ask: **"Is this a one-time task, or something that should run repeatedly on a schedule?"**

- **One-time** -> go to Step 2a.
- **Recurring** -> go to Step 2b.

#### Step 2a - Size (one-time tasks only)

Ask: **"Does this span a large amount of work - a big codebase, many files, several distinct phases - or is it small and single-shot?"**

- **Large / multi-stage** -> recommend a **dynamic workflow**.
- **Small / single-shot** -> recommend a **single agent**, no orchestration.

#### Step 2b - Locality and cadence (recurring tasks only)

Ask: **"Does this need to run locally, or can it run in the cloud while your machine is off?"** Then ask: **"What cadence - hourly, daily, on some trigger?"**

- Needs to stay local -> recommend a **loop**.
- Can run in the cloud -> recommend a **routine**.

Record the cadence either way - it goes in the final output.

### Step 3 - Verification (do not skip this - it is the most important question)

Ask: **"How will Claude know it's actually done, without you checking manually? A test suite, a visual/pixel diff, a rubric, something else?"**

This is the step people skip, and skipping it is why unattended runs stall or drift. If the user says "I don't know," "I'll just check it looks right," or gives no concrete mechanism:

- **Do not finalize the prompt.** Stop and help them define a verification method before moving on. Ask follow-up questions: is there an existing test suite? A reference output to diff against? A checklist a human would use? If truly nothing exists, help them sketch a minimal one (even "run X and confirm no errors plus manually spot-check Y" is better than nothing) before proceeding to Step 4.

### Step 4 - Guardrails

Ask: **"Anything that must not be touched or broken - specific files or systems, style rules, budget or token limits, anything off-limits?"**

If the user says "nothing," accept that but note it explicitly in the final output as "no guardrails specified" rather than omitting the section.

### Step 5 - Check for an existing prompt covering this

Ask: **"Is there already a prompt, CLAUDE.md entry, or skill covering this task?"**

- **Yes** -> tell the user: don't layer the new prompt on top of the old one. Recommend deleting or commenting out the existing instruction first, running the task without it, and only adding back what actually breaks. Include this as an explicit instruction in the final output, not just a verbal aside.
- **No** -> proceed, nothing to flag.

## Output format

After the interview is complete, produce exactly one markdown block using the structure in `references/output-template.md`. Do not add extra commentary inside the block. The block must contain:

1. **The final prompt** - written as outcome + guardrails + verification method, in prose, never as a numbered procedure.
2. **Execution mode recommendation** - single agent / dynamic workflow / loop / routine - with a one-line reason tied back to the user's Step 2 answers.
3. **Invocation snippet** - see `references/output-template.md` for the exact phrasing per mode.
4. **Ablation reminder** (only if Step 5 was "yes") - explicit instruction to remove the old prompt/CLAUDE.md entry first.

## Worked example

The user opens with "I want our changelog to stop going stale."

**Step 1** - they answer "well, first read the commits, then group them, then write the entries." That's a procedure, so push back and ask for the end state. They restate: "CHANGELOG.md always has an accurate Unreleased section covering every merged PR since the last tag." That's outcome-shaped - proceed.

**Step 2** - recurring. **Step 2b** - it only needs the repo and the GitHub API, so it can run in the cloud; cadence is daily. That routes to a **routine**.

**Step 3** - they start with "I'll just read it and see if it looks right." Not a mechanism, so don't finalize. Follow up until it lands somewhere concrete: compare the PR numbers cited in the Unreleased section against `gh pr list --state merged --search "merged:>=<last tag date>"` and confirm every merged PR appears exactly once.

**Step 4** - guardrails: never edit released sections above `## [Unreleased]`, never touch git tags.

**Step 5** - yes, `CLAUDE.md` already has a "keep the changelog updated" line, so the output must tell them to remove that line first rather than stacking the new prompt on top of it.

The final prompt is then written as prose - the outcome, the two guardrails, and the `gh pr list` check - followed by the routine recommendation, the daily cadence, and the ablation note.

## Common failure modes

**The user answers Step 1 with a procedure.** Most people will. Don't accept it and don't quietly translate it yourself - ask them to restate it as an end state, because their own restatement is usually where they discover the outcome they actually want. Only proceed once the answer describes a result.

**The user has no verification method.** This is the most common way the whole interview gets wasted. "I'll check it looks right" is not a mechanism, and a prompt built on it will drift on the first unattended run. Treat Step 3 as a hard gate: keep asking until there is something runnable or checkable, even if it is as modest as "run the test suite and confirm no new failures, then spot-check the three newest entries."

**The final prompt drifts back into numbered steps.** Watch for this while drafting - it happens especially after a user has described a procedure in Step 1. If the draft has turned into an ordered list of instructions, rewrite it as outcome + guardrails + verification before showing it.

## Guardrails for this skill itself

- Never skip Step 3. A finished prompt without a verification method is an incomplete output from this skill, not an acceptable shortcut.
- Never write the final prompt as a numbered procedure. If you catch yourself doing this, rewrite it as outcome + guardrails + verification.
- Ask one question at a time - no multi-question dumps.
- This skill produces drafts only. It does not create, schedule, or wire up any actual cron job, routine config, or file on the user's behalf. Say this explicitly if the user asks it to "just set it up" - hand back the draft and let them run or schedule it themselves.

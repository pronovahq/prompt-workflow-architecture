# How it works

The skill runs a five-step interview, one question at a time, then hands back a single markdown block: the prompt, the execution mode, and how to invoke it.

It never creates a cron job, routine config, or scheduled task for you. The output is a draft you run or schedule yourself.

## Why the interview exists

Two habits make prompts fail, and both are invisible to the person writing them.

**Writing procedures instead of outcomes.** Older, weaker models needed "do 1, then 2, then 3." Current models do better with the end state, the guardrails, and a way to check their own work — then left to run. A procedure locks the model into your guess about the right path, which is usually worse than the path it would find. It also breaks the moment reality differs from your assumptions.

**Skipping verification.** This is the expensive one. A prompt with no way for the model to confirm its own work is a prompt that drifts, and you will not notice until you inspect the output yourself — which defeats the point of automating it. Step 3 is a hard gate for that reason: the interview will not finalize a prompt without a concrete check.

## The five steps

| Step | Question | Gate |
|---|---|---|
| 1. Outcome | What's the end state, not the steps? | If you answer with a numbered procedure, it pushes back and asks you to restate. It won't proceed until the answer describes a result. |
| 2. Scope | One-time, or recurring? | Branches to 2a (size) or 2b (locality + cadence). |
| 3. Verification | How will Claude know it's done, without you checking? | **Hard gate.** "It'll look right" is rejected. It asks follow-ups until there's something runnable or checkable. |
| 4. Guardrails | What must not be touched or broken? | "Nothing" is accepted, but recorded explicitly as "no guardrails specified" rather than dropped. |
| 5. Existing prompt | Is there already a prompt, `CLAUDE.md` entry, or skill covering this? | If yes, the output tells you to remove the old instruction first — see Ablation below. |

## Choosing the execution mode

Steps 2, 2a, and 2b decide this. No judgment call on your part.

| Your answers | Mode | What it means |
|---|---|---|
| One-time, small, single-shot | **Single agent** | Paste the prompt as a message. No orchestration. |
| One-time, large or multi-stage | **Dynamic workflow** | Same prompt, plus "Use a workflow." Fans out across phases. |
| Recurring, must run locally | **Loop** | Repeats on your machine. Machine has to stay on. |
| Recurring, can run in the cloud | **Routine** | Repeats in the cloud. Machine can be off. |

The distinction that trips people up is loop vs routine, and it comes down to one question: does the task need something only your machine has — a local database, a VPN, an unpushed working tree? If yes, it's a loop. If it only needs a repo and some APIs, it's a routine.

## A worked example

You open with "I want our changelog to stop going stale."

**Step 1.** You answer "well, first read the commits, then group them, then write the entries." That's a procedure — the skill pushes back and asks for the end state. You restate: *"CHANGELOG.md always has an accurate Unreleased section covering every merged PR since the last tag."* Outcome-shaped. Proceed.

**Step 2.** Recurring. **Step 2b:** it only needs the repo and the GitHub API, so it can run in the cloud; cadence is daily. That routes to a **routine**.

**Step 3.** You start with "I'll just read it and see if it looks right." Not a mechanism. The skill keeps asking until it lands somewhere concrete: *compare the PR numbers cited in the Unreleased section against `gh pr list --state merged --search "merged:>=<last tag date>"` and confirm every merged PR appears exactly once.*

**Step 4.** Guardrails: never edit released sections above `## [Unreleased]`; never touch git tags.

**Step 5.** Yes — `CLAUDE.md` already has a "keep the changelog updated" line. The output will tell you to remove it first.

**The output** is one markdown block: the prompt as prose (outcome, the two guardrails, the `gh pr list` check), the routine recommendation with its daily cadence, the invocation snippet, and the ablation note.

## Ablation: why it tells you to delete the old prompt

If an instruction already covers the task, the instinct is to add the new prompt alongside it. Don't. Two overlapping instructions produce conflicts you can't attribute — when the result is wrong, you can't tell which one caused it, so you end up adding a third instruction to correct the second.

The output instead tells you to remove or comment out the old instruction, run with only the new prompt, and add back a piece of the old one **only if you see the same failure repeat**. Most of what accumulates in a `CLAUDE.md` was added preemptively and never needed.

## Output structure

Defined in [`skills/prompt-workflow-architect/references/output-template.md`](../skills/prompt-workflow-architect/references/output-template.md). Every run produces:

1. **Prompt** — prose. Outcome, then `**Guardrails:**`, then `**Verification:**`. Never a numbered list.
2. **Execution mode** — the mode, plus one line tying it back to your Step 2 answers.
3. **Invocation** — the exact snippet for that mode, including cadence and a "this is a draft, you schedule it" note for loops and routines.
4. **Before you use this** — only when Step 5 was yes. The ablation instruction.

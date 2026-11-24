# prompt-workflow-architect

> A Claude Code skill that interviews you before you write the prompt — so you end up with an outcome, guardrails, and a way for Claude to check its own work, instead of a numbered procedure that drifts.

> **Moved:** this repo now lives at [pronovahq/prompt-workflow-architecture](https://github.com/pronovahq/prompt-workflow-architecture). Links and clones of the old `promptmetrics/prompt-workflow-architecture` address redirect.

## The problem it solves

Two habits quietly waste most of the time people spend prompting.

**You write a procedure.** "First read the files, then group them, then write the output." That's what older, weaker models needed. Current models do better with the end state, the constraints, and a way to verify — then left to run. A procedure locks the model into your guess at the right path, and breaks the moment reality differs from your assumptions.

**You skip verification.** This is the expensive one. If Claude has no way to confirm its own work, you have to inspect the output yourself — which defeats the point of automating it. Unattended runs stall and drift for exactly this reason.

This skill forces the better shape through a short interview, then tells you whether the task should run as a single agent, a dynamic workflow, a local loop, or a cloud routine. It **drafts only** — it never creates or schedules a cron job, routine, or file on your behalf.

## Who it's for

Operators who run real automations and are tired of prompts that work once and then quietly degrade: RevOps and CS leads, DTC and marketing-ops folks, and anyone standing up recurring agent jobs against tools they already pay for. You don't need to write code to use it.

## Install

### Claude Code — plugin marketplace (recommended)

```
/plugin marketplace add pronovahq/prompt-workflow-architecture
/plugin install promptmetrics-prompt-workflow@prompt-workflow-architecture
/reload-plugins
```

The slash command is `/promptmetrics-prompt-workflow:prompt-workflow-architect`. It also triggers on its own when you ask a prompt- or workflow-shaped question — no slash needed.

### Claude Code — local clone

```
git clone https://github.com/pronovahq/prompt-workflow-architecture
cd prompt-workflow-architecture
claude --plugin-dir .
```

Or copy the skill into your personal skills directory so it loads in every project:

```
cp -r skills/prompt-workflow-architect ~/.claude/skills/
```

### Claude.ai

Prerequisite: enable **Code execution and file creation** in **Settings ▸ Capabilities**.

1. Download `prompt-workflow-architect.zip` from the [v0.1.0 release](https://github.com/pronovahq/prompt-workflow-architecture/releases/tag/v0.1.0), or build it locally with `./scripts/build-zip.sh`.
2. Open **Customize ▸ Skills** → **+** → **+ Create skill** → **Upload a skill** → upload the zip.
3. Enable it in **Settings ▸ Capabilities**.

> **Known limitation.** This skill's `description` is 878 characters — well under Anthropic's documented 1024-character limit, and deliberately long so its trigger phrases stay in the matcher. Some upload paths enforce a tighter ceiling. The Claude Code plugin install above is the verified route; if Claude.ai rejects the zip on description length, that's why. Shorten the `description:` line in `SKILL.md` and rebuild if you hit it.

### Claude Cowork

Prerequisite: enable **Code execution and file creation** in **Settings ▸ Capabilities**.

- **Standalone skill:** upload the same zip via **Customize ▸ Skills**.
- **Bundled in a plugin:** add the skill to a Cowork plugin via **Customize ▸ Plugins**.
- **Org-wide:** an owner enables sharing in **Organization settings ▸ Skills**, then the skill's **Share** action shares it with specific people or the whole org.

## What a session looks like

You bring a rough idea — "I want our changelog to stop going stale." The skill asks one question at a time:

1. **Outcome, not steps.** What does the end state look like? If you answer with a numbered procedure, it pushes back and makes you restate it as a result. It won't proceed until you do.
2. **Scope.** One-time or recurring? One-time branches on size (small → single agent, large or multi-stage → dynamic workflow). Recurring branches on locality and cadence (needs your machine → loop, can run in the cloud → routine).
3. **Verification.** How will Claude know it's done without you checking? This is a **hard gate**. "I'll see if it looks right" gets rejected, and it keeps asking until there's something runnable — a test suite, a diff against a reference, a concrete command whose output you can check.
4. **Guardrails.** What must not be touched or broken? "Nothing" is fine, but it gets recorded explicitly rather than dropped.
5. **Existing prompt.** Is something already covering this? If yes, the output tells you to remove the old instruction first and only add pieces back if the same failure actually repeats — instead of stacking two instructions that conflict in ways you can't attribute.

You get back one markdown block: the prompt as prose, the execution mode with a one-line reason, the invocation snippet, and — if relevant — the ablation note.

Full detail, including the mode decision table and a complete worked example: **[docs/how-it-works.md](docs/how-it-works.md)**.

## Repository contents

```
prompt-workflow-architecture/
├── README.md                       # this file
├── LICENSE                         # MIT
├── CONTRIBUTING.md                 # how to change the skill and cut a release
├── CHANGELOG.md                    # version history
├── .claude-plugin/
│   ├── plugin.json                 # promptmetrics-prompt-workflow plugin manifest
│   └── marketplace.json            # prompt-workflow-architecture marketplace manifest
├── docs/
│   └── how-it-works.md             # the five steps, mode decision table, worked example
├── scripts/
│   └── build-zip.sh                # builds dist/prompt-workflow-architect.zip for upload
└── skills/
    └── prompt-workflow-architect/
        ├── SKILL.md                # the interview, output contract, guardrails — model-facing
        ├── references/
        │   └── output-template.md  # exact output structure, loaded only when needed
        └── evals/
            └── evals.json          # trigger / non-trigger test cases
```

Per Anthropic's skills guidance there is deliberately **no `README.md` inside the skill folder** — human-facing documentation lives here and in `docs/`, so only `SKILL.md` and `references/` ship as model context.

## Compatibility

No scripts, no MCP servers, no credentials, no network calls — `prompt-workflow-architect` is a pure conversational skill, and it writes no files. That's why the same folder ships unchanged to Claude Code, Claude.ai, and Claude Cowork, following the open Agent Skills spec. The `.claude-plugin/` manifests are read only by Claude Code's plugin loader; Claude.ai and Cowork use the uploaded zip directly.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for the description-length rules, how to run the eval cases, and the release checklist.

## License

MIT © Izzy Aly. See [LICENSE](LICENSE).

---

Built by [Izzy Aly](https://github.com/iiizzzyyy) at [PromptMetrics](https://github.com/promptmetrics).

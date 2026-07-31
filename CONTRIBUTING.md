# Contributing

Issues and pull requests are welcome. This is a single-skill repository, so most changes touch one file.

## Layout

Only two things ship as model context: `skills/prompt-workflow-architect/SKILL.md` and everything under `skills/prompt-workflow-architect/references/`. Everything else — this file, `README.md`, `docs/` — is for humans and is never loaded into Claude's context.

Per Anthropic's skills guidance, do **not** add a `README.md` inside `skills/prompt-workflow-architect/`. Human-facing docs belong in `docs/`.

## Editing the skill

`SKILL.md` is the interview itself. When changing it, hold these invariants — they are the reason the skill exists:

- **Step 3 (verification) stays a hard gate.** A finished prompt with no verification method is an incomplete output, not an acceptable shortcut.
- **One question at a time.** No multi-question dumps; that turns an interview into a form.
- **The final prompt is prose, never a numbered procedure.** Outcome + guardrails + verification.
- **The skill drafts only.** It must never create, schedule, or wire up a cron job, routine config, or file on the user's behalf.

Keep the body under ~5,000 words. Detail that isn't needed on every run belongs in `references/`, which Claude loads only when it needs it.

### Description length

The `description:` field is what Claude matches against to decide whether to load the skill, so trigger phrases live there rather than in the body.

| Limit | Value | Enforcement |
|---|---|---|
| Anthropic documented maximum | 1024 chars | `scripts/build-zip.sh` **fails** above this |
| Claude.ai / Cowork upload | ~200 chars | `scripts/build-zip.sh` **warns** above this |

The current description is deliberately 878 characters — it keeps every trigger phrase in the matcher, which is what makes the skill fire without a slash command. That is above the upload soft limit, so the Claude Code plugin path is the verified install route. If you shorten it, move the dropped trigger phrases into the body so they aren't simply lost.

Frontmatter must contain no XML angle brackets (`<` or `>`) — it is injected into the system prompt, and the parser rejects them.

## Running the evals

`skills/prompt-workflow-architect/evals/evals.json` holds trigger and non-trigger cases. There is no automated runner; run them by hand:

```
claude --plugin-dir .
```

Then paste each `prompt` into a fresh session and check the result against `expected_output`.

- `should_trigger: true` → the skill loads and opens with the **Step 1 outcome question only**.
- `should_trigger: false` → the skill stays quiet and the request is handled normally.

Case `verification-gate-holds` is the one that matters most. If the skill accepts "I'll just read it over and see if it looks right" and produces a final prompt anyway, the change you made broke the gate.

When you fix a real-world miss, add it as a new case rather than editing an existing one.

## Releasing

1. Bump the version in **three** places — they must match:
   - `skills/prompt-workflow-architect/SKILL.md` → `metadata.version`
   - `.claude-plugin/plugin.json` → `version`
   - `.claude-plugin/marketplace.json` → `plugins[0].version`
2. Add a `CHANGELOG.md` entry under a new heading, following [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
3. Build and inspect the zip:
   ```
   ./scripts/build-zip.sh
   unzip -Z1 dist/prompt-workflow-architect.zip
   ```
   Every path must sit under a single `prompt-workflow-architect/` root. Files at the zip root are the documented upload failure mode.
4. Tag and release:
   ```
   git tag vX.Y.Z && git push --tags
   gh release create vX.Y.Z dist/prompt-workflow-architect.zip
   ```

`dist/` is gitignored on purpose — the zip ships as a release asset, not as a tracked file.

## Pull requests

Conventional commit subjects (`feat:`, `fix:`, `docs:`). Say which eval cases you ran, and add cases for behavior you changed.

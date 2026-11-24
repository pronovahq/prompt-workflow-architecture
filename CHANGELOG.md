# Changelog

All notable changes to this project are documented here.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed

- The repo moved from `promptmetrics/prompt-workflow-architecture` to `pronovahq/prompt-workflow-architecture` on 2026-11-24. Links, the install command and the manifest URLs point to the new address. The old address redirects. The plugin name `promptmetrics-prompt-workflow` is unchanged.

## [0.1.0] - 2026-07-31

Initial public release.

### Added

- `prompt-workflow-architect` skill — a five-step interview (outcome, scope, verification, guardrails, existing-prompt check) that turns a rough task idea into a high-level prompt written as outcome + guardrails + verification, never as a numbered procedure.
- Execution-mode routing: single agent, dynamic workflow, local loop, or cloud routine, decided by the scope answers rather than left to judgment.
- Verification as a hard gate — the interview will not finalize a prompt while the verification method is still undefined.
- Ablation guidance — when an existing prompt or `CLAUDE.md` entry already covers the task, the output instructs removing it first instead of stacking instructions.
- `references/output-template.md` defining the exact output structure and the per-mode invocation snippets.
- `promptmetrics-prompt-workflow` Claude Code plugin and the `prompt-workflow-architecture` marketplace manifest.
- `scripts/build-zip.sh` — builds `dist/prompt-workflow-architect.zip` for Claude.ai and Cowork upload, asserting the folder name matches the frontmatter `name` and that the description stays within Anthropic's 1024-character limit.
- `evals/evals.json` — nine trigger and non-trigger cases, including one asserting the verification gate holds.
- Documentation: `README.md` with install paths for Claude Code (plugin and local clone), Claude.ai, and Cowork; `docs/how-it-works.md` with the mode decision table and a worked example; `CONTRIBUTING.md` with the release checklist.

### Known limitations

- The skill `description` is 878 characters — under Anthropic's documented 1024-character limit, and kept long deliberately so its trigger phrases stay in the matcher. Some upload paths enforce a tighter ceiling, so the Claude Code plugin install is the verified route and `build-zip.sh` warns rather than fails above 200 characters.

[0.1.0]: https://github.com/pronovahq/prompt-workflow-architecture/releases/tag/v0.1.0

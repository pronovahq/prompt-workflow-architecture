#!/usr/bin/env bash
# Build a Claude.ai / Cowork-uploadable zip for the prompt-workflow-architect skill.
# Produces dist/prompt-workflow-architect.zip with the skill folder at the zip root
# (files directly at the zip root is the documented upload failure mode).
set -euo pipefail

cd "$(dirname "$0")/.."

SKILL_DIR="skills/prompt-workflow-architect"
SKILL_MD="$SKILL_DIR/SKILL.md"
OUT_DIR="dist"
OUT="$OUT_DIR/prompt-workflow-architect.zip"

if [ ! -f "$SKILL_MD" ]; then
  echo "ERROR: $SKILL_MD not found" >&2
  exit 1
fi

# Assert the folder name matches the `name` frontmatter field.
FOLDER_NAME="$(basename "$SKILL_DIR")"
NAME_FIELD="$(awk '/^name: /{sub(/^name: /,""); print; exit}' "$SKILL_MD")"
if [ "$FOLDER_NAME" != "$NAME_FIELD" ]; then
  echo "ERROR: folder name '$FOLDER_NAME' != frontmatter name '$NAME_FIELD'" >&2
  exit 1
fi
echo "OK: name='$NAME_FIELD' matches folder '$FOLDER_NAME'"

DESC="$(awk '/^description: /{sub(/^description: /,""); print; exit}' "$SKILL_MD")"
DESC_LEN="${#DESC}"

# Hard limit: Anthropic's documented frontmatter maximum.
if [ "$DESC_LEN" -gt 1024 ]; then
  echo "ERROR: description is $DESC_LEN chars (Anthropic limit 1024)" >&2
  exit 1
fi

# Soft limit: Claude.ai / Cowork upload may reject longer descriptions.
# This skill deliberately runs long to keep its trigger phrases in the matcher.
if [ "$DESC_LEN" -gt 200 ]; then
  echo "WARN: description is $DESC_LEN chars — Claude.ai/Cowork upload may reject it." >&2
  echo "      The Claude Code plugin path is unaffected." >&2
else
  echo "OK: description is $DESC_LEN chars (<=200)"
fi

# Run the official validator if available; otherwise note it (non-fatal).
if command -v skills-ref >/dev/null 2>&1; then
  echo "Running skills-ref validate..."
  skills-ref validate "$SKILL_DIR" || echo "WARN: skills-ref reported issues (review before upload)" >&2
else
  echo "NOTE: 'skills-ref' not installed — skipping validation. Install from https://github.com/agentskills/agentskills/tree/main/skills-ref"
fi

ABS_OUT="$PWD/$OUT_DIR/prompt-workflow-architect.zip"
rm -rf "$OUT_DIR"
mkdir -p "$OUT_DIR"

# Zip from skills/ so the skill folder sits at the zip root.
( cd skills && zip -rq "$ABS_OUT" "prompt-workflow-architect" -x '.DS_Store' -x '*/.DS_Store' )

echo "Built $OUT"
echo "Contents:"
unzip -Z1 "$OUT"

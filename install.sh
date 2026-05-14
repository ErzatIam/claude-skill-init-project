#!/usr/bin/env bash
set -e

SKILL_NAME="init-research-project"
INSTALL_DIR="$HOME/.claude/skills/$SKILL_NAME"
REPO="ErzatIam/claude-skill-init-project"

echo "Installing Claude skill: $SKILL_NAME"

if [ -d "$INSTALL_DIR" ]; then
  echo "Updating existing installation at $INSTALL_DIR"
  rm -rf "$INSTALL_DIR"
fi

mkdir -p "$INSTALL_DIR"

curl -fsSL "https://raw.githubusercontent.com/$REPO/main/$SKILL_NAME/SKILL.md" \
  -o "$INSTALL_DIR/SKILL.md"

echo "Done. Restart Claude Code and use '初始化项目' or 'init project' to trigger the skill."

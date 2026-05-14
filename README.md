# claude-skill-init-project

A Claude Code skill that initializes a structured `.claude/` directory for any new project — research, engineering, data science, etc.

## What it does

When you start a new project, run this skill and it will:

1. Interview you for project details (goal, stack, server, baselines, known pitfalls, references)
2. Scan the current directory for existing files
3. Generate a multi-file `.claude/` config:

```
.claude/
├── CLAUDE.md              # entry point — imports the other files
├── project-statements.md  # goal, scope, success criteria, deadline
├── environment.md         # local/remote setup, how to run
├── rules.md               # protected files, conventions
├── faults.md              # known pitfalls (grows over time)
├── references.md          # key papers / docs (optional)
└── settings.json          # permission allowlist for your stack
```

Claude reads these files automatically at the start of every session — no need to re-explain project context ever again.

## Install

### One-liner (recommended)

```bash
curl -fsSL https://raw.githubusercontent.com/ErzatIam/claude-skill-init-project/main/install.sh | bash
```

### Manual

```bash
mkdir -p ~/.claude/skills/init-research-project
curl -fsSL https://raw.githubusercontent.com/ErzatIam/claude-skill-init-project/main/init-research-project/SKILL.md \
  -o ~/.claude/skills/init-research-project/SKILL.md
```

Restart Claude Code after installing.

## Usage

In any new project directory, say:

```
初始化项目
```
or
```
init project
```

Claude will ask a few questions, scan the directory, and generate the `.claude/` files.

## Updating

Re-run the install one-liner — it will replace the existing skill with the latest version.

## Tips

- **`faults.md`** grows in value over time. Add to it every time you hit a non-obvious bug or constraint.
- **`project-statements.md`** keeps Claude from "helpfully" doing things outside your scope. Keep it updated when direction shifts.
- Works for any project type: ML research, systems, web, data science, etc.

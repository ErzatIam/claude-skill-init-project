---
name: init-research-project
description: "Initialize a structured .claude/ directory for any new project. Use this skill whenever the user says 'init project', '初始化项目', 'setup .claude', 'create project config', 'help me set up Claude for this project', or similar. Also triggers when the user asks to generate CLAUDE.md, rules.md, faults.md, project-statements.md, or environment.md. Works for any project type: research, software engineering, data science, web dev, systems, etc."
user-invocable: true
---

# init-research-project

Generate a structured `.claude/` directory so Claude has persistent context across sessions. The goal: after initialization, you should never need to re-explain project background, constraints, or infrastructure within this directory.

## Workflow

### Step 1: Gather project info via interview

First, extract everything already stated in the conversation. Then ask for what's still missing — all in one numbered list, not across multiple rounds.

```
To set up your .claude/ config, I need a few details:

1. Project name and one-sentence goal
2. Tech stack (languages, frameworks, key tools)
3. Dev environment (local machine, remote servers — ssh address + working dir if any)
4. How to run / test / build the project (the main command you use daily)
5. Key files or directories Claude should know about
6. Any baseline numbers or benchmarks you already have
7. Files or scripts that must NOT be modified without explicit permission
8. Any known pitfalls, constraints, or "gotchas" specific to this project
9. Key references — papers, docs, or prior work Claude should be aware of
   (optional — skip if not applicable)
```

If the project is clearly a specific type (ML research, web app, systems project, etc.), adapt the questions slightly — e.g. ask about hardware targets for an ML project, or about API keys and deployment for a web app. Use judgment; don't ask irrelevant questions.

Use `[unknown]` for anything the user skips.

### Step 2: Scan the current directory

Before writing files, get a quick picture of what's there:

```bash
ls -la
find . -maxdepth 2 -type f | grep -v "/.git/" | head -40
```

Use results to fill in key files more accurately and catch things the user didn't mention (e.g. if `Makefile` exists, note it in run instructions).

### Step 3: Generate the files

Create `.claude/` and write all files. Print a one-line summary after completing.

---

## Files to generate

### `.claude/CLAUDE.md` — entry point only

```markdown
# [Project Name]

> [One-sentence goal]

@.claude/project-statements.md
@.claude/environment.md
@.claude/rules.md
@.claude/faults.md
<!-- @.claude/references.md -->
```

This file is a table of contents only — keep it under 10 lines. All content lives in the imported files.

Uncomment `@.claude/references.md` only if that file is generated (i.e. user provided references).

---

### `.claude/project-statements.md`

Adapt sections based on project type. Research projects need hypothesis + venue; engineering projects need goals + non-goals + success criteria.

```markdown
# Project Statements

## Goal
[What this project is trying to achieve — specific enough that Claude can tell when a proposed approach is off-target]

## Scope
**In scope:**
- [What this project covers]

**Out of scope:**
- [Explicit exclusions — important for preventing Claude from "helpfully" expanding scope]

## Success Criteria
| Metric | Target | Notes |
|--------|--------|-------|
| [metric] | [value] | [how measured] |

## Deadline / Venue
- [Conference, release date, or "TBD"]

## Current Status
[One sentence: where things stand right now]
```

For research projects, rename "Goal" → "Core Hypothesis" and add "Venue / Submission deadline".
For engineering projects, rename "Goal" → "Product Goal" and add "Non-goals" if relevant.

---

### `.claude/environment.md`

Generate only the sections that apply. Skip sections entirely if not relevant (e.g. no "Remote Server" section if it's a purely local project; no "Hardware" section if there's no special target device).

```markdown
# Environment

## Local Machine
- OS: [e.g. macOS Apple Silicon / Ubuntu 22.04]
- [Any local constraints — e.g. "no GPU locally, prototyping only"]

## Remote Server  ← omit if not used
- **SSH**: `ssh [user]@[host]`
- **Working dir**: `[path]`
- **Env setup**: `[e.g. conda activate myenv / source venv/bin/activate]`

## Target Hardware  ← omit if not relevant
- **Device**: [e.g. Snapdragon 8 Gen 3 / Raspberry Pi 5 / AWS t3.large]
- **Constraints**: [e.g. "8GB RAM limit", "no fp32 on NPU", "arm64 only"]

## Tech Stack
- **Language(s)**: [e.g. Python 3.11, C++17]
- **Key frameworks**: [e.g. PyTorch 2.3, FastAPI, React 18]
- **Package manager**: [e.g. conda, pip, npm, cargo]

## How to Run
```bash
# [most common daily command]
[command]

# [second most common, e.g. run tests]
[command]
```
```

---

### `.claude/rules.md`

```markdown
# Rules

## Protected files — do not modify without explicit permission
- `[file or dir]` — [why it's protected, e.g. "canonical benchmark — changes break comparability"]

## Conventions
- [Key coding or workflow conventions for this project]
- [e.g. "all config via yaml, no hardcoded values", "tests must pass before any commit"]

## Before certain operations
- [e.g. "before changing DB schema: back up first", "before modifying shared scripts: check with team"]

## Communication
- [e.g. "respond in Chinese", "code comments in English", "commit messages in English"]
```

If the user mentioned no protected files and no special conventions, keep the sections but add one sensible default based on the tech stack (e.g. for Python projects: "no hardcoded credentials"). Don't invent constraints the user didn't imply.

---

### `.claude/faults.md`

**Important**: This file should contain only real pitfalls — either ones the user explicitly mentioned, or ones you're confident apply to their specific stack based on the interview. Do NOT pre-fill generic domain knowledge the user hasn't encountered yet. That makes the file noise rather than signal.

The exception: if the user's tech stack has a well-known sharp edge that is non-obvious and would cost real debugging time if hit, you may add it under a clearly labeled "Common pitfalls for [tech]" sub-section — but keep it to 2–3 max, and only things that are genuinely surprising (not "remember to handle errors").

```markdown
# Known Faults & Pitfalls

## Project-specific
<!-- Add here as you discover them. Format: bold title, what happened, how you found it, the fix. -->
[Fill from user's answer to question 8, if any. Otherwise leave the comment as a prompt.]

## Common pitfalls for [tech stack]  ← omit entirely if nothing non-obvious applies
[1–3 genuinely surprising gotchas for the specific stack, not generic advice]
```

---

### `.claude/references.md` — only if user provided references

Skip entirely if question 9 was skipped. Don't generate an empty table.

When generated, also uncomment `@.claude/references.md` in `CLAUDE.md`.

```markdown
# Key References

| Title | Source | Relation to this project |
|-------|--------|--------------------------|
| [name] | [Author YYYY / URL / doc name] | [e.g. "baseline to beat", "method we build on", "API we integrate with"] |

<!-- Claude: when suggesting approaches, check whether they align with or contradict these references. -->
```

---

### `.claude/settings.json`

Generate the permissions list based on what the user's tech stack actually needs. Don't include `Bash(nvcc *)` for a web project. Start from this base and add/remove:

```json
{
  "permissions": {
    "allow": [
      "Bash(git log *)",
      "Bash(git diff *)",
      "Bash(git status)"
    ]
  }
}
```

Then append what applies:

| If stack includes... | Add these |
|---------------------|-----------|
| Python / conda | `"Bash(python *)"`, `"Bash(python3 *)"`, `"Bash(conda *)"`, `"Bash(pip *)"` |
| Shell scripts | `"Bash(bash scripts/*)"`, `"Bash(sh scripts/*)"` |
| Remote server | `"Bash(ssh *)"`, `"Bash(scp *)"`, `"Bash(rsync *)"` |
| CUDA / GPU | `"Bash(nvcc *)"`, `"Bash(nsys *)"` |
| Node / npm | `"Bash(npm *)"`, `"Bash(npx *)"` |
| Rust / cargo | `"Bash(cargo *)"` |
| Make / cmake | `"Bash(make *)"`, `"Bash(cmake *)"` |
| Docker | `"Bash(docker *)"` |

---

## After generating

List the files created (one line each). Then say:

- `faults.md` grows in value over time — add to it whenever a new pitfall is found
- `project-statements.md` should be updated when goals or scope shift
- Run `/init` if you also want Claude to scan the codebase for file-level context

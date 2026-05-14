---
name: init-research-project
description: "Initialize a structured .claude/ directory for any new project. Use this skill whenever the user says 'init project', '初始化项目', 'setup .claude', 'create project config', 'help me set up Claude for this project', or similar. Also triggers when the user asks to generate CLAUDE.md, rules.md, faults.md, project-statements.md, or environment.md. Works for any project type: research, software engineering, data science, web dev, systems, etc."
user-invocable: true
---

# init-research-project

Generate a structured `.claude/` directory so Claude has persistent context across sessions. The goal: after initialization, you should never need to re-explain project background, constraints, or infrastructure within this directory.

## Core principle: conversational, not interrogational

**Never dump all questions at once.** Conduct the interview in rounds — at most 3 questions per round. Always use `AskUserQuestion` to present options. Provide smart defaults based on what the directory scan reveals and what was already answered.

---

## Workflow

### Step 0: Quick directory scan

Before asking anything, get a picture of what's already there:

```bash
ls -la
find . -maxdepth 2 -type f | grep -v "/.git/" | head -40
```

Note clues: existing README, config files, setup scripts, language-specific files (pyproject.toml, package.json, CMakeLists.txt, etc.). Use these to pre-fill smart defaults in later questions.

---

### Step 1: Interview (round by round)

Extract whatever the user already stated in the conversation before asking. Then proceed round by round. Each round uses `AskUserQuestion` with **2–3 questions max**.

#### Round 1 — Project identity (2 questions)

Ask about **project type** and **one-sentence goal**.

- **Project type** (single-select): provide options relevant to what the directory scan suggests. Typical options:
  - ML/AI Research (training, inference, optimization)
  - Systems / Infra (databases, compilers, kernels)
  - Web Application (frontend, backend, full-stack)
  - Data Science / Analytics
  - Mobile / Embedded
  - Other

- **One-sentence goal** (single-select with templates): offer 3–4 goal templates based on the detected project type, plus "I'll write my own". Keep templates generic enough to fit most projects of that type. Examples by type:
  - ML/AI: "Train a model for [task]" / "Optimize inference on [hardware]" / "Benchmark approaches for [problem]"
  - Web: "Build a [dashboard/API/landing page] for [audience]" / "Migrate [feature] from [old stack] to [new stack]"
  - Systems: "Build a [database/compiler/proxy] that handles [workload]" / "Optimize [component] for [metric]"
  - Data Science: "Analyze [dataset] to answer [question]" / "Build a pipeline to ingest and transform [data source]"

Use the directory scan clues to make the template options as specific as possible.

#### Round 2 — Tech & environment (2–3 questions)

Adapt options based on the project type from Round 1.

- **Primary language & frameworks** (multi-select): tailor options per project type. Examples:
  - ML/AI: Python + PyTorch, Python + JAX, Python + TensorFlow, C++/CUDA, Other
  - Web: TypeScript + React, TypeScript + Vue, Python + FastAPI/Django, Go, Other
  - Systems: C++/CUDA, Rust, C, Python + C extensions, Other

- **Dev environment** (multi-select):
  - Local machine only
  - Remote Linux server (SSH)
  - Cloud VM (AWS/GCP/Azure)
  - Mobile / embedded device
  - CI/CD only

- **Package manager** (single-select):
  - conda / mamba
  - pip / venv
  - poetry / uv
  - npm / yarn / pnpm
  - cargo
  - Other

#### Round 3 — Remote server details (1–2 questions — skip entirely if Round 2 was "local only")

Only ask if the user indicated a remote environment.

- **SSH connection**: free text with a template hint — `user@host`
- **Working directory + env setup**: free text with a template hint — `/home/user/project`, then `conda activate myenv` or `source venv/bin/activate`

These are free-text questions, so use single-select with a "I'll type it" option and maybe 1–2 pre-filled guesses from the directory scan.

#### Round 4 — Operations & guardrails (2–3 questions)

- **How to run / test** (multi-select or single-select with templates):
  - `python main.py` / `python train.py`
  - `bash scripts/run.sh`
  - `pytest` / `npm test` / `cargo test`
  - `make` / `cmake --build .`
  - "I'll describe it"

- **Protected files** (multi-select): list files/dirs the directory scan found that look important (e.g. `data/`, `config.yaml`, `benchmark.py`), plus:
  - "Nothing needs protection"
  - "I'll specify"

- **Known pitfalls** (single-select):
  - "No known pitfalls yet"
  - "There are a few — I'll describe them"

#### Round 5 — Optional extras (1–2 questions — skip if the user seems in a hurry)

- **Baseline numbers**: single-select with templates like:
  - "No baselines yet — this is exploratory"
  - "I have some numbers — I'll share them below"
  - "Skip for now"

- **Key references** (papers, docs, prior work): single-select:
  - "Skip for now"
  - "I'll list a few"

If the user chooses "skip" for both, skip this round entirely.

#### Round 6 — Final preferences (1 multi-select question, adapt options by project type)

Wrap up by asking if the user has any behavioral preferences they want baked into the config. This must be **multi-select** so the user can pick several preferences at once. Generate 3–4 options that fit the project type and the conversation so far — don't reuse the same static list every time. The goal is to surface useful defaults the user might not think to ask for.

Some inspiration (pick 3–4 that fit, or invent better ones):

| Project type | Suggested options |
|---|---|
| Research / ML | "Record each failed experiment result in faults.md", "Profile before optimizing any kernel", "Explain tradeoffs before coding", "Summarize after each task" |
| Web / Product | "Never modify DB schema without asking", "Run tests before suggesting a fix is done", "After each PR merge — update project-statements.md", "Keep UI changes accessible (a11y)" |
| Systems / Infra | "Always benchmark before and after a change", "Don't modify build system without asking", "Explain memory and CPU impact of each change" |
| General | "After each mistake — record it in faults.md", "After completing a task — short summary", "When suggesting approaches — explain tradeoffs first" |

Always include "No special preferences" as an option. If the user selects it alongside other preferences, treat "No special preferences" as the only selection and skip adding anything.

Write whatever the user selects into the most appropriate section of `rules.md`. Use a `## Workflow` or `## Communication` or `## Before certain operations` heading as needed. If the user types a custom instruction, place it where it fits best.

If the user selects only "No special preferences", skip without adding anything.

#### Stopping early

If at any point the user says "just generate the files" or indicates they don't want more questions, stop the interview and use `[unknown]` for unanswered fields.

---

### Step 2: Generate the files

Create `CLAUDE.md` at project root, plus `.claude/` directory with all sub-files. Print a one-line summary after creating each file.

---

## Files to generate

### `CLAUDE.md` — entry point (project root, NOT inside `.claude/`)

Write this file at the project root so Claude Code auto-loads it. All content lives in the imported sub-files.

```markdown
# [Project Name]

> [One-sentence goal]

@.claude/project-statements.md
@.claude/environment.md
@.claude/rules.md
@.claude/faults.md
<!-- @.claude/references.md -->
```

Uncomment `@.claude/references.md` only if references were provided.

---

### `.claude/project-statements.md`

Adapt sections based on project type:

```markdown
# Project Statements

## [Goal / Core Hypothesis]
[What this project is trying to achieve — specific enough that Claude can tell when a proposed approach is off-target]

## Scope
**In scope:**
- [What this project covers]

**Out of scope:**
- [Explicit exclusions — prevents Claude from "helpfully" expanding scope]

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
For engineering projects, rename "Goal" → "Product Goal" and add "Non-goals".

---

### `.claude/environment.md`

Generate only the sections that apply. Skip sections entirely if not relevant.

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
- **Device**: [e.g. Snapdragon 8 Gen 3 / Raspberry Pi 5]
- **Constraints**: [e.g. "8GB RAM limit", "arm64 only"]

## Tech Stack
- **Language(s)**: [e.g. Python 3.11, C++17]
- **Key frameworks**: [e.g. PyTorch 2.3, FastAPI]
- **Package manager**: [e.g. conda, pip, npm]

## How to Run
```bash
# [most common daily command]
[command]

# [second most common]
[command]
```
```

---

### `.claude/rules.md`

```markdown
# Rules

## Protected files — do not modify without explicit permission
- `[file or dir]` — [why it's protected]

## Conventions
- [Key coding or workflow conventions for this project]

## Before certain operations
- [e.g. "before changing DB schema: back up first"]

## Communication
- [e.g. "respond in Chinese", "code comments in English"]
```

If the user mentioned no protected files and no special conventions, keep the sections but add one sensible default (e.g. "no hardcoded credentials" for Python projects). Don't invent constraints the user didn't imply.

---

### `.claude/faults.md`

Only include real pitfalls — ones the user explicitly mentioned, or genuinely surprising gotchas for their specific stack. Don't pre-fill generic advice.

```markdown
# Known Faults & Pitfalls

## Project-specific
<!-- Add as you discover them. Format: bold title, what happened, how you found it, the fix. -->
[Fill from user's answer, if any. Otherwise leave the comment as a prompt.]

## Common pitfalls for [tech stack]  ← omit if nothing non-obvious applies
[1–3 genuinely surprising gotchas, not generic advice]
```

---

### `.claude/references.md` — only if user provided references

Skip entirely if no references. When generated, also uncomment `@.claude/references.md` in `CLAUDE.md`.

```markdown
# Key References

| Title | Source | Relation to this project |
|-------|--------|--------------------------|
| [name] | [Author YYYY / URL / doc name] | [e.g. "baseline to beat", "method we build on"] |

<!-- Claude: when discussing approaches or comparing against baselines from this table,
     use WebFetch (arXiv, open-access) or Read (local PDF) to pull the actual paper content
     before making claims. Don't rely on the title alone. -->
```

---

### `.claude/settings.json`

Start from this base and add based on the user's actual tech stack:

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

Then append based on detected stack:

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

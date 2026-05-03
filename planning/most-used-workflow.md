# Workflow: Curate & Install Most-Used Skills / Prompts / Commands

## Goal
Maintain a personal "favorites" list so you can bootstrap any project with your preferred AI components in one step.

---

## 1. Inventory Phase

**When:** Whenever you finish a task and think "I'll need this again."

**Steps:**
1. Identify the component you used (skill, prompt, command, tool, agent, workflow).
2. Note its:
   - **Name** (kebab-case)
   - **Category** (`skill`, `prompt`, `command`, `tool`, `agent`, `workflow`)
   - **Platform** (`all`, `pi`, `opencode`, `copilot`, `codex`, `claude`)
   - **Scope** (`global` vs `project-specific`)
3. Append it to your personal index (see §4).

---

## 2. Installation Phase

**Option A — Batch install from your favorites index**
```bash
# Example: install everything tagged 'daily-driver' from catalog.tsv
cut -f1,2,3,4,5 catalog.tsv | grep 'daily-driver' | \
  awk '{print $1}' | xargs -I {} ./scripts/skillkit.sh install {}
```

**Option B — One-off addition (preferred)**
```bash
# Add one component at a time, deliberately
./scripts/skillkit.sh add <category>/<name>

# External component (fetched at install time)
./scripts/skillkit.sh install <name>
```

**Option C — Project bootstrap**
```bash
# Install your full "daily-driver" stack into the current project
./scripts/skillkit.sh install --tag daily-driver

# Or pick only specific skills to avoid bloat
./scripts/skillkit.sh install prompt-engineer quick-commit
```

---

## 3. Maintenance Phase

| Trigger | Action |
|---------|--------|
| New component created | Add to `skills/<name>/` + update `catalog.tsv` + tag it |
| Component deprecated | Remove from `catalog.tsv`, archive `skills/<name>/` |
| Switching machines | Run `./scripts/skillkit.sh install --tag daily-driver` |
| Team onboarding | Share subset of `catalog.tsv` or generate a portable manifest |

---

## 4. Personal Index Format

Keep a `favorites.tsv` (or YAML frontmatter block in a markdown file) in your dotfiles repo:

```tsv
name	category	platforms	tags	source
prompt-engineer	prompt	all	daily-driver, coding	internal
quick-commit	command	all	daily-driver, git	internal
claude-web-search	agent	claude	research	external
```

**Rules:**
- Keep **one unified** `favorites.tsv` (not per-platform).
- Tag with `daily-driver` for anything you want on every project.
- Tag with `occasional` for rare but important components.
- Tag with `critical` for project-type-specific overrides (e.g., `frontend-critical`).
- Keep `source` as `internal` (this repo) or `external` (third-party).

---

## 5. Automation Hooks

- **Pre-project scaffold:** Add a `Makefile` or `justfile` target:
  ```make
  bootstrap-ai:
      # Install only critical + chosen daily-drivers
      ./scripts/skillkit.sh install --from favorites.tsv --tag daily-driver,critical
  ```
- **CI check:** Ensure `catalog.tsv` entries referenced in `favorites.tsv` still exist.
- **Sync script:** A small shell script that copies your `favorites.tsv` into the repo before running the installer.
- **Scrutiny gate:** Before adding any new component, ask: *"Will this still be useful in 3 months, or will the model make it obsolete?"*

---

## Open Questions

1. Should the installer support `--from <custom-tsv>` natively?  
   **→ Yes.** Encourage one-at-a-time additions, but allow batch from a curated file.
2. Should favorites be stored per-platform or unified?  
   **→ Unified.** Use the `platforms` column to filter at install time.
3. How should project-specific overrides work?  
   **→ Only for `critical` tagged components.** Skip nice-to-haves to avoid bloat.
4. Should there be a `pin` command to lock versions of external skills?  
   **→ Not required.** Keep external skills unpinned for now.
5. What's the best way to quickly preview a skill before adding it to favorites?  
   **→ Read the source markdown directly.** Scrutinize before adding — avoid accumulating stale steer components as models evolve.

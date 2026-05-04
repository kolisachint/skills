# Skill Installation Sources

This document captures the actual installation instructions from each skill's GitHub README for reference. Use this to verify catalog accuracy and handle platform-specific installations.

---

## superpowers (obra/superpowers)
**Source:** https://github.com/obra/superpowers
**Category:** workflow  
**Platforms:** Claude Code (official marketplace + superpowers marketplace)

### Claude Code - Official Marketplace
```bash
/plugin install superpowers@claude-plugins-official
```

### Claude Code - Superpowers Marketplace
```bash
/plugin marketplace add obra/superpowers-marketplace
/plugin install superpowers@superpowers-marketplace
```

**Note:** The catalog uses `npx skills add obra/superpowers --yes` which is the generic form.

---

## agent-skills (addyosmani/agent-skills)
**Source:** https://github.com/addyosmani/agent-skills  
**Category:** skill  
**Platforms:** Claude Code (marketplace)

### Claude Code
```bash
/plugin marketplace add addyosmani/agent-skills
/plugin install agent-skills@addy-agent-skills
```

**SSH Issues?** Use HTTPS:
```bash
/plugin marketplace add https://github.com/addyosmani/agent-skills.git
/plugin install agent-skills@addy-agent-skills
```

### Cursor
(See README for Cursor-specific instructions)

**Note:** The catalog uses `npx skills add addyosmani/agent-skills --yes`.

---

## caveman (JuliusBrussee/caveman)
**Source:** https://github.com/JuliusBrussee/caveman  
**Category:** command  
**Platforms:** Claude Code, Codex

### Claude Code
```bash
npx skills@latest add JuliusBrussee/caveman
```

### Codex
(Plugin available for Codex)

**Note:** The catalog uses `npx skills add JuliusBrussee/caveman --yes`.

---

## grill-me (mattpocock/skills)
**Source:** https://github.com/mattpocock/skills  
**Category:** command  
**Platforms:** Claude Code, Codex, (part of multi-skill repo)

### Installation
```bash
npx skills@latest add mattpocock/skills
```

Then run `/setup-matt-pocock-skills` in your agent to configure.

**Note:** This is a multi-skill repository. The catalog uses `--skill grill-me` to install just that specific skill. Full setup requires running the setup command.

---

## plannotator (backnotprop/plannotator)
**Source:** https://github.com/backnotprop/plannotator  
**Category:** command  
**Platforms:** Claude Code, Copilot CLI, Gemini CLI, OpenCode, Pi, Codex

### Claude Code
```bash
# Install CLI
curl -fsSL https://plannotator.ai/install.sh | bash

# Install plugin
/plugin marketplace add backnotprop/plannotator
```

### Copilot CLI
```bash
# Install CLI
curl -fsSL https://plannotator.ai/install.sh | bash

# In Copilot CLI:
/plugin marketplace add backnotprop/plannotator
/plugin install plannotator-copilot@plannotator
```

### Gemini CLI
```bash
# Install CLI (auto-detects Gemini)
curl -fsSL https://plannotator.ai/install.sh | bash

# Commands:
/plan                              # Enter plan mode
/plannotator-review                # Code review
/plannotator-review <pr-url>       # Review PR
/plannotator-annotate <file.md>    # Annotate file
```

### OpenCode
Add to `opencode.json`:
```json
{
  "plugin": ["@plannotator/opencode@latest"]
}
```

Then run install script for slash commands.

### Pi
```bash
pi install npm:@plannotator/pi-extension
```

Then start Pi with `--plan` or toggle with `/plannotator`.

### Codex
```bash
# Install CLI
curl -fsSL https://plannotator.ai/install.sh | bash
```

Restart Codex Desktop after installing.

**Codex Commands:**
```
$plannotator-review          # Code review skill
$plannotator-annotate        # Annotate file/URL/folder
$plannotator-last            # Annotate last message

!plannotator review           # Direct command
!plannotator review <pr-url>  # Review PR
!plannotator annotate file.md # Annotate file
!plannotator last             # Annotate last message
```

**Note:** The catalog only has the Pi command (`pi install npm:@plannotator/pi-extension`). Other platforms need the install script + plugin commands.

---

## codeburn
**Source:** (npm package)  
**Category:** tool  
**Platforms:** All (global npm CLI tool)

### Installation
```bash
npm install -g codeburn
```

**Note:** This is a standalone CLI tool, not an agent skill. It runs independently of any coding agent.

---

# Platform Installation Patterns

## Claude Code
Most skills use:
```bash
/plugin marketplace add <owner>/<repo>
/plugin install <skill-name>@<marketplace-name>
```

Or via `npx skills add` for simpler skills.

## Copilot CLI
Uses VS Code extension model:
```bash
/plugin marketplace add <owner>/<repo>
/plugin install <skill-id>@<publisher>
```

## OpenCode
Uses `opencode.json` config or `npx skills add -a opencode`.

## Pi
Uses `pi install`:
```bash
pi install npm:@<scope>/<package>
# or
pi install https://github.com/<owner>/<repo>
```

## Codex
Uses `codex skills add` (transformed from npx skills) or plugin marketplace.

---

# Catalog Accuracy Notes

1. **superpowers**: Catalog uses generic `npx skills`, but actual install uses `/plugin` commands
2. **agent-skills**: Catalog uses generic, actual uses marketplace
3. **plannotator**: Catalog only has Pi command, but skill supports 6 platforms
4. **grill-me**: Catalog uses `--skill` flag, but full setup requires running setup command
5. **codeburn**: Correct as-is (global npm tool)

# Recommendations

- Consider adding per-platform install commands to catalog
- Document when post-install setup commands are required
- Note which skills need additional marketplace registration

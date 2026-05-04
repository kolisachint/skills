Here is the expanded reference covering skill installation and management across all major AI coding agents.

# External Documentation References

Comprehensive links for skill installation, configuration, and authoring across terminal-based AI coding agents.

## Pi Coding Agent

- **Skills**: [https://pi.dev/docs/latest/skills](https://pi.dev/docs/latest/skills)
- **Quickstart**: [https://pi.dev/docs/latest/quickstart](https://pi.dev/docs/latest/quickstart)
- **Packages**: [https://pi.dev/packages](https://pi.dev/packages)
- **Prompt Templates**: [https://pi.dev/docs/latest/prompt-templates](https://pi.dev/docs/latest/prompt-templates)
- **Settings**: [https://pi.dev/docs/latest/settings](https://pi.dev/docs/latest/settings)

> User feedback: Pi is surgical - precise, good control - but comparatively slow.
> Use it when accuracy matters more than speed. Prefer for hard reasoning,
> architecture, and review. Route bounded tasks elsewhere.

> **Install syntax**: `pi install npm:@scope/package` or `pi install https://github.com/owner/repo`
>
> **Skill directory**: `.pi/skills/`

## OpenCode

- **Skills**: [https://opencode.ai/docs/skills/](https://opencode.ai/docs/skills/)
- **Commands**: [https://opencode.ai/docs/commands/](https://opencode.ai/docs/commands/)
- **Permissions**: [https://opencode.ai/docs/permissions/](https://opencode.ai/docs/permissions/)
- **Rules (AGENTS.md)**: [https://opencode.ai/docs/rules/](https://opencode.ai/docs/rules/)
- **CLI Reference**: [https://opencode.ai/docs/cli/](https://opencode.ai/docs/cli/)

> **Install syntax**: `npx skills add owner/repo -a opencode -g -y` or manual drop-in to `.opencode/skills/`
>
> **Note**: OpenCode requires the `-a opencode` flag when using `npx skills add`. The install.sh transforms commands automatically when `--platform opencode` is specified.
>
> **Skill directory**: `.opencode/skills/`

## OpenAI Codex

- **Skills**: [https://developers.openai.com/codex/skills](https://developers.openai.com/codex/skills)
- **Subagents**: [https://developers.openai.com/codex/subagents](https://developers.openai.com/codex/subagents)

> **Install syntax**: `codex skills add <skill-name>`
>
> **Note**: Codex uses a different CLI command (`codex skills add`) rather than `npx skills`. The install.sh transforms commands automatically when `--platform codex` is specified.
>
> **Skill directory**: `.codex/skills/`

## GitHub Copilot

- **Agent Skills**: [https://docs.github.com/en/copilot/concepts/agents/about-agent-skills](https://docs.github.com/en/copilot/concepts/agents/about-agent-skills) 
- **Custom Agents**: [https://docs.github.com/en/copilot/concepts/agents/cloud-agent/about-custom-agents](https://docs.github.com/en/copilot/concepts/agents/cloud-agent/about-custom-agents)
- **CLI Plugins**: [https://docs.github.com/copilot/concepts/agents/copilot-cli/about-cli-plugins](https://docs.github.com/copilot/concepts/agents/copilot-cli/about-cli-plugins)

> **Install syntax**: `gh copilot -- plugin install owner/repo`
> 
> **Note**: Copilot CLI requires the `gh` CLI with Copilot extension. The install.sh transforms `npx skills add` to `gh copilot -- plugin install` automatically when `--platform copilot` is specified.
> 
> **Skill directory**: `.github/copilot/skills/` (CLI plugins) or VS Code extensions

## Claude (Claude Code)

- **Agent Skills**: [https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview)

> **Install syntax**: `npx skills add owner/repo --yes` (standard, no special flags needed)
> 
> **Note**: Claude Code uses the standard `npx skills` command without platform-specific flags. The install.sh uses commands as-is when `--platform claude` is specified.
> 
> **Skill directory**: `.claude/skills/`

## Cross-Platform Skill Tools

- **npx skills (Vercel)**: [https://github.com/vercel-labs/skills](https://github.com/vercel-labs/skills)
- **add-skill CLI**: [https://add-skill.org](https://add-skill.org)

***

*Last updated: 2026-05-04*

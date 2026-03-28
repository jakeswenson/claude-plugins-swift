# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

A Claude Code plugin marketplace (`swift-tools`) containing plugins for Swift development. The marketplace name in `.claude-plugin/marketplace.json` (`"name": "swift-tools"`) is what appears after `@` in install commands (e.g., `/plugin install swift-bazel@swift-tools`).

## Commands

```bash
# Validate plugin structure, frontmatter, and hooks
claude plugin validate .
/plugin validate .

# Test a plugin locally without installing
claude --plugin-dir ./plugins/swift-bazel

# Test multiple plugins
claude --plugin-dir ./plugins/swift-bazel --plugin-dir ./plugins/another-plugin
```

## Repository Structure

```
.claude-plugin/marketplace.json                      # Marketplace manifest — the entry point
plugins/<name>/.claude-plugin/plugin.json            # Per-plugin manifest (name, description, version)
plugins/<name>/skills/<skill>/SKILL.md               # Skill definition (frontmatter + body)
plugins/<name>/skills/<skill>/references/            # Reference docs loaded by the skill
plugins/<name>/commands/                             # Slash commands (optional)
plugins/<name>/agents/                               # Subagent definitions (optional)
plugins/<name>/hooks/hooks.json                      # Event handlers (optional)
plugins/<name>/.mcp.json                             # MCP server config (optional)
```

## Adding a New Plugin

1. Create `plugins/<name>/.claude-plugin/plugin.json` with `name`, `description`, `version`
2. Add skills under `plugins/<name>/skills/<skill-name>/SKILL.md`
3. Add reference docs under `plugins/<name>/skills/<skill-name>/references/` if needed
4. Register the plugin in `.claude-plugin/marketplace.json` under the `plugins` array
5. Validate: `claude plugin validate ./plugins/<name>`

## Skill Frontmatter

Skills are Markdown files with YAML frontmatter. The `description` field is critical — Claude uses it to decide when to activate the skill. Write it as a comprehensive list of trigger scenarios, not a summary.

```yaml
---
name: skill-name
description: >-
  Detailed trigger description listing all scenarios when this skill should activate.
  Be exhaustive — if a scenario isn't listed, Claude may not activate the skill for it.
disable-model-invocation: true  # optional: only user can trigger via /skill-name
allowed-tools: Read, Grep       # optional: restrict which tools the skill can use
---
```

## Gotchas

- **Marketplace name = install scope**: The `name` in `marketplace.json` (`swift-tools`) is the `@marketplace` suffix in install commands. Changing it breaks existing installs.
- **Skills are auto-discovered**: Any `SKILL.md` under `skills/` is found automatically. No registration in `plugin.json` needed.
- **Component dirs must be at plugin root**: `commands/`, `agents/`, `skills/`, `hooks/` go directly under the plugin directory, not inside `.claude-plugin/`.
- **Local plugin takes precedence**: When testing with `--plugin-dir`, if the local plugin shares a name with an installed one, the local version wins for that session.

## Documentation References

When working on plugin structure or skill authoring, look up current docs via context7:

| Topic | Context7 ID | Notes |
|-------|-------------|-------|
| Claude Code (GitHub source) | `/anthropics/claude-code` | Plugin dev skills, reference implementations |
| Claude Code (docs site) | `/websites/code_claude` | Official docs: plugin-marketplaces, skills, plugins-reference |

Key doc pages:
- https://code.claude.com/docs/en/plugins — Plugin overview and local testing
- https://code.claude.com/docs/en/plugin-marketplaces — Marketplace creation and distribution
- https://code.claude.com/docs/en/plugins-reference — Full plugin.json schema and component reference
- https://code.claude.com/docs/en/skills — Skill authoring, frontmatter fields, invocation control
- https://code.claude.com/docs/en/slash-commands — Command and skill frontmatter YAML reference

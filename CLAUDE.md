# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

A Claude Code plugin marketplace (`swift-tools`) containing plugins for Swift development. Plugins are installed via `/plugin marketplace add` and `/plugin install` in Claude Code.

## Repository Structure

```
.claude-plugin/marketplace.json    # Marketplace manifest — lists all plugins
plugins/<name>/.claude-plugin/     # Per-plugin manifest (plugin.json with name, description, version)
plugins/<name>/skills/             # Skills provided by the plugin
plugins/<name>/skills/<skill>/SKILL.md              # Skill definition (frontmatter + content)
plugins/<name>/skills/<skill>/references/           # Reference docs loaded by the skill
```

The marketplace manifest (`.claude-plugin/marketplace.json`) is the entry point. Each plugin listed there has its own `plugin.json` and one or more skills.

## Adding a New Plugin

1. Create `plugins/<name>/.claude-plugin/plugin.json` with `name`, `description`, `version`
2. Add skills under `plugins/<name>/skills/<skill-name>/SKILL.md`
3. Add reference docs under `plugins/<name>/skills/<skill-name>/references/` if needed
4. Register the plugin in `.claude-plugin/marketplace.json` under the `plugins` array

## Skill Anatomy

Skills are Markdown files with YAML frontmatter:

```yaml
---
name: skill-name
description: >-
  Detailed trigger description — Claude uses this to decide when to activate the skill.
  Be specific about trigger conditions.
---
```

The `description` field is critical — it determines when Claude activates the skill. Write it as a comprehensive list of trigger scenarios, not a summary.

## Current Plugins

- **swift-bazel** (`v0.1.0`): Bazel + Swift project setup and maintenance. Covers project scaffolding, dependency tree knowledge, version compatibility, context7 doc lookups, SPM integration, and common pitfalls.

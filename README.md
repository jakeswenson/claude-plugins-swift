# claude-plugins-swift

A [Claude Code](https://docs.anthropic.com/en/docs/claude-code) plugin marketplace for Swift development.

## Plugins

### swift-bazel

When Claude Code detects you're working with Bazel + Swift, this skill automatically provides:

- **Project scaffolding** — Full project templates (MODULE.bazel, BUILD.bazel, Package.swift, Info.plist, entitlements, asset catalogs)
- **Dependency tree knowledge** — Knows which rules depend on which (apple_support -> rules_swift -> rules_apple -> rules_swift_package_manager)
- **Version compatibility** — Guides version updates in the correct bottom-up order, knows where to check compatibility
- **Context7 doc lookups** — Has library IDs for rules_swift, rules_apple, rules_swift_package_manager, rules_xcodeproj, and Gazelle
- **SPM integration** — The `swiftpkg_*` naming convention, adding deps, resolving, discovering target labels
- **Common pitfalls** — `@main` + `swift_test` conflicts, transitive deps in `use_repo`, `actool` failures, font bundling patterns

#### Known compatible version set (tested March 2026)

| Rule | Version |
|------|---------|
| Bazel | 9.0.1 |
| apple_support | 2.5.0 |
| rules_cc | 0.2.17 |
| rules_swift | 3.5.0 |
| rules_apple | 4.5.2 |
| rules_swift_package_manager | 1.13.0 |
| rules_xcodeproj | 4.0.0 |
| swiftlint | 0.63.2 |
| gazelle | 0.48.0 |
| swift_gazelle_plugin | 0.2.2 |

## Installation

### Step 1: Add the marketplace

In Claude Code, add this repo as a plugin marketplace:

```
/plugin marketplace add jakeswenson/claude-plugins-swift
```

Or from a local clone:

```
/plugin marketplace add /path/to/claude-plugins-swift
```

### Step 2: Install the plugin

```
/plugin install swift-bazel@swift-tools
```

You'll be prompted to choose an installation scope:

| Scope | Effect |
|-------|--------|
| **User** | Available in all your projects |
| **Project** | Shared with collaborators (saved in `.claude/settings.json`) |
| **Local** | Only you, only this repo (saved in `.claude/settings.local.json`) |

### Alternative: Interactive UI

Run `/plugin` in Claude Code to open the plugin browser. Navigate to the **Discover** tab to browse and install.

### Updating

```
/plugin marketplace update swift-tools
```

### Uninstalling

```
/plugin uninstall swift-bazel@swift-tools
```

## License

MIT

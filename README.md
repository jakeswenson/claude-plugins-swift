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
| Bazel | 8.4.2 |
| apple_support | 1.23.1 |
| rules_swift | 3.1.2 |
| rules_apple | 4.2.0 |
| rules_swift_package_manager | 1.11.0 |
| rules_xcodeproj | 3.5.1 |
| swiftlint | 0.62.2 |
| gazelle | 0.45.0 |
| swift_gazelle_plugin | 0.2.2 |

## Installation

### From GitHub

In Claude Code:

```
/plugin marketplace add jakeswenson/claude-plugins-swift
/plugin install swift-bazel@swift-tools
```

### From a local clone

```bash
git clone https://github.com/jakeswenson/claude-plugins-swift.git
```

Then in Claude Code:

```
/plugin marketplace add ./claude-plugins-swift
/plugin install swift-bazel@swift-tools
```

## License

MIT

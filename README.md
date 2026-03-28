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
| [Bazel][bazel] | [9.0.1][bazel-rel] |
| [apple_support][apple_support] | [2.5.0][apple_support-rel] |
| [rules_cc][rules_cc] | [0.2.17][rules_cc-rel] |
| [rules_swift][rules_swift] | [3.5.0][rules_swift-rel] |
| [rules_apple][rules_apple] | [4.5.2][rules_apple-rel] |
| [rules_swift_package_manager][rspm] | [1.13.0][rspm-rel] |
| [rules_xcodeproj][rules_xcodeproj] | [4.0.0][rules_xcodeproj-rel] |
| [swiftlint][swiftlint] | [0.63.2][swiftlint-rel] |
| [gazelle][gazelle] | [0.48.0][gazelle-rel] |
| [swift_gazelle_plugin][sgp] | [0.2.2][sgp-rel] |

[bazel]: https://github.com/bazelbuild/bazel
[bazel-rel]: https://github.com/bazelbuild/bazel/releases/tag/9.0.1
[apple_support]: https://github.com/bazelbuild/apple_support
[apple_support-rel]: https://github.com/bazelbuild/apple_support/releases/tag/2.5.0
[rules_cc]: https://github.com/bazelbuild/rules_cc
[rules_cc-rel]: https://github.com/bazelbuild/rules_cc/releases/tag/0.2.17
[rules_swift]: https://github.com/bazelbuild/rules_swift
[rules_swift-rel]: https://github.com/bazelbuild/rules_swift/releases/tag/3.5.0
[rules_apple]: https://github.com/bazelbuild/rules_apple
[rules_apple-rel]: https://github.com/bazelbuild/rules_apple/releases/tag/4.5.2
[rspm]: https://github.com/cgrindel/rules_swift_package_manager
[rspm-rel]: https://github.com/cgrindel/rules_swift_package_manager/releases/tag/v1.13.0
[rules_xcodeproj]: https://github.com/MobileNativeFoundation/rules_xcodeproj
[rules_xcodeproj-rel]: https://github.com/MobileNativeFoundation/rules_xcodeproj/releases/tag/4.0.0
[swiftlint]: https://github.com/realm/SwiftLint
[swiftlint-rel]: https://github.com/realm/SwiftLint/releases/tag/0.63.2
[gazelle]: https://github.com/bazel-contrib/bazel-gazelle
[gazelle-rel]: https://github.com/bazel-contrib/bazel-gazelle/releases/tag/v0.48.0
[sgp]: https://github.com/cgrindel/swift_gazelle_plugin
[sgp-rel]: https://github.com/cgrindel/swift_gazelle_plugin/releases/tag/v0.2.2

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

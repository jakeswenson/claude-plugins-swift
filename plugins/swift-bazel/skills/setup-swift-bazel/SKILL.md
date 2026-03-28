---
name: setup-swift-bazel
description: Set up, configure, and maintain Bazel builds for Swift/macOS/iOS projects. Use this skill whenever the user wants to create a new Swift Bazel project, add Bazel to an existing Swift project, update Bazel rule versions, troubleshoot Bazel + Swift build failures, add SPM dependencies to a Bazel project, configure rules_apple targets (macos_application, ios_application), set up rules_xcodeproj for Xcode generation, or integrate Swift Package Manager packages with Bazel. Also use when the user mentions rules_swift, rules_apple, rules_swift_package_manager, rules_xcodeproj, swift_gazelle_plugin, or apple_support in a Bazel context, even if they don't explicitly ask to "set up" anything.
---

# Bazel + Swift Project Setup & Maintenance

This skill covers creating, configuring, and maintaining Bazel builds for Swift projects targeting Apple platforms.

## Looking Up Documentation

Before making version or configuration decisions, look up current docs via context7. These are the library IDs:

| Rule Set | Context7 ID | What It Covers |
|----------|-------------|----------------|
| rules_swift | `/bazelbuild/rules_swift` | `swift_library`, `swift_test`, `swift_binary`, compiler plugins |
| rules_apple | `/bazelbuild/rules_apple` | `macos_application`, `ios_application`, bundling, signing, resources |
| rules_swift_package_manager | `/cgrindel/rules_swift_package_manager` | SPM integration, `swift_deps` extension, package resolution |
| rules_xcodeproj | `/mobilenativefoundation/rules_xcodeproj` | `xcodeproj` rule, Xcode project generation, scheme config |
| Gazelle | `/bazel-contrib/bazel-gazelle` | BUILD file generation, gazelle plugins |

**No context7 coverage** for: `apple_support`, `swift_gazelle_plugin`, `swiftlint`. For these, check their GitHub repos directly or use web search.

When the user asks about a specific rule or attribute, query context7 first — your training data may not reflect recent API changes.

## Dependency Tree

Understanding which rules depend on which is critical for version updates. Here's the dependency hierarchy (arrows mean "depends on"):

```
apple_support  ←── rules_swift  ←── rules_apple  ←── rules_swift_package_manager
                                         ↑                      ↑
                                         │                      │
                                  rules_xcodeproj          gazelle
                                                    swift_gazelle_plugin

swiftlint ──→ rules_swift (version-coupled)
```

**In plain English:**
- `apple_support` is the foundation — no deps on other rules
- `rules_swift` depends on `apple_support`
- `rules_apple` depends on `rules_swift` + `apple_support`
- `rules_swift_package_manager` depends on `rules_swift` + `rules_apple` + `gazelle`
- `rules_xcodeproj` depends on `rules_swift` + `rules_apple`
- `swiftlint` is version-coupled with `rules_swift` (specific versions require specific rules_swift ranges)
- `swift_gazelle_plugin` depends on `gazelle`

**Update order**: When bumping versions, always update bottom-up:
1. `apple_support` first
2. `rules_swift` next
3. `rules_apple` after rules_swift
4. `rules_swift_package_manager`, `rules_xcodeproj`, `swiftlint` last

## Checking Version Compatibility

Each rule declares its dependencies in its own `MODULE.bazel`. To check what versions are compatible:

1. **Bazel Central Registry (BCR)**: Go to `https://registry.bazel.build/modules/<rule_name>` to see all published versions and their declared dependencies
2. **GitHub MODULE.bazel**: Check `MODULE.bazel` in the repo's release tag to see exact `bazel_dep` version pins
3. **GitHub Releases**: Read changelogs for breaking changes

**Practical approach**: When updating, start from the rule you need to update, check its MODULE.bazel for minimum required versions of its dependencies, then cascade upward. If `rules_apple` 4.2.0 requires `rules_swift` >= 3.1.0, make sure your `rules_swift` version meets that.

## Updating Rule Versions

When a user wants to bump rule versions (e.g., to get a bug fix or new feature):

### Step 1: Identify what to update and why
Figure out which rule needs updating. Check its GitHub releases for the version with the fix/feature.

### Step 2: Check its dependencies
Fetch the target version's MODULE.bazel from the repo (or the BCR). Look at its `bazel_dep` entries — these are the minimum versions it requires. For example, if updating `rules_apple` to 4.3.0, check what version of `rules_swift` it requires.

### Step 3: Update bottom-up following the dependency tree
1. If `apple_support` needs bumping, do it first
2. Then `rules_swift` if needed
3. Then `rules_apple`
4. Then the leaf rules: `rules_swift_package_manager`, `rules_xcodeproj`, `swiftlint`

### Step 4: Test the update
```bash
bazel clean --expunge    # clear all caches (nuclear option — only if needed)
bazel build //...        # rebuild everything
bazel test //...         # run all tests
```

If the build breaks, check the error carefully:
- **Version mismatch errors**: Bazel will tell you which dep has an incompatible version
- **API changes**: Check the release notes/changelog for migration instructions
- **Toolchain errors**: May need to update `apple_support` or run `xcodebuild -runFirstLaunch`

### Step 5: Lock the resolution
After successful build, commit the updated `MODULE.bazel` and `MODULE.bazel.lock`.

### Where to find release notes and changelogs
- rules_swift: `https://github.com/bazelbuild/rules_swift/releases`
- rules_apple: `https://github.com/bazelbuild/rules_apple/releases`
- rules_swift_package_manager: `https://github.com/cgrindel/rules_swift_package_manager/releases`
- rules_xcodeproj: `https://github.com/MobileNativeFoundation/rules_xcodeproj/releases`
- apple_support: `https://github.com/bazelbuild/apple_support/releases`
- gazelle: `https://github.com/bazelbuild/bazel-gazelle/releases`
- swiftlint: `https://github.com/realm/SwiftLint/releases`

## MODULE.bazel Ordering Rules

The order of `bazel_dep` declarations matters:

1. **`apple_support` MUST come before `rules_cc`** — this is a toolchain registration order requirement. If reversed, the C++ toolchain won't resolve correctly on macOS.
2. After that, the remaining `bazel_dep` entries can be in any order, but by convention: core rules first (rules_swift, rules_apple), then higher-level rules (rules_swift_package_manager, rules_xcodeproj), then tools (swiftlint, gazelle).

## Project Setup Workflow

When setting up a new Swift Bazel project:

### Step 1: Create root config files

Read `references/project-template.md` for the exact file contents. The key files are:
- `.bazelversion` — pin the Bazel version
- `.bazelrc` — enable bzlmod, output filtering, xcodeproj spawn strategy
- `.bazelignore` — exclude `.build` (SPM build directory)
- `WORKSPACE` — empty file (required alongside MODULE.bazel for bzlmod)
- `.gitignore` — exclude `bazel-*` symlinks, `.build/`, `*.xcodeproj/`

### Step 2: Create Package.swift and resolve

Declare SPM dependencies in `Package.swift` at the workspace root. Then run:
```bash
swift package resolve    # generates Package.resolved
```

### Step 3: Create MODULE.bazel

Use the template from `references/project-template.md`. Key things:
- Declare all `bazel_dep` entries in the correct order
- Set up the `apple_cc_configure` extension
- Set up the `swift_deps` extension pointing to Package.swift and Package.resolved
- The `use_repo` block lists `swift_deps_info`, `swift_package`, and all `swiftpkg_*` repos

**The `swiftpkg_*` naming convention**: Package identity → lowercase → hyphens become underscores → prefix with `swiftpkg_`. Examples:
- `swift-markdown` → `swiftpkg_swift_markdown`
- `HighlighterSwift` → `swiftpkg_highlighterswift`
- `swift-nio` → `swiftpkg_swift_nio`

You don't need to get these perfect — after running `bazel mod tidy` or attempting a build, Bazel will tell you the correct repo names if yours are wrong.

### Step 4: Create BUILD files

Read `references/project-template.md` for the patterns. The structure is:
- Root `BUILD.bazel` — gazelle, version, aliases, test suite
- `Apps/<AppName>/BUILD.bazel` — `macos_application` (or `ios_application`) + `xcodeproj`
- `Apps/<AppName>/src/BUILD.bazel` — `swift_library`
- `Apps/<AppName>/tests/Tests_macOS/BUILD.bazel` — `swift_test`

### Step 5: Resolve and build

```bash
bazel run @swift_package//:resolve    # generates swift_deps_index.json
bazel mod tidy                         # fixes use_repo if needed
bazel build //:mac                     # or whatever your alias is
```

The first build is slow (fetches all external deps). Subsequent builds use the cache.

### Step 6: Discover SPM target labels

After resolution, use `bazel query` to find available targets within a package:
```bash
bazel query '@swiftpkg_<name>//...'
```

This shows all available targets. Common patterns:
- `//:ModuleName` (matches SPM product name)
- `//:ModuleName.rspm` (internal target, don't use directly)

## Adding an SPM Dependency

1. Add to `Package.swift`
2. Run `swift package resolve`
3. Run `bazel run @swift_package//:resolve`
4. Add `swiftpkg_<name>` to `use_repo` in `MODULE.bazel` (or run `bazel mod tidy`)
5. Add `@swiftpkg_<name>//:TargetName` to the relevant `BUILD.bazel` `deps`
6. Run `bazel run //:update_build_files` if using Gazelle

## Resource Bundling Patterns

### Fonts (or other files that need specific bundle placement)

Use `additional_contents` on `macos_application` / `ios_application` to place files at exact paths in the app bundle:

```starlark
filegroup(
    name = "fonts",
    srcs = glob(["resources/Fonts/**"]),
)

macos_application(
    name = "MyApp",
    additional_contents = {
        ":fonts": "Resources/Fonts",  # → Contents/Resources/Fonts/
    },
    ...
)
```

Pair with `ATSApplicationFontsPath = "Fonts"` in Info.plist for font registration.

### Asset catalogs

Use the `app_icons` attribute for icon sets, and `resources` for general assets:
```starlark
filegroup(
    name = "app_icons",
    srcs = glob(["resources/Assets.xcassets/AppIcon.appiconset/**"]),
)
```

## Common Pitfalls

### `@main` + `swift_test` = duplicate main symbol
The `swift_test` rule generates its own test runner main. If your `swift_library` contains `@main`, linking it into a test target causes a duplicate `_main` symbol. **Solution**: Keep testable logic in library targets that don't contain `@main`. Only link the `@main` entry point into the application target.

### Transitive deps in `use_repo`
Running `bazel mod tidy` or attempting a build will warn you if you've listed a transitive (indirect) dependency in `use_repo` that shouldn't be there. Only list direct dependencies — Bazel handles transitives automatically.

### `xcodebuild -runFirstLaunch`
If `actool` (asset catalog compiler) fails with "A required plugin failed to load", run `xcodebuild -runFirstLaunch` to install Xcode's system packages. This commonly happens after Xcode or macOS updates.

### Empty `glob` results are OK
A `glob(["resources/Fonts/**"])` that matches nothing produces an empty filegroup. The build still succeeds — the directory just contributes no files. This is useful for placeholder directories.

### Gazelle excludes
If Gazelle auto-generates BUILD files that conflict with your hand-written ones, add `# gazelle:exclude <path>` directives in the root BUILD.bazel.

# Swift + Bazel Project Template

This reference contains the full file templates for a new Swift Bazel project. Adapt names, bundle IDs, and dependencies to the specific project.

## Table of Contents
- [.bazelversion](#bazelversion)
- [.bazelrc](#bazelrc)
- [.bazelignore](#bazelignore)
- [.gitignore](#gitignore)
- [.swiftlint.yml](#swiftlintyml)
- [MODULE.bazel](#modulebazel)
- [Package.swift](#packageswift)
- [Root BUILD.bazel](#root-buildbazel)
- [App BUILD.bazel](#app-buildbazel)
- [Source BUILD.bazel](#source-buildbazel)
- [Test BUILD.bazel](#test-buildbazel)
- [Minimal App Entry Point](#minimal-app-entry-point)
- [Info.plist (macOS)](#infoplist-macos)
- [Entitlements (macOS)](#entitlements-macos)
- [Asset Catalog](#asset-catalog)
- [Directory Structure](#directory-structure)

---

## .bazelversion

Pin to a specific Bazel version. Check https://github.com/bazelbuild/bazel/releases for latest.

```
9.0.1
```

## .bazelrc

```
# Filter out warnings from external packages (only show output from local code)
build --output_filter='^//(Apps|Packages)/'

# rules_xcodeproj: worker before sandboxed (rules_swift 3.5.0+ worker crashes in sandbox),
# disable index-while-building (index-import tool missing in xcodeproj output base).
build:rules_xcodeproj --spawn_strategy=worker,sandboxed,remote,local
build:rules_xcodeproj --features=-swift.index_while_building

# Bazel 9 removed cc_library/objc_library from core — rules_cc re-enables autoloading.
# Required by: SwiftLint (its Yams dependency uses cc_library via implicit load).
# If you remove SwiftLint and have no other C/ObjC deps, you can remove this line
# AND the rules_cc bazel_dep in MODULE.bazel.
# Once Yams/SwiftLint add explicit load() statements for cc_library, this flag can
# be removed (keep the rules_cc bazel_dep — Yams still needs the rules themselves).
common --incompatible_autoload_externally=+@rules_cc
```

Add iOS simulator lines only if you have iOS targets:
```
build --ios_simulator_device="iPhone 16"
build --ios_simulator_version="18.0"
```

## .bazelignore

```
.build
```

## .gitignore

```
.idea/
bazel-*
build/
.build/
*.xcodeproj/
```

## .swiftlint.yml

```yaml
# https://github.com/realm/SwiftLint#configuration
included:
 - Apps
 - Packages
```

## WORKSPACE

Not needed for Bazel 9 — WORKSPACE support was removed entirely. Do not create this file for new projects. If migrating from Bazel 8, delete the existing empty WORKSPACE file.

## MODULE.bazel

Template for a macOS-only app. Adapt the module name, and add/remove `use_repo` entries based on your actual SPM dependencies.

```starlark
module(
    name = "my_project",
    version = "0.0",
)

# IMPORTANT: apple_support must come ABOVE rules_cc for toolchain registration order
bazel_dep(name = "apple_support", version = "2.5.0")
bazel_dep(name = "rules_cc", version = "0.2.17")

# Gazelle for BUILD file generation
bazel_dep(name = "gazelle", version = "0.48.0")

# Core Apple/Swift rules
bazel_dep(name = "rules_swift", version = "3.5.0")
bazel_dep(name = "rules_apple", version = "4.5.2")
bazel_dep(name = "rules_swift_package_manager", version = "1.13.0")
bazel_dep(name = "rules_xcodeproj", version = "4.0.0")

# SwiftLint (optional — remove if not using)
bazel_dep(name = "swiftlint", version = "0.63.2", repo_name = "SwiftLint")

# Swift Gazelle plugin
bazel_dep(name = "swift_gazelle_plugin", version = "0.2.2")

# Apple CC toolchain configuration for Bazel 9
apple_cc_configure = use_extension(
    "@apple_support//crosstool:setup.bzl",
    "apple_cc_configure_extension",
)
use_repo(apple_cc_configure, "local_config_apple_cc")

# swift_deps START
swift_deps = use_extension(
    "@rules_swift_package_manager//:extensions.bzl",
    "swift_deps",
)
swift_deps.from_package(
    declare_swift_deps_info = True,
    declare_swift_package = True,
    resolved = "//:Package.resolved",
    swift = "//:Package.swift",
)
use_repo(
    swift_deps,
    "swift_deps_info",
    "swift_package",
    # Add swiftpkg_* entries here after running bazel mod tidy
)
# swift_deps END
```

### Known compatible version set — Bazel 9 (tested March 2026)

These versions work together as a set:

| Rule | Version |
|------|---------|
| Bazel | 9.0.1 |
| apple_support | 2.5.0 |
| rules_cc | 0.2.17 |
| gazelle | 0.48.0 |
| rules_swift | 3.5.0 |
| rules_apple | 4.5.2 |
| rules_swift_package_manager | 1.13.0 |
| rules_xcodeproj | 4.0.0 |
| swiftlint | 0.63.2 |
| swift_gazelle_plugin | 0.2.2 |

### Legacy version set — Bazel 8 (tested March 2026)

Use these only if you must stay on Bazel 8. Bazel 8 requires an empty `WORKSPACE` file and `common --enable_bzlmod` in `.bazelrc`.

| Rule | Version |
|------|---------|
| Bazel | 8.4.2 |
| apple_support | 1.23.1 |
| rules_cc | 0.1.5 |
| gazelle | 0.45.0 |
| rules_swift | 3.1.2 |
| rules_apple | 4.2.0 |
| rules_swift_package_manager | 1.11.0 |
| rules_xcodeproj | 3.5.1 |
| swiftlint | 0.62.2 |
| swift_gazelle_plugin | 0.2.2 |

## Package.swift

Workspace-root SPM manifest. Only declares dependencies — no targets.

```swift
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "workspace-dependencies",
    dependencies: [
        // Add SPM dependencies here, e.g.:
        // .package(url: "https://github.com/example/package.git", from: "1.0.0"),
    ]
)
```

## Root BUILD.bazel

```starlark
load("@gazelle//:def.bzl", "gazelle", "gazelle_binary")
# gazelle:exclude .build

load(
    "@rules_apple//apple:versioning.bzl",
    "apple_bundle_version",
)

gazelle_binary(
    name = "gazelle_bin",
    languages = [
        "@swift_gazelle_plugin//gazelle",
    ],
)

gazelle(
    name = "update_build_files",
    gazelle = ":gazelle_bin",
)

# To update Swift packages:
#   bazel run @swift_package//:update
# To resolve packages:
#   bazel run @swift_package//:resolve

alias(
    name = "lint",
    actual = "@SwiftLint//:swiftlint",
)

apple_bundle_version(
    name = "version",
    build_version = "0.0.0",
    short_version_string = "0.0.0",
    visibility = ["//visibility:public"],
)

# Convenience aliases — adapt to your app name
alias(
    name = "mac",
    actual = "//Apps/MyApp:MyApp",
)

alias(
    name = "xcode",
    actual = "//Apps/MyApp:xcode",
)

test_suite(
    name = "test",
    tests = [
        "//Apps/MyApp/tests/Tests_macOS:Tests_macOS",
    ],
)
```

## App BUILD.bazel

For `Apps/<AppName>/BUILD.bazel`:

### macOS-only

```starlark
load("@rules_apple//apple:macos.bzl", "macos_application")
load(
    "@rules_xcodeproj//xcodeproj:defs.bzl",
    "top_level_target",
    "xcodeproj",
)

filegroup(
    name = "app_icons",
    srcs = glob(["resources/Assets.xcassets/AppIcon.appiconset/**"]),
)

filegroup(
    name = "app_assets",
    srcs = glob(["resources/Assets.xcassets/**"]),
)

alias(
    name = "source",
    actual = "//Apps/MyApp/src",
    visibility = ["//visibility:public"],
)

macos_application(
    name = "MyApp",
    app_icons = [":app_icons"],
    bundle_id = "com.example.myapp",
    entitlements = "resources/MyApp.entitlements",
    infoplists = [":resources/Info.plist"],
    minimum_os_version = "15.0",
    version = "//:version",
    visibility = ["//visibility:public"],
    deps = [":source"],
)

xcodeproj(
    name = "xcode",
    project_name = "MyApp",
    tags = ["manual"],
    visibility = ["//visibility:public"],
    top_level_targets = [
        top_level_target(
            ":MyApp",
            target_environments = ["device"],
        ),
    ],
)
```

### macOS + iOS

Add an iOS target alongside the macOS one:

```starlark
load("@rules_apple//apple:ios.bzl", "ios_application")

ios_application(
    name = "MyApp-iOS",
    app_icons = [":app_icons"],
    bundle_id = "com.example.myapp",
    entitlements = "resources/MyApp-iOS.entitlements",
    families = ["iphone", "ipad"],
    infoplists = [":resources/Info-iOS.plist"],
    minimum_os_version = "18.0",
    version = "//:version",
    visibility = ["//visibility:public"],
    deps = [":source"],
)
```

And update xcodeproj to include both:

```starlark
xcodeproj(
    name = "xcode",
    project_name = "MyApp",
    tags = ["manual"],
    visibility = ["//visibility:public"],
    top_level_targets = [
        top_level_target(":MyApp", target_environments = ["device"]),
        top_level_target(":MyApp-iOS", target_environments = ["simulator"]),
    ],
)
```

### Font / resource bundling

Add a filegroup and use `additional_contents`:

```starlark
filegroup(
    name = "fonts",
    srcs = glob(["resources/Fonts/**"]),
)

macos_application(
    name = "MyApp",
    additional_contents = {
        ":fonts": "Resources/Fonts",
    },
    # ... rest of attributes
)
```

## Source BUILD.bazel

For `Apps/<AppName>/src/BUILD.bazel`:

```starlark
load("@rules_swift//swift:swift.bzl", "swift_library")

swift_library(
    name = "src",
    srcs = glob(["**/*.swift"]),
    module_name = "MyApp",
    visibility = ["//visibility:public"],
    deps = [
        # Add SPM and local deps here, e.g.:
        # "@swiftpkg_swift_markdown//:Markdown",
    ],
)
```

## Test BUILD.bazel

For `Apps/<AppName>/tests/Tests_macOS/BUILD.bazel`:

```starlark
load("@rules_swift//swift:swift.bzl", "swift_test")

swift_test(
    name = "Tests_macOS",
    srcs = ["MyAppTests.swift"],
    module_name = "Tests_macOS",
    deps = [],  # Don't depend on src if it contains @main — see Common Pitfalls
)
```

## Minimal App Entry Point

For `Apps/<AppName>/src/MyApp.swift`:

```swift
import SwiftUI

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            Text("Hello")
                .frame(minWidth: 600, minHeight: 400)
        }
        .defaultSize(width: 900, height: 700)
    }
}
```

## Info.plist (macOS)

Minimal macOS Info.plist. Add keys as needed.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleName</key>
	<string>MyApp</string>
	<key>CFBundleDisplayName</key>
	<string>MyApp</string>
</dict>
</plist>
```

`CFBundleName` and `CFBundleDisplayName` are needed for Gatekeeper and macOS dialogs to show the app name correctly (otherwise they display "(null)"). Version strings (`CFBundleVersion`, `CFBundleShortVersionString`) are injected automatically by the `apple_bundle_version` rule — do not add them here.

Add these keys as needed:
- `ATSApplicationFontsPath` — for bundled fonts (value: the folder name under Resources/)
- `CFBundleDocumentTypes` — for file type associations
- `CFBundleURLTypes` — for URL schemes

## Entitlements (macOS)

Common sandbox entitlements:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>com.apple.security.app-sandbox</key>
	<true/>
	<key>com.apple.security.network.client</key>
	<true/>
	<key>com.apple.security.files.user-selected.read-only</key>
	<true/>
</dict>
</plist>
```

Other common entitlements:
- `com.apple.security.files.downloads.read-write` — write to Downloads
- `com.apple.security.files.user-selected.read-write` — read-write file picker
- `com.apple.security.application-groups` — shared app group containers

## Asset Catalog

Minimal Contents.json files:

### `Assets.xcassets/Contents.json`
```json
{ "info": { "author": "xcode", "version": 1 } }
```

### `Assets.xcassets/AccentColor.colorset/Contents.json`
```json
{ "colors": [{ "idiom": "universal" }], "info": { "author": "xcode", "version": 1 } }
```

### `Assets.xcassets/AppIcon.appiconset/Contents.json`
```json
{
  "images": [
    { "idiom": "mac", "scale": "1x", "size": "16x16" },
    { "idiom": "mac", "scale": "2x", "size": "16x16" },
    { "idiom": "mac", "scale": "1x", "size": "32x32" },
    { "idiom": "mac", "scale": "2x", "size": "32x32" },
    { "idiom": "mac", "scale": "1x", "size": "128x128" },
    { "idiom": "mac", "scale": "2x", "size": "128x128" },
    { "idiom": "mac", "scale": "1x", "size": "256x256" },
    { "idiom": "mac", "scale": "2x", "size": "256x256" },
    { "idiom": "mac", "scale": "1x", "size": "512x512" },
    { "idiom": "mac", "scale": "2x", "size": "512x512" }
  ],
  "info": { "author": "xcode", "version": 1 }
}
```

## Directory Structure

```
project-root/
├── .bazelversion
├── .bazelrc
├── .bazelignore
├── .gitignore
├── .swiftlint.yml
├── MODULE.bazel
├── MODULE.bazel.lock          (auto-generated, commit to VCS)
├── BUILD.bazel                (root: gazelle, version, aliases)
├── Package.swift
├── Package.resolved           (auto-generated, commit to VCS)
├── swift_deps_index.json      (auto-generated, may or may not appear at root)
├── CLAUDE.md
├── Apps/
│   └── MyApp/
│       ├── BUILD.bazel        (macos_application, xcodeproj)
│       ├── src/
│       │   ├── BUILD.bazel    (swift_library)
│       │   └── MyApp.swift    (@main entry point)
│       ├── resources/
│       │   ├── Info.plist
│       │   ├── MyApp.entitlements
│       │   ├── Assets.xcassets/
│       │   │   ├── Contents.json
│       │   │   ├── AccentColor.colorset/Contents.json
│       │   │   └── AppIcon.appiconset/Contents.json
│       │   └── Fonts/         (optional, for bundled fonts)
│       └── tests/
│           └── Tests_macOS/
│               ├── BUILD.bazel (swift_test)
│               └── MyAppTests.swift
└── Packages/                  (shared libraries, extracted later)
```

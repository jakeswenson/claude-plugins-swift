# Bazel 8 → 9 Migration Guide

This reference covers breaking changes when migrating a Swift Bazel project from Bazel 8 to Bazel 9.

## Pre-Migration

Always `bazel clean --expunge` before switching major Bazel versions — cached analysis from the old version is incompatible.

## Breaking Changes

### 1. WORKSPACE Removal

Bazel 9 removed WORKSPACE support entirely.

- Delete the empty `WORKSPACE` file (or `WORKSPACE.bazel`)
- Remove `common --enable_bzlmod` from `.bazelrc` — bzlmod is always-on in Bazel 9, and the flag causes an error

### 2. Built-in Rule Removal

Bazel 9 removed `cc_library`, `cc_binary`, `objc_library`, etc. from core. External deps that use these without explicit `load()` statements will fail.

**Fix**: Add to `.bazelrc`:
```
common --incompatible_autoload_externally=+@rules_cc
```

This re-enables autoloading for the removed built-in rules.

### 3. apple_support 2.x — Layering Check

apple_support 2.x enables `layering_check` by default for C/C++ header dependencies. Pure Swift projects are unaffected, but projects with C/ObjC targets may see build errors for implicitly-available headers.

**Fix** (if needed): Add to `.bazelrc`:
```
build --repo_env=APPLE_SUPPORT_LAYERING_CHECK_BETA=0
```

This disables the check until headers are properly declared.

### 4. rules_xcodeproj + rules_swift in Xcode Builds

rules_xcodeproj 4.0.0 drops WORKSPACE support and requires Bazel 9. Check release notes for API changes before upgrading.

Two issues affect Xcode builds (via rules_xcodeproj) with Bazel 9 + rules_swift 3.5.0+:

**Swift worker crashes in sandbox**: The rules_swift worker crashes with `filesystem_error: in canonical` when running in `darwin-sandbox` inside the xcodeproj output base. The worker tries to canonicalize `BUILD.bazel` in the sandbox directory where it doesn't exist. Fix by putting `worker` before `sandboxed` in the spawn strategy so Swift compilation uses persistent workers instead:

```
build:rules_xcodeproj --spawn_strategy=worker,sandboxed,remote,local
```

**`index-import` not found**: The `build_bazel_rules_swift_index_import_6_1` repo (used for Xcode index-while-building) doesn't resolve in the xcodeproj output base. Fix by disabling the feature:

```
build:rules_xcodeproj --features=-swift.index_while_building
```

This trades Xcode's deep indexing for a working build. Code navigation via the generated project structure still works.

Both fixes are compatible with rules_xcodeproj 3.5.1 and 4.0.0.

## Migration Steps

1. Update `.bazelversion` to 9.x
2. `bazel clean --expunge`
3. Delete `WORKSPACE` / `WORKSPACE.bazel`
4. Remove `common --enable_bzlmod` from `.bazelrc`
5. Add `common --incompatible_autoload_externally=+@rules_cc` to `.bazelrc` (if needed)
6. Fix rules_xcodeproj spawn strategy and index-import in `.bazelrc` (see section 4 above)
7. Bump rule versions bottom-up (see dependency tree in the main skill)
8. `bazel build //...` — fix any remaining errors
9. `bazel test //...` — verify tests pass
10. Commit updated `MODULE.bazel`, `MODULE.bazel.lock`, `.bazelrc`, and deleted WORKSPACE

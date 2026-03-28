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

### 4. rules_xcodeproj 4.x

rules_xcodeproj 4.0.0 drops WORKSPACE support and requires Bazel 9. Check release notes for API changes before upgrading.

## Migration Steps

1. Update `.bazelversion` to 9.x
2. `bazel clean --expunge`
3. Delete `WORKSPACE` / `WORKSPACE.bazel`
4. Remove `common --enable_bzlmod` from `.bazelrc`
5. Add `common --incompatible_autoload_externally=+@rules_cc` to `.bazelrc`
6. Bump rule versions bottom-up (see dependency tree in the main skill)
7. `bazel build //...` — fix any remaining errors
8. `bazel test //...` — verify tests pass
9. Commit updated `MODULE.bazel`, `MODULE.bazel.lock`, `.bazelrc`, and deleted WORKSPACE

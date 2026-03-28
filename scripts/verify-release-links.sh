#!/usr/bin/env bash
# Verify that all GitHub release tag URLs in README.md resolve to real releases.
# Requires: gh cli (authenticated)

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
README="$REPO_ROOT/README.md"

errors=0
checked=0

# Extract reference-style release URLs: [key]: https://github.com/{owner}/{repo}/releases/tag/{tag}
while IFS= read -r line; do
  url="${line#*]: }"
  # Parse owner/repo and tag from the URL
  if [[ "$url" =~ github\.com/([^/]+)/([^/]+)/releases/tag/(.+)$ ]]; then
    owner="${BASH_REMATCH[1]}"
    repo="${BASH_REMATCH[2]}"
    tag="${BASH_REMATCH[3]}"
    checked=$((checked + 1))

    if gh api "repos/$owner/$repo/releases/tags/$tag" --silent 2>/dev/null; then
      echo "  ok  $owner/$repo @ $tag"
    else
      echo " FAIL $owner/$repo @ $tag"
      errors=$((errors + 1))
    fi
  fi
done < <(grep -E '^\[.*-rel\]: https://github\.com/.*/releases/tag/' "$README")

echo ""
echo "Checked $checked release links, $errors failed."
exit "$errors"

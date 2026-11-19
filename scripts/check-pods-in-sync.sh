#!/usr/bin/env bash
# Fails if `pod install` changed any tracked file.
#
# Pods/ is not committed, but `pod install` also rewrites Podfile.lock and the
# Xcode project. If a commit edits the Podfile without the matching
# Podfile.lock / project changes, this check catches it and prints the diff
# that needs to be committed.
#
# Usage: run `pod install`, then scripts/check-pods-in-sync.sh
set -euo pipefail
cd "$(dirname "$0")/.."

tracked=(Podfile.lock MusicPlayer.xcodeproj MusicPlayer.xcworkspace)

if ! git diff --quiet -- "${tracked[@]}"; then
  echo "error: 'pod install' modified tracked files. Commit these changes:" >&2
  git --no-pager diff -- "${tracked[@]}"
  exit 1
fi
echo "Pods are in sync with Podfile.lock and the Xcode project."

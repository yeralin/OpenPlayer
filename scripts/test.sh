#!/usr/bin/env bash
# Builds the app once and runs the test suites on an iOS simulator.
# CI runs exactly this script, so a local run reproduces CI.
#
# Usage: scripts/test.sh [unit|ui|all]   (default: all)
#
# Requires: Xcode, and `pod install` already run.
# Result bundles are written to build/results/<suite>.xcresult.
set -euo pipefail

suite="${1:-all}"
cd "$(dirname "$0")/.."

udid="${SIMULATOR_UDID:-$(scripts/pick-simulator.sh)}"
destination="platform=iOS Simulator,id=${udid}"
derived_data="build/DerivedData"
results="build/results"
mkdir -p "$results"

common_args=(
  -workspace MusicPlayer.xcworkspace
  -scheme MusicPlayer
  -configuration Debug
  -destination "$destination"
  -derivedDataPath "$derived_data"
  CODE_SIGNING_ALLOWED=NO
)

echo "==> Building for testing on simulator ${udid}"
xcodebuild build-for-testing "${common_args[@]}" -quiet

run_suite() {
  local name="$1" target="$2"
  rm -rf "${results}/${name}.xcresult"
  echo "==> Running ${name} tests (${target})"
  # Time limits turn a hung test into a failure with a report instead of a
  # silent wait until the CI job times out.
  xcodebuild test-without-building "${common_args[@]}" \
    -only-testing:"${target}" \
    -test-timeouts-enabled YES \
    -default-test-execution-time-allowance 120 \
    -maximum-test-execution-time-allowance 300 \
    -resultBundlePath "${results}/${name}.xcresult"
}

case "$suite" in
  unit) run_suite unit MusicPlayerTests ;;
  ui) run_suite ui MusicPlayerUITests ;;
  all)
    run_suite unit MusicPlayerTests
    run_suite ui MusicPlayerUITests
    ;;
  *)
    echo "Unknown suite: ${suite} (expected unit, ui or all)" >&2
    exit 64
    ;;
esac

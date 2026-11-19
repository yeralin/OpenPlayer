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
  # Only the standard Swift toolchain. With the Metal toolchain installed (as
  # on GitHub's macos-26 image), Xcode 26 also adds its usr/lib/swift/<platform>
  # folder, which Metal does not ship, to every link: "ld: warning: search
  # path '...MetalToolchain.../usr/lib/swift/iphonesimulator' not found".
  TOOLCHAINS=com.apple.dt.toolchain.XcodeDefault
)

echo "==> Building for testing on simulator ${udid}"
# -quiet prints only warnings and errors; keep them for scripts/report-warnings.sh.
mkdir -p build/logs
xcodebuild build-for-testing "${common_args[@]}" -quiet 2>&1 | tee build/logs/build.log

# Usage: run_suite <name> <test target> <per-test time limit in seconds>
run_suite() {
  local name="$1" target="$2" allowance="$3"
  rm -rf "${results}/${name}.xcresult"
  echo "==> Running ${name} tests (${target})"
  # Time limits turn a hung test into a failure with a report instead of a
  # silent wait until the CI job times out.
  if ! xcodebuild test-without-building "${common_args[@]}" \
    -only-testing:"${target}" \
    -test-timeouts-enabled YES \
    -default-test-execution-time-allowance "$allowance" \
    -maximum-test-execution-time-allowance "$((allowance * 2))" \
    -resultBundlePath "${results}/${name}.xcresult"; then
    print_failures "${results}/${name}.xcresult"
    return 1
  fi
}

# Prints each failed test with its failure message from a result bundle, so
# failures can be read without digging through thousands of log lines.
print_failures() {
  echo "==> Failed tests"
  xcrun xcresulttool get test-results summary --path "$1" --compact 2>/dev/null | python3 -c '
import json, sys
for failure in json.load(sys.stdin).get("testFailures", []):
    print("- {}: {}".format(failure.get("testIdentifierString") or failure.get("testName"),
                            " ".join(str(failure.get("failureText", "")).split())))
' || echo "(could not read $1)"
}

# UI tests launch and drive the whole app, so they get a larger limit.
run_unit() { run_suite unit MusicPlayerTests 120; }
run_ui() { run_suite ui MusicPlayerUITests 300; }

case "$suite" in
  unit) run_unit ;;
  ui) run_ui ;;
  all)
    run_unit
    run_ui
    ;;
  *)
    echo "Unknown suite: ${suite} (expected unit, ui or all)" >&2
    exit 64
    ;;
esac

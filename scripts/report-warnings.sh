#!/usr/bin/env bash
# Summarizes the compiler and linker warnings of the last scripts/test.sh
# build (build/logs/build.log), one line per distinct warning, our own code
# first. In GitHub Actions the summary is also added to the job summary.
#
# Usage: scripts/report-warnings.sh
set -euo pipefail
cd "$(dirname "$0")/.."

log="build/logs/build.log"
[ -f "$log" ] || { echo "No build log at $log"; exit 0; }

root="$(pwd)/"
warnings="$(grep -E '(^|: )warning: ' "$log" | sed "s|$root||g" | sort | uniq -c | sort -rn || true)"
ours="$(printf '%s\n' "$warnings" | grep -E 'MusicPlayer(Tests|UITests)?/' || true)"
others="$(printf '%s\n' "$warnings" | grep -vE 'MusicPlayer(Tests|UITests)?/' | grep -v '^$' || true)"

count() { printf '%s' "$1" | grep -c . || true; }
report="$(cat <<REPORT
### Build warnings
In app and test sources: $(count "$ours")
Elsewhere (pods, toolchain, project settings): $(count "$others")

\`\`\`
${ours}
${others}
\`\`\`
REPORT
)"

echo "$report"
if [ -n "${GITHUB_STEP_SUMMARY:-}" ]; then
  echo "$report" >> "$GITHUB_STEP_SUMMARY"
fi

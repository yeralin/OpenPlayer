#!/usr/bin/env bash
# Prints the UDID of an available iPhone simulator on the newest installed
# iOS runtime. Used by scripts/test.sh and CI so both pick devices the same way.
#
# Usage: scripts/pick-simulator.sh
set -euo pipefail

xcrun simctl list devices available --json | python3 -c '
import json, re, sys

devices = json.load(sys.stdin)["devices"]

def version(runtime):
    match = re.search(r"iOS-([0-9-]+)$", runtime)
    return [int(part) for part in match.group(1).split("-")] if match else []

for runtime in sorted((r for r in devices if "iOS" in r), key=version, reverse=True):
    for device in devices[runtime]:
        if device["name"].startswith("iPhone"):
            print(device["udid"])
            sys.exit(0)

sys.exit("No available iPhone simulator found")
'

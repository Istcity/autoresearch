#!/usr/bin/env bash
# Syntax-validate every Swift source with the open-source Swift toolchain.
#
# Stillway's full build needs macOS + Xcode. On Linux the Apple SDKs
# (SwiftUI, UIKit, CoreLocation, ...) are unavailable, so this runs
# `swiftc -parse`, which checks that every file is syntactically valid
# without resolving those imports. It is the closest the app source can
# get to "compiling" on a Linux Cloud Agent.
set -uo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

if ! command -v swiftc >/dev/null 2>&1; then
  echo "swiftc not found. Run .cursor/install.sh first." >&2
  exit 127
fi

total=0
fail=0
while IFS= read -r f; do
  total=$((total + 1))
  if ! swiftc -parse "$f" 2>/tmp/swift_parse.err; then
    fail=$((fail + 1))
    echo "FAIL: $f"
    cat /tmp/swift_parse.err
  fi
done < <(find Stillway StillwayWidgets -name '*.swift' | sort)

echo "-------------------------------------------"
echo "Swift files parsed: $total | OK: $((total - fail)) | FAIL: $fail"
[ "$fail" -eq 0 ]

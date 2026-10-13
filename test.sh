#!/bin/bash
set -euo pipefail
project_dir="$(cd "$(dirname "$0")" && pwd)"
test_dir="$(mktemp -d "${TMPDIR:-/tmp}/screen-awake-tests.XXXXXX")"
trap 'rm -rf "$test_dir"' EXIT
xcrun clang -O2 -fobjc-arc -Wall -Wextra -mmacosx-version-min=12.0 \
  -I "$project_dir/src" "$project_dir/src/SleepHold.m" "$project_dir/tests/SleepHoldTests.m" \
  -framework Foundation -framework IOKit -o "$test_dir/SleepHoldTests"
"$test_dir/SleepHoldTests"

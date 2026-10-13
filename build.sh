#!/bin/bash
set -euo pipefail
project_dir="$(cd "$(dirname "$0")" && pwd)"
app_path="$project_dir/build/熄屏保活.app"
mkdir -p "$app_path/Contents/MacOS"
xcrun clang -O2 -fobjc-arc -Wall -Wextra -Wno-unused-parameter \
  -arch arm64 -arch x86_64 -mmacosx-version-min=12.0 \
  "$project_dir/src/SleepHold.m" "$project_dir/src/main.m" \
  -framework AppKit -framework IOKit -o "$app_path/Contents/MacOS/ScreenAwake"
cp "$project_dir/resources/Info.plist" "$app_path/Contents/Info.plist"
codesign --force --sign - "$app_path"
codesign --verify --strict "$app_path"
plutil -lint "$app_path/Contents/Info.plist"
printf '已生成：%s\n' "$app_path"

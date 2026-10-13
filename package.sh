#!/bin/bash
set -euo pipefail
project_dir="$(cd "$(dirname "$0")" && pwd)"
bash "$project_dir/build.sh"
version="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$project_dir/resources/Info.plist")"
mkdir -p "$project_dir/dist"
archive="ScreenAwake-v${version}-universal.zip"
ditto -c -k --sequesterRsrc --keepParent "$project_dir/build/熄屏保活.app" "$project_dir/dist/$archive"
(cd "$project_dir/dist" && shasum -a 256 "$archive" > SHA256SUMS.txt)
printf '已打包：%s\n' "$project_dir/dist/$archive"

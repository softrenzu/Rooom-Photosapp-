#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

DERIVED_DATA="${DERIVED_DATA:-$ROOT_DIR/build/DerivedDataScreenshots}"
DEVICE_NAME="${DEVICE_NAME:-iPhone 17 Pro Max}"

DEVICE_ID="$(xcrun simctl list devices available -j | /usr/bin/python3 -c '
import json, sys
data = json.load(sys.stdin)
preferred = sys.argv[1]
devices = [d for group in data["devices"].values() for d in group if d.get("isAvailable") and d["name"].startswith("iPhone")]
exact = next((d for d in devices if d["name"] == preferred), None)
fallback = next((d for d in devices if "Pro Max" in d["name"]), None)
chosen = exact or fallback or (devices[0] if devices else None)
if not chosen:
    raise SystemExit("No available iPhone simulator")
print(chosen["udid"])
' "$DEVICE_NAME")"

xcrun simctl boot "$DEVICE_ID" 2>/dev/null || true
xcrun simctl bootstatus "$DEVICE_ID" -b
xcrun simctl status_bar "$DEVICE_ID" override --time "9:41" --batteryState charged --batteryLevel 100 --wifiBars 3 --cellularBars 4 || true

xcodebuild \
  -project RooomShot.xcodeproj \
  -scheme RooomShot \
  -configuration Debug \
  -sdk iphonesimulator \
  -destination "platform=iOS Simulator,id=$DEVICE_ID" \
  -derivedDataPath "$DERIVED_DATA" \
  CODE_SIGNING_ALLOWED=NO \
  build

APP_PATH="$DERIVED_DATA/Build/Products/Debug-iphonesimulator/RooomShot.app"
if [[ ! -d "$APP_PATH" ]]; then
  echo "Built app not found at $APP_PATH" >&2
  exit 1
fi

xcrun simctl install "$DEVICE_ID" "$APP_PATH"

screens=(home uploading history settings)
locales=(ja en-US)

for locale in "${locales[@]}"; do
  output_dir="fastlane/screenshots/$locale"
  mkdir -p "$output_dir"
  if [[ "$locale" == "ja" ]]; then
    language="ja"
    apple_locale="ja_JP"
  else
    language="en"
    apple_locale="en_US"
  fi

  index=1
  for screen in "${screens[@]}"; do
    xcrun simctl terminate "$DEVICE_ID" com.rooomtech.rooomshot 2>/dev/null || true
    xcrun simctl launch "$DEVICE_ID" com.rooomtech.rooomshot \
      -ScreenshotMode \
      -ScreenshotScreen "$screen" \
      -AppleLanguages "($language)" \
      -AppleLocale "$apple_locale"
    sleep 2
    xcrun simctl io "$DEVICE_ID" screenshot --type=png "$output_dir/${index}_${screen}.png"
    index=$((index + 1))
  done
done

xcrun simctl status_bar "$DEVICE_ID" clear || true

accepted_dimensions='^(1260x2736|1290x2796|1320x2868)$'
for screenshot in fastlane/screenshots/ja/*.png fastlane/screenshots/en-US/*.png; do
  dimensions="$(sips -g pixelWidth -g pixelHeight "$screenshot" | awk '/pixelWidth/ {w=$2} /pixelHeight/ {h=$2} END {print w "x" h}')"
  alpha="$(sips -g hasAlpha "$screenshot" | awk '/hasAlpha/ {print $2}')"
  if [[ ! "$dimensions" =~ $accepted_dimensions ]]; then
    echo "Unsupported App Store screenshot dimensions: $screenshot ($dimensions)" >&2
    exit 1
  fi
  if [[ "$alpha" != "no" ]]; then
    echo "Screenshot contains alpha: $screenshot" >&2
    exit 1
  fi
done

echo "App Store screenshots generated and validated."


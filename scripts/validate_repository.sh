#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

required_files=(
  "RooomShot.xcodeproj/project.pbxproj"
  "Configuration/Info.plist"
  "RooomShot/Resources/PrivacyInfo.xcprivacy"
  "RooomShot/Resources/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png"
  "RooomShot/App/RooomShotApp.swift"
  "RooomShot/Services/SubscriptionManager.swift"
  "RooomShot/Views/SubscriptionPaywallView.swift"
  "PRIVACY.md"
  "TERMS.md"
  "docs/terms.html"
  "app_store_submission/SUBSCRIPTION_SETUP.md"
  "SUPPORT.md"
  "fastlane/metadata/ja/description.txt"
  "fastlane/metadata/en-US/description.txt"
)

for path in "${required_files[@]}"; do
  if [[ ! -s "$path" ]]; then
    echo "Missing or empty required file: $path" >&2
    exit 1
  fi
done

if command -v plutil >/dev/null 2>&1; then
  plutil -lint Configuration/Info.plist RooomShot/Resources/PrivacyInfo.xcprivacy >/dev/null
elif command -v xmllint >/dev/null 2>&1; then
  xmllint --noout Configuration/Info.plist RooomShot/Resources/PrivacyInfo.xcprivacy
fi

app_icon="RooomShot/Resources/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png"
if command -v sips >/dev/null 2>&1; then
  width="$(sips -g pixelWidth "$app_icon" | awk '/pixelWidth/ {print $2}')"
  height="$(sips -g pixelHeight "$app_icon" | awk '/pixelHeight/ {print $2}')"
  alpha="$(sips -g hasAlpha "$app_icon" | awk '/hasAlpha/ {print $2}')"
  [[ "$width" == "1024" && "$height" == "1024" && "$alpha" == "no" ]]
elif command -v identify >/dev/null 2>&1; then
  dimensions="$(identify -format '%wx%h' "$app_icon")"
  channels="$(identify -format '%[channels]' "$app_icon")"
  [[ "$dimensions" == "1024x1024" ]]
  [[ "$channels" != *a* ]]
fi

ja_keys="$(mktemp)"
en_keys="$(mktemp)"
trap 'rm -f "$ja_keys" "$en_keys"' EXIT
sed -n 's/^"\([^"]*\)".*/\1/p' RooomShot/Resources/ja.lproj/Localizable.strings | sort > "$ja_keys"
sed -n 's/^"\([^"]*\)".*/\1/p' RooomShot/Resources/en.lproj/Localizable.strings | sort > "$en_keys"
if ! diff -u "$ja_keys" "$en_keys"; then
  echo "Localization keys differ between Japanese and English." >&2
  exit 1
fi

if command -v rg >/dev/null 2>&1; then
  broad_scope_matches="$(rg -n 'googleapis\.com/auth/drive[" ]' RooomShot --glob '*.swift' || true)"
else
  broad_scope_matches="$(grep -R -n -E 'googleapis\.com/auth/drive[" ]' RooomShot --include='*.swift' || true)"
fi
if [[ -n "$broad_scope_matches" ]]; then
  echo "$broad_scope_matches"
  echo "Broad Google Drive scope found. Use drive.file only." >&2
  exit 1
fi

if command -v rg >/dev/null 2>&1; then
  product_id_found="$(rg -l 'com\.rooomtech\.rooomshot\.monthly' RooomShot/Models/SubscriptionPlan.swift app_store_submission/APP_STORE_VALUES.md | wc -l | tr -d ' ')"
else
  product_id_found="$(grep -l -E 'com\.rooomtech\.rooomshot\.monthly' RooomShot/Models/SubscriptionPlan.swift app_store_submission/APP_STORE_VALUES.md | wc -l | tr -d ' ')"
fi
if [[ "$product_id_found" != "2" ]]; then
  echo "The StoreKit product ID is missing or inconsistent." >&2
  exit 1
fi

if command -v rg >/dev/null 2>&1; then
  terms_url_found="$(rg -l 'TERMS\.md' fastlane/metadata/ja/description.txt fastlane/metadata/en-US/description.txt | wc -l | tr -d ' ')"
else
  terms_url_found="$(grep -l -E 'TERMS\.md' fastlane/metadata/ja/description.txt fastlane/metadata/en-US/description.txt | wc -l | tr -d ' ')"
fi
if [[ "$terms_url_found" != "2" ]]; then
  echo "App Store descriptions must include the Terms of Use URL." >&2
  exit 1
fi

if find . -type l | grep -q .; then
  echo "Symlinks are not allowed in the submission repository." >&2
  exit 1
fi

echo "Repository validation passed."

#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
PROJECT_PATH="$ROOT_DIR/PulsePanel.xcodeproj"
IOS_SCHEME="${IOS_SCHEME:-PulsePaneliOS}"
MAC_SCHEME="${MAC_SCHEME:-PulsePanelMac}"
APP_NAME="${APP_NAME:-PulsePanel}"
MAC_APP_NAME="${MAC_APP_NAME:-PulsePanelMac}"
TEAM_ID="${TEAM_ID:-4P293R4B47}"
IOS_BUNDLE_ID="${IOS_BUNDLE_ID:-com.cagataydonmez.pulsepanel}"
MAC_BUNDLE_ID="${MAC_BUNDLE_ID:-com.cagataydonmez.pulsepanel.mac}"
CONFIGURATION="${CONFIGURATION:-Debug}"
BUILD_DIR="${BUILD_DIR:-$ROOT_DIR/build/Xcode}"
ARCHIVE_DIR="${ARCHIVE_DIR:-$ROOT_DIR/build/archives}"
MAC_INSTALL_DIR="${MAC_INSTALL_DIR:-$HOME/Applications}"
DEVICECTL_TIMEOUT="${DEVICECTL_TIMEOUT:-30}"
BUILD_NUMBER="${BUILD_NUMBER:-}"
ASC_KEY_ID="${ASC_KEY_ID:-}"
ASC_ISSUER_ID="${ASC_ISSUER_ID:-}"
TESTFLIGHT_CONFIRM="${TESTFLIGHT_CONFIRM:-${CONFIRM_TESTFLIGHT:-}}"
ASC_KEY_PATH="${ASC_KEY_PATH:-}"

log() { printf '%s\n' "$*"; }
die() { printf 'Error: %s\n' "$*" >&2; exit 1; }
require_cmd() { command -v "$1" >/dev/null 2>&1 || die "Missing required command: $1"; }

print_help() {
  cat <<EOF
Usage:
  ./install_local.sh devices
  ./install_local.sh mac
  ./install_local.sh iphone
  ./install_local.sh ios
  ./install_local.sh both
  ./install_local.sh testflight

Commands:
  devices     List iPhones visible to Xcode CoreDevice/devicectl.
  mac         Build the macOS menu bar app, copy it to ~/Applications, and launch it.
  iphone      Build the iOS app for a paired iPhone, install over USB/Wi-Fi, and launch it.
  ios         Alias for iphone.
  both        Build/install Mac first, then build/install iPhone.
  testflight  Archive, export IPA, and upload to App Store Connect/TestFlight.

Defaults:
  TEAM_ID=$TEAM_ID
  IOS_BUNDLE_ID=$IOS_BUNDLE_ID
  MAC_BUNDLE_ID=$MAC_BUNDLE_ID
  MAC_INSTALL_DIR=$MAC_INSTALL_DIR

Wi-Fi iPhone prerequisites:
  1. Pair the iPhone in Xcode > Window > Devices and Simulators.
  2. Enable wireless/network debugging for that device.
  3. Keep Mac and iPhone on the same Wi-Fi network.
  4. Keep the iPhone unlocked during install.

TestFlight prerequisites:
  export ASC_KEY_ID=XXXXXXXXXX
  export ASC_ISSUER_ID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
  export ASC_KEY_PATH=~/.appstoreconnect/private_keys/AuthKey_\${ASC_KEY_ID}.p8
  export TESTFLIGHT_CONFIRM=1   # required for noninteractive uploads
  Put AuthKey_\${ASC_KEY_ID}.p8 in ~/.appstoreconnect/private_keys/
EOF
}

write_export_options() {
  local path="$1"
  /usr/bin/python3 - "$path" "$TEAM_ID" <<'PYPLIST'
from pathlib import Path
import sys

path = Path(sys.argv[1])
team_id = sys.argv[2]
path.parent.mkdir(parents=True, exist_ok=True)
path.write_text(
    '<?xml version="1.0" encoding="UTF-8"?>\n'
    '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" '
    '"http://www.apple.com/DTDs/PropertyList-1.0.dtd">\n'
    '<plist version="1.0">\n'
    '<dict>\n'
    '    <key>method</key>\n'
    '    <string>app-store-connect</string>\n'
    '    <key>signingStyle</key>\n'
    '    <string>automatic</string>\n'
    '    <key>teamID</key>\n'
    f'    <string>{team_id}</string>\n'
    '    <key>uploadBitcode</key>\n'
    '    <false/>\n'
    '    <key>uploadSymbols</key>\n'
    '    <true/>\n'
    '</dict>\n'
    '</plist>\n',
    encoding='utf-8',
)
PYPLIST
}

build_number() {
  if [[ -n "$BUILD_NUMBER" ]]; then
    printf '%s' "$BUILD_NUMBER"
  else
    date +%Y%m%d%H%M%S
  fi
}

appstore_connect_key_path() {
  if [[ -n "$ASC_KEY_PATH" ]]; then
    printf '%s' "${ASC_KEY_PATH/#\~/$HOME}"
  else
    printf '%s' "$HOME/.appstoreconnect/private_keys/AuthKey_${ASC_KEY_ID}.p8"
  fi
}

list_ios_devices_json() {
  local tmp log_file stderr_file
  tmp="$(mktemp "${TMPDIR:-/tmp}/pulsepanel-devices-json.XXXXXX")"
  log_file="$(mktemp "${TMPDIR:-/tmp}/pulsepanel-devices-log.XXXXXX")"
  stderr_file="$(mktemp "${TMPDIR:-/tmp}/pulsepanel-devices-stderr.XXXXXX")"
  if ! xcrun devicectl list devices \
    --timeout "$DEVICECTL_TIMEOUT" \
    --json-output "$tmp" \
    --log-output "$log_file" \
    >/dev/null \
    2>"$stderr_file"; then
    cat "$stderr_file" >&2
    rm -f "$tmp" "$log_file" "$stderr_file"
    return 1
  fi
  rm -f "$log_file" "$stderr_file"
  printf '%s' "$tmp"
}

list_ios_devices() {
  require_cmd xcrun
  local tmp
  tmp="$(list_ios_devices_json)" || return 1
  /usr/bin/python3 - "$tmp" <<'PYDEV'
import json
import sys

with open(sys.argv[1], "r", encoding="utf-8") as fh:
    payload = json.load(fh)

for device in payload.get("result", {}).get("devices", []):
    props = device.get("deviceProperties", {})
    hardware = device.get("hardwareProperties", {})
    conn = device.get("connectionProperties", {})
    product = hardware.get("productType", "")
    if not product.startswith("iPhone"):
        continue
    name = props.get("name", device.get("identifier", "unknown"))
    paired = conn.get("pairingState", "")
    tunnel = conn.get("tunnelState", "")
    transport = conn.get("transportType", "")

    candidates = []
    def add(value):
        if value is None:
            return
        text = str(value).strip()
        if text and text not in candidates:
            candidates.append(text)

    identifier = device.get("identifier")
    add(identifier)
    if isinstance(identifier, str) and identifier.startswith("ecid_"):
        add(identifier.removeprefix("ecid_"))
    for source in (device, props, hardware, conn):
        for key in ("udid", "UDID", "serialNumber", "serial_number", "ecid", "ECID", "dnsName", "hostname"):
            add(source.get(key))
    add(name)
    print(f"{name} | {product} | {transport} | paired={paired} | tunnel={tunnel}|||{'|'.join(candidates)}")
PYDEV
  rm -f "$tmp"
}

select_ios_device() {
  if [[ -n "${DEVICE_ID:-}" ]]; then
    printf '%s' "$DEVICE_ID"
    return
  fi

  local entries_file entry choice selected
  local entries=()
  entries_file="$(mktemp "${TMPDIR:-/tmp}/pulsepanel-device-entries.XXXXXX")"
  list_ios_devices > "$entries_file" || {
    rm -f "$entries_file"
    die "No iPhone list returned. Open Xcode > Window > Devices and Simulators, unlock/pair the iPhone, then rerun."
  }

  while IFS= read -r entry; do
    [[ -n "$entry" ]] && entries+=("$entry")
  done < "$entries_file"
  rm -f "$entries_file"

  [[ ${#entries[@]} -gt 0 ]] || die "No iPhone found. Pair it in Xcode first, then rerun."
  if [[ ${#entries[@]} -eq 1 ]]; then
    printf '%s' "${entries[0]##*|||}"
    return
  fi

  printf '\nAvailable iPhones\n' > /dev/tty
  local index=1
  for entry in "${entries[@]}"; do
    printf '  %s. %s\n' "$index" "${entry%%|||*}" > /dev/tty
    index=$((index + 1))
  done

  while true; do
    read -r -p "Select device [1-${#entries[@]}]: " choice < /dev/tty
    if [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= ${#entries[@]} )); then
      selected="${entries[$((choice - 1))]}"
      printf '%s' "${selected##*|||}"
      return
    fi
  done
}

build_mac() {
  require_cmd xcodebuild
  mkdir -p "$BUILD_DIR"
  log "Building macOS companion."
  xcodebuild \
    -project "$PROJECT_PATH" \
    -scheme "$MAC_SCHEME" \
    -configuration "$CONFIGURATION" \
    -destination 'platform=macOS' \
    -allowProvisioningUpdates \
    "BUILD_DIR=$BUILD_DIR" \
    "OBJROOT=$BUILD_DIR/objroot" \
    DEVELOPMENT_TEAM="$TEAM_ID" \
    PRODUCT_BUNDLE_IDENTIFIER="$MAC_BUNDLE_ID" \
    COMPILER_INDEX_STORE_ENABLE=NO \
    build
}

install_mac() {
  local built_app="$BUILD_DIR/$CONFIGURATION/$MAC_APP_NAME.app"
  local install_app="$MAC_INSTALL_DIR/$MAC_APP_NAME.app"
  [[ -d "$built_app" ]] || die "Built Mac app not found: $built_app"

  mkdir -p "$MAC_INSTALL_DIR"
  if [[ -d "$install_app" ]]; then
    rm -rf "$install_app"
  fi
  ditto "$built_app" "$install_app"
  open "$install_app"
  log "Mac app installed and launched: $install_app"
}

build_iphone() {
  require_cmd xcodebuild
  mkdir -p "$BUILD_DIR"
  local number
  number="$(build_number)"
  log "Building iOS app for iPhone device install (build $number)."
  xcodebuild \
    -project "$PROJECT_PATH" \
    -scheme "$IOS_SCHEME" \
    -configuration "$CONFIGURATION" \
    -destination 'generic/platform=iOS' \
    -allowProvisioningUpdates \
    -allowProvisioningDeviceRegistration \
    "BUILD_DIR=$BUILD_DIR" \
    "OBJROOT=$BUILD_DIR/objroot" \
    DEVELOPMENT_TEAM="$TEAM_ID" \
    PRODUCT_BUNDLE_IDENTIFIER="$IOS_BUNDLE_ID" \
    CURRENT_PROJECT_VERSION="$number" \
    COMPILER_INDEX_STORE_ENABLE=NO \
    build
}

install_and_launch_iphone() {
  require_cmd xcrun
  local device_ref="$1"
  local app_path="$BUILD_DIR/$CONFIGURATION-iphoneos/$APP_NAME.app"
  [[ -d "$app_path" ]] || die "Built iOS app not found: $app_path"

  local candidates candidate installed_device stderr_file
  IFS='|' read -r -a candidates <<< "$device_ref"
  stderr_file="$(mktemp "${TMPDIR:-/tmp}/pulsepanel-install-stderr.XXXXXX")"

  log "Installing on iPhone over devicectl."
  for candidate in "${candidates[@]}"; do
    [[ -n "$candidate" ]] || continue
    if xcrun devicectl device install app \
      --device "$candidate" \
      --timeout "$DEVICECTL_TIMEOUT" \
      "$app_path" \
      2>"$stderr_file"; then
      installed_device="$candidate"
      break
    fi
  done

  if [[ -z "${installed_device:-}" ]]; then
    cat "$stderr_file" >&2
    rm -f "$stderr_file"
    die "Could not install on the selected iPhone. Keep it unlocked, connect USB once if Wi-Fi pairing is stale, then rerun."
  fi

  log "Launching $IOS_BUNDLE_ID."
  xcrun devicectl device process launch \
    --device "$installed_device" \
    --timeout "$DEVICECTL_TIMEOUT" \
    --terminate-existing \
    "$IOS_BUNDLE_ID"
  rm -f "$stderr_file"
  log "iPhone app installed and launched."
}

iphone_flow() {
  require_cmd xcrun
  cat <<'EOF'

Before iPhone install:
- Unlock the iPhone.
- For Wi-Fi install, pair it once in Xcode and keep both devices on the same Wi-Fi network.
- If the device is missing, open Xcode > Window > Devices and Simulators.
EOF
  local device_id
  device_id="$(select_ios_device)"
  build_iphone
  install_and_launch_iphone "$device_id"
}

mac_flow() {
  build_mac
  install_mac
}

both_flow() {
  mac_flow
  iphone_flow
}

check_testflight_prereqs() {
  require_cmd xcodebuild
  require_cmd xcrun
  require_cmd security

  local ok=1
  [[ -n "$ASC_KEY_ID" ]] || { log "[MISSING] ASC_KEY_ID is not set."; ok=0; }
  [[ -n "$ASC_ISSUER_ID" ]] || { log "[MISSING] ASC_ISSUER_ID is not set."; ok=0; }
  if [[ -n "$ASC_KEY_ID" ]]; then
    local key_path
    key_path="$(appstore_connect_key_path)"
    [[ -f "$key_path" ]] || { log "[MISSING] App Store Connect key file: $key_path"; ok=0; }
  fi

  local dist_count
  dist_count="$(security find-identity -v -p codesigning 2>/dev/null | grep -c 'Apple Distribution:' || true)"
  [[ "$dist_count" -gt 0 ]] || { log "[MISSING] Apple Distribution certificate in Keychain."; ok=0; }
  [[ "$ok" -eq 1 ]] || die "Fix TestFlight prerequisites, then rerun."

  cat <<EOF

TestFlight target:
  Team ID      : $TEAM_ID
  Bundle ID    : $IOS_BUNDLE_ID
  Archive dir  : $ARCHIVE_DIR
EOF

  if [[ "$TESTFLIGHT_CONFIRM" == "1" || "$TESTFLIGHT_CONFIRM" =~ ^[Yy][Ee]?[Ss]?$ ]]; then
    log "TESTFLIGHT_CONFIRM is set; continuing without interactive prompt."
    return
  fi

  [[ -r /dev/tty ]] || die "Set TESTFLIGHT_CONFIRM=1 to run TestFlight upload without an interactive terminal."

  local confirm
  read -r -p "Proceed with archive/export/upload? [y/N] " confirm < /dev/tty
  [[ "$confirm" =~ ^[Yy]$ ]] || die "Aborted."
}

testflight_flow() {
  check_testflight_prereqs

  mkdir -p "$ARCHIVE_DIR"
  local timestamp archive_path export_path export_options ipa_path number key_path
  timestamp="$(date +%Y%m%d_%H%M%S)"
  number="$(build_number)"
  key_path="$(appstore_connect_key_path)"
  archive_path="$ARCHIVE_DIR/${APP_NAME}_${timestamp}.xcarchive"
  export_path="$ARCHIVE_DIR/${APP_NAME}_${timestamp}_ipa"
  export_options="$ARCHIVE_DIR/ExportOptions_${timestamp}.plist"

  write_export_options "$export_options"

  log "Archiving iOS app for App Store Connect (build $number)."
  xcodebuild \
    -project "$PROJECT_PATH" \
    -scheme "$IOS_SCHEME" \
    -configuration Release \
    -destination 'generic/platform=iOS' \
    -archivePath "$archive_path" \
    -allowProvisioningUpdates \
    -authenticationKeyPath "$key_path" \
    -authenticationKeyID "$ASC_KEY_ID" \
    -authenticationKeyIssuerID "$ASC_ISSUER_ID" \
    DEVELOPMENT_TEAM="$TEAM_ID" \
    PRODUCT_BUNDLE_IDENTIFIER="$IOS_BUNDLE_ID" \
    CURRENT_PROJECT_VERSION="$number" \
    COMPILER_INDEX_STORE_ENABLE=NO \
    archive

  log "Exporting IPA."
  xcodebuild \
    -exportArchive \
    -archivePath "$archive_path" \
    -exportPath "$export_path" \
    -exportOptionsPlist "$export_options" \
    -allowProvisioningUpdates \
    -authenticationKeyPath "$key_path" \
    -authenticationKeyID "$ASC_KEY_ID" \
    -authenticationKeyIssuerID "$ASC_ISSUER_ID"

  ipa_path="$(find "$export_path" -name '*.ipa' -print -quit)"
  [[ -f "$ipa_path" ]] || die "IPA not found in $export_path"

  log "Uploading to App Store Connect/TestFlight."
  xcrun altool \
    --upload-app \
    -f "$ipa_path" \
    -t ios \
    --apiKey "$ASC_KEY_ID" \
    --apiIssuer "$ASC_ISSUER_ID"

  log "Upload complete. Processing will appear in App Store Connect > TestFlight."
  log "Archive: $archive_path"
  log "IPA: $ipa_path"
}

case "${1:-help}" in
  devices)
    list_ios_devices
    ;;
  mac)
    mac_flow
    ;;
  iphone|ios)
    iphone_flow
    ;;
  both|all|mac-ios|ios-mac)
    both_flow
    ;;
  testflight)
    testflight_flow
    ;;
  help|-h|--help)
    print_help
    ;;
  *)
    print_help
    die "Unknown command: $1"
    ;;
esac

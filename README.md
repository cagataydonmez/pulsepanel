# PulsePanel

PulsePanel is a native SwiftUI iPhone command board with a SwiftUI/AppKit macOS menu bar companion. The iPhone discovers a Mac on the local network, pairs with a 6-digit code, stores trust in Keychain, and sends JSON commands for local execution.

## Current Implementation

- Shared Swift package models for commands, pairing, devices, responses, and errors.
- iOS SwiftUI app source for discovery, pairing, dashboard, tile editing, settings, local board storage, Bonjour browsing, command transport, and Keychain token storage.
- macOS SwiftUI menu bar companion source with pairing code UI, trusted-device storage, Bonjour listener, command routing, and local command executors.
- MVP commands:
  - `launchApp(bundleId)`
  - `openURL(url)`
  - `runShortcut(name)`
  - `sendHotkey(modifiers, key)`
  - `getInstalledApps`
  - `getRunningApps`

## Build Checks

The shared package and macOS executable can be checked with:

```bash
swift test
swift build --product PulsePanelMac
```

The iOS sources are included as a Swift package target for Xcode integration. A formal `.xcodeproj` with iOS and macOS app targets is the next packaging step before device deployment.

## Docs

- `docs/LOCAL_COMMAND_PANEL_PLAN.md`
- `docs/UI_UX_PLAN.md`

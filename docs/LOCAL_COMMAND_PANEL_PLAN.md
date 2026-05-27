# Local Command Panel Plan

Status: planning only, no implementation in this pass.

Working product name: **PulsePanel**

Name note: PulsePanel is a temporary internal name for planning. Before shipping, run an App Store, domain, and trademark availability check. The product must not copy the branding, layout, wording, icons, color palette, screenshots, or interaction identity of any existing remote-control or button-deck app.

## 1. Goal

Build a native Apple ecosystem app where an iPhone becomes a local touch command panel for a Mac.

- iPhone app: discovers trusted Macs, pairs with a 6-digit code, and exposes a dashboard of command tiles.
- Mac app: runs as a SwiftUI/AppKit menu bar companion, advertises itself locally, verifies trusted devices, and executes commands on the same Mac.
- Shared layer: Swift package containing the Codable JSON protocol, command definitions, pairing messages, and response/error models.
- Privacy stance: local network first, no account requirement for MVP, no cloud relay in MVP, no command history leaving the devices.

## 2. Research Summary

Comparable apps and product patterns reviewed:

| Product | Relevant patterns | What to learn | What to avoid copying |
|---|---|---|---|
| BTT Remote Control | Same-Wi-Fi Mac control, trackpad, keyboard, media keys, app-specific actions, custom action icons, one-handed iPhone use | Users value broad Mac control, app-specific commands, custom icons, and one-handed operation | Do not copy BetterTouchTool/BTT naming, broad "full control" wording, or remote-trackpad-first UX |
| Unified Remote | Automatic server detection, Wi-Fi/Bluetooth connection, password protection, encryption, free/premium tiers, custom remotes | Discovery, security expectations, theme support, and extensible remote profiles are category norms | Do not copy "unified remote" positioning or generic universal-remote visual language |
| Kommand | iPhone + Mac companion, local Wi-Fi discovery, trackpad, keyboard, media, browser controls | Simple setup and automatic discovery are table stakes for Mac companion apps | Avoid copying its tab set, marketing language, or visual composition |
| ReMac | Local-network-first control with optional relay, trusted paired devices, deeper Mac surface | A future remote-access tier can exist, but local direct control should remain the core | Do not ship relay or screen/file/terminal surfaces in MVP |
| Elgato Stream Deck Mobile | Customizable keys, profiles, folders, pages, icons, multi-actions, six-key free tier | Tile dashboards need organization, icon personalization, profiles, and future monetization hooks | Do not copy Stream Deck grid identity, "keys" terminology, icon pack style, or hardware-deck metaphors too closely |
| Wake PC / Unyx-style companions | Lightweight menu bar agent, local network, no-account expectations, launch apps, volume/brightness/hotkeys | Menu bar status, permission checks, and local-only setup should feel lightweight | Avoid copying wording and all-in-one system-control positioning |

Sources:

- BTT Remote Control App Store listing: https://apps.apple.com/us/app/btt-remote-control/id561676304
- Unified Remote features: https://www.unifiedremote.com/features
- Kommand product page: https://kommandapp.com/
- ReMac product page: https://www.remac.tech/
- Elgato Stream Deck Mobile App Store listing: https://apps.apple.com/nl/app/elgato-stream-deck-mobile/id1440014184?l=en-GB&platform=mac
- Elgato Stream Deck Mobile getting started: https://help.elgato.com/hc/en-us/articles/16786832942221-Elgato-Stream-Deck-Mobile-2-0-Getting-Started
- Wake PC product page: https://wakepc.app/
- Unyx product page: https://unyxapp.com/

## 3. Product Properties From Research

PulsePanel should keep these category-proven properties, expressed with original UX and wording:

- Local-first discovery: Macs appear automatically through Bonjour on the same network.
- Visible trust state: every Mac shows paired, unpaired, unavailable, or permission-limited status.
- Fast tactile dashboard: the primary iPhone surface is a grid of user-created tiles, not a remote trackpad.
- One-handed operation: tile size, bottom actions, and edit flows should work comfortably on iPhone.
- Profiles later, simple board now: MVP ships one board; the data model supports profiles/pages without exposing unfinished UI.
- Personal tile identity: color, SF Symbol, label, and optional icon image should be part of the tile model.
- Permission transparency: hotkeys, Shortcuts, and future Accessibility features must show exact Mac-side permission needs.
- Mac menu bar confidence: companion app must show server status, paired devices, IP/service state, and recent command failures.
- Privacy copy: no account, no cloud relay, command JSON stays on local network in MVP.
- Extensibility: single-tap commands now; multi-action sequences and conditional commands later.

## 4. Original UX Direction

Register: product UI. Design should serve repeated command execution, not marketing.

Scene: a user is at a desk or across the room with their Mac visible, using the iPhone as a low-friction command surface while working, presenting, editing, or relaxing.

UX principles:

- The first screen after setup should be useful: show the board, connection status, and add tile affordance.
- Avoid a remote-desktop mental model. This app is not a screen viewer, mouse replacement, or file browser in MVP.
- Use native Apple controls and SF Symbols. System familiarity matters more than decorative novelty.
- Use restrained color: neutral surfaces, semantic status color, and user-chosen tile accents.
- Do not use Stream Deck-style terminology as the product language. Prefer "tile", "board", "Mac", "command", "pair".
- Keep all safety-sensitive actions visible: destructive or permission-heavy actions should require clear user intent.

Brand voice:

- English: calm, direct, privacy-first.
- Turkish: natural Turkish, not literal translation.
- Avoid claims like "full control of your Mac" for MVP. Use narrower claims such as "Run local commands on your Mac."

## 5. Architecture Decision

Primary MVP transport: **Network.framework + Bonjour**.

Reasoning:

- Fits the requested local network architecture.
- Gives explicit control over service type, pairing messages, framing, reconnection, and future encryption.
- Apple documents Bonjour as automatic local service discovery, and Network.framework supports Bonjour advertisement through `NWListener` and browsing through `NWBrowser`.

Fallback option: **MultipeerConnectivity** only if Bonjour/NWConnection setup becomes too slow for the MVP.

Use MultipeerConnectivity only as a temporary MVP branch because it bundles discovery/session behavior, but it gives less control over protocol and future transport hardening.

Apple references:

- Bonjour overview: https://developer.apple.com/bonjour/
- NWListener documentation: https://developer.apple.com/documentation/network/nwlistener
- MultipeerConnectivity documentation: https://developer.apple.com/documentation/multipeerconnectivity
- Keychain Services: https://developer.apple.com/documentation/security/keychain-services
- NSWorkspace: https://developer.apple.com/documentation/appkit/nsworkspace
- Shortcuts command line guide: https://support.apple.com/guide/shortcuts-mac/run-shortcuts-from-the-command-line-apd455c82f02/mac
- CGEvent: https://developer.apple.com/documentation/coregraphics/cgevent

## 6. Proposed Repository Structure

```text
PulsePanel.xcodeproj
Packages/
  PulsePanelProtocol/
    Package.swift
    Sources/
      PulsePanelProtocol/
        CommandModels.swift
        PairingModels.swift
        DeviceModels.swift
        TransportEnvelope.swift
        ProtocolError.swift
    Tests/
      PulsePanelProtocolTests/
        CommandCodingTests.swift
        PairingCodingTests.swift

Apps/
  PulsePaneliOS/
    PulsePaneliOSApp.swift
    Features/
      Discovery/
      Pairing/
      Dashboard/
      TileEditor/
      Settings/
    Services/
      BonjourBrowser.swift
      CommandClient.swift
      TrustedMacStore.swift
      KeychainStore.swift
    Resources/
      Localizable.xcstrings

  PulsePanelMac/
    PulsePanelMacApp.swift
    MenuBar/
      MenuBarRootView.swift
      StatusMenuCommands.swift
    Pairing/
      PairingCodePresenter.swift
      TrustedDeviceStore.swift
    Transport/
      BonjourServer.swift
      CommandRouter.swift
      JSONLineConnection.swift
    Executor/
      MacCommandExecutor.swift
      AppCatalogProvider.swift
      ShortcutRunner.swift
      HotkeySender.swift
      URLLauncher.swift
      Accessibility/
        AccessibilityPermissionGate.swift
        WindowControlExecutor.swift
    Resources/
      Localizable.xcstrings
```

## 7. Shared Protocol Plan

Encoding: JSON over a framed stream.

Framing for MVP:

- Prefer length-prefixed UTF-8 JSON frames for robust parsing.
- JSON Lines is acceptable for first local prototype, but length-prefixing should be the planned shape.

Core models:

```swift
public struct CommandEnvelope: Codable, Sendable {
    public let id: UUID
    public let protocolVersion: Int
    public let issuedAt: Date
    public let deviceToken: String
    public let command: Command
}

public enum Command: Codable, Sendable {
    case launchApp(bundleId: String)
    case openURL(url: URL)
    case runShortcut(name: String)
    case sendHotkey(modifiers: [HotkeyModifier], key: HotkeyKey)
    case getInstalledApps
    case getRunningApps
}

public struct CommandResponse: Codable, Sendable {
    public let id: UUID
    public let ok: Bool
    public let result: CommandResult?
    public let error: ProtocolError?
}
```

Pairing models:

- `PairingCodeAnnouncement`: Mac advertises that pairing is available, but never advertises trusted token.
- `PairingRequest`: iPhone sends 6-digit code plus generated device public metadata.
- `PairingAccepted`: Mac returns trusted device token and Mac display metadata.
- `PairingRejected`: wrong code, expired code, too many attempts, or pairing disabled.

Data model notes:

- `deviceToken` should be random, high entropy, and stored in Keychain on both platforms.
- MVP token authenticates a trusted device, but is not enough for long-term security. Encryption and stronger challenge-response are explicit TODOs.
- Protocol version starts at `1`; reject unsupported future major versions.

## 8. macOS Companion Plan

App type:

- SwiftUI app with AppKit integration.
- Menu bar extra as the primary shell.
- Optional settings window for paired devices, privacy, logs, and advanced modules.

Core modules:

- `BonjourServer`: publishes `_pulsepanel._tcp` or final service name, accepts local connections.
- `PairingCodePresenter`: generates a 6-digit code, expires it after a short window, limits attempts.
- `TrustedDeviceStore`: stores trusted device records and token hashes in Keychain.
- `CommandRouter`: decodes `CommandEnvelope`, validates token, dispatches to executor.
- `MacCommandExecutor`: pure command facade used by router and tests.
- `AppCatalogProvider`: returns installed and running apps with names, bundle IDs, and optional icons.
- `ShortcutRunner`: calls `/usr/bin/shortcuts list` and `/usr/bin/shortcuts run <name>`.
- `HotkeySender`: uses `CGEvent` to post key down/up events with modifier flags.
- `URLLauncher`: uses `NSWorkspace` to open URLs.

MVP command behavior:

- `launchApp(bundleId)`: use `NSWorkspace` and Launch Services. If app is already running, activate it.
- `openURL(url)`: validate URL scheme against an allowlist for MVP (`http`, `https`, `mailto`, plus user-confirmed custom schemes later), then open with `NSWorkspace`.
- `runShortcut(name)`: execute `/usr/bin/shortcuts run` via `Process`; capture exit code, stdout, stderr.
- `sendHotkey(modifiers, key)`: synthesize keyboard event pair with `CGEvent`; show permission troubleshooting if blocked by macOS privacy settings.
- `getInstalledApps`: scan standard application locations and Launch Services metadata.
- `getRunningApps`: use `NSWorkspace.shared.runningApplications`.

Menu bar UX:

- Status: Online, Pairing, Offline, Permission Needed.
- Actions: Show Pairing Code, Pause Server, Open Settings, Quit.
- Paired Devices list: device name, last seen, revoke button.
- Command log: last 20 local events, stored locally only, with opt-out.

Permission stance:

- Shortcuts command support may surface Shortcuts-side security prompts depending on the shortcut.
- Hotkey sending and future window control must be permission-gated and documented in-app.
- Advanced Accessibility window control stays behind `Accessibility/` module and is not enabled in MVP command tiles.

## 9. iOS App Plan

Main screens:

1. Discovery
   - Shows Macs found on the local network.
   - Shows empty state with local network permission guidance.
   - Allows manual IP entry as a debug/developer fallback later, not MVP default.

2. Pairing
   - User selects Mac, sees "Enter the 6-digit code shown on your Mac."
   - Handles expired code, wrong code, and Mac unavailable states.
   - On success, stores trusted token in Keychain.

3. Dashboard
   - Grid of command tiles.
   - Header shows connected Mac, status dot, and switch Mac affordance.
   - Empty state: add first tile.
   - Tile press sends command and shows immediate progress/success/failure feedback.

4. Add/Edit Tile
   - Tile type picker: App, Website, Shortcut, Hotkey.
   - Common fields: title, accent color, symbol/icon, confirmation toggle.
   - App tile: choose from `getInstalledApps`.
   - Website tile: URL input with validation.
   - Shortcut tile: choose from Mac shortcuts list after adding a `getShortcuts` command in post-MVP, or type name in MVP.
   - Hotkey tile: modifier chips plus key picker.

5. Settings
   - Paired Macs.
   - Privacy explanation.
   - Local data reset.
   - Diagnostics export later.

Dashboard UX:

- Use a 2-column compact grid on iPhone, 3-column on larger phones if comfortable.
- Tiles should have stable dimensions and not resize based on text.
- Use SF Symbols for command categories.
- Long labels wrap to two lines; no marquee.
- Press states should be fast and tactile: visual down state, optional haptic, then result badge.

## 10. Localization Plan

Use String Catalogs from day one:

- `Apps/PulsePaneliOS/Resources/Localizable.xcstrings`
- `Apps/PulsePanelMac/Resources/Localizable.xcstrings`

Initial locales:

- English: development language
- Turkish: first supported localization

Example string keys:

| Key | English | Turkish |
|---|---|---|
| `app.name` | PulsePanel | PulsePanel |
| `discovery.title` | Choose a Mac | Bir Mac sec |
| `discovery.empty` | No Macs found on this network. | Bu agda Mac bulunamadi. |
| `pairing.codePrompt` | Enter the 6-digit code shown on your Mac. | Mac'inizde gorunen 6 haneli kodu girin. |
| `dashboard.emptyTitle` | Add your first tile | Ilk kutucugunuzu ekleyin |
| `tile.type.app` | App | Uygulama |
| `tile.type.website` | Website | Web sitesi |
| `tile.type.shortcut` | Shortcut | Kestirme |
| `tile.type.hotkey` | Hotkey | Klavye kisayolu |
| `privacy.localOnly` | Commands stay on your local network. | Komutlar yerel aginizda kalir. |

Note: final Turkish copy should use proper Turkish characters in `.xcstrings`. ASCII is used in this plan file only for editing consistency.

## 11. Pairing Flow

Mac:

1. User clicks "Show Pairing Code" in menu bar.
2. Mac generates a 6-digit code valid for 3 minutes.
3. Mac advertises pairable status in Bonjour TXT metadata without exposing the code.
4. Mac accepts limited pairing attempts per code.

iPhone:

1. User selects discovered Mac.
2. User enters 6-digit code.
3. iPhone generates local device ID and requested display name.
4. iPhone sends pairing request.
5. On success, iPhone stores trusted token in Keychain and opens dashboard.

Security caveat:

- MVP pairing token is trust-on-first-pairing. Add encryption and challenge-response before public release.

## 12. Persistence Plan

iOS:

- Keychain: trusted Mac tokens.
- App storage/file JSON: boards, tiles, selected Mac ID, local preferences.
- No iCloud sync in MVP.

macOS:

- Keychain: trusted device token hashes or secrets.
- App storage/file JSON: paired device display names, service settings, command log preference.
- No external database needed for MVP.

## 13. Xcode Setup Plan

Project:

- One Xcode project: `PulsePanel.xcodeproj`.
- Two app targets:
  - `PulsePaneliOS`
  - `PulsePanelMac`
- One local Swift package:
  - `PulsePanelProtocol`

Target deployment:

- iOS: choose current practical minimum during implementation, likely iOS 17+ unless product requirements force lower.
- macOS: choose current practical minimum during implementation, likely macOS 14+ for modern SwiftUI menu bar behavior.

Capabilities and Info.plist:

- iOS: Local Network usage description and Bonjour service entries.
- macOS: App Sandbox decision to validate early. If sandbox blocks required local execution behaviors, document and choose distribution strategy deliberately.
- macOS: privacy explanations for Accessibility/Input Monitoring if hotkey/window behavior requires them.

Testing:

- Unit tests for command JSON compatibility.
- Unit tests for tile-to-command mapping.
- Mac executor tests with injectable adapters.
- Manual local-network test matrix: same Wi-Fi, Mac firewall on/off, iPhone local network permission denied, wrong pairing code, token revoked.

## 14. MVP Milestones

Milestone 1: Project foundation

- Create Xcode project, targets, and local Swift package.
- Add protocol models and JSON tests.
- Add localization catalogs with English and Turkish keys.

Milestone 2: Local discovery and pairing

- Mac advertises Bonjour service.
- iOS discovers Mac.
- Pairing code flow works.
- Trusted tokens persist in Keychain.

Milestone 3: Command transport

- Implement framed JSON command request/response.
- Validate protocol version and device token.
- Add clear error responses.

Milestone 4: Mac command executor

- Implement app launch, URL opening, Shortcuts run/list helper, hotkey sender, installed apps, running apps.
- Add permission status reporting where possible.

Milestone 5: iOS dashboard

- Dashboard grid.
- Add/edit App, Website, Shortcut, and Hotkey tiles.
- Tile execution feedback.
- Local board persistence.

Milestone 6: Companion polish

- Menu bar status.
- Paired device management.
- Revoke token.
- Pause/resume server.
- Basic diagnostics.

## 15. Explicit TODOs

Encryption TODO:

- Replace plain trusted-token transport with encrypted sessions before release.
- Candidate approach: pairing establishes a long-term device key; every connection performs nonce-based challenge-response and derives a short-lived session key.
- Evaluate CryptoKit with Curve25519 key agreement plus ChaChaPoly or AES-GCM.
- Include replay protection, token rotation, and pairing reset.

StoreKit TODO:

- Keep monetization out of MVP command path.
- Possible future paid surfaces:
  - Multiple boards/profiles.
  - More tile styles.
  - Multi-action sequences.
  - Advanced Mac modules.
- Free tier should remain useful enough for trust: one Mac, one board, a limited number of tiles.

Accessibility TODO:

- Keep window control in a separate permission-gated module.
- Add preflight screen explaining exactly why Accessibility is needed.
- Do not request Accessibility at first launch.
- Provide fallback behavior when permission is denied.
- Document App Review rationale before enabling advanced controls.

Product TODO:

- Final naming and trademark search.
- App icon direction.
- PRODUCT.md and DESIGN.md creation before implementation.
- Privacy policy copy, even for local-only MVP.
- App Store review notes for local network, Shortcuts execution, and keyboard event behavior.

## 16. First Implementation Order

When implementation begins, do not start with UI polish. Start with the shared protocol and one end-to-end command.

Recommended first vertical slice:

1. `PulsePanelProtocol` with `openURL(url)`.
2. Mac menu bar app with Bonjour listener.
3. iOS discovery and pairing.
4. iOS single debug tile that sends `openURL`.
5. Replace debug tile with real dashboard/editor once transport is stable.

This reduces risk because local network discovery, pairing, token validation, and command dispatch are the core unknowns. Once one command works end to end, the remaining MVP commands can be added behind the same protocol.

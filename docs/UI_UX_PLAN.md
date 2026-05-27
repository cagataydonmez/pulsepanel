# PulsePanel UI/UX Plan

Status: planning only, no implementation in this pass.

Skill note: updated with the local `ui-ux-pro-max` skill at `.codex/skills/ui-ux-pro-max/SKILL.md`, plus the previously used product-interface guidance from `impeccable`.

Source plan: `docs/LOCAL_COMMAND_PANEL_PLAN.md`

## 0. ui-ux-pro-max Run Summary

Requirement extraction:

- Product type: native Apple productivity utility, local command panel, dashboard-like command board.
- Industry/context: personal productivity, Mac workflow automation, local network companion.
- Style keywords: professional, restrained, native, privacy-first, precise, low-friction.
- Stack: SwiftUI for iOS and macOS.

Commands run:

```bash
python3 .codex/skills/ui-ux-pro-max/scripts/search.py "native Apple SwiftUI productivity utility local command panel dashboard privacy professional restrained" --design-system -p "PulsePanel" -f markdown
python3 .codex/skills/ui-ux-pro-max/scripts/search.py "mobile app dashboard command panel accessibility loading animation" --domain ux -n 8
python3 .codex/skills/ui-ux-pro-max/scripts/search.py "native utility minimal professional dashboard" --domain style -n 8
python3 .codex/skills/ui-ux-pro-max/scripts/search.py "productivity utility dashboard teal orange restrained" --domain color -n 8
python3 .codex/skills/ui-ux-pro-max/scripts/search.py "dashboard navigation forms animation accessibility" --stack swiftui
```

Accepted recommendations:

- Productivity palette direction: teal focus plus warm orange for the strongest CTA, adapted for native system light/dark instead of copied as flat web colors.
- Dashboard guidance: dense but readable grid, stable loading states, clear filters/status, compact information hierarchy.
- Minimal/direct style guidance: reduce ornament, use clean typography, keep one obvious primary action per screen.
- UX guidance: show feedback for async operations, prevent repeated taps while commands are running, use numeric keyboard for pairing code, respect reduced motion.
- SwiftUI guidance: prefer type-safe `navigationDestination(for:)`, check `accessibilityReduceMotion`, and use native animation APIs.

Rejected or adapted recommendations:

- "Horizontal Scroll Journey" is a landing-page pattern, not appropriate for the iOS command board or macOS menu bar MVP.
- Fira Code/Fira Sans are not appropriate as the default native app typography. Use SF Pro/system fonts. A monospaced style may appear only in diagnostics.
- Web-only checklist items such as `cursor-pointer`, Tailwind classes, and web font loading are not implementation requirements for this native app.
- Hover-only interaction guidance must be adapted to touch, focus, keyboard, and pointer behavior by platform.

## 1. Product UX Position

PulsePanel is a local command surface for people who want to trigger Mac actions from an iPhone without turning the phone into a remote desktop. The core job is fast, trusted command execution: open an app, launch a website, run a Shortcut, send a hotkey, or inspect available Mac apps.

This should feel like a native Apple utility: calm, precise, tactile, privacy-aware, and predictable. It should not feel like a streaming control deck clone, a VNC client, a gaming controller, or a novelty automation toy.

Primary product promise:

> Run trusted local commands on your Mac from a personal iPhone command board.

Anti-promises:

- Do not claim "full Mac control" in MVP.
- Do not imply cloud sync, remote access outside the local network, or screen viewing.
- Do not copy the visual identity or language of Stream Deck, BetterTouchTool, Unified Remote, Kommand, ReMac, Wake PC, or Unyx.

## 2. Target Users And Contexts

Primary users:

- Mac power users who repeatedly launch apps, websites, shortcuts, and hotkeys.
- Creators, presenters, developers, students, and desk workers who want common Mac actions one tap away.
- Users who prefer local-only tools and do not want an account for a LAN companion app.

Usage contexts:

- Desk workflow: iPhone sits next to keyboard, user taps commands while focused on the Mac.
- Presentation or room control: user is near the Mac but not at the keyboard.
- Relaxed media/workflow context: user triggers simple actions from across the room.
- Setup context: user pairs iPhone and Mac once, then expects the app to reconnect quietly.

User mental state:

- During setup: cautious and permission-sensitive.
- During dashboard use: focused, expecting instant feedback.
- During errors: needs plain troubleshooting, not technical transport details.

## 3. Design Direction

Register: product UI.

Color strategy: Restrained with user-selected tile accents. The `ui-ux-pro-max` productivity palette recommends teal focus with warm orange action emphasis. Use that as a starting direction, but soften it into native light/dark tokens instead of applying raw saturated web colors everywhere.

Theme scene sentence: A user is working near a Mac in mixed indoor light, glancing between the Mac and iPhone while staying in flow, so the app should support both system light/dark mode with low-glare neutrals and clear state color.

Visual references to learn from, not copy:

- Apple Home: trusted local devices, clear rooms/devices, calm status language.
- Raycast: command-oriented hierarchy, fast actions, utility density.
- Shortcuts: user-created actions and approachable automation language.

Original visual lane:

- Native SwiftUI, SF Pro, SF Symbols, platform materials used sparingly.
- Rounded rectangles are acceptable for touch tiles, but avoid a hardware-button imitation.
- Tile grid should feel personal and editable, not like a branded keycap wall.
- Mac menu bar app should feel like a small system utility, not a full dashboard.
- Command feedback should be local and immediate: pressed, running, done, failed. Avoid frozen UI during network or command execution.

## 4. Information Architecture

iOS app:

```text
Launch
  -> Discovery
  -> Pairing
  -> Dashboard
       -> Add Tile
       -> Edit Tile
       -> Tile Detail/Error
       -> Switch Mac
       -> Settings
```

macOS app:

```text
Menu Bar Extra
  -> Status popover
  -> Show Pairing Code
  -> Paired Devices
  -> Permissions
  -> Command Activity
  -> Settings Window
```

Shared concepts:

- Mac: a discovered or paired computer running the companion.
- Board: the user's command grid for one selected Mac.
- Tile: a tappable command.
- Pair: establish trust between iPhone and Mac.
- Token: stored trust credential, never user-facing except as "trusted device".

Terminology rules:

- Use "tile", not "key", "button deck", or "remote key".
- Use "board", not "profile" in MVP UI.
- Use "Mac companion", not "server" in user-facing copy unless in diagnostics.
- Use "local network", not "LAN" in main UI.

## 5. iOS UX Plan

### 5.1 Launch And Routing

Routing logic:

- First launch with no paired Macs: Discovery.
- Paired Mac available: Dashboard.
- Paired Mac unavailable: Dashboard with offline state and reconnect affordance.
- Token revoked: Discovery with revoked trust message.

Launch should avoid splash-like marketing. The product opens into the next useful state.

### 5.2 Discovery Screen

Purpose: help the user find a Mac companion on the local network.

Layout:

- Top area: title, short privacy statement, local network status.
- Main list: discovered Macs with name, status, last seen, and pairing state.
- Bottom action: "Try again" or "Open setup help" when no devices are found.

States:

- Loading: skeleton rows for nearby Macs.
- Empty: explain that the Mac companion must be open and on the same local network.
- Permission denied: guide user to iOS Settings for Local Network permission.
- Mac found, unpaired: row CTA "Pair".
- Mac found, paired: row CTA "Connect".
- Mac found, incompatible: show version mismatch and update guidance.

Copy:

- Title: "Choose a Mac"
- Empty: "No Macs found on this network."
- Help: "Open PulsePanel on your Mac and keep both devices on the same Wi-Fi."
- Privacy: "Discovery stays on your local network."

### 5.3 Pairing Screen

Purpose: establish explicit trust with a 6-digit code.

Layout:

- Mac identity at top: name, status, network indicator.
- Code input: six fixed cells, numeric keyboard, paste support.
- Supporting copy: where to find the code on the Mac.
- Secondary action: "Choose another Mac."

States:

- Code entry.
- Verifying.
- Wrong code.
- Expired code.
- Too many attempts.
- Mac unavailable.
- Success transition to dashboard.

Behavior:

- Auto-submit after six digits.
- Use numeric keyboard on iPhone.
- Disable repeated submission while verification is running.
- Clear wrong code after failure but leave user on same screen.
- Use haptic feedback for success and failure.
- Never show the trusted token.

Copy:

- Prompt: "Enter the 6-digit code shown on your Mac."
- Wrong code: "That code did not match. Check the Mac and try again."
- Expired: "That code expired. Show a new code on your Mac."
- Success: "Paired with this Mac."

### 5.4 Dashboard

Purpose: make trusted commands fast, glanceable, and editable.

Layout:

- Header:
  - Connected Mac name.
  - Status dot and short state.
  - Switch Mac button.
  - Settings icon.
- Board:
  - 2-column grid on compact iPhone widths.
  - 3-column grid only when tile width remains comfortable.
  - Stable tile aspect ratio, roughly square or slightly tall.
- Bottom:
  - Add tile button.
  - Optional edit mode toggle.

Tile anatomy:

- SF Symbol or app icon.
- Label, max two lines.
- Optional small type badge: App, Web, Shortcut, Hotkey.
- Result indicator shown only after action: running, done, failed.

Tile interactions:

- Tap: execute command.
- Long press: context menu with Edit, Duplicate, Move, Delete.
- Drag in edit mode: reorder.
- Disable or debounce repeated taps while the same tile command is running.
- Failed command: show inline failed state and allow tap for details.
- Confirmation-enabled tile: show native confirmation dialog before execution.

States:

- Empty board: teach the user to add the first tile.
- Connected: normal grid.
- Reconnecting: dashboard remains visible, actions disabled with status.
- Offline: keep board visible, disable execution, show reconnect action.
- Permission limited: affected tiles show warning badge, not global panic.
- Command running: tile-level progress only.
- Command success: brief visual/haptic confirmation.
- Command failure: tile-level error plus detail sheet.

Dashboard visual rules:

- Keep the board calm. Tile accents identify commands, not decorate the whole screen.
- Avoid identical-looking tiles by using type badges, symbols, and user accents.
- Never resize the grid when a command result appears.
- Do not hide Add Tile in a top-only toolbar; it should be reachable one-handed.

### 5.5 Add/Edit Tile Flow

Purpose: create a command without exposing protocol complexity.

Flow:

1. Choose tile type.
2. Configure command.
3. Customize appearance.
4. Save and return to board.

Recommended structure:

- Use a pushed navigation flow or sheet with clear sections.
- Avoid modal stacking.
- Keep preview visible near the top.
- Put Save in the navigation bar and destructive Delete at bottom in edit mode.

Tile type picker:

- App: choose installed Mac app.
- Website: enter URL.
- Shortcut: enter Shortcut name in MVP; later browse Mac shortcuts.
- Hotkey: choose modifiers and key.

Common fields:

- Title.
- Symbol or icon.
- Accent color.
- Require confirmation toggle.

Validation:

- App requires a bundle ID.
- Website requires valid URL scheme.
- Shortcut requires non-empty name.
- Hotkey requires at least one key, modifiers optional.

Error style:

- Inline field errors.
- Plain language.
- No raw JSON or transport errors in editor UI.

### 5.6 Settings

Purpose: trust, privacy, and maintenance.

Sections:

- Connected Mac.
- Paired Macs.
- Privacy.
- Local Data.
- About.
- Diagnostics, hidden under advanced or debug in MVP.

Critical actions:

- Revoke Mac trust.
- Clear board data.
- Reset all local data.

Confirmation copy must name the target:

- "Forget MacBook Pro?"
- "This removes the trusted pairing from this iPhone. You can pair again later."

## 6. macOS UX Plan

### 6.1 Menu Bar Status

Purpose: make the companion feel present, trustworthy, and lightweight.

Menu bar icon states:

- Idle/online.
- Pairing code active.
- Connected device.
- Permission needed.
- Server paused.

Popover layout:

- Header: app name, online status, local network indicator.
- Primary action: Show Pairing Code.
- Paired devices summary.
- Permissions summary.
- Recent command status.
- Settings and Quit.

Avoid:

- Large marketing panels.
- Dense logs in the first popover.
- Technical network jargon in the default view.

### 6.2 Pairing Code Popover

Purpose: make pairing obvious and time-bounded.

Layout:

- Large 6-digit code.
- Countdown.
- Mac name as seen by iPhone.
- "Stop Pairing" action.

Security behavior:

- Code expires after 3 minutes.
- New code replaces old code.
- Failed attempts lock the current code briefly.

Copy:

- "Enter this code on your iPhone."
- "This code expires in 3:00."

### 6.3 Settings Window

Use a native SwiftUI settings window with tabs or sidebar:

- General:
  - Start at login.
  - Pause local command listener.
  - Mac display name.
- Devices:
  - Paired iPhones.
  - Last seen.
  - Revoke trust.
- Permissions:
  - Shortcuts status.
  - Keyboard event status.
  - Accessibility module disabled in MVP.
- Privacy:
  - Local-only explanation.
  - Command activity retention.
- Advanced:
  - Service name.
  - Port/debug info.
  - Export diagnostics.

Settings should support keyboard navigation and VoiceOver labels.

### 6.4 Command Activity

Purpose: help troubleshoot without feeling surveilled.

Default retention:

- Keep last 20 local command results on Mac only.
- No command payloads beyond useful labels unless diagnostics are enabled.
- Allow disabling activity history.

Activity row:

- Time.
- Device.
- Command type.
- Result.
- Short error if failed.

## 7. Visual System

Typography:

- Use SF Pro through SwiftUI system fonts.
- Large title only for first-run and empty states.
- Dashboard header should be compact.
- Tile labels use medium weight, max two lines.
- Settings and diagnostics use standard platform table/list type.

Color:

- Support system light and dark.
- Neutral backgrounds tinted slightly cool, not pure black or pure white.
- Accent color reserved for selected Mac, primary actions, and user tile accents.
- Suggested base palette from `ui-ux-pro-max`, adapted for SwiftUI:
  - Focus teal: `#0D9488`.
  - Secondary teal: `#14B8A6`.
  - Warm action: `#F97316`.
  - Light background seed: `#F0FDFA`.
  - Deep text seed: `#134E4A`.
- Do not apply teal to every surface. Use it for connection, selection, and calm focus. Reserve orange for rare primary creation or setup actions.
- Semantic states:
  - Success: green.
  - Warning: yellow/orange.
  - Error: red.
  - Info/connection: blue or app accent.

Tile colors:

- Provide a curated palette of 8 to 12 accents.
- Accent appears as symbol tint, subtle fill, or top-level tile emphasis.
- Avoid full-saturation fills on every tile.

Shape:

- iOS tiles: 14 to 18 pt corner radius, depending on SwiftUI platform norms.
- Mac popover panels: platform-native grouping.
- Do not nest card-like containers inside tiles or settings cards.

Iconography:

- SF Symbols first.
- App tiles may use real app icons from Mac catalog.
- Website tiles may use generated favicon later, but not required for MVP.
- Use one icon style consistently: no mixed emoji/SF/custom glyph set by default.

Motion:

- 150 to 250 ms transitions.
- Motion communicates state: connecting, press, success, failure, reorder.
- No ornamental launch animations.
- Respect Reduce Motion.
- Loading or running states above 300 ms must show feedback. Use tile-level progress for commands and skeleton/list placeholders for discovery.

Haptics:

- Tile success: light confirmation.
- Tile failure: subtle error.
- Pairing success: stronger success.
- Respect system settings.

## 8. Accessibility

iOS:

- Minimum 44 x 44 pt touch targets.
- VoiceOver labels for every tile: title, command type, connected Mac, and status.
- Dynamic Type support for setup, settings, and editor.
- Dashboard tiles should handle larger text through wrapping and stable tile height.
- Color is never the only status indicator.
- Reduce Motion support.

macOS:

- Keyboard navigable menu and settings.
- VoiceOver labels for menu bar status and pairing code.
- Sufficient contrast in light and dark.
- Permission states readable without color.

Accessibility-specific copy:

- Avoid vague "permission required."
- Say what is needed and why: "Keyboard shortcuts need permission so the Mac can receive the hotkey you tap."

## 9. Localization And Copy

Languages:

- English.
- Turkish.

Localization requirements:

- Use String Catalogs.
- Design for longer Turkish strings.
- Do not rely on fixed button widths.
- Avoid idioms that translate poorly.
- Final Turkish strings should use proper Turkish characters in `.xcstrings`.

Voice:

- Direct.
- Privacy-aware.
- Calm during errors.
- No jokes in permission or security flows.

Copy examples:

| Context | English | Turkish draft |
|---|---|---|
| Discovery title | Choose a Mac | Bir Mac sec |
| Discovery empty | No Macs found on this network. | Bu agda Mac bulunamadi. |
| Pairing prompt | Enter the 6-digit code shown on your Mac. | Mac'inizde gorunen 6 haneli kodu girin. |
| Dashboard offline | This Mac is offline. | Bu Mac cevrimdisi. |
| Tile failed | Command failed. | Komut calismadi. |
| Privacy | Commands stay on your local network. | Komutlar yerel aginizda kalir. |
| Revoke trust | Forget this Mac | Bu Mac'i unut |

Note: ASCII Turkish is used here for repository editing consistency. The shipped string catalog should use Turkish diacritics.

## 10. Key UX States Checklist

Discovery:

- Local network permission unknown.
- Local network permission denied.
- Searching.
- No Macs found.
- One Mac found.
- Multiple Macs found.
- Paired Mac found.
- Incompatible companion version.

Pairing:

- Code entry.
- Verifying.
- Wrong code.
- Expired code.
- Too many attempts.
- Pairing disabled on Mac.
- Success.

Dashboard:

- Empty board.
- Connected with tiles.
- Reconnecting.
- Offline.
- Token revoked.
- Command running.
- Command succeeded.
- Command failed.
- Permission-limited tile.
- Edit mode.

Tile editor:

- New tile.
- Existing tile.
- Validation error.
- Unsaved changes.
- Delete confirmation.

Mac companion:

- Online.
- Paused.
- Pairing active.
- Device connected.
- Permission needed.
- Command failure.
- No paired devices.
- Device revoked.

## 11. Responsive And Platform Adaptation

iPhone compact:

- 2-column dashboard.
- Bottom-reachable Add Tile.
- Editor uses vertical sections.
- Avoid horizontal scrolling.

iPhone larger:

- 2 or 3 columns based on content fit.
- Header stays compact.

iPad, later:

- Board plus inspector/editor split view.
- Multi-column settings.
- Same command model.

macOS:

- Menu bar popover for daily use.
- Settings window for management.
- No large always-on dashboard in MVP.

Orientation:

- Portrait first on iPhone.
- Landscape must not break pairing code entry or tile grid.

## 12. Permission UX

Principles:

- Ask only when the user attempts or configures a feature that needs permission.
- Explain before triggering a system prompt.
- Keep permission repair steps visible after denial.
- Do not block unrelated command types.

Permission surfaces:

- iOS Local Network: first discovery.
- macOS Shortcuts behavior: explain when Shortcut execution fails due to Shortcuts security.
- macOS keyboard/hotkey permissions: show before first hotkey tile execution if required.
- macOS Accessibility: future module only, not MVP default.

Permission copy pattern:

1. What feature needs access.
2. Why it needs access.
3. What happens if user declines.
4. Button to continue or open settings.

## 13. Error And Recovery Model

Error display rules:

- Tile execution errors stay close to the tile.
- Connection errors appear in dashboard header.
- Pairing errors remain on pairing screen.
- Technical details go behind "Details" or diagnostics.

Common errors:

- Mac not reachable: "This Mac is offline."
- Token rejected: "This iPhone is no longer paired with this Mac."
- App missing: "That app is not installed on this Mac."
- Shortcut failed: "The Shortcut did not finish."
- URL blocked: "This URL type is not allowed yet."
- Hotkey unavailable: "The Mac needs permission before it can receive this hotkey."

Recovery actions:

- Try again.
- Choose another Mac.
- Pair again.
- Edit tile.
- Open Mac permissions.
- Delete invalid tile.

## 14. SwiftUI Implementation Guidance

Navigation:

- Use `NavigationStack` for iOS setup, dashboard, and tile editor flows.
- Prefer typed routes with `navigationDestination(for:)` instead of ad hoc destination links.
- Keep Mac settings in a native settings window or sidebar-style layout, not a reused iPhone flow.

State and feedback:

- Model command execution per tile so one running tile does not freeze the whole board.
- Disable repeated submission while pairing verification or tile execution is in flight.
- Show skeleton rows while discovering Macs instead of a blank screen.
- Keep offline and reconnecting states visible in the dashboard header.

Forms:

- Pairing code uses numeric keyboard and paste handling.
- Website URL field should use URL keyboard and inline validation.
- Hotkey editor should use chips/toggles for modifiers and a constrained key picker.
- Shortcut field should support plain text in MVP and later become a picker when Shortcut listing is promoted.

Motion:

- Read `@Environment(\.accessibilityReduceMotion)`.
- Use SwiftUI animation APIs for state changes.
- Avoid manual timing systems unless a specific native API requires it.

Native adaptation:

- Translate web recommendations into native controls. `cursor-pointer`, Tailwind utilities, hover-only feedback, and web font loading do not apply to shipped SwiftUI.
- Pointer hover can be added on iPad/macOS later, but touch and keyboard behavior are the primary MVP constraints.

## 15. Professional UI Checklist

Visual quality:

- SF Symbols or real app icons only, no emoji-as-icon default.
- One icon style across the app.
- Tile hover/press/running/failure states do not resize layout.
- Light and dark mode contrast meets WCAG AA.
- Teal/orange palette is restrained, not a one-note teal app.

Interaction:

- All tappable controls have clear pressed/focused states.
- Async actions show feedback after 300 ms.
- Pairing and command buttons prevent accidental repeated execution.
- Focus states work on macOS settings and any keyboard-navigable iOS controls.

Layout:

- iPhone verified at 375 pt compact width.
- Dashboard has no horizontal scrolling.
- Fixed-format tiles use stable dimensions.
- Large Turkish strings do not clip primary actions.
- Mac menu bar popover fits without requiring a large window.

Accessibility:

- VoiceOver labels describe tile title, command type, Mac target, and state.
- Color is not the only status indicator.
- Reduce Motion is respected.
- Permission explanations say what access is needed and why.

## 16. Implementation Handoff Notes

Before UI implementation:

- Create formal `PRODUCT.md` and `DESIGN.md`.
- Finalize app name and icon direction.
- Decide minimum iOS/macOS versions.
- Confirm whether Mac app is sandboxed.
- Confirm final transport status labels from engineering.

Recommended first UI slice:

1. iOS Discovery skeleton and found Mac row.
2. macOS menu bar status popover.
3. Pairing code screen on both platforms.
4. iOS dashboard empty and connected states.
5. Add Website tile editor.
6. Tile execution feedback states.

Design QA gates:

- No screen relies on color alone.
- All primary controls are reachable on compact iPhone.
- Turkish strings fit without clipping.
- Dashboard tile dimensions remain stable during loading, success, and failure.
- Offline state keeps user-created tiles visible.
- Permission-limited command types do not disable the whole app.
- Mac menu bar companion exposes pairing and status within one click.

## 17. Open Questions

- Final product name: keep PulsePanel, or choose another original name?
- Should MVP support one board per Mac or one global board reused across Macs?
- Should Shortcut tiles be typed manually in MVP, or should `getShortcuts` be promoted into MVP?
- Should command activity history be on by default, or opt-in?
- Should app icons be pulled from Mac catalog during `getInstalledApps` in MVP?
- Should iPad support be blocked until iPhone + Mac MVP is stable?

## 18. Non-Goals For MVP UI

- Remote screen viewer.
- Trackpad/mouse control.
- File browser.
- Cloud account.
- Cloud relay.
- Public plugin marketplace.
- Complex automation builder.
- Accessibility-based window control UI.
- Stream Deck-style store, icon marketplace, or hardware metaphor.

## 19. Completion Definition For UI/UX Planning

The UI/UX plan is ready for implementation when:

- `PRODUCT.md` and `DESIGN.md` exist.
- This document's open questions are answered or explicitly deferred.
- The first implementation slice is selected.
- Core English and Turkish strings for Discovery, Pairing, Dashboard, Tile Editor, and Mac menu bar are listed in String Catalog tasks.
- Accessibility and permission-copy requirements are accepted as MVP requirements, not polish.

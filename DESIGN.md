# PulsePanel Design

## Direction

PulsePanel should feel like a native Apple utility: calm, precise, tactile, privacy-aware, and predictable. The UI serves repeated command execution, so familiarity and clarity matter more than decorative novelty.

## Theme

Support system light and dark mode. Use low-glare neutral surfaces with a restrained focus palette.

## Palette

- Focus teal: `#0D9488`
- Secondary teal: `#14B8A6`
- Warm action: `#F97316`
- Light background seed: `#F0FDFA`
- Deep text seed: `#134E4A`

Teal is for connection, selection, and calm focus. Orange is reserved for rare primary setup or creation actions.

## Typography

Use SF Pro through native SwiftUI system fonts. Use monospaced text only for diagnostics, codes, or technical details.

## Components

- Dashboard tiles use stable dimensions and max two-line labels.
- Tile states: idle, pressed, running, success, failed, permission-limited, disabled.
- Discovery lists use skeleton rows during scanning.
- Pairing uses six fixed numeric cells and a numeric keyboard on iPhone.
- Mac companion uses a menu bar extra plus settings window.

## Accessibility

- 44 pt minimum touch targets on iOS.
- VoiceOver labels describe tile title, command type, Mac target, and state.
- Color is never the only status indicator.
- Reduce Motion must be respected.
- Turkish strings must fit without clipping.

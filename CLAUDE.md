# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

- Build: `swift build`
- Run tests: `swift test`
- Run app from SwiftPM executable: `swift run AndroidToolbox`
- Run a single test file: `swift test --filter ADBParserTests`
- Run a single test case: `swift test --filter ADBParserTests/parseDevices_extractsOnlineAndModel`

Notes:
- The package is a SwiftPM macOS executable target defined in `Package.swift`.
- The app is intended for macOS 15+ and Swift 6.2+.
- During development, the team often launches the generated `.app` bundle from `.build/debug/AndroidToolbox.app` to verify Dock behavior, app activation, title bar integration, and other macOS app-shell details that differ from running the bare executable.

## Architecture Overview

`AndroidToolboxApp.swift` is the app entrypoint. It sets the app icon from bundled resources and mounts a single `AppShellView`, which is the main composition root for shared UI state and feature view models.

### Top-level UI composition

`AppShellView.swift` owns:
- the active top-level mode (`ADB`, `Fastboot`, `EDL`)
- the expanded sidebar section state
- the ADB subpage state (`ADBPanelSection`)
- a single shared `AppLogStore`
- one view model per feature (`ADBViewModel`, `FastbootViewModel`, `EDLViewModel`)

The shell layout is intentionally fixed-size and split into three conceptual regions:
- center main panel for the active feature
- right sidebar for toolbox navigation and device summary
- bottom global log console

`WindowConfigurator.swift` applies AppKit window tweaks after SwiftUI creates the window. If a change affects title bar behavior, fixed sizing, transparency, or full-size content view behavior, it usually belongs there rather than in pure SwiftUI layout.

### Navigation model

Navigation happens at two levels:
- `ToolboxMode` switches between ADB / Fastboot / EDL panels.
- Inside ADB, `ADBPanelSection` switches between subpages such as file manager, device list, and reboot actions.

`ModeSidebarView.swift` is not just presentational: it drives both top-level mode changes and ADB subpage selection. If the user asks for “click sidebar item to enter X”, the likely implementation path is `ModeSidebarView` → `AppShellView` state → panel-specific view rendering.

### Feature pattern

Each transport mode follows the same broad pattern:
- `*PanelView.swift`: SwiftUI screen for the mode
- `*ViewModel.swift`: `@Observable` state and UI-facing actions
- `*Service.swift`: command execution and transport-specific operations
- `*Parser.swift`: output parsing into typed models
- `*ExecutableLocator.swift`: binary discovery for adb / fastboot / edl tooling

The important boundary is: panels should stay mostly declarative, view models orchestrate user actions and log updates, and services are the only layer that should know how to invoke external tooling.

### Process execution pipeline

All command execution flows through `ProcessRunner.swift`. Services call it with an executable URL and argument list, then interpret exit status and parse stdout/stderr. If behavior changes across ADB / Fastboot / EDL commands, start by checking:
1. the relevant `*Service.swift`
2. `ProcessRunner.swift`
3. the corresponding parser

This shared runner currently enforces a timeout and merges stdout/stderr into one output string, which is why feature logs can surface raw command failures consistently.

### Logging model

Runtime logs are intentionally centralized:
- feature view models append local messages through their own logging helpers
- those helpers also write into `AppLogStore`
- `GlobalLogConsoleView.swift` renders the aggregated log and handles log export

If you add a new operation in a feature view model, keep it on the existing log path so it appears in the bottom global log console and exported logs automatically.

### ADB-specific structure

ADB is currently the richest feature and has an extra internal navigation layer.

`ADBViewModel.swift` owns:
- auto-refresh timer behavior for connected devices
- selected device state
- reboot actions
- file manager state for both local and remote browsing
- push/pull actions

`ADBPanelView.swift` renders different content depending on `ADBPanelSection`. The current file manager is a Finder-style two-pane flow:
- local entries are loaded via `FileManager`
- remote entries are loaded through `ADBService.listRemoteDirectory(path:)`
- transfer actions are driven by current selections rather than raw text entry alone

When extending the ADB file manager, prefer evolving this stateful browse/select model instead of reintroducing plain path text forms into the main UI.

### Shared models and data flow

`DeviceInfo.swift` is the shared device summary model used across ADB / Fastboot / EDL UI. `DeviceStatusCardView.swift` in the sidebar reads the currently active mode’s selected device, which `AppShellView` computes from the active feature view model.

This means selection state is feature-local, but presentation of the “current device” is shell-level.

### Visual design constraints

The app uses a custom liquid-glass look implemented through `LiquidGlassTheme.swift`. Panels and cards consistently use theme-provided backgrounds, strokes, corner radii, and shadows. UI changes should generally reuse this theme rather than introducing per-view ad hoc styling.

### Resources and packaging

The SwiftPM target copies `Sources/AndroidToolbox/Resources`. `AndroidToolboxApp.swift` expects the app icon as a bundled resource (`app-icon.png`). If app metadata, icon behavior, or `.app` bundle launch behavior changes, verify both SwiftPM execution and `.app` bundle execution because they behave differently on macOS.

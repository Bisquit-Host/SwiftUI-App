# Repository Guidelines

## Project Structure & Module Organization

- `Bisquit.Host.xcodeproj/`: main Xcode project (shared schemes live in `Bisquit.Host.xcodeproj/xcshareddata/xcschemes/`)
- Platform targets: `iOS/`, `macOS/`, `watchOS/`, `tvOS/`, `visionOS/`
- Extensions & supporting targets: `Widgets/`, `Intent/`, `Intent Handler/`, `iMessage Extension/`, `AppClip Demo/`, `Contact Provider Extension/`, `QuickLook Extension/`
- Tests: `Unit Tests/` (unit/perf), `UI Tests/` (UI automation)
- Assets & localization are typically platform-scoped (for example `iOS/Assets.xcassets/`, `iOS/Localizable.xcstrings`)

## Build, Test, and Development Commands

Preferred workflow is Xcode (it will resolve Swift Package Manager dependencies on first open):

- Do not build unless I ask to do so
- Open the project: `open Bisquit.Host.xcodeproj`
- Build a scheme (example macOS): `xcodebuild -project Bisquit.Host.xcodeproj -scheme macOS -configuration Debug build`
- Build iOS simulator (example): `xcodebuild -project Bisquit.Host.xcodeproj -scheme "Bisquit.Host" -destination 'platform=iOS Simulator,name=iPhone 15' build`
- Run tests (example): `xcodebuild -project Bisquit.Host.xcodeproj -scheme "Bisquit.Host" -destination 'platform=iOS Simulator,name=iPhone 15' test`

Tip: choose the scheme that matches the target you’re changing (for example `Widgets`, `iMessage`, `watchOS`)

## Coding Style & Naming Conventions

- Language: Swift (mostly SwiftUI); follow Swift API Design Guidelines
- Indentation: 4 spaces; keep braces on the same line; prefer early `guard` returns
- Naming: `UpperCamelCase` for types, `lowerCamelCase` for values/functions; SwiftUI views typically end in `View` (for example `DashboardView.swift`)
- Keep platform-specific code inside its platform folder; avoid cross-target imports unless shared intentionally

## Testing Guidelines
- Do not create tests unless I ask to do so
- Unit tests use `XCTest` and Swift’s `Testing` (`@Test`); add new unit tests under `Unit Tests/` (for example `FeatureTests.swift`)
- UI tests live under `UI Tests/` and use `XCUIApplication`; keep tests deterministic and avoid relying on network state

## Commit & Pull Request Guidelines

- Commits in this repo are short and action-oriented (for example `improved …`, `fixed …`, `removed …`). Use a concise subject; add a scope when helpful (for example `macOS: fix settings crash`)
- PRs should describe the user-visible impact, list affected platforms/schemes, and include screenshots/screen recordings for UI changes

## Security & Configuration Tips

- Don’t commit secrets or environment-specific files. `iOS/Config.plist` is intentionally gitignored; prefer checked-in `*.example` files when new local config is required

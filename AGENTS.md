# Repository Guidelines

## Project Structure & Module Organization

- `Bisquit.Host.xcodeproj/`: main Xcode project (shared schemes live in `Bisquit.Host.xcodeproj/xcshareddata/xcschemes/`)
- Platform targets: `iOS/`, `macOS/`, `watchOS/`, `tvOS/`, `visionOS/`
- Extensions & supporting targets: `Widgets/`, `Intent/`, `Intent Handler/`, `Contact Provider Extension/`, `QuickLook Extension/`
- Tests: `Unit Tests/` (unit/perf), `UI Tests/` (UI automation)
- BisquitoNet library is located in `/Users/topscrech/Library/Mobile Documents/com~apple~CloudDocs/Projects/Packages/BisquitoNet` 
- PteroNet library is located in `/Users/topscrech/Library/Mobile Documents/com~apple~CloudDocs/Projects/Packages/PteroNet` 
- The backend project is located in `/Users/topscrech/IdeaProjects/billing-backend-ktor`

## Build, Test, and Development Commands

Preferred workflow is Xcode (it will resolve Swift Package Manager dependencies on first open):

- Do not build unless I ask to do so
- Open the project: `open Bisquit.Host.xcodeproj`
- Build a scheme (example macOS): `xcodebuild -project Bisquit.Host.xcodeproj -scheme macOS -configuration Debug build`
- Build iOS simulator (example): `xcodebuild -project Bisquit.Host.xcodeproj -scheme "Bisquit.Host" -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' build`
- Run tests (example): `xcodebuild -project Bisquit.Host.xcodeproj -scheme "Bisquit.Host" -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' test`

Tip: choose the scheme that matches the target you’re changing (for example `Widgets`, `iMessage`, `watchOS`)

## Coding Style & Best Practices

- New animations must check if store.bigAssAnimations from ValueStore() is enabled
- .onChange now provides two closure parameters: oldValue and newValue; Use `_` for any parameter you do not need; If neither parameter is needed, omit them entirely
- Bindings: do not use Bindings with a getter & setter for readability 
- Logger: Prefer OSLog's Logger() instead of prints
- Split subviews in long views into separate views in separate files
- Language: Swift & SwiftUI; follow Swift API Design Guidelines
- Indentation: Write code with re-indents; 4 spaces; keep braces on the same line; prefer early `guard` returns
- Naming: `UpperCamelCase` for types, `lowerCamelCase` for values/functions; SwiftUI views typically end in `View` (for example `DashboardView.swift`)
- Keep platform-specific code inside its platform folder; avoid cross-target imports unless shared intentionally
- When defining enums, prefer concise single-line cases without associated values, written as a simple comma-separated list, for example: case cloud, game, bot

## Swift Concurrency
- Swift 6 language mode
- MainActor default isolation mode
- All API calls must be async/await
- Avoid Grand Central Dispatch (GCD) APIs 

## Testing

- Do not create tests unless I ask to do so
- Unit tests use `XCTest` and Swift’s `Testing` (`@Test`); add new unit tests under `Unit Tests/` (for example `FeatureTests.swift`)
- UI tests live under `UI Tests/` and use `XCUIApplication`; keep tests deterministic and avoid relying on network state

## Commit, Push & Pull Request

- When asked to checkout, do that in the main project without creating copies of it
- When asked to push, commit all existing changes first
- Commits in this repo are short and action-oriented (for example `improved …`, `fixed …`, `removed …`). Use a concise subject; add a scope when helpful (for example `macOS: fix settings crash`)
- PRs should describe the user-visible impact, list affected platforms/schemes

## Security & Configuration Tips

- Don’t commit secrets or environment-specific files

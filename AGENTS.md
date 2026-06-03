# Repository Guidelines

## Project Structure & Module Organization
- `Bisquit.Host.xcodeproj/`: main Xcode project (shared schemes live in `Bisquit.Host.xcodeproj/xcshareddata/xcschemes/`)
- Platform targets: `iOS/`, `macOS/`, `watchOS/`, `tvOS/`, `visionOS/`
- Extensions & supporting targets: `Widgets/`, `Intent/`, `Intent Handler/`, `Contact Provider Extension/`, `QuickLook Extension/`
- Tests: `Unit Tests/` (unit/perf), `UI Tests/` (UI automation)
- BisquitoNet library is located in `~/Library/Mobile Documents/com~apple~CloudDocs/Projects/Packages/BisquitoNet` 
- PteroNet library is located in `~/Library/Mobile Documents/com~apple~CloudDocs/Projects/Packages/PteroNet` 
- The backend project is located in `~/IdeaProjects/billing-backend-ktor`; do not edit, if there's an issue -> just tell me 

## Build
- Choose the scheme that matches the target you’re changing (for example `Widgets`, `iMessage`, `watchOS`)

## Coding Style & Best Practices
- New animations must check if store.bigAssAnimations from ValueStore() is enabled
- Logger: Prefer OSLog's Logger() instead of prints
- Language: Swift & SwiftUI; follow Swift API Design Guidelines
- Indentation: Write code with re-indents; 4 spaces; keep braces on the same line; prefer early `guard` returns
- Keep platform-specific code inside its platform folder; avoid cross-target imports unless shared intentionally

## UI/UX
- Prefer displaying currency symbols instead of 3-letter codes (RUB -> ₽) 

## Testing
- Unit tests use `XCTest` and Swift’s `Testing` (`@Test`); add new unit tests under `Unit Tests/` (for example `FeatureTests.swift`)
- UI tests live under `UI Tests/` and use `XCUIApplication`; keep tests deterministic and avoid relying on network state

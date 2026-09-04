# Repository Guidelines

## Calagopus Game Panel
All new panel network requests should be added to the Calagopus library, while billing network requests should be added to the BisquitoNet library
- When implementing Calagopus related changes, always make sure it stays in sync with the API docs & panel repo
- Never add local libs
- Calagopus URL - https://5.83.140.20:8000
- Calagopus API docs - https://5.83.140.20:8000/api
- Do not make & push changes to related projects unless confirmed by me; Never make changes to the backend & panel projects

## Coding Style & Best Practices
- New cool animations must check if store.bigAssAnimations from ValueStore() is enabled
- Logger: Prefer OSLog Logger() instead of prints
- Language: Swift & SwiftUI; follow Swift API Design Guidelines
- Indentation: Write code with re-indents; 4 spaces; keep braces on the same line; prefer early `guard` returns
- Keep platform-specific code inside its platform folder; avoid cross-target imports unless shared intentionally
- Prefer the newest API's for widgets and app intents, for iOS 27 or 26 if possible

## UI/UX
- Prefer displaying currency symbols instead of 3-letter codes: RUB -> ₽

## Releases
- asc-release should only update iOS & visionOS platforms, macOS & tvOS are deprecated


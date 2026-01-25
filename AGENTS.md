# Agent Guide (Checkpoint)

This repo is a macOS app built with Swift + SwiftUI (Xcode project).

Quick facts:
- Primary project: `Checkpoint.xcodeproj`
- Primary scheme: `Checkpoint` (`xcodebuild -list`)
- Tests: none currently (no `*Tests` targets/schemes)
- No Cursor rules (`.cursor/rules/`, `.cursorrules`) or Copilot rules (`.github/copilot-instructions.md`) found

## Setup

- Build/run from Xcode using scheme `Checkpoint`.
- Signing: copy `Config.xcconfig.template` -> `Config.xcconfig` and set `DEVELOPMENT_TEAM = <YOUR_TEAM_ID>` (don’t commit personal/team changes unless asked).

## Build / Run Commands

```sh
# List schemes/targets
xcodebuild -list -json

# Build (Debug)
xcodebuild -scheme Checkpoint -configuration Debug -destination 'platform=macOS,name=Any Mac' build

# Build (Release)
xcodebuild -scheme Checkpoint -configuration Release -destination 'platform=macOS,name=Any Mac' build

# Clean
xcodebuild -scheme Checkpoint clean

# Static analysis (Xcode “Analyze”)
xcodebuild -scheme Checkpoint analyze
```

If you see “multiple matching destinations”, add `-destination 'platform=macOS,name=Any Mac'`.

## Lint / Format

No repo-configured SwiftLint/SwiftFormat found.

Guidance:
- Match existing formatting/style near your changes.
- If adding lint/format tooling, do it as a dedicated change.

Typical (only if those tools get added):

```sh
swiftlint lint --strict
swiftformat .
```

## Tests

No unit/UI test targets are present today.

When tests exist:

```sh
# Run all tests
xcodebuild test -scheme Checkpoint -destination 'platform=macOS,name=Any Mac'

# Run a single test class
xcodebuild test -scheme Checkpoint -destination 'platform=macOS,name=Any Mac' -only-testing:CheckpointTests/MyTestClass

# Run a single test method
xcodebuild test -scheme Checkpoint -destination 'platform=macOS,name=Any Mac' -only-testing:CheckpointTests/MyTestClass/testExample
```

## Architecture & Project Conventions

High-level structure under `Checkpoint/`:
- `Views/`: SwiftUI views.
- `ViewModels/`: ObservableObject view models (MVVM).
- `Services/`: stateful services and app orchestration.
- `Models/`: small value types and documents.
- `Protocols/`: abstractions for dependency injection/testing.

Dependency style:
- Prefer depending on protocols (e.g., `DataManagingProtocol`) and injecting them.
- Use singletons sparingly; the repo currently has `LogEntryStore.shared` and `AppEventPublisher.shared`.

Concurrency & threading:
- Many types are annotated `@MainActor` (e.g., view models, `DataManagerService`).
- Prefer `Task {}` from UI actions to call async methods.
- If a service owns concurrent state, isolate it (see `CountdownTimerService.State` actor).
- When bridging async work back to Combine/UI, publish on the main actor.

## Swift Style Guidelines

State management (SwiftUI):
- For new code, prefer Observation (`@Observable`) over `ObservableObject`.
- Own an `@Observable` model with `@State`; inject it and bind via `@Bindable` when the child needs writable bindings.
- Keep `@State` / `@StateObject` properties `private`.

Async work (SwiftUI):
- Keep `body` pure; avoid side effects in `body` or initializers.
- Prefer `.task {}` / `.task(id:)` for async work so it cancels automatically when the view disappears or the id changes.

Formatting:
- Indentation: 4 spaces.
- One statement per line; wrap argument lists vertically when they get long.
- Keep SwiftUI modifier chains readable; break lines at major modifier boundaries.

Imports:
- Import the minimum needed modules.
- Typical order (match file context): `Foundation`, `Combine`, then UI modules (`SwiftUI`, `UniformTypeIdentifiers`).

Modern SwiftUI APIs (prefer):
- `foregroundStyle()` over `foregroundColor()`.
- `clipShape(.rect(cornerRadius:))` over `cornerRadius()`.
- `Button` over `onTapGesture()` unless you need gesture details.

Naming:
- Types: `PascalCase` (`LogWorkViewModel`, `DataManagerService`).
- Vars/functions: `lowerCamelCase` (`saveLogEntry`, `loadLogEntries`).
- Enums for domain events/errors: `PascalCase` with descriptive cases (`ValidationError.emptyProject`).
- Prefer verb phrases for actions (`save…`, `load…`, `delete…`, `update…`).

Types & access control:
- Prefer `struct` for models/value types (`LogEntry`, `CSVDocument`).
- Prefer `final class` for services unless subclassing is intended.
- Default to the narrowest visibility that works (`private` helpers, `private(set)` for published state).

Error handling:
- Prefer `LocalizedError` enums for user-facing errors (see `ValidationError`).
- Preserve root error context when rethrowing (e.g., wrap with a domain error that includes `localizedDescription`).
- Avoid force unwraps (`!`) in new code; if unavoidable, justify with invariants.

Performance:
- Avoid creating expensive objects (e.g., `DateFormatter()`) in `body` or frequently-called computed properties; cache/static where it matters.
- For user-entered search, prefer `localizedStandardContains()` over plain `contains()`.

Logging:
- Debug logging is commonly guarded by `#if DEBUG`.
- Avoid logging sensitive data.
- If you introduce structured logging, prefer `os.Logger` and keep messages concise.

SwiftUI patterns:
- Views should be mostly declarative; keep business logic in view models/services.
- Use `@StateObject` for owned view models, `@ObservedObject` for injected ones.
- Use `@Environment` for system actions (`dismiss`, `openWindow`).
- Prefer `#Preview` blocks for local view previews.

Combine usage:
- Store cancellables in a `Set<AnyCancellable>`.
- Use `.receive(on: DispatchQueue.main)` when binding to UI state.
- Prefer `assign(to:on:)` for simple bindings; use `sink` when side effects are needed.

Data & persistence:
- Current persistence uses `UserDefaults` with JSON encoding/decoding.
- Keep keys stable (`checkpoint_interval`, `checkpoint_log_entries`).
- When changing model encoding, consider migrations/backwards compatibility.

## Guardrails for Automated Changes

- Don’t change signing/team IDs (`DEVELOPMENT_TEAM`) unless explicitly requested.
- Avoid broad reformatting; keep diffs focused.
- If you add tests or tooling (SwiftLint/SwiftFormat), isolate to a dedicated change set.

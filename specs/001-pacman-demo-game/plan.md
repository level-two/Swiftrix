# Implementation Plan: Pacman Demo Game Controlled by On-Screen Keyboard

**Branch**: `001-pacman-demo-game` | **Date**: 2025-12-03 | **Spec**: /Users/elychkouski/my-work/clanbomber-remake/Swiftrix/specs/001-pacman-demo-game/spec.md  
**Input**: Feature specification from `/specs/001-pacman-demo-game/spec.md`

## Summary

Implement a playable Pacman demo inside the Swiftrix test application where Pacman is controlled entirely via an on-screen keyboard. The demo should showcase Swiftrix as the engine powering Pacman’s game loop and state, while SpriteKit is used by the host app to render the maze, characters, HUD, and on-screen controls. The MVP focuses on a single maze layout, simple ghost behavior, no audio, and reliable restart so that internal users can easily evaluate on-screen touch controls and the engine integration.

## Technical Context

<!--
  ACTION REQUIRED: Replace the content in this section with the technical details
  for the project. The structure here is presented in advisory capacity to guide
  the iteration process.
-->

**Language/Version**: Swift (modern toolchain; align with existing Swiftrix package)  
**Primary Dependencies**: SwiftrixCore engine (SwiftPM package), SpriteKit for rendering in the SwiftrixTest host app  
**Storage**: N/A (all game state is in-memory per Pacman session)  
**Testing**: XCTest for engine-level unit tests and any host-side integration tests  
**Target Platform**: Apple platforms supporting SpriteKit (primary focus: iOS simulator/device via SwiftrixTest app)  
**Project Type**: Engine core as Swift package + iOS-style host app (SwiftrixTest) embedding the engine  
**Performance Goals**: Stable 60 fps gameplay for a single Pacman level on typical development hardware  
**Constraints**: Core engine must remain independent from SpriteKit and other platform APIs; no audio required; demo must remain simple enough for quick manual QA  
**Scale/Scope**: Single demo level, one Pacman instance, a small set of ghosts, and localized state within the test app; no persistence or multi-level progression

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- Engine core changes: Pacman systems, entities, and session management will
  live inside `SwiftrixCore` examples or engine-compatible modules and will NOT
  introduce any direct imports of SpriteKit, UIKit, or other platform APIs.
  Rendering and input remain responsibilities of the SwiftrixTest host app.
- Planned public API changes: Pacman support is intended as an example; any
  new public types or entry points exposed from the engine will be documented
  and treated as a MINOR version addition, with clear comments and usage notes.
- Test coverage: For Pacman engine behavior (movement rules, collisions, score
  and life tracking), we will plan XCTest unit tests that exercise success
  paths and edge cases (e.g., wall collisions, ghost collisions, pellet
  consumption) independent of SpriteKit.
- SwiftPM boundaries: SwiftrixCore will remain a clean SwiftPM package with
  Pacman logic organized under its sources/examples structure, and SwiftrixTest
  will depend on it as a client app without circular dependencies.
- Observability and AI workflows: Pacman engine types (session, maze, entities)
  will expose explicit, inspectable state (e.g., positions, counts, status
  flags) so that debug tools and AI agents can reason about game state without
  needing to introspect SpriteKit nodes directly.

## Project Structure

### Documentation (this feature)

```text
specs/[###-feature]/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)
<!--
  ACTION REQUIRED: Replace the placeholder tree below with the concrete layout
  for this feature. Delete unused options and expand the chosen structure with
  real paths (e.g., apps/admin, packages/something). The delivered plan must
  not include Option labels.
-->

```text
/Users/elychkouski/my-work/clanbomber-remake/Swiftrix/
├── Package.swift                 # SwiftrixCore SwiftPM package manifest
├── Sources/
│   └── SwiftrixCore/
│       ├── Engine/               # Core engine systems and types
│       └── Examples/
│           └── Pacman/           # Pacman-specific engine logic (session, maze, systems)
└── Tests/
    └── SwiftrixCoreTests/        # XCTest target for engine behavior (including Pacman)

/Users/elychkouski/my-work/clanbomber-remake/SwiftrixTest/
├── SwiftrixGame.xcodeproj        # Host app project embedding SwiftrixCore
└── SwiftrixGame/
    ├── GameViewController.swift  # Entry point that mounts the Pacman SpriteKit scene
    └── PacmanGameScene.swift     # SpriteKit scene rendering Pacman and on-screen keyboard
```

**Structure Decision**: Use a SwiftPM-based engine core (`SwiftrixCore`) that
contains all Pacman game state and rules, alongside an Xcode-based host app
(`SwiftrixTest/SwiftrixGame`) responsible for rendering via SpriteKit and
collecting on-screen input. All feature work will live within these existing
directories and respect the engine/host separation.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| [e.g., 4th project] | [current need] | [why 3 projects insufficient] |
| [e.g., Repository pattern] | [specific problem] | [why direct DB access insufficient] |

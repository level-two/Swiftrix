# Implementation Plan: Pacman Demo Game Controlled by On-Screen Keyboard

**Branch**: `001-pacman-demo-game` | **Date**: 2025-12-03 | **Spec**: [/Users/elychkouski/my-work/clanbomber-remake/Swiftrix/specs/001-pacman-demo-game/spec.md]
**Input**: Feature specification from `/specs/001-pacman-demo-game/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/commands/plan.md` for the execution workflow.

## Summary

Implement a Pacman-style demo game inside the Swiftrix test application (`/Users/elychkouski/my-work/SwiftrixTest`) that showcases Swiftrix as the game engine and uses SpriteKit for rendering, controlled entirely through an on-screen keyboard. The demo will provide a single-level Pacman experience (maze, pellets, ghosts, score, lives, restart) designed for quick usability testing and demonstrations, without audio.

## Technical Context

<!--
  ACTION REQUIRED: Replace the content in this section with the technical details
  for the project. The structure here is presented in advisory capacity to guide
  the iteration process.
-->

**Language/Version**: Swift 5.9 (as defined in `Package.swift`)  
**Primary Dependencies**: SwiftrixCore (game engine), SpriteKit (rendering), XCTest for tests  
**Storage**: No persistent storage required; in-memory game state only  
**Testing**: XCTest-based unit and integration tests targeting SwiftrixCore and the SwiftrixTest game target  
**Target Platform**: macOS 13+ and iOS 16+ (per package platforms and SwiftrixTest Xcode project)
**Project Type**: Game engine library (`SwiftrixCore`) plus demo app target (`SwiftrixGame` in `/Users/elychkouski/my-work/SwiftrixTest`)  
**Performance Goals**: Consistent 60 fps gameplay on supported devices during typical Pacman demo sessions  
**Constraints**: No audio/sound effects in this iteration; keep Pacman demo logic self-contained and reusable within Swiftrix examples  
**Scale/Scope**: Single Pacman level demo focused on on-screen keyboard interaction and basic game loop; no multi-level progression or advanced AI required

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- Core principles in `/Users/elychkouski/my-work/clanbomber-remake/Swiftrix/.specify/memory/constitution.md` are currently placeholders and do not define concrete technology, workflow, or testing mandates.
- This implementation plan respects the spirit of a simple, testable design by:
  - Keeping the Pacman demo as a focused, single-level feature on top of SwiftrixCore.
  - Planning XCTest coverage around core game loop logic and input handling.
  - Avoiding unnecessary subsystems (e.g., networking, persistence, audio).
- No explicit constitutional rules are violated by using SwiftrixCore + SpriteKit for a local demo game.

**Gate Evaluation (Pre-Research)**: PASS — proceed to Phase 0 research.

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

```text
/Users/elychkouski/my-work/clanbomber-remake/Swiftrix
├── Package.swift
├── Sources/
│   ├── SwiftrixCore/          # Core engine library code
│   ├── Components/            # Reusable components
│   ├── Core/
│   ├── Events/
│   ├── Examples/
│   ├── GameObject/
│   ├── Input/
│   ├── Introspection/
│   ├── Loop/
│   ├── Math/
│   ├── Physics/
│   └── Scene/
├── Tests/
│   └── SwiftrixCoreTests/     # Engine-level tests
└── specs/
    └── 001-pacman-demo-game/  # This feature’s planning and docs

/Users/elychkouski/my-work/SwiftrixTest
├── SwiftrixGame.xcodeproj
└── SwiftrixGame/              # Demo game app target using SwiftrixCore + SpriteKit
```

**Structure Decision**: Use `SwiftrixCore` as the reusable engine library in `/Users/elychkouski/my-work/clanbomber-remake/Swiftrix`, and implement the Pacman demo as a scene and supporting types inside the `SwiftrixGame` app in `/Users/elychkouski/my-work/SwiftrixTest`, reusing existing Swiftrix patterns under `Sources/Examples` where appropriate.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| [e.g., 4th project] | [current need] | [why 3 projects insufficient] |
| [e.g., Repository pattern] | [specific problem] | [why direct DB access insufficient] |

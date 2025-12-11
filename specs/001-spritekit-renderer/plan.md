# Implementation Plan: Swiftrix SpriteKit Rendering Adapter

**Branch**: `001-spritekit-renderer` | **Date**: 2025-12-09 | **Spec**: [specs/001-spritekit-renderer/spec.md](spec.md)
**Input**: Feature specification from `/specs/001-spritekit-renderer/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/commands/plan.md` for the execution workflow.

## Summary

Deliver a host-side SpriteKit module that adapts Swiftrix Core `Scene`, `GameObject`, and `View` abstractions into live `SKScene` / `SKNode` hierarchies. The adapter owns a `CADisplayLink`-driven loop, synchronizes dirty Core data into SpriteKit nodes, and exposes inspection hooks so renderers remain replaceable without touching gameplay code.

## Technical Context

<!--
  ACTION REQUIRED: Replace the content in this section with the technical details
  for the project. The structure here is presented in advisory capacity to guide
  the iteration process.
-->

**Language/Version**: Swift 5.9 (matches `Package.swift`)  
**Primary Dependencies**: SwiftrixCore engine APIs, SpriteKit (`SKScene`, `SKNode`, `CADisplayLink`), Foundation  
**Storage**: N/A (all state in-memory per scene)  
**Testing**: XCTest suite backed by a headless `SKView` harness plus fake `CADisplayLink` drivers  
**Target Platform**: Apple platforms that ship SpriteKit (iOS 15+, macOS 13+, visionOS)  
**Project Type**: Swift package with host demo app + engine module  
**Performance Goals**: Sustain 60 FPS while syncing up to 500 SpriteKit nodes across ≤6 hierarchy levels using dirty-flag batching  
**Constraints**: All Core updates on main thread; deterministic Core-first update order; adapter must remain optional host module  
**Scale/Scope**: Documented ceiling of ~1,000 concurrent GameObjects per scene, assuming ≤500 carry visual Views

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- Engine core changes MUST preserve core-only architecture: no new direct
  dependencies on rendering, input, audio, or resource-loading frameworks from
  core modules. **PASS**: Adapter lives outside `Sources/SwiftrixCore`.
- Planned public API changes MUST be explicitly listed, documented, and mapped
  to a semantic version bump type (MAJOR/MINOR/PATCH) with rationale. **PASS**: Introduce public types within new SwiftPM target `SwiftrixSpriteKitRendering`; no Core API changes → MINOR bump justified.
- Every new behavior MUST have planned unit tests that will fail before
  implementation and pass after; plans that omit tests are not acceptable. **PASS**: Mapping logic, lifecycle, and dirty-flag sync tests planned under `Tests/SwiftrixSpriteKitRenderingTests`.
- The feature MUST keep the package consumable as a SwiftPM dependency with
  clear target/module boundaries. **PASS**: New SwiftPM target `SwiftrixSpriteKitRendering` (host-only) + optional dependency docs.
 - Plans SHOULD consider observability and AI-assisted workflows: new systems
   and features SHOULD expose state and behavior in ways that are inspectable
   by tools and AI agents (e.g., via explicit structures, logs, or debug views). **PASS**: Bidirectional mapping API + debug overlays + logging requirements captured in spec.

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
Sources/
├── SwiftrixCore/                 # existing engine target (unchanged)
└── SwiftrixSpriteKitRendering/   # NEW: adapter target + Sprite/View implementations

Tests/
├── SwiftrixCoreTests/                 # existing coverage
└── SwiftrixSpriteKitRenderingTests/   # NEW: mapping + lifecycle unit tests

specs/
├── 000-swiftrix-engine-core/
└── 001-spritekit-renderer/       # spec + plan + research + contracts (this feature)
```

**Structure Decision**: Add a dedicated SwiftPM target/folder `Sources/SwiftrixSpriteKitRendering` plus mirrored tests so host integrations can depend on the adapter without polluting the core target layout.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| _None_ | — | — |

## Phase 0 — Research Summary

- See [research.md](research.md) for seven recorded decisions covering test harness strategy, CADisplayLink scheduling, performance budgets (500 nodes @ 60 FPS), scale expectations (~1k Core GameObjects), SemVer impact (MINOR via new SwiftPM target), bidirectional mapping data structure, and observability tooling (camera + overlays).
- Testing clarifications resolved: we will use a headless `SKView` harness with fake clocks instead of UI tests or pure mocks.
- Dependency best practices captured: SpriteKit interactions remain on the main run loop; CADisplayLink pacing ensures Core updates precede rendering.

## Phase 1 — Design & Contracts

- **Data Model**: [data-model.md](data-model.md) defines `SpriteKitScene`, `NodeBinding`, `DirtySyncQueue`, `CameraController`, `DebugOverlayConfig`, and optional `TouchHitTestMap`.
- **API Contracts**: [contracts/spritekit-rendering.yaml](contracts/spritekit-rendering.yaml) models conceptual host controls (session lifecycle, batched object sync, mapping inspection, performance metrics).
- **Quickstart**: [quickstart.md](quickstart.md) documents dependency wiring, adapter binding, lifecycle control, debug overlays, camera usage, hit-testing, and deterministic tests.

## Constitution Check (Post-Design)

- Core-only boundary: still respected; all SpriteKit references live in the new adapter target.
- Public API governance: new target introduces host-side types only → MINOR release remains correct.
- Unit tests: plan mandates XCTest harness plus fake clocks; mapping, lifecycle, dirty queue, and overlays each have failing-test-first coverage.
- SwiftPM distribution: module layout and Package manifest updates keep consumption simple (optional target).
- Observability & AI tooling: Node inspector, debug overlays, performance snapshots, and OpenAPI contract provide machine-readable insight for tooling.

# Research & Decisions: Pacman Demo Game Controlled by On-Screen Keyboard

**Feature**: /Users/elychkouski/my-work/clanbomber-remake/Swiftrix/specs/001-pacman-demo-game/spec.md  
**Branch**: 001-pacman-demo-game  
**Date**: 2025-12-03

This document captures design-time research and decisions for implementing the Pacman demo game on top of SwiftrixCore with SpriteKit rendering in the SwiftrixTest host app.

---

## Unknowns and Clarifications

From the technical context and spec, the main questions were:

1. How strictly should Pacman logic be separated into the engine core versus the SpriteKit scene?
2. What level of ghost AI and maze complexity is appropriate for an MVP demo?
3. How should controls be structured so that on-screen input is the primary control method while still allowing optional keyboard input during development?

All of these have been resolved in the decisions below; no remaining NEEDS CLARIFICATION markers are carried forward into later phases.

---

## Engine vs. Rendering Separation

**Decision**: Pacman game rules and state live in SwiftrixCore as a reusable example system; SpriteKit is used only for rendering and input collection in SwiftrixTest.

- Pacman entities (Pacman, ghosts, pellets, maze) and session state live under
  `/Users/elychkouski/my-work/clanbomber-remake/Swiftrix/Sources/SwiftrixCore/Examples/Pacman/`.
- A `PacmanSession` (or equivalent) coordinates the maze, score, lives, and game status and is advanced by an engine-style system (`PacmanSystem`) on each update tick.
- The host app (`/Users/elychkouski/my-work/clanbomber-remake/SwiftrixTest/SwiftrixGame/`) uses SpriteKit to visualize the current engine state and to send input events (desired direction, restart) back into the Pacman session/system.
- No SpriteKit, UIKit, or platform APIs are imported in engine modules; all such dependencies remain in the SwiftrixTest app.

**Rationale**:

- Keeps the engine core platform-agnostic per the Swiftrix constitution.
- Allows Pacman behavior to be reused or tested without SpriteKit, making it a good reference example.
- Simplifies manual reasoning and AI-assisted inspection because Pacman state is represented in plain Swift structures.

**Alternatives considered**:

- Implementing Pacman entirely inside a SpriteKit scene with ad-hoc state:
  - Rejected: tightly couples game logic to rendering, making it harder to reuse or test.
- Embedding Pacman logic in a separate non-engine module within SwiftrixTest:
  - Rejected: would underuse SwiftrixCore and not demonstrate engine capabilities.

---

## Ghost Behavior and Maze Complexity

**Decision**: Use a single fixed maze layout and simple, deterministic ghost movement suitable for a demo.

- Maze: one pre-defined grid layout configured in `PacmanMaze` with walls, paths, and pellet positions.
- Ghost AI: simple behavior (e.g., constant-speed movement along valid paths with basic direction choices) sufficient to make ghosts a real hazard but not requiring full Pacman-accurate AI.
- Difficulty and pacing tuned for demonstration: ghosts move at a speed that keeps the game engaging but not frustrating during short test sessions.

**Rationale**:

- Keeps implementation focused on demonstrating Swiftrix integration rather than replicating every detail of the original Pacman.
- Single maze and simple AI keep scope small and predictable for manual QA.
- Deterministic movement makes debugging and automated testing easier.

**Alternatives considered**:

- Multiple levels with increasing difficulty:
  - Rejected for MVP due to additional design and testing complexity.
- Full Pacman-accurate AI:
  - Rejected as overkill for a demo whose goal is to showcase the engine and on-screen controls.

---

## Input Model and On-Screen Controls

**Decision**: Treat the on-screen control overlay as the primary input path; represent input as a simple directional intent consumed by the Pacman engine.

- On-screen controls: rendered in `PacmanGameScene` with one button for each direction and a visible restart control.
- Input abstraction: the scene translates taps into a directional intent (e.g., up, down, left, right) and passes this to the Pacman engine/session.
- Keyboard input: may be optionally mapped during development (e.g., arrow keys) but is not required for feature success and is not part of the core spec.

**Rationale**:

- Aligns directly with the user stories, which emphasize on-screen keyboard control.
- Keeps the engine’s view of input simple and decoupled from the specific UI implementation.
- Supports future reuse of Pacman logic with different input schemes (gamepad, network, etc.).

**Alternatives considered**:

- Letting the Pacman engine read input directly from platform APIs:
  - Rejected to maintain core-only architecture and testability.
- Implementing a more complex input buffering system from the outset:
  - Deferred: a simple directional intent is sufficient for this MVP; more complex schemes can be added later if needed.

---

## Testing & Observability Strategy

**Decision**: Focus on engine-level unit tests for Pacman rules and rely on manual QA for the SpriteKit scene, while keeping engine state easily inspectable.

- Engine tests: add XCTest cases under `/Users/elychkouski/my-work/clanbomber-remake/Swiftrix/Tests/SwiftrixCoreTests/` that:
  - Verify pellet consumption and score updates.
  - Verify life loss and game-over transitions on ghost collisions.
  - Verify restart behavior resets all relevant state.
- Rendering and UX: validated manually using `SwiftrixTest/SwiftrixGame`, following scenarios in the feature spec and Quickstart.
- Observability: Pacman session exposes counts (remaining pellets, lives), positions, and status flags that can be logged or inspected from debug UIs.

**Rationale**:

- Matches the constitution’s emphasis on unit-tested core features.
- Keeps the test suite independent from SpriteKit and Xcode projects.
- Provides sufficient observability for debugging and AI tooling without overcomplicating the MVP.

**Alternatives considered**:

- UI automation tests for the SpriteKit scene:
  - Deferred: would add tooling complexity for limited additional value at this stage.


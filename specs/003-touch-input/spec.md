# Feature Specification: Touch Input (Unity-like)

**Feature ID (proposed)**: `003-touch-input`  
**Created**: 2026-02-04  
**Status**: Draft  
**Scope**: SwiftrixCore + (optional) SwiftrixSpriteKitRendering

## Summary

Introduce Unity-like touch input to Swiftrix:

- `Input.touches` style access (per scene) returning an array of touches each frame
- each `Touch` has at least a stable id (`fingerId`-like), position, and phase
- touch snapshots update **once per rendered frame**, specifically **after all fixed updates** and **right before** the scene’s variable-step `update(deltaTime:)` traversal

This feature builds on the existing `InputSystem` contract and keeps Core platform-agnostic; host adapters (e.g. SpriteKit) feed physical touch events.

## User Scenarios & Testing *(mandatory)*

### User Story 1 — Query touches from gameplay code (P1)

Gameplay code can read a touch snapshot each frame, similar to Unity’s `Input.touches`.

**Acceptance Scenarios**

1. **Given** the host injects touch events, **When** a script runs `update(deltaTime:)`, **Then** it can read `touches` with stable ids, positions, and phases for that frame.
2. **Given** there is no touch-capable input system, **When** gameplay code reads touches, **Then** it receives an empty array (safe default).

**Independent Tests**

- Core unit tests using a fake `InputSystem` validate `Scene` update calls input sampling at the correct time (after fixed updates).

### User Story 2 — Touch phases behave predictably (P1)

Touch phases match a Unity-like mental model:

- `.began` for the first frame a finger appears
- `.moved` on frames where the finger position changes
- `.stationary` on frames where the finger remains down without movement
- `.ended` / `.cancelled` reported for exactly one frame, then removed from the touches array

**Acceptance Scenarios**

1. **Given** a touch ends, **When** the next `update(deltaTime:)` runs, **Then** the touch appears with phase `.ended` for that frame and disappears on the following frame.
2. **Given** a touch does not move, **When** subsequent frames run, **Then** the touch phase transitions to `.stationary` (unless updated by host events).

**Independent Tests**

- Core unit tests validate the touch state machine in the default/core-provided touch-capable implementation.

### User Story 3 — Touches are accessible from scripts and objects (P2)

Scripts and game objects should be able to access scene input without requiring a global singleton.

**Acceptance Scenarios**

1. **Given** a `Script` attached to a `GameObject` in a `Scene`, **When** it runs, **Then** it can read input via `script.input` (or equivalent) without any explicit wiring in the script.
2. **Given** a `GameObject` is moved between scenes, **Then** its input access points at the new scene’s input after being reattached.

**Independent Tests**

- Core unit tests validate scene back-references on game objects and that scripts can reach the scene’s input safely.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Core MUST define `Touch` and `TouchPhase` types.
- **FR-002**: Core MUST expose a per-scene “Input-like” query surface that includes `touches` and existing logical queries (axes/buttons).
- **FR-003**: Touch snapshots MUST be sampled once per rendered frame, after fixed updates and before variable update traversal.
- **FR-004**: Touch snapshots MUST be deterministic given the same host-fed input stream (including stable ordering rules).
- **FR-005**: Scripts MUST be able to access scene input without relying on global state.

### Non-Functional Requirements

- **NFR-001**: `SwiftrixCore` MUST remain platform-agnostic (no SpriteKit/UIKit/etc imports).
- **NFR-002**: Touch processing must be O(n) in number of active touches per frame.
- **NFR-003**: Touch ordering MUST be stable (e.g., sorted by touch id) to improve determinism and testability.

## Notes / Constraints

- Touch position is intentionally defined by the host adapter (core treats it as “touch space”).
  - For SpriteKit, the recommended convention is `SKScene` coordinates (so touch positions align with sprites, effects, and hit-testing/raycasting in the adapter).
- Hit-testing a touch location back to a `GameObject` is out-of-scope for Core. SpriteKit already has an optional `HitTestBridge` (see `specs/001-spritekit-renderer`).

## Non-goals (v1)

- No touch event dispatch pipeline in Core (query-only via the frame cycle).

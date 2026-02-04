# Implementation Plan: Touch Input (Unity-like)

**Feature**: `003-touch-input`  
**Date**: 2026-02-04  
**Input**: `specs/003-touch-input/spec.md`

## Summary

Add Unity-like touch input to Swiftrix by extending the Core `InputSystem` contract with touch snapshots and exposing a per-scene `Input`-style query object. Touch sampling remains orchestrated by `Scene` (not by scripts), and happens once per frame after fixed updates and right before the variable update traversal.

This plan also adds an explicit `Scene` back-reference on `GameObject` so gameplay code can access `scene.input` from any script/object without global singletons.

## Technical Context

- **Language/Version**: Swift 5.9 (SwiftPM package)
- **Core constraints**: `SwiftrixCore` must not import SpriteKit/UIKit/SwiftUI/Metal/etc.
- **Host adapters**: may translate physical touches to core `Touch` snapshots (SpriteKit `UITouch` events, etc.).

## Public API (proposed)

### SwiftrixCore

- `public enum TouchPhase`
  - `.began`, `.moved`, `.stationary`, `.ended`, `.cancelled`
- `public struct Touch`
  - `var id: Int` (Unity-like `fingerId`)
  - `var position: Vector2` (host-defined touch space; SpriteKit recommends `SKScene` coordinates)
  - `var phase: TouchPhase`
- Extend `InputSystem` with a defaulted requirement:
  - `func touches() -> [Touch]` (default implementation returns `[]`)
- `public struct InputProxy`
  - wraps an optional `InputSystem` and exposes:
    - `var touches: [Touch]`
    - `func axis(named:)`, `isButtonDown`, `isButtonPressed`, etc. (existing logical queries)
- `public extension Scene`
  - `var input: InputProxy { InputProxy(inputSystem) }`
- `open class GameObject`
  - `public private(set) weak var scene: (any Scene)?` (set by the scene graph owner)
- `open class Script`
  - `public var scene: (any Scene)? { gameObject.scene }`
  - `public var input: InputProxy { scene?.input ?? InputProxy(nil) }`

### SwiftrixSpriteKitRendering (optional)

- A touch-capable input system implementation that:
  - receives `touchesBegan/Moved/Ended/Cancelled` events from `SKScene`
  - maps `UITouch` instances to stable `Touch.id`
  - produces core `Touch` snapshots for Core consumption

## Data Model & Invariants

### Frame sampling point

- `GameLoop.tick(deltaTime:)` executes:
  1. `scene.fixedUpdate` zero or more times
  2. `scene.update(deltaTime:)` once
  3. `scene.draw()` once
- Touch snapshots are sampled/advanced exactly once at the *start* of `scene.update(deltaTime:)`.
  - Fixed updates observe the previous frame’s input snapshot (Unity-like behavior).

### Touch ordering

- Touch arrays are returned in stable order (recommended: ascending `Touch.id`).

### Touch lifecycle

- The touch-capable implementation is responsible for a simple per-id state machine:
  - `.began` is reported for one frame when a new id appears.
  - `.moved` is reported when position changes in the frame.
  - `.stationary` is used when an id remains down without movement.
  - `.ended` / `.cancelled` are reported for one frame then removed.

## Implementation Strategy

### Core

1. Add `TouchPhase` + `Touch` types in `Sources/SwiftrixCore/Input/`.
2. Extend `InputSystem` with `touches()` (default `[]`).
3. Add `InputProxy` and `Scene.input` convenience.
4. Add `GameObject.scene` back-reference and wire it in `SceneCore.addRootObject/removeRootObject`.
5. Add `Script.scene` / `Script.input` convenience.

### SpriteKit adapter (optional follow-up)

1. Add a touch input system for SpriteKit scenes (or a small helper that bridges SpriteKit touches into an existing input system).
2. Ensure touch sampling happens at the correct time relative to the Core loop (no changes needed if Core samples at start of update).

## Testing Plan

### SwiftrixCore tests (unit)

- Touch types compile and are equatable as needed.
- `InputProxy` returns safe defaults when no input system exists.
- GameLoop sequencing: fixed steps run before input is sampled for the frame’s update.
- Scene → GameObject scene back-reference is set for root objects and descendants.
- Optional: verify stable touch ordering and end/cancel “one frame” semantics in the chosen touch-capable input implementation.

### SwiftrixSpriteKitRendering tests (unit/integration, optional)

- Deterministic mapping of SpriteKit touches to core touch ids (stable across frames).
- Touch phases are translated correctly and observed by scripts in Core update.

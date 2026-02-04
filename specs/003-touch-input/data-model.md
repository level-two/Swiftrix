# Data Model: Touch Input (Unity-like)

## Core types

### `TouchPhase`

Represents the phase of a touch at the current frame:

- `began`: first frame the touch id exists
- `moved`: position changed this frame
- `stationary`: still down, no movement this frame
- `ended`: touch released (reported for one frame)
- `cancelled`: touch cancelled by the system (reported for one frame)

### `Touch`

Minimal touch snapshot used by gameplay code:

- `id` (`Int`): stable identifier for the touch across frames (Unity-like `fingerId`)
- `position` (`Vector2`): touch location in host-defined “touch space” (SpriteKit recommends `SKScene` coordinates)
- `phase` (`TouchPhase`): current touch phase for the frame

## Scene access

### `InputProxy`

A lightweight value wrapper over an optional `InputSystem` instance, providing:

- `touches`: `[Touch]` (default `[]`)
- existing logical input queries (axes/buttons) with safe defaults

### `GameObject.scene`

Each `GameObject` in a `Scene` holds a weak back-reference to its owning scene so:

- scripts can use `self.input` without global state
- multiple scenes can exist without cross-talk

## Update timeline (per frame)

1. Zero or more `fixedUpdate(fixedDeltaTime:)` steps
2. Exactly one input sampling step at the beginning of `update(deltaTime:)`
3. Depth-first `update(deltaTime:)` traversal
4. `draw()`

This makes input “frame-based” and leaves fixed updates observing the previous frame’s input snapshot (Unity-like behavior).

## Touch ordering

Touches are returned in a stable order for determinism and tests (recommended: ascending `Touch.id`).

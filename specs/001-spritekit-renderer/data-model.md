# Data Model — Swiftrix SpriteKit Rendering Scene

## Entity: SpriteKitScene

- **Purpose**: An `SKScene` subclass that conforms to Core `Scene`, drives its `GameLoop`, and mirrors the game object graph into the SpriteKit node tree.
- **Key Fields**:
  - `rootObjects` — Core scene root objects (read-only).
  - `eventBus`, `inputSystem`, `corePhysicsWorld` — Core systems that back the `Scene` protocol.
  - `state` — enum { idle, running, paused, stopped } plus timestamps.
  - `performanceBudget` — struct { maxSyncOpsPerFrame }.
  - `registry` — manages `NodeBinding` instances.
  - `dirtyQueue` — controls incremental sync.
  - `cameraController` — optional active camera mapping.
  - `debugOverlayConfig` — optional overlay toggles.
- **Relationships**:
  - Owns a collection of `NodeBinding` entities (one per visual GameObject).
  - Owns exactly one `DirtySyncQueue`.
  - References optional `DebugOverlayConfig`.
- **State Transitions**:
  - `idle → running` (start display link or allow `update(_:)`, prime node mirror).
  - `running → paused` (host background, throttles Core updates).
  - `paused → running` (resume, flush dirty queue).
  - `running → stopped` (teardown, all bindings invalidated).

## Entity: NodeBinding

- **Purpose**: Tracks the relationship between a Core `GameObject`/`View` pair and the SpriteKit node that renders it.
- **Key Fields**:
  - `objectID` — Core identifier (stable).
  - `viewKind` — enum { sprite, label, shape, container, custom }.
  - `skNodeRef` — weak pointer/wrapper to the SpriteKit node.
  - `parentObjectID` — Core identifier for current parent object.
  - `dirtyFlags` — bitset { transform, visibility, asset, hierarchy, debugOverlay }.
  - `zOrder` — numeric layering value.
  - `viewState` — struct containing last-synced transform, alpha, texture token, size, anchor, isEnabled.
- **Relationships**:
  - Belongs to one `SpriteKitScene`.
  - Linked to zero or one `DirtySyncQueueItem` when flagged for update.
  - Optionally references a `DebugOverlayInstance` (if overlays enabled).
- **State Transitions**:
  - `unbound → bound` when object enters scene.
  - `bound → pendingRemoval` when object marked for destruction.
  - `pendingRemoval → released` after node removed and binding dropped.

## Entity: DirtySyncQueue

- **Purpose**: Prioritized queue that ensures only changed bindings are processed per frame.
- **Key Fields**:
  - `queueID`
  - `items` — ordered set of `DirtySyncQueueItem`.
  - `budget` — { maxItemsPerFrame } derived from `performanceBudget`.
- **Relationships**:
  - Owned by `SpriteKitScene`.
  - Each `DirtySyncQueueItem` references a `NodeBinding`.
- **State Transitions**:
  - Items are enqueued whenever a binding sets any dirty flag.
  - Queue flush occurs during sync step; processed items clear their flags.
  - Remaining items carry over to next frame if budget exhausted.

## Entity: CameraController

- **Purpose**: Minimal camera representation that translates Core camera intent into SpriteKit coordinates.
- **Key Fields**:
  - `mode` — enum { staticOffset, followObject }.
  - `targetObjectID` — optional when `mode == followObject`.
  - `worldToScreen` — matrix or struct storing scale/offset.
  - `cameraNodeRef` — reference to `SKCameraNode`.
  - `constraints` — optional bounds, damping factors.
- **Relationships**:
  - Associated with a single `SpriteKitScene`.
  - Reads transforms from `NodeBinding` when following an object.
- **State Transitions**:
  - `inactive → active` when host sets camera mode.
  - `active → inactive` on teardown.
  - `followObject` revalidates when target binding is destroyed.

## Entity: DebugOverlayConfig

- **Purpose**: Captures developer-facing toggles for rendering overlays, logs, and inspection hooks.
- **Key Fields**:
  - `isEnabled`
  - `showBounds`, `showAnchors`, `showNames`, `highlightSelection`
  - `selectedObjectIDs` — set for highlight.
  - `overlayStyle` — colors, line widths, z-position.
- **Relationships**:
  - Attached to `SpriteKitScene`.
  - Spawns `DebugOverlayInstance` per NodeBinding when active.
- **State Transitions**:
  - Toggles can be updated at runtime; overlay instances update accordingly.

## Entity: TouchHitTestMap (optional v1 scope)

- **Purpose**: When hit-testing is enabled, this structure accelerates mapping from `SKNode` hits back to Core `GameObject`s.
- **Key Fields**:
  - `nodeToObject` — dictionary keyed by SpriteKit node IDs.
  - `hitAreas` — cached transformed bounds for quick intersection checks.
- **Relationships**:
  - Shares data with `NodeBinding`.
  - Consumed by optional input bridge.
- **State Transitions**:
  - Rebuilt or incrementally updated whenever `NodeBinding` transform dirty flag is flushed.

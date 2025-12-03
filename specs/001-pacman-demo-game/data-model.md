# Data Model: Pacman Demo Game Controlled by On-Screen Keyboard

**Feature**: /Users/elychkouski/my-work/clanbomber-remake/Swiftrix/specs/001-pacman-demo-game/spec.md  
**Branch**: 001-pacman-demo-game  
**Date**: 2025-12-03

This document describes the conceptual entities, fields, and relationships used by the Pacman demo game. It is implementation-agnostic and focuses on behavior implied by the spec and research.

---

## Entities

### PacmanSession

Represents a single playable session of the Pacman demo.

- **Fields**
  - `score`: current integer score for the session.
  - `livesRemaining`: number of lives still available to the player.
  - `status`: enum or equivalent with values such as `running`, `gameOver`, `completed`.
  - `maze`: reference to the current `Maze` layout.
  - `pacman`: reference to the `Pacman` character.
  - `ghosts`: collection of `Ghost` entities.
  - `pelletsRemaining`: count of pellets still present in the maze.
  - `tickCount`: optional counter for debugging and deterministic updates.
  - `lastInputDirection`: most recent directional intent coming from input.

- **Relationships**
  - Owns exactly one `Maze` instance.
  - Owns exactly one `Pacman` instance.
  - Owns one or more `Ghost` instances.
  - Depends on `InputState` for directional intent and restart signals.

- **State Transitions**
  - `running` → `gameOver` when `livesRemaining` reaches zero.
  - `running` → `completed` when `pelletsRemaining` reaches zero.
  - `gameOver` or `completed` → `running` on session restart (state reset).

---

### Maze

Represents the static layout and dynamic pellet state of the Pacman level.

- **Fields**
  - `gridWidth`, `gridHeight`: dimensions of the maze grid.
  - `cells`: 2D structure of `MazeCell` values.
  - `initialPacmanPosition`: starting coordinates for `Pacman`.
  - `initialGhostPositions`: starting coordinates for each `Ghost`.

- **Relationships**
  - Composed of multiple `MazeCell` instances.
  - Used by `PacmanSession` to determine valid movement and collision.

- **Validation Rules**
  - Exactly one valid starting position for `Pacman`.
  - At least one pellet in the maze.
  - Outer boundaries and internal walls must prevent escaping the playable area.

---

### MazeCell

Represents a single grid location in the maze.

- **Fields**
  - `x`, `y`: coordinates in the maze grid.
  - `isWall`: whether this cell blocks movement.
  - `hasPellet`: whether this cell currently contains a collectible pellet.
  - `isSpawnArea`: optional flag for ghost or Pacman spawn areas.

- **Relationships**
  - Belongs to exactly one `Maze`.

- **Validation Rules**
  - A cell cannot be both a wall and contain a pellet.
  - Spawn areas must not be walls.

---

### Pacman

Represents the player-controlled character.

- **Fields**
  - `position`: current coordinate in the `Maze` grid.
  - `direction`: current movement direction (e.g., up, down, left, right, none).
  - `pendingDirection`: optional next direction requested by input when immediate turn is not possible.

- **Relationships**
  - Belongs to a `PacmanSession`.
  - Moves within a `Maze`.

- **Validation Rules**
  - Movement attempts into walls are ignored; Pacman remains in place or keeps current direction when possible.

---

### Ghost

Represents an autonomous opponent.

- **Fields**
  - `id`: identifier for the ghost (for debugging/visual differentiation).
  - `position`: current coordinate in the `Maze`.
  - `direction`: current movement direction.
  - `behaviorMode`: simple mode flag (e.g., normal chase/patrol).

- **Relationships**
  - Belongs to a `PacmanSession`.
  - Moves within a `Maze`.

- **Validation Rules**
  - Ghosts must not occupy invalid wall cells.
  - Movement rules must avoid undefined positions outside the maze.

---

### InputState

Represents the most recent input intent from the on-screen keyboard (and optionally other inputs).

- **Fields**
  - `requestedDirection`: last direction requested by the user.
  - `restartRequested`: boolean indicating whether the user has requested a session restart.

- **Relationships**
  - Read by `PacmanSession` or `PacmanSystem` during each update to adjust Pacman’s movement and handle restarts.

- **Validation Rules**
  - `requestedDirection` must be one of the supported directions or a neutral value.

---

### HUDState

Represents the information shown in the Pacman demo interface.

- **Fields**
  - `displayScore`: value derived from `PacmanSession.score`.
  - `displayLives`: value derived from `PacmanSession.livesRemaining`.
  - `displayStatus`: textual or symbolic status (e.g., “Ready”, “Game Over”, “You Win!”).

- **Relationships**
  - Derived from `PacmanSession`; rendered by the host app.

---

## Summary of Relationships

- A `PacmanSession` owns one `Maze`, one `Pacman`, multiple `Ghost` instances, and holds counters derived from `MazeCell` pellet state.
- `Maze` is composed of many `MazeCell` entries defining walls, paths, and pellets.
- `InputState` is produced by the on-screen keyboard and consumed by the session/system to update movement and restart behavior.
- `HUDState` is a read-only projection of session data for display in the UI.


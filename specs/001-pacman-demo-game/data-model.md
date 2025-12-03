# Data Model: Pacman Demo Game Controlled by On-Screen Keyboard

## Overview

The Pacman demo uses SwiftrixCore for game state and logic, with SpriteKit responsible for rendering. All persistent state is in-memory for the duration of a single play session; there is no long-term storage.

## Entities

### PlayerSession

- **Description**: Represents a single run of the Pacman demo.
- **Fields**:
  - `id`: Unique identifier for the session (in-memory).
  - `score`: Integer ≥ 0.
  - `livesRemaining`: Integer ≥ 0 (e.g., initial value 3).
  - `isActive`: Boolean flag indicating if the session is currently running.
  - `isGameOver`: Boolean flag indicating if the session has ended.
  - `maze`: Reference to the current `Maze` instance.
  - `pacman`: Reference to the current `PacmanCharacter`.
  - `ghosts`: Collection of `Ghost` entities.
  - `createdAt`: Timestamp for session start (in-memory).
  - `endedAt`: Optional timestamp when session ended.
- **Validation Rules**:
  - `livesRemaining` must not be negative.
  - `isGameOver` implies `isActive == false`.
  - `maze`, `pacman`, and `ghosts` must be non-null while `isActive == true`.

### Maze

- **Description**: Static layout for a single Pacman-style level.
- **Fields**:
  - `width`: Integer > 0.
  - `height`: Integer > 0.
  - `cells`: 2D collection of `MazeCell`.
  - `pelletCountTotal`: Integer ≥ 0.
  - `pelletCountRemaining`: Integer ≥ 0.
- **Validation Rules**:
  - `pelletCountRemaining` ≤ `pelletCountTotal`.
  - `width` and `height` must match the dimensions of `cells`.

### MazeCell

- **Description**: A single position in the maze grid.
- **Fields**:
  - `x`: Integer coordinate within `[0, width)`.
  - `y`: Integer coordinate within `[0, height)`.
  - `isWall`: Boolean.
  - `hasPellet`: Boolean.
  - `isSpawnPointPacman`: Boolean (optional spawn location).
  - `isSpawnPointGhost`: Boolean (optional spawn location).
- **Validation Rules**:
  - A cell cannot simultaneously be a wall and a spawn point.
  - Spawn points must not be walls.

### PacmanCharacter

- **Description**: Player-controlled character.
- **Fields**:
  - `position`: Coordinate or maze cell index.
  - `direction`: Enumeration (up, down, left, right, none).
  - `pendingDirection`: Optional direction requested by the on-screen keyboard (for cornering).
  - `speed`: Movement speed in cells per second or equivalent unit.
- **Validation Rules**:
  - `position` must correspond to a non-wall cell.
  - Movement updates must not move Pacman through wall cells.

### Ghost

- **Description**: Autonomous enemy character.
- **Fields**:
  - `id`: Identifier for the ghost.
  - `position`: Coordinate or maze cell index.
  - `direction`: Enumeration (up, down, left, right, none).
  - `speed`: Movement speed (may differ from Pacman).
  - `behaviorMode`: Simple mode (e.g., “chase” / “scatter” or similar basic pattern).
- **Validation Rules**:
  - `position` must correspond to a non-wall cell.
  - Movement updates must respect maze walls.

### OnScreenKey

- **Description**: Represents a single button in the on-screen keyboard overlay.
- **Fields**:
  - `id`: Identifier (e.g., "up", "down", "left", "right").
  - `label`: Text or icon mapping to the displayed control.
  - `action`: Logical input action (e.g., change Pacman direction).
  - `isPressed`: Boolean visual state.
- **Validation Rules**:
  - `action` must map to a valid game input (e.g., one of the allowed directions).

## State Transitions

### Session Lifecycle

- **Start Session**:
  - Initial state: no active session or previous session ended.
  - Action: initialize `PlayerSession` with default `score`, `livesRemaining`, maze, Pacman, and ghosts.
  - Result: `isActive = true`, `isGameOver = false`.

- **Game Over**:
  - Trigger: `livesRemaining` reaches 0.
  - Action: mark session as ended.
  - Result: `isActive = false`, `isGameOver = true`, `endedAt` set.

- **Restart Session**:
  - Trigger: user chooses restart (game over or mid-game).
  - Action: create new `PlayerSession` or reset fields to initial values.
  - Result: new active session with clean maze, score, and lives.

### Movement and Input

- **Directional Input**:
  - Trigger: user presses an `OnScreenKey`.
  - Action: set `pendingDirection` or `direction` on `PacmanCharacter` if movement is possible.
  - Result: engine updates `position` on each tick, respecting walls.

- **Pellet Collection**:
  - Trigger: Pacman moves into a cell with `hasPellet == true`.
  - Action: clear pellet from cell, decrement `pelletCountRemaining`, increment `score`.
  - Result: if `pelletCountRemaining` reaches 0, level is considered cleared (end-of-round behavior can be treated as “win/game over” for this demo).

- **Ghost Collision**:
  - Trigger: Pacman and a ghost occupy the same cell.
  - Action: decrement `livesRemaining`, reset Pacman and ghosts to spawn positions; if `livesRemaining` is now 0, transition to game over.


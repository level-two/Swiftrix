# Phase 0 Research: Pacman Demo Game Controlled by On-Screen Keyboard

## Unknowns and Decisions

### Rendering and Engine Integration

- **Unknown**: How to combine SwiftrixCore’s game loop and entities with SpriteKit scenes in the SwiftrixTest app.
- **Decision**: Use SwiftrixCore as the authoritative game engine (game loop, entities, physics, input mapping) and treat SpriteKit purely as the rendering layer inside the SwiftrixGame app.
- **Rationale**: Keeps the Pacman demo aligned with the primary purpose of SwiftrixCore (engine abstraction) while leveraging SpriteKit’s strengths in 2D rendering, animations, and scene management.
- **Alternatives considered**:
  - Implementing Pacman directly with SpriteKit only (bypassing SwiftrixCore) — rejected because it would not showcase Swiftrix as a game engine, which is the main goal of the demo.
  - Implementing a custom rendering backend inside SwiftrixCore without SpriteKit — rejected for this demo because it would significantly increase implementation effort without clear benefit compared to using the platform-native 2D engine.

### On-Screen Keyboard Input Model

- **Unknown**: How to structure on-screen keyboard input so it works consistently across macOS and iOS inside SwiftrixTest.
- **Decision**: Model the on-screen keyboard as a UI overlay (SpriteKit nodes) in the SwiftrixGame scene that translates tap/click events into Swiftrix input actions (e.g., directional commands) passed into the engine’s input system.
- **Rationale**: Keeps UI concerns on the SpriteKit side while ensuring the game logic only depends on abstract input actions, allowing future reuse of the Pacman logic with different input mechanisms (e.g., physical keyboard, controller).
- **Alternatives considered**:
  - Wiring on-screen buttons directly to SpriteKit-specific movement logic — rejected because it would duplicate logic that should live inside SwiftrixCore and reduce portability.
  - Implementing a separate UIKit/AppKit overlay for controls instead of SpriteKit nodes — rejected for this demo to keep everything inside a single SpriteKit scene.

### Game Scope and Features

- **Unknown**: How far to go beyond a minimal Pacman implementation (multiple levels, power-ups, advanced ghost AI, etc.).
- **Decision**: Implement a single-level Pacman-style maze with basic pellet collecting, simple ghost movement, score, and lives, without power-ups or multi-level progression.
- **Rationale**: The spec defines the feature as a demo to showcase the engine and on-screen controls; focusing on a single level keeps scope manageable and allows time to polish controls and stability.
- **Alternatives considered**:
  - Adding multiple levels and power-ups (e.g., energizers, frightened ghost mode) — rejected for this iteration due to additional complexity and testing surface area.
  - Implementing a very minimal prototype without ghosts — rejected because ghosts are key to the Pacman experience and are explicitly mentioned in the spec.

### Audio and Effects

- **Unknown**: Whether to include sounds or music in the first iteration.
- **Decision**: Do not include any sounds or music in this demo, in line with the user input.
- **Rationale**: The user explicitly requested “No sounds at the moment”; omitting audio reduces complexity and keeps the focus on engine integration and input responsiveness.
- **Alternatives considered**:
  - Adding simple sound effects for pellet collection and death — deferred to a potential future iteration once core gameplay and controls are validated.

### Testing Strategy

- **Unknown**: What level of automated testing is appropriate for a visual demo game.
- **Decision**: Focus tests on engine-level logic and integration, including:
  - Unit tests for Pacman movement, collision detection, scoring, and life management in SwiftrixCore.
  - Integration tests that simulate directional input sequences and verify resulting game state (e.g., clearing pellets, triggering game over).
  - Light sanity checks that the Pacman scene can be created and started in the SwiftrixGame target (where feasible).
- **Rationale**: Many visual and UX aspects require manual validation, but game rules and state transitions are well-suited for automated tests.
- **Alternatives considered**:
  - Relying on manual testing only — rejected because it increases regression risk and contradicts typical test-first expectations for engine logic.
  - Attempting full UI automation for SpriteKit scenes — deferred due to complexity and limited benefit for an internal demo.

## Clarifications Resolved

- Use SwiftrixCore as the primary engine and SpriteKit as the rendering layer inside the SwiftrixGame app.
- Target macOS 13+ and iOS 16+ using Swift 5.9, matching the existing Swiftrix setup.
- Limit scope to a single-level Pacman demo with ghosts, pellets, score, and lives, without multi-level progression or power-ups.
- Exclude audio for this iteration, as requested.
- Provide on-screen controls as SpriteKit UI elements that translate into Swiftrix input actions, ensuring the demo is fully playable with the on-screen keyboard alone.


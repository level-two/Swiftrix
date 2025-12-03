# Feature Specification: Pacman Swiftrix Migration

**Feature Branch**: `001-pacman-swiftrix-migration`  
**Created**: 2025-12-03  
**Status**: Draft  
**Input**: User description: "Move the existing Pacman implementation into the Swiftrix test application so that Pacman runs on the shared game engine and is playable via on-screen controls without audio."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Playable Pacman Demo in SwiftrixTest (Priority: P1)

As a developer or stakeholder evaluating the Swiftrix engine, I can launch the Pacman demo from the SwiftrixTest app and play a full game session (start, move, lose lives, clear pellets) so I can experience the engine-powered gameplay end to end.

**Why this priority**: This is the primary value of the migration—demonstrating that Pacman gameplay runs correctly inside the Swiftrix-powered test app, providing a concrete, interactive example of the engine in action.

**Independent Test**: From a clean build of SwiftrixTest, a tester can launch the app, start the Pacman demo, control Pacman using on-screen controls, and reach either game over (no lives) or completion (all pellets eaten) without needing additional tools or projects.

**Acceptance Scenarios**:

1. **Given** SwiftrixTest is installed and opened, **When** the user navigates to or starts the Pacman demo, **Then** a Pacman maze appears with Pacman, ghosts, pellets, and a visible score/lives display.
2. **Given** the Pacman demo is running, **When** the user taps the on-screen directional controls, **Then** Pacman moves in the corresponding direction, pellets are consumed when passed over, and score and remaining pellets update accordingly.
3. **Given** Pacman collides with a ghost, **When** a collision occurs, **Then** the game visibly indicates a lost life, updates the remaining lives, and either restarts the maze or shows a game-over state when no lives remain.
4. **Given** the user has reached a game-over state, **When** they activate a restart control, **Then** a new session starts with initial score, lives, and pellets reset.

---

### User Story 2 - On-Screen Control-Only Gameplay (Priority: P1)

As someone evaluating the demo on a touch device or simulator, I can fully play Pacman using an on-screen keyboard/control overlay so the game is usable even when a physical keyboard is not available.

**Why this priority**: The original requirement is that Pacman be controlled via on-screen controls; ensuring all primary actions can be performed this way makes the demo usable across devices and environments.

**Independent Test**: Run the Pacman demo on a device or simulator without using any hardware keyboard, and verify that all necessary gameplay (moving, starting, restarting) can be completed solely with on-screen controls.

**Acceptance Scenarios**:

1. **Given** the Pacman demo is visible, **When** the user only interacts with the on-screen control overlay, **Then** Pacman can be steered in all four cardinal directions required to navigate the maze.
2. **Given** the user needs to restart after losing or finishing, **When** they use the on-screen restart control, **Then** the game starts a new session without requiring any external keyboard command.
3. **Given** the device is in a typical play orientation (e.g., landscape), **When** the Pacman demo is active, **Then** on-screen controls and the maze are both visible and not overlapping in a way that hides essential information.

---

### User Story 3 - Engine-Based Pacman Logic Separation (Priority: P2)

As a Swiftrix engine user, I want Pacman’s game rules and state to run as an engine-driven system (separate from rendering) so that the same Pacman logic can be reused, tested, and understood independently of SpriteKit or any specific UI.

**Why this priority**: The migration should showcase the engine, not just a hardcoded scene. Having Pacman logic owned by the engine makes it easier to extend, test, and reuse Pacman as an example for future games built on Swiftrix.

**Independent Test**: With the Pacman demo running, testers can confirm that game state (score, pellets, positions, lives) is updated through a centralized game-session abstraction and that rendering is only a visual layer over that state, allowing engine-level inspection and restart without rewriting UI logic.

**Acceptance Scenarios**:

1. **Given** the Pacman demo is running, **When** multiple frames of gameplay occur, **Then** Pacman and ghosts update positions, collisions, and pellet consumption through a shared game-session abstraction rather than per-frame UI-only logic.
2. **Given** the user triggers a restart from the UI, **When** a new session begins, **Then** all relevant game state (score, lives, pellets, character positions) is reset by the underlying game-session or engine layer, and the UI reflects those changes.
3. **Given** Pacman’s rules are updated in the engine layer (e.g., pellet scoring or life count), **When** the demo is rebuilt, **Then** those rule changes are reflected in gameplay without needing per-view rewrites, demonstrating separation between engine and presentation.

---

### Edge Cases

- What happens when the user rapidly taps or presses on-screen controls in conflicting directions (e.g., alternating left/right or up/down quickly)? The game should continue to behave predictably without freezing, skipping input, or becoming stuck between tiles.
- How does the game behave if the app is backgrounded or deactivated while a session is in progress? On returning, the state should either resume safely or clearly reset to a consistent start state.
- What happens if Pacman has no remaining valid move in the desired direction (e.g., a wall is present)? The game should ignore that particular move input while continuing to accept other valid directions without visual glitches.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The Pacman demo MUST be accessible from within the SwiftrixTest application so that users can start a Pacman game session without opening any other project.
- **FR-002**: The system MUST display a Pacman maze, Pacman character, ghosts, pellets, score, and remaining lives as part of the demo’s primary screen.
- **FR-003**: Users MUST be able to control Pacman using an on-screen control overlay that supports movement in all required directions for navigating the maze.
- **FR-004**: The system MUST support completing a full Pacman run (either by losing all lives or clearing all pellets) in a single continuous session, with clear indication of game-over or completion.
- **FR-005**: The system MUST provide an in-demo control that allows users to restart the Pacman game session from the beginning without closing the SwiftrixTest app.
- **FR-006**: The Pacman game rules (movement, collisions, scoring, life tracking) MUST be represented as a reusable game-session or engine-level abstraction that is not tied to a single rendering implementation.
- **FR-007**: The system MUST ensure that Pacman’s visible position and the internal engine state remain consistent at all times, so that what the user sees on screen accurately reflects the underlying game rules.
- **FR-008**: The migration MUST preserve the core gameplay experience of the original Pacman implementation (maze navigation, ghost avoidance, pellet collection, scoring, and life loss) sufficiently for stakeholders to recognize behavior parity.
- **FR-009**: The demo MUST operate without relying on audio output, so that it can be evaluated in environments where sound is disabled or unavailable.
- **FR-010**: The system SHOULD allow the demo to be run and evaluated on at least one common development target (e.g., simulator or device) with standard project-setup steps documented for developers.

### Key Entities *(include if feature involves data)*

- **Pacman Game Session**: Represents a single run of the game, including current score, remaining lives, current level or maze, elapsed time, and status (running, paused, game over, completed).
- **Maze Layout**: Represents the grid or structure of the Pacman maze, including walls, paths, pellet locations, and any special tiles used to control ghost or Pacman behavior.
- **Character**: Represents Pacman and each ghost, including their positions, movement direction, speed characteristics, and basic behavioral state (e.g., chasing, fleeing, idle).
- **Input State**: Represents the current and recent user input from on-screen controls (and optionally other inputs), translating presses into directional intentions for Pacman.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A typical internal tester can launch the SwiftrixTest app and start playing the Pacman demo within 5 minutes of opening the project, following documented steps, without needing to modify code.
- **SC-002**: At least 90% of internal testers report that they can play a complete Pacman session (from start to game over or completion) using only on-screen controls, without requiring a hardware keyboard.
- **SC-003**: In informal side-by-side comparison with the previous Pacman implementation, stakeholders agree that the migrated demo preserves core gameplay behavior (maze navigation, collisions, scoring, life loss) with no major regressions in at least 9 out of 10 evaluation runs.
- **SC-004**: Over a 10-minute continuous play session on a supported target, the Pacman demo runs without crashes or visibly incorrect state (such as desynchronized positions or incorrect scores) in at least 95% of observed runs.

## Assumptions & Dependencies

- The previous Pacman implementation is available as a behavioral reference so that stakeholders can judge parity of gameplay after migration.
- The SwiftrixTest application is the primary host for the Pacman demo and will remain part of the standard project used to evaluate the engine.
- At least one common development target (such as a simulator or physical device) is available and supported for running the Pacman demo.
- The demo focuses on visual gameplay only; audio is intentionally excluded from the scope of this feature.
- On-screen controls are treated as the primary control method; use of hardware keyboards or alternative input devices is considered optional and outside the core MVP scope.

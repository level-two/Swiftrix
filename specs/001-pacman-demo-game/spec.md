# Feature Specification: Pacman Demo Game Controlled by On-Screen Keyboard

**Feature Branch**: `001-pacman-demo-game`  
**Created**: 2025-12-03  
**Status**: Draft  
**Input**: User description: "implement demo Pacman game. Pacman is conntrolled by the on-screen keyboard. Game is located at ../SwiftrixTest"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Play Pacman demo via on-screen keyboard (Priority: P1)

A player opens the Swiftrix test application, launches the Pacman demo, and uses the on-screen keyboard buttons to move Pacman around the maze, collecting pellets and avoiding ghosts.

**Why this priority**: This is the core purpose of the demo; if players cannot start the demo and control Pacman with the on-screen keyboard, the feature fails to deliver value.

**Independent Test**: From the Swiftrix test application, launch the Pacman demo and complete at least one full round (either collecting all pellets or losing all lives) using only on-screen keyboard controls.

**Acceptance Scenarios**:

1. **Given** a user has opened the Swiftrix test application, **When** they select the "Pacman Demo" entry point, **Then** a Pacman game screen loads showing a maze, Pacman, ghosts, score, lives, and an on-screen keyboard with clear directional controls.
2. **Given** the Pacman demo is running and the on-screen keyboard is visible, **When** the user taps or clicks the directional controls, **Then** Pacman moves in the corresponding direction, pellets are consumed when Pacman passes over them, the score updates, and collisions with ghosts reduce the remaining lives.

---

### User Story 2 - Understand and use on-screen controls (Priority: P2)

A player can easily recognize the on-screen keyboard, understand which buttons move Pacman, and see immediate visual feedback that their inputs have been registered.

**Why this priority**: Clear and responsive controls are essential for demonstrating that the on-screen keyboard is usable and intuitive, especially for users without a physical keyboard.

**Independent Test**: Observe a first-time user opening the Pacman demo and ask them to move Pacman in all four directions using only the on-screen controls without additional instructions.

**Acceptance Scenarios**:

1. **Given** the Pacman demo is visible, **When** a user looks at the on-screen keyboard, **Then** the directional controls are clearly labeled and positioned so users can identify how to move Pacman without guessing.
2. **Given** the on-screen keyboard is visible, **When** a user presses a directional control, **Then** that control provides visible feedback (such as highlighting) within a fraction of a second so the user knows the input was registered.

---

### User Story 3 - Restart and reuse the demo (Priority: P3)

A player or tester can quickly restart the Pacman demo after a game over (or at any time) so they can repeatedly try out the on-screen keyboard and game behavior.

**Why this priority**: The feature is a demo; being able to restart quickly is important for repeated demonstrations, testing, and experimentation without manually resetting the environment.

**Independent Test**: Play until game over, then restart the demo and verify that a new game begins with the maze reset, score and lives restored, and on-screen keyboard ready for use.

**Acceptance Scenarios**:

1. **Given** the Pacman demo has reached a game over state, **When** the user chooses to restart, **Then** a new game starts with Pacman, pellets, ghosts, score, and lives reset while keeping the on-screen keyboard visible and usable.
2. **Given** the Pacman demo is running, **When** a user chooses to restart mid-game, **Then** the current round is discarded and a fresh game begins without errors or leftover state from the previous session.

---

### Edge Cases

- What happens when a user rapidly taps or presses multiple directional controls in quick succession (e.g., quickly changing direction)? The demo should handle rapid input without freezing, dropping input, or causing unpredictable movement.
- How does the system behave when there is no input for an extended period (e.g., idle screen)? The demo should remain stable and playable when the user returns, without crashing or losing state unexpectedly.
- What happens if a user tries to use a physical keyboard instead of the on-screen keyboard? The demo should remain fully usable with the on-screen keyboard alone, regardless of whether physical keyboard input is available.
- How does the on-screen keyboard layout adapt when the display size or orientation changes (where applicable) so that both the maze and controls remain visible and usable?

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The Swiftrix test application MUST provide a clear entry point labeled for the Pacman demo so users can easily launch it.
- **FR-002**: When the Pacman demo is launched, the system MUST display a Pacman game screen that includes at minimum a maze, Pacman, ghosts, score, remaining lives, and an on-screen keyboard with directional controls.
- **FR-003**: The on-screen keyboard MUST provide directional controls that allow Pacman to move up, down, left, and right within the maze.
- **FR-004**: Pacman MUST move in response to on-screen keyboard input in a way that respects the maze layout (e.g., no passing through walls) and feels responsive to typical users.
- **FR-005**: The demo MUST include pellets (or equivalent collectibles) that are removed from the maze when Pacman moves over them and MUST update the displayed score accordingly.
- **FR-006**: The demo MUST include ghosts (or equivalent hazards) that move autonomously and MUST reduce Pacman’s remaining lives when a collision occurs.
- **FR-007**: The demo MUST show a game over state when Pacman has no remaining lives, including a clear indication that the game is finished.
- **FR-008**: From the game over state, users MUST be able to start a new game round without needing to close and reopen the Swiftrix test application.
- **FR-009**: Users MUST be able to restart the demo during an active game round, resetting the maze, score, and lives to their initial state.
- **FR-010**: The on-screen keyboard MUST provide visible feedback (for example, button highlighting or animation) when a control is pressed so users can see that their action was recognized.
- **FR-011**: The Pacman demo MUST be clearly identified as a demo (for example, via title or label) so users understand it is a sample experience rather than a full production game.
- **FR-012**: The demo MUST be fully playable using only the on-screen keyboard, without requiring a physical keyboard or other external input devices.

### Key Entities *(include if feature involves data)*

- **Player Session**: Represents a single run of the Pacman demo, including current score, remaining lives, maze state (which pellets have been collected), and whether the session is active or finished.
- **Pacman Character**: Represents the player-controlled character, including its current position in the maze, movement direction, and interaction with pellets and ghosts.
- **Ghost**: Represents an autonomous opponent, including its current position in the maze and behavior rules for movement and interaction with Pacman.
- **Maze Cell**: Represents a single position in the maze layout, including whether it contains a wall, pellet, empty space, or other special element.
- **On-Screen Key**: Represents a button in the on-screen keyboard, including its label (e.g., direction), visual state (normal, pressed), and the game action it triggers when activated.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: In usability testing with first-time users, at least 90% of participants can launch the Pacman demo and move Pacman in all four directions using only the on-screen keyboard within 30 seconds, without written instructions.
- **SC-002**: During internal testing, at least 95% of 15-minute play sessions complete without crashes, freezes, or input failures while using the Pacman demo.
- **SC-003**: In a structured usability survey, at least 80% of participants rate the on-screen controls for the Pacman demo as "easy" or "very easy" to understand and use.
- **SC-004**: Internal stakeholders (such as QA or product team members) can complete a defined Pacman demo test script—covering launching the demo, playing a round, and restarting—within 10 minutes, confirming that the demo is suitable for showcasing the on-screen keyboard.

## Assumptions

- The Pacman demo is a self-contained feature within the Swiftrix test application, intended for demonstration and testing rather than as a full-length commercial game.
- The demo uses a single maze layout with basic Pacman-style rules (collect pellets, avoid ghosts, lose lives on collision) and does not require advanced features such as multiple levels, power-ups, or complex scoring systems.
- Users may have access to a physical keyboard, but all critical interactions (launching the demo, moving Pacman, and restarting) are assumed to be performed with the on-screen keyboard.
- The demo will be used primarily on devices with pointer or touch input and a display large enough to show both the maze and the on-screen keyboard clearly at the same time.

# Tasks: Pacman Demo Game Controlled by On-Screen Keyboard

**Input**: Design documents from `/Users/elychkouski/my-work/clanbomber-remake/Swiftrix/specs/001-pacman-demo-game/`  
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, contracts/

**Tests**: This plan assumes manual validation guided by spec.md and quickstart.md. No dedicated automated test tasks are defined here.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- All descriptions include exact file paths

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure for the Pacman demo across SwiftrixCore and SwiftrixTest.

- [ ] T001 Configure SwiftrixGame to reference the local SwiftrixCore Swift package in `/Users/elychkouski/my-work/clanbomber-remake/SwiftrixTest/SwiftrixGame.xcodeproj`
- [ ] T002 [P] Create Pacman example module folder and placeholder Swift files in `/Users/elychkouski/my-work/clanbomber-remake/Swiftrix/Sources/Examples/Pacman/`
- [ ] T003 [P] Add placeholder `PacmanGameScene.swift` SpriteKit scene file for the demo in `/Users/elychkouski/my-work/clanbomber-remake/SwiftrixTest/SwiftrixGame/PacmanGameScene.swift`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core engine and rendering structures that MUST be complete before ANY user story can be implemented.

**⚠️ CRITICAL**: No user story work can begin until this phase is complete.

- [ ] T004 Implement `Maze` and `MazeCell` structures per data-model.md in `/Users/elychkouski/my-work/clanbomber-remake/Swiftrix/Sources/Examples/Pacman/PacmanMaze.swift`
- [ ] T005 [P] Implement `PacmanCharacter` and `Ghost` entities per data-model.md in `/Users/elychkouski/my-work/clanbomber-remake/Swiftrix/Sources/Examples/Pacman/PacmanEntities.swift`
- [ ] T006 [P] Implement `PlayerSession` with score, lives, and game-over state per data-model.md in `/Users/elychkouski/my-work/clanbomber-remake/Swiftrix/Sources/Examples/Pacman/PacmanSession.swift`
- [ ] T007 Implement `PacmanSystem` that integrates Pacman session with the SwiftrixCore game loop in `/Users/elychkouski/my-work/clanbomber-remake/Swiftrix/Sources/Examples/Pacman/PacmanSystem.swift`
- [ ] T008 [P] Align `PacmanSystem` API (start, input, restart) with conceptual contracts in `/Users/elychkouski/my-work/clanbomber-remake/Swiftrix/specs/001-pacman-demo-game/contracts/pacman-demo.yaml` in `/Users/elychkouski/my-work/clanbomber-remake/Swiftrix/Sources/Examples/Pacman/PacmanSystem.swift`
- [ ] T009 Implement initial SpriteKit `PacmanGameScene` that hosts a `PlayerSession` and renders the maze and characters in `/Users/elychkouski/my-work/clanbomber-remake/SwiftrixTest/SwiftrixGame/PacmanGameScene.swift`

**Checkpoint**: Engine-level Pacman session and basic rendering are available; user story implementation can now begin.

---

## Phase 3: User Story 1 - Play Pacman demo via on-screen keyboard (Priority: P1) 🎯 MVP

**Goal**: Allow a player to launch the Pacman demo in SwiftrixGame and play a full round using the on-screen keyboard, including pellets, ghosts, score, lives, and game over.

**Independent Test**: From the SwiftrixGame app, launch the Pacman demo, use only the on-screen keyboard to move Pacman, collect pellets, and either clear all pellets or lose all lives in a single session.

### Implementation for User Story 1

- [ ] T010 [US1] Add a “Pacman Demo” entry point in the SwiftrixGame UI to present `PacmanGameScene` from `/Users/elychkouski/my-work/clanbomber-remake/SwiftrixTest/SwiftrixGame/GameViewController.swift`
- [ ] T011 [P] [US1] Implement directional on-screen controls (up, down, left, right) as SpriteKit nodes within the Pacman scene in `/Users/elychkouski/my-work/clanbomber-remake/SwiftrixTest/SwiftrixGame/PacmanGameScene.swift`
- [ ] T012 [P] [US1] Wire on-screen control touch/click events to call `PacmanSystem` directional input APIs in `/Users/elychkouski/my-work/clanbomber-remake/SwiftrixTest/SwiftrixGame/PacmanGameScene.swift`
- [ ] T013 [P] [US1] Implement pellet layout for the single Pacman level in `/Users/elychkouski/my-work/clanbomber-remake/Swiftrix/Sources/Examples/Pacman/PacmanMaze.swift`
- [ ] T014 [P] [US1] Implement pellet consumption and score updates when Pacman moves over pellets in `/Users/elychkouski/my-work/clanbomber-remake/Swiftrix/Sources/Examples/Pacman/PacmanSession.swift`
- [ ] T015 [US1] Implement ghost movement and collision detection with Pacman affecting lives in `/Users/elychkouski/my-work/clanbomber-remake/Swiftrix/Sources/Examples/Pacman/PacmanEntities.swift`
- [ ] T016 [US1] Ensure `PlayerSession` triggers game-over state when lives reach zero and exposes that state to the scene in `/Users/elychkouski/my-work/clanbomber-remake/Swiftrix/Sources/Examples/Pacman/PacmanSession.swift`
- [ ] T017 [US1] Connect SwiftrixCore game loop updates to SpriteKit frame updates to keep Pacman and ghosts moving smoothly at target 60 fps in `/Users/elychkouski/my-work/clanbomber-remake/SwiftrixTest/SwiftrixGame/PacmanGameScene.swift`

**Checkpoint**: User Story 1 is fully functional and testable independently: users can launch the Pacman demo and complete a full round using only on-screen keyboard controls.

---

## Phase 4: User Story 2 - Understand and use on-screen controls (Priority: P2)

**Goal**: Make the on-screen keyboard intuitive and clearly labeled so first-time users can understand and use the controls without extra instructions.

**Independent Test**: Observe a first-time user launching the Pacman demo and ask them to move Pacman in all four directions using only on-screen controls; they should succeed without needing external guidance.

### Implementation for User Story 2

- [ ] T018 [US2] Refine on-screen keyboard layout and positioning for clarity across macOS/iOS in `/Users/elychkouski/my-work/clanbomber-remake/SwiftrixTest/SwiftrixGame/PacmanGameScene.swift`
- [ ] T019 [P] [US2] Implement visible pressed/active state feedback for each on-screen key on touch/click in `/Users/elychkouski/my-work/clanbomber-remake/SwiftrixTest/SwiftrixGame/PacmanGameScene.swift`
- [ ] T020 [P] [US2] Add minimal in-scene hint or title label explaining how to use the on-screen keyboard in `/Users/elychkouski/my-work/clanbomber-remake/SwiftrixTest/SwiftrixGame/PacmanGameScene.swift`
- [ ] T021 [US2] Tune input handling (e.g., cornering behavior and input buffering) to maintain responsive, predictable control in `/Users/elychkouski/my-work/clanbomber-remake/SwiftrixTest/SwiftrixGame/PacmanGameScene.swift`

**Checkpoint**: User Story 2 is independently testable: users can clearly see and understand the controls and receive immediate visual feedback when using them.

---

## Phase 5: User Story 3 - Restart and reuse the demo (Priority: P3)

**Goal**: Allow users to restart the Pacman demo quickly from game over or mid-game so they can repeatedly test and demonstrate the on-screen controls.

**Independent Test**: Play until game over, restart the demo, and confirm a clean new session; then restart mid-game and confirm that the session resets correctly both times.

### Implementation for User Story 3

- [ ] T022 [US3] Add an in-scene restart control (button or equivalent) to the Pacman demo UI in `/Users/elychkouski/my-work/clanbomber-remake/SwiftrixTest/SwiftrixGame/PacmanGameScene.swift`
- [ ] T023 [P] [US3] Implement session restart behavior to reset maze, score, lives, and entity positions in `/Users/elychkouski/my-work/clanbomber-remake/Swiftrix/Sources/Examples/Pacman/PacmanSession.swift`
- [ ] T024 [US3] Ensure restart works from both game-over and active-session states and that UI elements (score, lives, pellets) refresh correctly in `/Users/elychkouski/my-work/clanbomber-remake/SwiftrixTest/SwiftrixGame/PacmanGameScene.swift`

**Checkpoint**: User Story 3 is independently testable: users can restart the Pacman demo reliably without restarting the entire app.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories and overall demo quality.

- [ ] T025 Review Pacman demo performance and adjust engine/scene parameters to maintain target 60 fps using `/Users/elychkouski/my-work/clanbomber-remake/SwiftrixTest/SwiftrixGame/PacmanGameScene.swift` and related Pacman engine files under `/Users/elychkouski/my-work/clanbomber-remake/Swiftrix/Sources/Examples/Pacman/`
- [ ] T026 [P] Update documentation to reflect the Pacman demo flow and controls in `/Users/elychkouski/my-work/clanbomber-remake/Swiftrix/specs/001-pacman-demo-game/quickstart.md`
- [ ] T027 [P] Run through the full Pacman demo flow following quickstart.md and fix minor UX or visual issues across Pacman-related Swift files under `/Users/elychkouski/my-work/clanbomber-remake/Swiftrix` and `/Users/elychkouski/my-work/clanbomber-remake/SwiftrixTest/SwiftrixGame/`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies – can start immediately.
- **Foundational (Phase 2)**: Depends on Setup completion – BLOCKS all user stories.
- **User Stories (Phases 3–5)**: All depend on Foundational phase completion.
  - User Story 1 (P1) is the MVP and should be implemented first.
  - User Stories 2 (P2) and 3 (P3) can proceed after Phase 2 and in parallel with each other once User Story 1’s basic flow is available.
- **Polish (Phase 6)**: Depends on all desired user stories being functionally complete.

### User Story Dependencies

- **User Story 1 (P1)**: Depends on Setup (Phase 1) and Foundational (Phase 2); no dependency on other stories and forms the MVP.
- **User Story 2 (P2)**: Depends on Setup (Phase 1) and Foundational (Phase 2); assumes User Story 1 is available so control clarity can be tested in a full game context, but can be developed largely in parallel with late US1 tasks.
- **User Story 3 (P3)**: Depends on Setup (Phase 1) and Foundational (Phase 2); also depends on a functioning Pacman session and UI from User Story 1 so restart behavior can be wired.

### Within Each User Story

- For User Story 1:
  - Implement entry point (T010) before wiring in-scene controls (T011, T012).
  - Implement maze and pellets (T013, T014) before ghost collisions and game-over logic (T015, T016).
  - Finalize loop integration and smooth movement (T017) after core movement and collisions work.
- For User Story 2:
  - Layout adjustments (T018) can be done before or alongside visual feedback (T019) and hints (T020).
  - Tuning responsiveness (T021) should be done after basic control visuals are in place.
- For User Story 3:
  - Add restart control in UI (T022) before wiring restart behavior (T023) and validating both game-over and mid-game restart flows (T024).

---

## Parallel Opportunities

- Phase 1:
  - T002 and T003 are marked [P] and can be executed in parallel once T001 is in progress or complete.
- Phase 2:
  - T005, T006, and T008 are marked [P] and can be worked on in parallel since they operate on different files and build on the Maze structures from T004.
- Phase 3 (US1):
  - T011, T012, T013, and T014 are marked [P] and can proceed in parallel once foundational engine types are present.
- Phase 4 (US2):
  - T019 and T020 are marked [P] and can be implemented in parallel after the basic on-screen keyboard exists from T011.
- Phase 5 (US3):
  - T023 is marked [P] and can proceed in parallel with UI wiring in T022 and validation in T024.
- Phase 6:
  - T026 and T027 are marked [P] and can be done in parallel after core implementation is stable.

Different developers (or agents) can also take separate user stories (US1, US2, US3) in parallel once Phase 2 is complete, as long as they coordinate changes in shared files like `PacmanGameScene.swift`.

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (T001–T003).
2. Complete Phase 2: Foundational (T004–T009).
3. Complete Phase 3: User Story 1 (T010–T017).
4. **STOP and VALIDATE**: Manually test User Story 1 using the quickstart and spec acceptance scenarios.
5. Demo the Pacman demo as an MVP showcasing SwiftrixCore + SpriteKit + on-screen keyboard.

### Incremental Delivery

1. Deliver MVP (User Story 1) as above.
2. Add User Story 2 (T018–T021) to improve clarity and feedback of controls; validate independently.
3. Add User Story 3 (T022–T024) to support quick restarts; validate independently.
4. Apply Phase 6 polish tasks (T025–T027) to stabilize performance and documentation.

### Parallel Team Strategy

With multiple implementers:

1. Work together on Setup (Phase 1) and Foundational (Phase 2).
2. After Phase 2:
   - Developer A: Focus on US1 core gameplay tasks (T010–T017).
   - Developer B: Focus on US2 control clarity and feedback (T018–T021).
   - Developer C: Focus on US3 restart flow (T022–T024).
3. Once stories are complete, share final polish tasks (T025–T027) across the team.

All tasks follow the required checklist format and provide concrete file paths suitable for LLM-based execution.


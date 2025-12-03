# Quickstart: Pacman Demo Game Controlled by On-Screen Keyboard

**Feature**: /Users/elychkouski/my-work/clanbomber-remake/Swiftrix/specs/001-pacman-demo-game/spec.md  
**Branch**: 001-pacman-demo-game  
**Date**: 2025-12-03

This guide describes how to build, run, and manually test the Pacman demo game that uses SwiftrixCore as the engine and SpriteKit for rendering in the SwiftrixTest host app.

---

## 1. Prerequisites

- Xcode and a compatible Apple platform SDK installed.
- Swift toolchain compatible with the existing Swiftrix package.
- This repository checked out locally at:
  - `/Users/elychkouski/my-work/clanbomber-remake/Swiftrix`
  - `/Users/elychkouski/my-work/clanbomber-remake/SwiftrixTest`

---

## 2. Build the Engine Package

From the Swiftrix repository root:

```bash
cd /Users/elychkouski/my-work/clanbomber-remake/Swiftrix
swift build
```

This ensures that `SwiftrixCore` and its Pacman example code compile successfully as a SwiftPM package.

---

## 3. Open and Run the SwiftrixTest App

1. Open the host app project in Xcode:

   ```bash
   open /Users/elychkouski/my-work/clanbomber-remake/SwiftrixTest/SwiftrixGame.xcodeproj
   ```

2. In Xcode, select a simulator or device target that supports SpriteKit.
3. Build and run the `SwiftrixGame` app.

When the app launches, it should present the Pacman demo scene powered by SwiftrixCore.

---

## 4. Manual Test Script (User Stories)

### User Story 1 – Play Pacman via On-Screen Keyboard

1. Confirm that the initial screen shows:
   - A Pacman maze with walls and pellets.
   - Pacman and at least one ghost.
   - Score and lives indicators.
   - An on-screen keyboard or control overlay for directions.
2. Use only the on-screen controls to move Pacman around the maze.
3. Verify:
   - Pacman cannot pass through walls.
   - Pellets disappear when Pacman passes over them and the score increases.
   - Collisions with ghosts reduce lives and eventually lead to a game-over state.

### User Story 2 – Understand and Use On-Screen Controls

1. Without additional instructions, identify which on-screen controls move Pacman in each direction.
2. Tap each directional control and observe:
   - Pacman moves in the expected direction when possible.
   - The pressed control provides visual feedback (e.g., highlight) when tapped.
3. Confirm that both the maze and controls remain visible during play.

### User Story 3 – Restart and Reuse the Demo

1. Play until reaching a game-over state (no lives remaining).
2. Use the visible restart control to start a new game.
3. Verify that:
   - Score and lives reset to their initial values.
   - All pellets reappear and Pacman/ghosts return to their starting positions.
4. Optionally, trigger a restart during an active game and confirm that the new session starts cleanly.

---

## 5. Engine-Level Testing (Optional but Recommended)

To validate Pacman rules independently of SpriteKit:

1. From the Swiftrix repository root:

   ```bash
   cd /Users/elychkouski/my-work/clanbomber-remake/Swiftrix
   swift test
   ```

2. Confirm that tests covering Pacman behavior (movement, pellet consumption, life loss, restart) pass successfully.

---

## 6. Observability & Debugging Tips

- Inspect Pacman session state (score, lives, remaining pellets, positions) via logs or debug output from the SwiftrixCore Pacman example code.
- When investigating issues, compare observed gameplay against the expectations in:
  - `specs/001-pacman-demo-game/spec.md`
  - `specs/001-pacman-demo-game/data-model.md`
  - `specs/001-pacman-demo-game/research.md`


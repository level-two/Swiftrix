# Quickstart: Pacman Demo Game Controlled by On-Screen Keyboard

This guide explains how to run and test the Pacman demo that uses SwiftrixCore as the engine and SpriteKit for rendering, with control via an on-screen keyboard.

## Prerequisites

- Xcode installed with support for:
  - macOS 13+ development
  - iOS 16+ simulator or device (if testing on iOS)
- Swift 5.9 toolchain (as defined in `Package.swift`)

## Project Locations

- Engine library: `/Users/elychkouski/my-work/clanbomber-remake/Swiftrix`
- Demo app: `/Users/elychkouski/my-work/SwiftrixTest`

## Steps to Run the Demo

1. Open the demo app project:
   - Launch Xcode.
   - Open `/Users/elychkouski/my-work/SwiftrixTest/SwiftrixGame.xcodeproj`.

2. Ensure engine dependency is available:
   - Confirm that the SwiftrixGame target is configured to use the `SwiftrixCore` package from `/Users/elychkouski/my-work/clanbomber-remake/Swiftrix`.

3. Choose a run target:
   - macOS: Select the macOS app scheme for SwiftrixGame.
   - iOS: Select an iOS simulator or connected device compatible with iOS 16+.

4. Build and run:
   - Press Run in Xcode.
   - Wait for the app to launch.

5. Launch the Pacman demo:
   - From the SwiftrixGame app, navigate to the Pacman demo entry point (labelled according to the spec, e.g., “Pacman Demo”).

6. Play using the on-screen keyboard:
   - Use the on-screen directional controls to move Pacman up, down, left, and right.
   - Observe score updates when collecting pellets and life reductions when colliding with ghosts.

7. Restart the demo:
   - After game over (or during a game), use the restart control or entry point to start a new session and verify that maze, score, and lives are reset.

## Basic Test Flow

- Confirm the Pacman demo screen appears with maze, Pacman, ghosts, score, lives, and on-screen keyboard visible.
- Verify that pressing each directional control produces responsive movement that respects maze walls.
- Collect pellets and confirm score increments as expected.
- Trigger a ghost collision and confirm lives decrement and game over when lives reach zero.
- Restart the demo and verify a clean new session.


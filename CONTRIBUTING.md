# Contributing to SwiftrixCore

This project is designed to be easy to understand and safe to modify by both humans and AI agents. This document gives a high-level map of how to contribute; it does **not** duplicate the detailed rules in `AGENTS.md` or the specs.

If you are building a game *using* Swiftrix, you can mostly ignore this file and focus on `README.md` and the docs under `docs/`.

---

## 1. Ground Rules and Architecture

- The **engine core** (`Sources/SwiftrixCore`) must remain platform-agnostic:
  - no direct imports of SpriteKit, UIKit, SwiftUI, Metal, AVFoundation, etc.
  - allowed frameworks are `Foundation`, `CoreGraphics`, and internal modules.
- Rendering, platform input, audio, and UI live in **host apps** or adapter modules such as `SwiftrixSpriteKitRendering`.
- New public API surface in the core should be:
  - small and coherent
  - driven by real use cases
  - covered by specs and tests.

Before changing core architecture or public APIs, read:

- `AGENTS.md`
- `specs/000-swiftrix-engine-core/spec.md`
- `specs/000-swiftrix-engine-core/plan.md`
- `specs/000-swiftrix-engine-core/tasks.md`

For the SpriteKit adapter, see:

- `specs/001-spritekit-renderer/spec.md`
- `specs/001-spritekit-renderer/plan.md`
- `specs/001-spritekit-renderer/tasks.md`

---

## 2. Where to Put Code

- Engine core:
  - code: `Sources/SwiftrixCore/**`
  - tests: `Tests/SwiftrixCoreTests/**`
- SpriteKit adapter:
  - code: `Sources/SwiftrixSpriteKitRendering/**`
  - tests: `Tests/SwiftrixSpriteKitRenderingTests/**`
- Docs:
  - user-facing docs: `docs/**`
  - specs and plans: `specs/**`

In general:

- put **gameplay-agnostic engine primitives** (scene graph, components, physics, input) in `SwiftrixCore`.
- put **platform-specific glue** (SpriteKit nodes, host lifecycle, hit-testing) in adapter or host targets.

---

## 3. Tests First, Then Code

- When changing behavior or adding features:
  - add or adjust tests in the relevant test target:
    - `Tests/SwiftrixCoreTests` for core features
    - `Tests/SwiftrixSpriteKitRenderingTests` for adapter features
  - aim for “red → green” (tests fail before your change, pass after).
- Run the full suite from the repo root:

  ```bash
  swift test
  ```

If a change can’t be reasonably tested (rare), note the rationale clearly in the spec or PR description.

---

## 4. Documentation Expectations

- For **engine users** (game developers):
  - keep `README.md` and `docs/` accurate and concise.
  - when you add new capabilities that matter to users (e.g., a new adapter feature), update:
    - `docs/host-integration-spritekit.md`
    - `docs/debugging-and-introspection.md`
    - or add a focused doc under `docs/`.
- For **maintainers**:
  - keep specs in `specs/000-*` and `specs/001-*` aligned with implemented behavior.
  - use the spec/plan/tasks flow for significant features rather than ad-hoc design.

---

## 5. Style and Simplicity

- Follow the existing Swift style in this repo (Swift 5.9, standard conventions).
- Prefer small, composable types and clear data flow over clever abstractions.
- Avoid introducing parallel concepts when an existing protocol or type can reasonably be extended.

If you’re unsure where something belongs or how to name it, check similar patterns in:

- `Sources/SwiftrixCore/Scene/**`
- `Sources/SwiftrixCore/GameObject/**`
- `Sources/SwiftrixSpriteKitRendering/**`

---

## 6. AI Agents

AI agents working in this repo should:

- always consult `AGENTS.md` and relevant specs before editing core or adapter APIs.
- keep changes minimal and targeted to the requested task.
- prefer editing existing files over introducing new top-level concepts unless justified by specs/tests.

Human contributors can lean on agents for repetitive changes, but architectural decisions should remain grounded in the documented plans and tests.


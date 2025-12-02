<!--
Sync Impact Report
- Version: 1.0.0 → 1.1.0
- Modified principles:
  - II. Swift-First & SwiftPM Distribution (no title change, clarified scope)
  - III. Public API as Product (no title change, clarified tooling focus)
  - V. Simplicity, Performance, Extensibility & Observability (renamed to add observability)
- Added sections / content:
  - Observability and AI-friendly architecture expectations embedded into core principles.
  - Explicit observability and AI/tooling alignment in Architecture & Integration Constraints.
  - Constitution Check in plan-template now includes observability and AI considerations.
- Removed sections:
  - None
- Templates:
  - ✅ .specify/templates/plan-template.md (Constitution Check aligned with observability + AI)
  - ✅ .specify/templates/spec-template.md (already consistent with user-story + testing focus)
  - ✅ .specify/templates/tasks-template.md (test discipline aligned; observability tasks encouraged)
  - ⚠ .specify/templates/commands/* (directory not present; no command docs to sync)
  - ⚠ README.md (not present; future overview should reference core principles, including observability and AI)
- Deferred TODOs:
  - None
-->

# Swiftrix Constitution

## Core Principles

### I. Core-Only Engine Architecture

Swiftrix is a Unity3D-like game engine core written in Swift. The core
MUST remain platform-agnostic and delegate platform concerns to host
applications.

- Core modules MUST NOT depend directly on rendering, input, audio, windowing,
  networking, or resource-loading frameworks.
- All platform-specific behavior MUST flow through clearly defined protocols
  or abstractions owned by the core and implemented by the host.
- The core MUST focus on simulation, scene/graph management, components,
  systems, and scheduling, not platform integration details.
- Engine behavior MUST be deterministic where feasible given its inputs to
  enable repeatable tests.

**Rationale**: Keeping the core independent from the platform maximizes
testability, portability, and long-term maintainability.

### II. Swift-First & SwiftPM Distribution

Swiftrix is a Swift-first engine core distributed as a Swift Package Manager
package.

- All production engine code MUST be written in Swift unless a specific FFI
  boundary is documented and justified.
- The engine MUST be consumable as one or more SwiftPM targets with clear
  module boundaries.
- Public package products and targets MUST follow semantic versioning and
  remain stable across minor and patch releases.
- Package manifests and module layout MUST stay simple and predictable for
  consumers embedding the engine.

**Rationale**: SwiftPM-centric design ensures straightforward integration into
Swift projects and keeps dependencies explicit.

### III. Public API as Product

The public API surface of Swiftrix is treated as a product with strict
documentation and stability requirements.

- Every public type, initializer, property, and method MUST have Swift
  documentation comments describing behavior, inputs, outputs, and invariants.
- Public APIs MUST be designed for clarity and composability over convenience;
  surprising side effects are not allowed.
- Breaking changes to public APIs MUST be deliberate, rare, and accompanied by
  migration notes and a semantic version MAJOR bump.
- High-level entry points (e.g., engine bootstrap, scene management, component
  registration) SHOULD have examples in feature specs or quickstart docs.

**Rationale**: A well-documented and stable API is essential for teams
embedding Swiftrix as an engine core.

### IV. Unit-Tested Features (NON-NEGOTIABLE)

All behavior added to the engine core MUST be covered by automated unit tests.

- New features and bug fixes MUST include unit tests that fail before code
  changes and pass after implementation.
- Public API behavior MUST have corresponding unit tests that exercise success
  paths, error paths, and key edge cases.
- Test suites MUST run in CI for every change and MUST pass before merging.
- Integration or contract tests MAY be added as needed, but they DO NOT replace
  unit tests for core behavior.

**Rationale**: A game engine core is foundational infrastructure; high test
coverage is required to prevent regressions and enable safe evolution.

### V. Simplicity, Performance, Extensibility & Observability

Engine internals and APIs MUST remain as simple as possible while supporting
high-performance use cases, rich observability, and future extension.

- Prefer simple, composable data structures and algorithms over complex
  abstractions unless there is a demonstrated need.
- Hot paths (e.g., update loops, component iteration) MUST be designed and
  profiled for performance appropriate to real-time game workloads.
- Extensibility points (e.g., systems, components, services) MUST be explicit
  and documented, not reached via hidden globals or incidental coupling.
- New dependencies or subsystems MUST justify their complexity and be removed
  or simplified when they no longer deliver clear value.
- State and behavior of core systems SHOULD be easily inspectable at runtime
  (e.g., via debug views, structured logs, snapshots) to support tooling and
  AI-assisted workflows.
- Scene graphs, component composition, and event flows MUST be represented
  using explicit, uniform structures suitable for automated inspection,
  visualization, and reasoning.

**Rationale**: A simple, performant, observable, and extensible core enables a
wide variety of games, tools, and AI workflows to be built on Swiftrix without
unnecessary friction.

## Architecture & Integration Constraints

Swiftrix defines a strict separation of concerns between the engine core and
embedding applications.

- Host applications are responsible for rendering, input collection, audio,
  resource loading, and platform lifecycle; the core consumes only abstracted
  inputs and services.
- Communication between the host and core MUST occur through clearly defined
  protocols, data structures, or callback interfaces.
- Core modules MUST be reusable across platforms (desktop, mobile, console)
  without source changes, assuming hosts implement the required protocols.
- Global state in the core MUST be avoided; shared state MUST be routed through
  explicit engine contexts or world/scene objects.
- Error handling MUST be explicit and predictable: use typed errors or result
  types instead of silent failures.

Performance and concurrency:

- The main update loop MUST expose clear extension points where hosts can
  integrate platform work without blocking core processing unnecessarily.
- Concurrency constructs (e.g., tasks, queues) MUST be used deliberately and
  documented; data races in core structures are unacceptable.

Observability and AI-assisted workflows:

- Core data structures (e.g., scenes, game objects, components) SHOULD support
  serialization or reflection mechanisms that enable inspection and tooling.
- Logging, metrics, and debugging facilities SHOULD be structured so that
  automated tools and AI agents can reason about engine state and behavior.

## Development Workflow & Quality Gates

The following workflow and gates apply to all changes to Swiftrix.

- Each feature MUST have a spec and implementation plan capturing API changes,
  test strategy, and performance considerations.
- All code changes MUST go through code review with explicit verification of:
  architecture boundaries, test coverage, documentation, and API stability.
- CI MUST run the full test suite for every merge to main and for published
  release branches.
- Any change that affects public APIs MUST declare the intended semantic
  version bump type (MAJOR, MINOR, PATCH) in the plan and release notes.
- Features MUST be integrated incrementally; partial implementations without
  passing tests MUST NOT be merged to main.

**Quality reviews**:

- Periodic reviews SHOULD evaluate whether existing systems remain necessary,
  are over-generalized, or can be simplified.
- Performance regressions detected by profiling or benchmarks MUST be treated
  as defects and prioritized accordingly.

## Governance

This constitution defines the non-negotiable rules for working on the Swiftrix
engine core and supersedes ad-hoc practices or historical conventions.

- Amendments to this constitution MUST be proposed via pull request that
  includes:
  - A description of the problem the amendment solves.
  - The semantic version impact (MAJOR/MINOR/PATCH) and rationale.
  - Any required migration plan for existing features or APIs.
- MAJOR changes (principle additions/removals or semantic redefinitions) MUST
  be reviewed and approved by the project maintainer(s) or core team.
- MINOR and PATCH updates MAY be approved by maintainers but MUST still go
  through the standard review process.
- Every feature spec, plan, and tasks document MUST include a "Constitution
  Check" step that confirms compliance with:
  - Core-only architecture boundaries.
  - SwiftPM distribution and module structure.
  - Public API documentation requirements.
  - Unit test coverage for new behavior.

Compliance:

- Reviewers are responsible for blocking changes that violate this
  constitution.
- Violations discovered after merge MUST be corrected promptly, with follow-up
  tasks added and prioritized.

**Version**: 1.1.0 | **Ratified**: 2025-12-02 | **Last Amended**: 2025-12-02

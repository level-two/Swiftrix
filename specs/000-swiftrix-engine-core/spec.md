# Swiftrix Engine — High‑Level Specification

**Document Type:** Vision & Scope  
**Focus:** *What* we are building and *why*  
**Audience:** Designers, developers, collaborators

---

## 1. Purpose of the Engine

Swiftrix Engine is a lightweight, modular, and highly understandable game
engine designed for rapid prototyping, small‑to‑medium games, and
AI‑augmented development workflows.

The core purpose is **to provide a clean, intuitive model for building
interactive worlds**, where game logic is expressed in small, composable units
(components) attached to hierarchical game objects.

The engine is not trying to compete with large, feature-heavy engines.
Instead, it focuses on:

- **Clarity** — predictable behaviour, readable architecture, minimal magic
- **Modularity** — each part of the engine can be swapped, extended, or
  replaced
- **Approachability** — easy to learn for newcomers and comfortable for
  experienced engineers
- **Observability** — structure and state are transparent (ideal for tools and
  AI agents)
- **Determinism** — predictable updates, physics, and event flows

---

## 2. Vision

### 2.1 A Simpler Unity-like Model

We want to recreate the *feel* of Unity’s component-based design, but with:

- fewer concepts,
- lower mental overhead,
- and a more explicit and transparent architecture.

A `GameObjectInterface` represents a node in a tree (default implementation: `GameObject`).  
Components (such as views, scripts, colliders, controls) attach behaviour or
data.  
Scenes hold trees of objects and orchestrate update, input, physics, and draw
cycles.

This creates a mental model that is both powerful and easy to reason about.

### 2.2 Engine as a Set of LEGO Bricks

Everything should be:

- small,
- replaceable,
- and operating through well-defined contracts.

Examples:

- Rendering could be implemented using different backends without rewriting
  game logic.
- Physics can be swapped out or even disabled entirely.
- Input can come from touch, keyboard, scripts, or AI.

The system’s clarity makes it an excellent playground for experimentation.

### 2.3 Designed for AI-Assisted Creative Work

The engine is intentionally structured to allow:

- code generation by AI agents
- documentation and reflection tools
- automated reasoning about game object structures
- predictable behavior modeling

Because the architecture is explicit, uniform, and readable, AI can easily
operate on it.

---

## 3. What We Are Building (Functional Overview)

### 3.1 Scene Graph

A tree of game objects forming the world.  
Scenes manage:

- lifecycle (update, fixed update, draw)
- traversal and snapshots
- object creation and destruction
- coordination with subsystems (physics, input, events)

### 3.2 Game Objects

The fundamental elements in the world.  
Each object:

- holds a transform (position, rotation, scale)
- lives inside a parent–child hierarchy
- can have zero or more components
- may serve as a container or behavior source

### 3.3 Components

Atomic units of behaviour and data.  
We start with four essential ones:

1. **Script** — custom logic (movement, AI, reactions)
2. **View** — rendering (sprites, shapes, meshes)
3. **Collider** — participates in physics and collisions
4. **Control** — interprets input (axes, actions, buttons)

Everything else is an extension of these basic blocks.

### 3.4 Update Lifecycle

The engine executes:

1. **Fixed Update** — deterministic systems (e.g. physics)
2. **Update** — game logic, animations, timers
3. **Draw** — rendering layer

This loop guarantees predictability and clarity.

### 3.5 Event Pipeline

A unified event system (collision events, input events, script-triggered
events) that:

- decouples subsystems
- simplifies debugging
- allows reactive patterns (e.g. async streams)

### 3.6 Input Abstraction

Input is expressed through:

- **axes** (continuous values like horizontal movement)
- **actions** (buttons or events like “jump”, “fire”)

This makes gameplay code independent of device-specific mechanics.

### 3.7 Physics Layer

A lightweight collision/overlap system:

- collider registration
- queries (overlap, raycast)
- collision detection and dispatch
- trigger vs solid collisions

Physics is intentionally small so it can evolve without redesigning gameplay
logic.

---

## 4. Why This Engine?

### 4.1 For Developers

- A clear mental model: no hidden behaviour, no magic.
- Easy debugging and extension.
- Suitable for hobby projects, prototypes, tools, game jams, and teaching.

### 4.2 For AI Integration

- Explicit and predictable architecture
- Simple component taxonomies
- Straightforward transformation and scene graphs
- Rich opportunities for automation (tools, generation, refactoring)

### 4.3 For Long-Term Evolution

The design ensures we can later add:

- advanced renderers
- editor tools
- asset pipelines
- networking
- ECS backend
- scripting languages
- AI behavior trees
- particle systems
- 3D support

Without breaking existing gameplay code.

---

## 5. Non-Goals (What We Are NOT Building)

- We are **not** recreating Unity or Unreal.
- We are **not** building a full editor with complex tooling (at least not
  now).
- We are **not** focusing on AAA graphics, shaders, or heavy engine tech.
- We are **not** optimizing for large-scale commercial production.

The engine is deliberately minimal and elegant.

---

## 6. Success Criteria

### 6.1 Engine-Level

- Runs simple scenes at stable framerate
- Predictable update behavior
- Clean, readable, well-documented public API
- Can build small test games (platformer, shooter, puzzle)

### 6.2 Developer Experience

- Adding a new behavior feels natural and simple
- The structure is obvious even without documentation
- AI tools can auto-generate working gameplay code
- Easy to debug scenes and object hierarchies

### 6.3 Extensibility

- New components can be implemented without modifying the core
- Backends can be swapped with minimal refactoring
- Event system supports new event types gracefully

---

## 7. Summary

Swiftrix Engine is built to be:

- **small**
- **clear**
- **modular**
- **predictable**
- **AI‑friendly**

It takes the best conceptual lessons from Unity’s component model and
reimagines them in a more explicit and elegant architecture.

The engine’s ultimate goal:  
### Empower rapid creation of interactive worlds with clarity, joy, and flexibility.

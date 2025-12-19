# Swiftrix Documentation Index

Swiftrix ships as two SwiftPM libraries:

- `SwiftrixCore`: platform-agnostic engine core (scene graph, components, loop, input, physics, events).
- `SwiftrixSpriteKitRendering`: optional SpriteKit adapter (mirrors Core state into `SKScene`/`SKNode`).

## Where to Start

- Quick overview + example: `README.md`
- Single-file API reference (Markdown): `docs/api-reference.md`
- Conceptual model and update flow: `docs/engine-concepts.md`
- Public API walkthrough (symbols and responsibilities): `docs/public-api.md`
- SpriteKit host integration patterns: `docs/host-integration-spritekit.md`
- Debugging/introspection helpers: `docs/debugging-and-introspection.md`

## Generate API Reference (DocC)

Swiftrix includes DocC catalogs (in `Sources/**/.docc`) so you can generate a browsable API reference from the public interfaces.

### Option A: Xcode (recommended)

Open `Package.swift` in Xcode, then use Product → Build Documentation.

### Option B: SwiftPM (requires plugin)

The `swift package generate-documentation` command is provided by Apple’s `swift-docc-plugin`. If your environment has that plugin available, you can run:

```bash
swift package --allow-writing-to-directory ./docs generate-documentation --output-path ./docs/api
```

If you only want one product’s docs:

```bash
swift package --allow-writing-to-directory ./docs generate-documentation --product SwiftrixCore --output-path ./docs/api/SwiftrixCore
swift package --allow-writing-to-directory ./docs generate-documentation --product SwiftrixSpriteKitRendering --output-path ./docs/api/SwiftrixSpriteKitRendering
```

## Products and Import Names

- Add to your target: `.product(name: "SwiftrixCore", package: "Swiftrix")`
  - Import in Swift: `import SwiftrixCore`
- Optional adapter: `.product(name: "SwiftrixSpriteKitRendering", package: "Swiftrix")`
  - Import in Swift: `import SwiftrixSpriteKitRendering`

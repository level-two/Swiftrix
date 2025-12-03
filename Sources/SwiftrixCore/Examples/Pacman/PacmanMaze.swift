import Foundation

public struct MazeCell: Codable, Hashable {
    public var position: GridPosition
    public var isWall: Bool
    public var hasPellet: Bool
    public var isPacmanSpawn: Bool
    public var isGhostSpawn: Bool

    public init(position: GridPosition, isWall: Bool, hasPellet: Bool, isPacmanSpawn: Bool, isGhostSpawn: Bool) {
        self.position = position
        self.isWall = isWall
        self.hasPellet = hasPellet
        self.isPacmanSpawn = isPacmanSpawn
        self.isGhostSpawn = isGhostSpawn
    }
}

public struct PacmanMaze: Codable {
    public let width: Int
    public let height: Int
    public internal(set) var cells: [MazeCell]
    public internal(set) var pelletCountTotal: Int
    public internal(set) var pelletCountRemaining: Int

    public init(width: Int, height: Int, cells: [MazeCell]) {
        self.width = width
        self.height = height
        self.cells = cells
        let pelletCount = cells.filter(\.hasPellet).count
        self.pelletCountTotal = pelletCount
        self.pelletCountRemaining = pelletCount
    }

    public func index(for position: GridPosition) -> Int? {
        guard position.x >= 0, position.x < width, position.y >= 0, position.y < height else {
            return nil
        }
        return position.y * width + position.x
    }

    public func cell(at position: GridPosition) -> MazeCell? {
        guard let idx = index(for: position) else { return nil }
        return cells[idx]
    }

    public mutating func consumePellet(at position: GridPosition) -> Bool {
        guard let idx = index(for: position) else { return false }
        guard cells[idx].hasPellet else { return false }
        cells[idx].hasPellet = false
        pelletCountRemaining = max(0, pelletCountRemaining - 1)
        return true
    }

    public func isWalkable(_ position: GridPosition) -> Bool {
        guard let cell = cell(at: position) else { return false }
        return !cell.isWall
    }

    public func pacmanSpawn() -> GridPosition {
        cells.first(where: { $0.isPacmanSpawn })?.position ?? GridPosition(x: 1, y: 1)
    }

    public func ghostSpawns() -> [GridPosition] {
        let spawns = cells.filter { $0.isGhostSpawn }.map(\.position)
        if spawns.isEmpty {
            return [GridPosition(x: width / 2, y: height / 2)]
        }
        return spawns
    }

    public func pelletPositions() -> [GridPosition] {
        cells.filter { $0.hasPellet }.map(\.position)
    }

    public static func demoMaze() -> PacmanMaze {
        let layout = [
            "#################",
            "#P.............G#",
            "#.###.#####.###.#",
            "#.....#...#.....#",
            "###.#.#.#.#.#.###",
            "#...#.#.#.#.#...#",
            "#.#.#.#.#.#.#.#.#",
            "#.#...G...G...#.#",
            "#.#.#.#.#.#.#.#.#",
            "#...#.#.#.#.#...#",
            "###.#.#.#.#.#.###",
            "#.....#...#.....#",
            "#.###.#####.###.#",
            "#G.............G#",
            "#################"
        ]

        return PacmanMaze(layout: layout)
    }

    public init(layout: [String]) {
        guard let first = layout.first else {
            self.init(width: 0, height: 0, cells: [])
            return
        }
        let width = first.count
        var parsed: [MazeCell] = []
        var pellets = 0
        for (y, line) in layout.enumerated() {
            precondition(line.count == width, "All maze rows must have equal width")
            for (x, char) in line.enumerated() {
                let position = GridPosition(x: x, y: y)
                let isWall = (char == "#")
                let isPacmanSpawn = (char == "P")
                let isGhostSpawn = (char == "G")
                var hasPellet = (char == ".")
                if isPacmanSpawn || isGhostSpawn {
                    hasPellet = false
                }
                if hasPellet { pellets += 1 }
                parsed.append(
                    MazeCell(
                        position: position,
                        isWall: isWall,
                        hasPellet: hasPellet,
                        isPacmanSpawn: isPacmanSpawn,
                        isGhostSpawn: isGhostSpawn
                    )
                )
            }
        }
        self.width = width
        self.height = layout.count
        self.cells = parsed
        self.pelletCountTotal = pellets
        self.pelletCountRemaining = pellets
    }
}

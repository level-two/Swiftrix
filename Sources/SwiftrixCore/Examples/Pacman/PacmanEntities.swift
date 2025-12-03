import Foundation

public enum PacmanDirection: CaseIterable, Codable {
    case up
    case down
    case left
    case right
    case none

    public var delta: GridPosition {
        switch self {
        case .up: return GridPosition(x: 0, y: -1)
        case .down: return GridPosition(x: 0, y: 1)
        case .left: return GridPosition(x: -1, y: 0)
        case .right: return GridPosition(x: 1, y: 0)
        case .none: return GridPosition(x: 0, y: 0)
        }
    }

    public var opposite: PacmanDirection {
        switch self {
        case .up: return .down
        case .down: return .up
        case .left: return .right
        case .right: return .left
        case .none: return .none
        }
    }
}

public struct GridPosition: Hashable, Codable {
    public var x: Int
    public var y: Int

    public init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }

    public func offset(by direction: PacmanDirection) -> GridPosition {
        let delta = direction.delta
        return GridPosition(x: x + delta.x, y: y + delta.y)
    }

    public func manhattanDistance(to other: GridPosition) -> Int {
        abs(x - other.x) + abs(y - other.y)
    }
}

public struct PacmanCharacter: Codable, Equatable {
    public var position: GridPosition
    public var direction: PacmanDirection
    public var pendingDirection: PacmanDirection?
    public var speed: Double

    public init(position: GridPosition, direction: PacmanDirection = .none, pendingDirection: PacmanDirection? = nil, speed: Double = 6.0) {
        self.position = position
        self.direction = direction
        self.pendingDirection = pendingDirection
        self.speed = speed
    }
}

public struct Ghost: Codable, Equatable, Identifiable {
    public let id: UUID
    public var position: GridPosition
    public var direction: PacmanDirection
    public var speed: Double

    public init(id: UUID = UUID(), position: GridPosition, direction: PacmanDirection = .left, speed: Double = 5.0) {
        self.id = id
        self.position = position
        self.direction = direction
        self.speed = speed
    }
}

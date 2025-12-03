import Foundation

public struct PacmanConfiguration {
    public let initialLives: Int
    public let stepRate: Double
    public let ghostStepRate: Double
    public let pelletScore: Int

    public init(initialLives: Int = 3, stepRate: Double = 8.0, ghostStepRate: Double = 6.0, pelletScore: Int = 10) {
        self.initialLives = initialLives
        self.stepRate = stepRate
        self.ghostStepRate = ghostStepRate
        self.pelletScore = pelletScore
    }
}

public struct PlayerSession: Identifiable, Codable {
    public enum Status: String, Codable {
        case idle
        case running
        case cleared
        case gameOver
    }

    public let id: UUID
    public internal(set) var score: Int
    public internal(set) var livesRemaining: Int
    public internal(set) var status: Status
    public internal(set) var maze: PacmanMaze
    public internal(set) var pacman: PacmanCharacter
    public internal(set) var ghosts: [Ghost]
    public let createdAt: Date
    public internal(set) var endedAt: Date?
    internal var pacmanAccumulator: TimeInterval
    internal var ghostAccumulator: TimeInterval

    public init(id: UUID = UUID(), score: Int = 0, livesRemaining: Int, status: Status, maze: PacmanMaze, pacman: PacmanCharacter, ghosts: [Ghost], createdAt: Date = Date(), endedAt: Date? = nil, pacmanAccumulator: TimeInterval = 0, ghostAccumulator: TimeInterval = 0) {
        self.id = id
        self.score = score
        self.livesRemaining = livesRemaining
        self.status = status
        self.maze = maze
        self.pacman = pacman
        self.ghosts = ghosts
        self.createdAt = createdAt
        self.endedAt = endedAt
        self.pacmanAccumulator = pacmanAccumulator
        self.ghostAccumulator = ghostAccumulator
    }

    public var isActive: Bool { status == .running }
    public var isGameOver: Bool { status == .gameOver || status == .cleared }
}

import Foundation

/// Manages Pacman sessions and handles deterministic updates for the demo.
public final class PacmanSystem {
    private let configuration: PacmanConfiguration
    private let stepDuration: TimeInterval
    private let ghostStepDuration: TimeInterval
    private var sessionValue: PlayerSession
    private var random = SystemRandomNumberGenerator()

    public init(configuration: PacmanConfiguration = PacmanConfiguration()) {
        self.configuration = configuration
        self.stepDuration = 1.0 / configuration.stepRate
        self.ghostStepDuration = 1.0 / configuration.ghostStepRate
        self.sessionValue = PacmanSystem.makeSession(configuration: configuration)
    }

    public var session: PlayerSession { sessionValue }

    public func restartSession() {
        sessionValue = PacmanSystem.makeSession(configuration: configuration)
    }

    public func applyInput(_ direction: PacmanDirection) {
        guard direction != .none else { return }
        guard sessionValue.isActive else { return }
        sessionValue.pacman.pendingDirection = direction
        if sessionValue.pacman.direction == .none {
            sessionValue.pacman.direction = direction
        }
    }

    public func update(deltaTime: TimeInterval) {
        guard sessionValue.isActive else { return }
        sessionValue.pacmanAccumulator += deltaTime
        sessionValue.ghostAccumulator += deltaTime

        while sessionValue.pacmanAccumulator >= stepDuration {
            sessionValue.pacmanAccumulator -= stepDuration
            advancePacman()
            evaluatePelletsAndWinCondition()
            if !sessionValue.isActive {
                break
            }
            handleGhostCollisions()
        }

        guard sessionValue.isActive else { return }

        while sessionValue.ghostAccumulator >= ghostStepDuration {
            sessionValue.ghostAccumulator -= ghostStepDuration
            advanceGhosts()
            handleGhostCollisions()
            if !sessionValue.isActive {
                break
            }
        }
    }

    private func advancePacman() {
        if let pending = sessionValue.pacman.pendingDirection,
           pending != sessionValue.pacman.direction,
           canMove(from: sessionValue.pacman.position, toward: pending) {
            sessionValue.pacman.direction = pending
            sessionValue.pacman.pendingDirection = nil
        }

        let direction = sessionValue.pacman.direction
        guard direction != .none else { return }
        let target = sessionValue.pacman.position.offset(by: direction)
        guard canMove(to: target) else { return }
        sessionValue.pacman.position = target
    }

    private func advanceGhosts() {
        for index in sessionValue.ghosts.indices {
            let direction = nextDirection(forGhostAt: index)
            guard direction != .none else { continue }
            let target = sessionValue.ghosts[index].position.offset(by: direction)
            guard canMove(to: target) else { continue }
            sessionValue.ghosts[index].position = target
            sessionValue.ghosts[index].direction = direction
        }
    }

    private func evaluatePelletsAndWinCondition() {
        let currentPosition = sessionValue.pacman.position
        if sessionValue.maze.consumePellet(at: currentPosition) {
            sessionValue.score += configuration.pelletScore
        }

        if sessionValue.maze.pelletCountRemaining == 0 {
            sessionValue.status = .cleared
            sessionValue.endedAt = Date()
        }
    }

    private func handleGhostCollisions() {
        let pacmanPosition = sessionValue.pacman.position
        guard sessionValue.isActive else { return }

        let collided = sessionValue.ghosts.contains { $0.position == pacmanPosition }
        guard collided else { return }

        sessionValue.livesRemaining -= 1
        if sessionValue.livesRemaining <= 0 {
            sessionValue.status = .gameOver
            sessionValue.endedAt = Date()
            return
        }

        resetCharactersPositions()
    }

    private func resetCharactersPositions() {
        sessionValue.pacman.direction = .none
        sessionValue.pacman.pendingDirection = nil
        sessionValue.pacman.position = sessionValue.maze.pacmanSpawn()
        let ghostSpawns = sessionValue.maze.ghostSpawns()
        for index in sessionValue.ghosts.indices {
            let spawn = ghostSpawns.indices.contains(index) ? ghostSpawns[index] : sessionValue.maze.pacmanSpawn()
            sessionValue.ghosts[index].position = spawn
            sessionValue.ghosts[index].direction = .none
        }
    }

    private func nextDirection(forGhostAt index: Int) -> PacmanDirection {
        let ghost = sessionValue.ghosts[index]
        let pacmanPosition = sessionValue.pacman.position
        var candidates: [PacmanDirection] = []
        let directions: [PacmanDirection] = [.up, .down, .left, .right]
        for direction in directions {
            let next = ghost.position.offset(by: direction)
            guard canMove(to: next) else { continue }
            candidates.append(direction)
        }

        if candidates.count > 1, ghost.direction != .none {
            candidates.removeAll { $0 == ghost.direction.opposite }
        }

        guard !candidates.isEmpty else {
            return ghost.direction == .none ? .none : ghost.direction.opposite
        }

        let sorted = candidates.sorted { lhs, rhs in
            let lhsDistance = ghost.position.offset(by: lhs).manhattanDistance(to: pacmanPosition)
            let rhsDistance = ghost.position.offset(by: rhs).manhattanDistance(to: pacmanPosition)
            if lhsDistance == rhsDistance {
                let lhsPriority = directions.firstIndex(of: lhs) ?? 0
                let rhsPriority = directions.firstIndex(of: rhs) ?? 0
                return lhsPriority < rhsPriority
            }
            return lhsDistance < rhsDistance
        }

        let shouldChase = Int.random(in: 0..<100, using: &random) < 70
        if shouldChase {
            return sorted.first ?? .none
        }
        let randomIndex = Int.random(in: 0..<candidates.count, using: &random)
        return candidates[randomIndex]
    }

    private func canMove(to position: GridPosition) -> Bool {
        sessionValue.maze.isWalkable(position)
    }

    private func canMove(from position: GridPosition, toward direction: PacmanDirection) -> Bool {
        guard direction != .none else { return false }
        let next = position.offset(by: direction)
        return canMove(to: next)
    }

    private static func makeSession(configuration: PacmanConfiguration) -> PlayerSession {
        var maze = PacmanMaze.demoMaze()
        let pacman = PacmanCharacter(position: maze.pacmanSpawn(), direction: .left, pendingDirection: nil, speed: configuration.stepRate)
        let ghostSpawns = maze.ghostSpawns()
        let ghosts = ghostSpawns.map { Ghost(position: $0, direction: .right, speed: configuration.ghostStepRate) }
        return PlayerSession(
            score: 0,
            livesRemaining: configuration.initialLives,
            status: .running,
            maze: maze,
            pacman: pacman,
            ghosts: ghosts
        )
    }
}

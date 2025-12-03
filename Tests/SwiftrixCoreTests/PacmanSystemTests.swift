import XCTest
@testable import SwiftrixCore

final class PacmanSystemTests: XCTestCase {

    func testPelletConsumptionAdjustsScoreAndPelletCount() {
        let system = makeSystem(
            configuration: PacmanConfiguration(initialLives: 3, stepRate: 8, ghostStepRate: 0.05, pelletScore: 25),
            layout: [
                "#####",
                "#P.G#",
                "#####"
            ]
        )

        let initialPellets = system.session.maze.pelletCountRemaining
        system.applyInput(.right)
        system.update(deltaTime: 0.2)

        let session = system.session
        XCTAssertEqual(session.score, 25)
        XCTAssertEqual(session.maze.pelletCountRemaining, initialPellets - 1)
    }

    func testGhostCollisionConsumesLifeAndResetsPositions() {
        let system = makeSystem(
            configuration: PacmanConfiguration(initialLives: 2, stepRate: 6, ghostStepRate: 0.05),
            layout: [
                "#####",
                "#PG.#",
                "#####"
            ]
        )

        let spawn = system.session.maze.pacmanSpawn()
        system.applyInput(.right)
        system.update(deltaTime: 0.2)

        let session = system.session
        XCTAssertEqual(session.livesRemaining, 1)
        XCTAssertEqual(session.pacman.position, spawn, "Pacman should reset to spawn after collision")
        XCTAssertEqual(session.status, .running)
    }

    func testClearingAllPelletsMarksSessionCleared() {
        let system = makeSystem(
            configuration: PacmanConfiguration(initialLives: 1, stepRate: 10, ghostStepRate: 0.05),
            layout: [
                "#####",
                "#P.G#",
                "#####"
            ]
        )

        system.applyInput(.right)
        system.update(deltaTime: 0.2)

        XCTAssertEqual(system.session.status, .cleared)
        XCTAssertEqual(system.session.maze.pelletCountRemaining, 0)
    }

    func testRestartSessionRestoresInitialState() {
        let configuration = PacmanConfiguration(initialLives: 3, stepRate: 8, ghostStepRate: 0.05, pelletScore: 50)
        let system = makeSystem(configuration: configuration, layout: [
            "#####",
            "#P.G#",
            "#####"
        ])

        system.applyInput(.right)
        system.update(deltaTime: 0.2)
        XCTAssertTrue(system.session.score > 0)

        system.restartSession()
        let restarted = system.session
        XCTAssertEqual(restarted.score, 0)
        XCTAssertEqual(restarted.livesRemaining, configuration.initialLives)
        XCTAssertEqual(restarted.status, .running)
        XCTAssertEqual(restarted.maze.pelletCountRemaining, restarted.maze.pelletCountTotal)
    }

    // MARK: - Helpers

    private func makeSystem(configuration: PacmanConfiguration, layout: [String]) -> PacmanSystem {
        return PacmanSystem(configuration: configuration) {
            PacmanMaze(layout: layout)
        }
    }
}

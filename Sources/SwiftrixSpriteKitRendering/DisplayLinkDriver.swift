import Foundation
import SpriteKit
#if canImport(QuartzCore)
import QuartzCore
#endif

/// Abstraction over a display-linked clock so tests can inject manual drivers.
public protocol DisplayLinkDriving: AnyObject {
    var onTick: ((TimeInterval) -> Void)? { get set }
    var preferredFramesPerSecond: Int { get set }

    func start()
    func pause()
    func resume()
    func stop()
}

/// Real display link driver backed by `CADisplayLink`.
public final class CADisplayLinkDriver: DisplayLinkDriving {
    public var onTick: ((TimeInterval) -> Void)?
    public var preferredFramesPerSecond: Int {
        didSet {
            #if os(macOS)
            // Timer-based driver uses preferredFramesPerSecond to compute interval.
            timerInterval = 1.0 / Double(preferredFramesPerSecond)
            #else
            displayLink?.preferredFramesPerSecond = preferredFramesPerSecond
            #endif
        }
    }

    #if os(macOS)
    private var timer: Timer?
    private var isPaused = false
    private var timerInterval: TimeInterval
    #else
    private var displayLink: CADisplayLink?
    private var lastTimestamp: CFTimeInterval?
    #endif

    public init(preferredFramesPerSecond: Int = 60) {
        self.preferredFramesPerSecond = preferredFramesPerSecond
        #if os(macOS)
        self.timerInterval = 1.0 / Double(preferredFramesPerSecond)
        #endif
    }

    public func start() {
        #if os(macOS)
        guard timer == nil else { return }
        timer = Timer.scheduledTimer(withTimeInterval: timerInterval, repeats: true) { [weak self] _ in
            self?.fireTimer()
        }
        if let timer {
            RunLoop.main.add(timer, forMode: .common)
        }
        #else
        guard displayLink == nil else { return }
        #if canImport(QuartzCore)
        let link = CADisplayLink(target: self, selector: #selector(step(_:)))
        link.preferredFramesPerSecond = preferredFramesPerSecond
        link.add(to: .main, forMode: .common)
        displayLink = link
        #endif
        #endif
    }

    public func pause() {
        #if os(macOS)
        isPaused = true
        #else
        displayLink?.isPaused = true
        #endif
    }

    public func resume() {
        #if os(macOS)
        isPaused = false
        #else
        displayLink?.isPaused = false
        #endif
    }

    public func stop() {
        #if os(macOS)
        timer?.invalidate()
        timer = nil
        isPaused = false
        #else
        displayLink?.invalidate()
        displayLink = nil
        lastTimestamp = nil
        #endif
    }

    #if os(macOS)
    private func fireTimer() {
        guard !isPaused else { return }
        onTick?(timerInterval)
    }
    #else
    @objc private func step(_ link: CADisplayLink) {
        guard let onTick else { return }
        if lastTimestamp == nil {
            lastTimestamp = link.timestamp
            return
        }
        let delta = link.timestamp - (lastTimestamp ?? link.timestamp)
        lastTimestamp = link.timestamp
        onTick(delta)
    }
    #endif
}

/// Manual driver used by tests to deterministically advance frames.
public final class ManualDisplayLinkDriver: DisplayLinkDriving {
    public var onTick: ((TimeInterval) -> Void)?
    public var preferredFramesPerSecond: Int = 60
    private var isPaused = false

    public init() {}

    public func start() {}

    public func pause() {
        isPaused = true
    }

    public func resume() {
        isPaused = false
    }

    public func stop() {
        isPaused = false
    }

    /// Advances the clock by the given delta, respecting pause state.
    public func tick(deltaTime: TimeInterval) {
        guard !isPaused else { return }
        onTick?(deltaTime)
    }
}

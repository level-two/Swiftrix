import Foundation

/// Simple FIFO queue of dirty binding ids with de-duplication.
public final class DirtySyncQueue {
    private var queued: [UUID] = []
    private var queuedSet: Set<UUID> = []

    public init() {}

    /// Adds an id to the queue (no-op if already queued).
    public func markDirty(_ id: UUID) {
        guard !queuedSet.contains(id) else { return }
        queuedSet.insert(id)
        queued.append(id)
    }

    /// Removes and returns up to `maxItems` queued ids (or all ids when `nil`).
    public func drain(maxItems: Int?) -> [UUID] {
        let count = maxItems.map { min($0, queued.count) } ?? queued.count
        guard count > 0 else { return [] }
        let slice = Array(queued.prefix(count))
        queued.removeFirst(count)
        queuedSet.subtract(slice)
        return slice
    }

    /// Clears the queue.
    public func clear() {
        queued.removeAll()
        queuedSet.removeAll()
    }
}

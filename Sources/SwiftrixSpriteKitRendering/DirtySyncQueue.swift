import Foundation

/// Simple FIFO queue of dirty bindings with optional frame budget.
public final class DirtySyncQueue {
    private var queued: [UUID] = []
    private var queuedSet: Set<UUID> = []

    public init() {}

    public func markDirty(_ id: UUID) {
        guard !queuedSet.contains(id) else { return }
        queuedSet.insert(id)
        queued.append(id)
    }

    public func drain(maxItems: Int?) -> [UUID] {
        let count = maxItems.map { min($0, queued.count) } ?? queued.count
        guard count > 0 else { return [] }
        let slice = Array(queued.prefix(count))
        queued.removeFirst(count)
        queuedSet.subtract(slice)
        return slice
    }

    public func clear() {
        queued.removeAll()
        queuedSet.removeAll()
    }
}

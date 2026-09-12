// SPDX-License-Identifier: GPL-3.0-or-later

import Foundation

protocol MobyRequestClock: Sendable {
    func now() async -> TimeInterval
    func sleep(for seconds: TimeInterval) async throws
}

struct ContinuousMobyClock: MobyRequestClock {
    private let origin = ContinuousClock.now

    func now() async -> TimeInterval {
        let elapsed = origin.duration(to: .now).components
        return Double(elapsed.seconds) + Double(elapsed.attoseconds) / 1_000_000_000_000_000_000
    }

    func sleep(for seconds: TimeInterval) async throws {
        try await Task.sleep(for: .seconds(seconds))
    }
}

/// Conservative pacing satisfies both documented sustained and burst quotas.
/// Commercial policies need verified subscription limits before being added.
enum MobyAccessTier: Sendable {
    case nonCommercial
    case legacyNonCommercial

    var requestInterval: TimeInterval {
        switch self {
        case .nonCommercial: 5
        case .legacyNonCommercial: 10
        }
    }
}

/// Only request admission is serialized. Network I/O and decoding can overlap.
/// Waiting suspends tasks; no thread sleeps, semaphores, or reserved FIFO slots.
actor MobyRateLimiter {
    private let clock: any MobyRequestClock
    private let interval: TimeInterval
    private var nextAllowed: TimeInterval = 0

    init(tier: MobyAccessTier = .nonCommercial, clock: any MobyRequestClock = ContinuousMobyClock()) {
        self.clock = clock
        interval = tier.requestInterval
    }

    func waitForPermit() async throws {
        while true {
            try Task.checkCancellation()
            let now = await clock.now()
            try Task.checkCancellation()
            let delay = nextAllowed - now
            if delay <= 0 {
                nextAllowed = now + interval
                return
            }
            // Chunk long server cooldowns so Duration conversion cannot overflow.
            // Re-check the shared deadline after every suspension: a 429 may extend it.
            try await clock.sleep(for: min(delay, 60))
        }
    }

    func deferRequests(for seconds: TimeInterval) async {
        let now = await clock.now()
        nextAllowed = max(nextAllowed, now + max(0, seconds))
    }
}

// SPDX-License-Identifier: GPL-3.0-or-later

import Foundation

enum MobyRetryPolicy: Sendable {
    case disabled
    case limited

    var maximumAttempts: Int {
        switch self {
        case .disabled: 1
        case .limited: 3
        }
    }

    /// Larger server cooldowns are retained by the limiter, but reported to the caller.
    var maximumAutomaticDelay: TimeInterval { 30 }

    func backoff(after attempt: Int) -> TimeInterval {
        min(pow(2, Double(attempt)), 8)
    }
}

enum MobyRetryAfter {
    /// Supports delay-seconds and the standard HTTP date forms. Never logs raw headers.
    static func seconds(from header: String?, now: Date = .now) -> TimeInterval? {
        guard let header else { return nil }
        let value = header.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !value.isEmpty else { return nil }
        if value.utf8.allSatisfy({ (48...57).contains($0) }) {
            // An unrepresentably long wait must not accidentally become an immediate retry.
            let seconds = TimeInterval(value) ?? .greatestFiniteMagnitude
            return seconds.isFinite ? seconds : .greatestFiniteMagnitude
        }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.isLenient = false
        for format in ["EEE, dd MMM yyyy HH:mm:ss zzz", "EEEE, dd-MMM-yy HH:mm:ss zzz", "EEE MMM d HH:mm:ss yyyy"] {
            formatter.dateFormat = format
            if let date = formatter.date(from: value) {
                return max(0, date.timeIntervalSince(now))
            }
        }
        return nil
    }
}

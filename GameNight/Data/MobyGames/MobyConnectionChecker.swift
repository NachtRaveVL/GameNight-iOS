// SPDX-License-Identifier: GPL-3.0-or-later

/// Shares the catalog client's limiter and transport; loading settings never calls this.
struct MobyConnectionChecker: MobyConnectionChecking {
    let client: MobyAPIClient

    func checkConnection() async throws {
        _ = try await client.send(MobyRequests.platforms())
    }
}

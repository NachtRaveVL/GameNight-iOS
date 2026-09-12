// SPDX-License-Identifier: GPL-3.0-or-later

struct StubPage {
    let id: String
    let title: String
    let systemImage: String
    let summary: String
    let plannedWork: [String]
    let links: [StubLink]
}

struct StubLink: Identifiable {
    let id: String
    let title: String
    let systemImage: String
    let intent: NavigationIntent
}

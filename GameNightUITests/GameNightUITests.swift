// SPDX-License-Identifier: GPL-3.0-or-later

import XCTest

final class GameNightUITests: XCTestCase {
    @MainActor
    func testWelcomeCanBeDismissedAndAllTabsAreReachable() {
        let app = XCUIApplication()
        app.launch()

        let close = app.buttons["sheet.close"]
        XCTAssertTrue(close.waitForExistence(timeout: 5))
        close.tap()

        for title in ["Discover", "Explore", "Backlog", "Played", "Profile"] {
            let tab = app.tabBars.buttons[title]
            XCTAssertTrue(tab.waitForExistence(timeout: 3))
            tab.tap()
            XCTAssertTrue(app.staticTexts["Work in progress"].waitForExistence(timeout: 3))
        }
    }

    @MainActor
    func testOnboardingUsesItsOwnNavigationStack() {
        let app = XCUIApplication()
        app.launch()

        let setup = app.buttons["onboarding.consoles"]
        XCTAssertTrue(setup.waitForExistence(timeout: 5))
        for _ in 0..<4 where !setup.isHittable {
            app.swipeUp()
        }
        setup.tap()
        XCTAssertTrue(app.navigationBars["Your consoles"].waitForExistence(timeout: 3))
        app.navigationBars.buttons.element(boundBy: 0).tap()
        app.buttons["sheet.close"].tap()

        XCTAssertTrue(app.navigationBars["Discover"].waitForExistence(timeout: 3))
    }
}

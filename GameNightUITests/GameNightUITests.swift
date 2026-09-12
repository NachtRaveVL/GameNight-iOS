// SPDX-License-Identifier: GPL-3.0-or-later

import XCTest

final class GameNightUITests: XCTestCase {
    @MainActor
    func testAppOpensWithoutSetupAndAllTabsAreReachable() {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.tabBars.buttons["Discover"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["sheet.close"].exists)

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

        let profile = app.tabBars.buttons["Profile"]
        XCTAssertTrue(profile.waitForExistence(timeout: 5))
        profile.tap()
        let welcome = app.buttons["profile.onboarding"]
        for _ in 0..<8 where !welcome.isHittable { app.swipeUp() }
        XCTAssertTrue(welcome.isHittable)
        welcome.tap()

        let setup = app.buttons["onboarding.consoles"]
        XCTAssertTrue(setup.waitForExistence(timeout: 5))
        for _ in 0..<4 where !setup.isHittable {
            app.swipeUp()
        }
        setup.tap()
        XCTAssertTrue(app.navigationBars["Your consoles"].waitForExistence(timeout: 3))
        app.navigationBars.buttons.element(boundBy: 0).tap()
        app.buttons["sheet.close"].tap()

        XCTAssertTrue(app.navigationBars["Profile"].waitForExistence(timeout: 3))
    }
}

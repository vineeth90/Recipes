//
//  RecipesUITests.swift
//  RecipesUITests
//
//  Created by Vineeth M on 30/3/2026.
//

import XCTest

final class RecipesUITests: XCTestCase {
    override func setUpWithError() throws {
        try super.setUpWithError()
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        XCUIDevice.shared.orientation = .portrait
        try super.tearDownWithError()
    }

    @MainActor
    func testPortraitMode_displaysRecipeDetailsWithCorrectContent() throws {
        // Given
        let app = launchApp(in: .portrait)
        let title = app.staticTexts["recipeDetail.title"]
        let description = app.staticTexts["recipeDetail.description"]
        let ingredientsHeader = app.staticTexts["recipeDetail.ingredientsHeader"]

        // When
        XCTAssertTrue(
            title.waitForExistence(timeout: 5),
            "Expected the recipe title to appear in portrait mode."
        )

        // Then
        XCTAssertEqual(
            title.label,
            "Curtis Stone's tomato and bread salad with BBQ eggplant and capsicum"
        )
        XCTAssertEqual(
            description.label,
            "For a crowd-pleasing salad, try this tasty combination of fresh tomato, crunchy bread and BBQ veggies. It’s topped with fresh basil and oregano for a finishing touch. "
        )
        XCTAssertTrue(ingredientsHeader.exists)
        XCTAssertTrue(app.staticTexts["Serves 8 People"].exists)
        XCTAssertTrue(app.staticTexts["Prep time: 15m"].exists)
        XCTAssertTrue(app.staticTexts["Cooking time: 15m"].exists)
        XCTAssertTrue(app.staticTexts["1 cup (250ml) extra virgin olive oil, divided"].exists)
    }

    @MainActor
    func testLandscapeMode_displaysRecipeGridWithCorrectContent() throws {
        // Given
        let app = launchApp(in: .portrait)
        let detailTitle = app.staticTexts["recipeDetail.title"]
        let gridContainer = app.scrollViews["recipeGrid.container"]
        let firstRecipeTitle = app.staticTexts["recipeCard.title.Curtis Stone's tomato and bread salad with BBQ eggplant and capsicum"]
        let secondRecipeTitle = app.staticTexts["recipeCard.title.Pork, fennel and sage ragu with polenta"]
        let thirdRecipeTitle = app.staticTexts["recipeCard.title.Apple and kale panzanella"]

        // When
        XCTAssertTrue(
            detailTitle.waitForExistence(timeout: 5),
            "Expected the recipe detail screen to appear before rotating."
        )
        XCUIDevice.shared.orientation = .landscapeLeft
        XCTAssertTrue(
            gridContainer.waitForExistence(timeout: 5),
            "Expected the recipe grid to appear after rotating to landscape mode."
        )

        // Then
        XCTAssertTrue(firstRecipeTitle.exists)
        XCTAssertTrue(secondRecipeTitle.exists)
        XCTAssertTrue(thirdRecipeTitle.exists)
        XCTAssertFalse(app.staticTexts["recipeDetail.title"].exists)
    }
}

private extension RecipesUITests {
    @MainActor
    func launchApp(in orientation: UIDeviceOrientation) -> XCUIApplication {
        XCUIDevice.shared.orientation = orientation

        let app = XCUIApplication()
        app.launch()

        // Re-apply orientation after launch to avoid simulator defaults overriding the test setup.
        XCUIDevice.shared.orientation = orientation
        return app
    }
}

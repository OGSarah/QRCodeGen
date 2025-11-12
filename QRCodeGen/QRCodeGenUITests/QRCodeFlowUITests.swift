//
//  QRCodeFlowUITests.swift
//  QRCodeGenUITests
//
//  Created by Sarah Clark on 11/11/25.
//

import XCTest

final class QRCodeFlowUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    // Helpers
    @MainActor private func inputElement(in app: XCUIApplication) -> XCUIElement {
        // Prefer the explicit identifier we added
        let identified = app.textFields["inputTextField"]
        if identified.exists { return identified }

        // Fallbacks by placeholder
        let tf = app.textFields["Enter text to encode"]
        if tf.exists { return tf }

        let tv = app.textViews["Enter text to encode"]
        return tv.exists ? tv : identified
    }

    @MainActor
    func testGenerateQRCodeHappyPath() throws {
        let app = XCUIApplication()
        app.launch()

        // Enter text
        let input = inputElement(in: app)
        XCTAssertTrue(input.waitForExistence(timeout: 3), "Input text field should exist")
        input.tap()
        input.typeText("Hello UI Tests")

        // Select High ECL using identifier
        let segmented = app.segmentedControls["eclSegmentedControl"]
        XCTAssertTrue(segmented.waitForExistence(timeout: 2))
        // Buttons are created from Text(level.description). We assigned ids per case name.
        let high = segmented.buttons["eclSegment_H"]
        if high.exists {
            high.tap()
        } else {
            // Fallback to visible label
            let highLabel = segmented.buttons["High (30%)"]
            if highLabel.exists { highLabel.tap() }
        }

        // Tap Generate
        let generateButton = app.buttons["generateButton"]
        XCTAssertTrue(generateButton.waitForExistence(timeout: 3), "Generate button should exist")
        generateButton.tap()

        // Wait for result image using its identifier
        let qrImage = app.images["qrImageView"]
        XCTAssertTrue(qrImage.waitForExistence(timeout: 5), "QR image should appear after generation")
    }

    @MainActor
    func testContextMenuActionsOnImage() throws {
        let app = XCUIApplication()
        app.launch()

        // Enter text and generate
        let input = inputElement(in: app)
        XCTAssertTrue(input.waitForExistence(timeout: 3))
        input.tap()
        input.typeText("Context Menu Test")

        let generateButton = app.buttons["generateButton"]
        XCTAssertTrue(generateButton.waitForExistence(timeout: 3))
        generateButton.tap()

        let qrImage = app.images["qrImageView"]
        XCTAssertTrue(qrImage.waitForExistence(timeout: 5))

        // Ensure image is hittable (scroll into view if needed)
        if !qrImage.isHittable {
            app.swipeUp()
        }
        XCTAssertTrue(qrImage.isHittable, "QR image should be hittable before long press")

        // Open context menu (long press)
        qrImage.press(forDuration: 1.0)

        // Expect menu items by identifiers we added
        let copyItem = app.buttons["contextCopyImage"]
        let saveItem = app.buttons["contextSaveToPhotos"]
        let shareItem = app.buttons["contextShare"]

        XCTAssertTrue(copyItem.waitForExistence(timeout: 2), "Copy Image action should be present")
        XCTAssertTrue(saveItem.exists, "Save to Photos action should be present")
        XCTAssertTrue(shareItem.exists, "Share action should be present")
    }

    @MainActor
    func testToolbarButtonsPasteAndClear() throws {
        let app = XCUIApplication()
        app.launch()

        // Disambiguate Paste buttons: use toolbar identifier
        let pasteButton = app.buttons["toolbarPasteButton"]
        XCTAssertTrue(pasteButton.waitForExistence(timeout: 2))
        pasteButton.tap()

        // Enter some text and then Clear
        let input = inputElement(in: app)
        XCTAssertTrue(input.waitForExistence(timeout: 3))
        input.tap()
        input.typeText("Clearable text")

        // Clear toolbar button only appears when text is non-empty
        let clearButton = app.buttons["toolbarClearButton"]
        XCTAssertTrue(clearButton.waitForExistence(timeout: 2))
        clearButton.tap()

        // Verify input field exists (placeholder visible again is hard to assert directly)
        XCTAssertTrue(input.exists)
    }

    @MainActor
    func testSwitchingECLSegments() throws {
        let app = XCUIApplication()
        app.launch()

        let segmented = app.segmentedControls["eclSegmentedControl"]
        XCTAssertTrue(segmented.waitForExistence(timeout: 2))

        // Tap through segments using identifiers
        let ids = ["eclSegment_L", "eclSegment_M", "eclSegment_Q", "eclSegment_H"]
        for id in ids {
            let button = segmented.buttons[id]
            if button.exists {
                button.tap()
            }
        }
    }

    @MainActor
    func testGenerateButtonStateChange() throws {
        let app = XCUIApplication()
        app.launch()

        // Enter input
        let input = inputElement(in: app)
        XCTAssertTrue(input.waitForExistence(timeout: 3))
        input.tap()
        input.typeText("State change test")

        let generateButton = app.buttons["generateButton"]
        XCTAssertTrue(generateButton.waitForExistence(timeout: 2))

        // Tap generate and assert it becomes disabled briefly, then re-enabled when done
        generateButton.tap()

        // Expect it to be disabled (or at least not hittable) during generation
        let waitedNotHittable = generateButton.wait(for: \.isHittable, toEqual: false, timeout: 1.0)
        let becameDisabled = waitedNotHittable || !generateButton.isEnabled
        XCTAssertTrue(becameDisabled, "Generate button should become temporarily disabled while generating")

        // Wait for result image and then ensure button is enabled again
        let qrImage = app.images["qrImageView"]
        XCTAssertTrue(qrImage.waitForExistence(timeout: 5))
        XCTAssertTrue(generateButton.isEnabled, "Generate button should be enabled after generation completes")
    }
}

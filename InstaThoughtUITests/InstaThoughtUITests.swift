//
//  InstaThoughtUITests.swift
//  InstaThoughtUITests
//
//  A slow, watchable tour of every flow with real taps. Run it while recording the
//  simulator to get a walkthrough video; it also works as an end-to-end smoke test.
//
//  The tour resets Photos permission and the saved draft itself, so tests can run in any order.
//

import XCTest

final class InstaThoughtUITests: XCTestCase {
  private let app = XCUIApplication()
  private let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")

  override func setUp() {
    continueAfterFailure = false
    XCUIDevice.shared.appearance = .light
  }

  override func tearDown() {
    XCUIDevice.shared.appearance = .light
  }

  @MainActor
  func testCloudTour() throws {
    // Start clean whatever ran before: Photos permission undecided and an empty draft
    // (the "editor" screenshot scene clears the saved draft and changes nothing else).
    app.resetAuthorizationStatus(for: .photos)
    app.launchArguments = ["-screenshotScene", "editor"]
    app.launch()
    pause(1.5)

    // Editor: write a thought, then browse the inspiration passages.
    let bubble = app.textViews.firstMatch
    tap(bubble)
    bubble.typeText("Rain on the windows, the kettle going, nowhere to be until noon.")
    pause(1)
    tap(app.buttons["Done"])

    tap(button(containing: "Ideas"))
    app.scrollViews.firstMatch.swipeUp()
    pause(0.8)
    tap(app.scrollViews.firstMatch.buttons.element(boundBy: 2))

    // Style
    tap(app.buttons["Make it a page"])
    pause(1.5)
    // Font chooser: jump down the letter rail, star a font, then search for one and pick it.
    tap(app.buttons["Choose font"])
    pause(1)
    let rail = app.otherElements["Jump to letter"]
    XCTAssertTrue(rail.waitForExistence(timeout: 5))
    rail.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.1))
      .press(forDuration: 0.1, thenDragTo: rail.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.6)))
    pause(1.2)
    // Star whichever font the rail landed on, then pick the one below it.
    let stars = app.buttons.matching(NSPredicate(format: "label BEGINSWITH 'Star '")).allElementsBoundByIndex.filter(\.isHittable)
    XCTAssertGreaterThan(stars.count, 1, "The letter rail should leave fonts in view")
    tap(stars[0])
    let picked = String(stars[1].label.dropFirst("Star ".count))
    tap(app.buttons[picked])
    pause(1.2)
    tap(app.textFields.firstMatch)
    app.textFields.firstMatch.typeText("source")
    pause(1)
    tap(app.buttons["Source Sans 3"])
    pause(1.2)
    tap(app.buttons["Done"])
    tap(app.buttons["Increase Size"])
    tap(app.buttons["Increase Size"])
    tap(app.buttons["Increase Line spacing"])
    tap(app.buttons["Center"])

    tap(app.buttons["Color"])
    tap(app.buttons["Background color"])
    pause(1)
    tap(app.buttons["Violet 1"])
    tap(app.buttons["Teal 0"])
    pause(1)
    tap(app.buttons["Done"])

    tap(app.buttons["Layout"])
    tap(button(containing: "Square"))
    tap(button(containing: "Insta"))

    tap(app.buttons["Presets"])
    tap(presets.element(boundBy: 2))
    tap(button(containing: "See all"))
    app.swipeUp()
    pause(0.8)
    tap(presets.element(boundBy: 13))
    XCTAssertTrue(app.buttons["Done"].waitForNonExistence(timeout: 3), "Choosing a preset should close the Presets sheet")
    pause(1)

    // Preview: swipe through, save (allowing Photos access), share.
    tap(app.buttons["Preview"])
    pause(1.5)
    app.swipeLeft()
    pause(1)
    app.swipeLeft()
    pause(1)
    tap(button(containing: "Save to Photos"))
    answerPhotosPrompt(allow: true)
    XCTAssertTrue(app.descendants(matching: .any).matching(NSPredicate(format: "label BEGINSWITH 'Saved'")).firstMatch.waitForExistence(timeout: 5))
    pause(2.5)

    tap(button(containing: "Share"))
    pause(3)
    dismissShareSheet()

    // Back out: the back button, then a swipe from the left edge.
    tap(app.buttons["Back"])
    XCTAssertTrue(app.buttons["Presets"].waitForExistence(timeout: 3), "Back from Preview should land on Style")
    pause(1)
    swipeBack()
    XCTAssertTrue(app.buttons["Make it a page"].waitForExistence(timeout: 3), "Edge swipe should go back to the editor")
    pause(1.5)

    // Photos access off: reset the permission (this quits the app), relaunch, which
    // restores the draft, then save and decline.
    app.resetAuthorizationStatus(for: .photos)
    app.launchArguments = []
    app.launch()
    pause(2)
    tap(app.buttons["Make it a page"])
    pause(1.5)
    tap(app.buttons["Preview"])
    pause(1.5)
    tap(button(containing: "Save to Photos"))
    answerPhotosPrompt(allow: false)
    XCTAssertTrue(app.staticTexts["Photos access is off"].waitForExistence(timeout: 5))
    pause(3)
    tap(app.buttons["Not now"])

    // Dark mode
    XCUIDevice.shared.appearance = .dark
    pause(2.5)
    tap(app.buttons["Back"])
    pause(1.5)
    tap(app.buttons["Presets"])
    pause(1.5)
    tap(app.buttons["Back"])
    pause(1.5)
    tap(button(containing: "Ideas"))
    pause(1.5)
    tap(app.buttons["Close"])
    pause(1.5)
  }

  /// Picking an inspiration sample brings its own look with it, not just its words.
  @MainActor
  func testSampleAppliesItsStyle() throws {
    app.launchArguments = ["-screenshotScene", "editor"]
    app.launch()
    tap(button(containing: "Ideas"))
    let sonnet = button(containing: "Sonnet 18")
    for _ in 0..<12 where !sonnet.isHittable {
      app.scrollViews.firstMatch.swipeUp()
    }
    tap(sonnet)
    tap(app.buttons["Make it a page"])
    let fontRow = app.buttons["Choose font"]
    XCTAssertTrue(fontRow.waitForExistence(timeout: 5))
    XCTAssertEqual(fontRow.value as? String, "Slabo 27px", "Sonnet 18 opens in its preset's font")
  }

  /// Back from Preview lands on Style, with and without opening the share sheet first.
  @MainActor
  func testBackFromPreview() throws {
    app.launchArguments = ["-screenshotScene", "preview"]
    app.launch()
    XCTAssertTrue(button(containing: "Save to Photos").waitForExistence(timeout: 15))
    tap(app.buttons["Back"])
    XCTAssertTrue(app.buttons["Presets"].waitForExistence(timeout: 3), "Back from Preview should land on Style")
  }

  @MainActor
  func testBackFromPreviewAfterShare() throws {
    app.launchArguments = ["-screenshotScene", "preview"]
    app.launch()
    XCTAssertTrue(button(containing: "Save to Photos").waitForExistence(timeout: 15))
    tap(button(containing: "Share"))
    pause(2)
    dismissShareSheet()
    tap(app.buttons["Back"])
    XCTAssertTrue(app.buttons["Presets"].waitForExistence(timeout: 3), "Back after sharing should land on Style")
  }

  @MainActor
  func testBackFromPreviewAfterSave() throws {
    app.launchArguments = ["-screenshotScene", "preview"]
    app.launch()
    XCTAssertTrue(button(containing: "Save to Photos").waitForExistence(timeout: 15))
    tap(button(containing: "Save to Photos"))
    answerPhotosPrompt(allow: true)
    pause(3)
    tap(app.buttons["Back"])
    XCTAssertTrue(app.buttons["Presets"].waitForExistence(timeout: 3), "Back after saving should land on Style")
  }

  /// Swiping from the left edge goes back, even though the navigation bar is hidden.
  @MainActor
  func testSwipeBackFromStyle() throws {
    app.launchArguments = ["-screenshotScene", "style"]
    app.launch()
    XCTAssertTrue(app.buttons["Presets"].waitForExistence(timeout: 15))
    pause(1)
    swipeBack()
    XCTAssertTrue(app.buttons["Make it a page"].waitForExistence(timeout: 3), "Edge swipe should go back to the editor")
  }

  // MARK: - Helpers

  private func swipeBack() {
    // Across the top bar, clear of the sideways-scrolling page carousel.
    app.coordinate(withNormalizedOffset: CGVector(dx: 0.0, dy: 0.14))
      .press(forDuration: 0.02, thenDragTo: app.coordinate(withNormalizedOffset: CGVector(dx: 0.98, dy: 0.14)),
             withVelocity: XCUIGestureVelocity(2000), thenHoldForDuration: 0)
    pause(1)
  }

  private func pause(_ seconds: TimeInterval) {
    Thread.sleep(forTimeInterval: seconds)
  }

  /// Waits for the element, taps it, and leaves a beat so the video is easy to follow.
  private func tap(_ element: XCUIElement, file: StaticString = #filePath, line: UInt = #line) {
    XCTAssertTrue(element.waitForExistence(timeout: 8), "Missing: \(element)", file: file, line: line)
    element.tap()
    pause(0.9)
  }

  private var presets: XCUIElementQuery {
    app.buttons.matching(NSPredicate(format: "label == 'Preset'"))
  }

  private func button(containing text: String) -> XCUIElement {
    app.buttons.matching(NSPredicate(format: "label CONTAINS %@", text)).firstMatch
  }

  private func dismissSheet() {
    let top = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.62))
    top.press(forDuration: 0.05, thenDragTo: app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.99)))
    pause(1)
  }

  private func dismissShareSheet() {
    let close = app.buttons.matching(NSPredicate(format: "label == 'Close' OR identifier == 'Close'")).firstMatch
    if close.waitForExistence(timeout: 2) {
      close.tap()
    } else {
      dismissSheet()
    }
    pause(1)
  }

  /// Answers the system "Add to Photos" prompt, which belongs to SpringBoard.
  private func answerPhotosPrompt(allow: Bool) {
    let predicate = allow
      ? NSPredicate(format: "label == 'Allow' OR label BEGINSWITH 'Allow'")
      : NSPredicate(format: "label BEGINSWITH 'Don'")
    let answer = springboard.buttons.matching(predicate).firstMatch
    if answer.waitForExistence(timeout: 5) {
      pause(1.2)
      answer.tap()
    }
  }
}

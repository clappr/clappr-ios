import XCTest

class PlayerViewElements {
    let container: XCUIElement
    let fullscreenButton: XCUIElement
    let playPosterButton: XCUIElement

    init(app: XCUIApplication) {
        playPosterButton = app.buttons["PlayPosterButton"]
        container = app.otherElements["Container"]
        fullscreenButton = app.buttons["FullscreenButton"]
    }
}

import XCTest

class PlayerViewElements {
    let container: XCUIElement
    let fullscreenButton: XCUIElement
    let play: XCUIElement

    init(app: XCUIApplication) {
        container = app.otherElements["Container"]
        fullscreenButton = app.buttons["FullscreenButton"]
        play = app.buttons["ClapprPlayButton"]
    }
}

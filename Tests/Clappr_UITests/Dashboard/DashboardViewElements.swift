import XCTest

class DashboardViewElements {
    let playButton: XCUIElement
    let startAsFullscreen: XCUIElement

    init(app: XCUIApplication) {
        playButton = app.buttons["StartVideo"]
        startAsFullscreen = app.switches["StartAsFullscreen"]
    }
}

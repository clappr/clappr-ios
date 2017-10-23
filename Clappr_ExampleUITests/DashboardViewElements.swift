import XCTest

class DashboardViewElements {
    let playButton: XCUIElement
    let startAsFullscreen: XCUIElement
    let fullscreenControledByApp: XCUIElement

    init(app: XCUIApplication) {
        playButton = app.buttons["StartVideo"]
        startAsFullscreen = app.switches["StartAsFullscreen"]
        fullscreenControledByApp = app.switches["FullscreenControledByApp"]
    }
}

import XCTest

class PlayerViewInteractor {

    var elements: PlayerViewElements

    var containerFrame: CGRect {
        return elements.container.frame
    }

    init(app: XCUIApplication) {
        elements = PlayerViewElements(app: app)
    }

    func tapOnContainer() {
        elements.container.tap()
    }

    func tapOnFullscreen() {
        if XCTWaiter().waitFor(element: elements.fullscreenButton) {
            elements.fullscreenButton.tap()
        }
    }
}

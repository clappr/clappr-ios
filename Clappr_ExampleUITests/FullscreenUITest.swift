import XCTest

class FullscreenUITest: XCTestCase {

    var dashboardInteractor: DashboardViewInteractor!
    var app: XCUIApplication!

    var container: XCUIElement {
        return app.otherElements["Container"]
    }

    var window: XCUIElement {
        return app.windows.element(boundBy: 0)
    }

    var fullscreenButton: XCUIElement {
        return app.buttons["FullscreenButton"]
    }

    override func setUp() {
        super.setUp()
        app = XCUIApplication()
        app.launch()
        dashboardInteractor = DashboardViewInteractor(app: app)
    }

    override func tearDown() {
        super.tearDown()
    }

    func testPlayerShouldHaveTheSameSizeOfWindow() {
        dashboardInteractor.fullscreenControledByApp = false
        dashboardInteractor.startAsFullscreen = true
        dashboardInteractor.startVideo()
        XCTAssert(container.frame == window.frame)
    }

    func testPlayerShouldNotHaveTheSizeOfWindow() {
        dashboardInteractor.fullscreenControledByApp = true
        dashboardInteractor.startAsFullscreen = true
        dashboardInteractor.startVideo()
        XCTAssert(container.frame != window.frame)
    }

    func testPlayerShouldNotChangeTheLayerSizeWhenStartAsFullscreenIsDisabled() {
        dashboardInteractor.fullscreenControledByApp = true
        dashboardInteractor.startAsFullscreen = false
        dashboardInteractor.startVideo()

        let currentFrame = container.frame
        container.tap()
        fullscreenButton.tap()
        XCTAssert(currentFrame == container.frame)
    }

    func testPlayerShouldNotChangeTheLayerSizeWhenStartAsFullscreenIsEnabled() {
        dashboardInteractor.fullscreenControledByApp = true
        dashboardInteractor.startAsFullscreen = true
        dashboardInteractor.startVideo()

        let currentFrame = container.frame
        container.tap()
        fullscreenButton.tap()
        XCTAssert(currentFrame == container.frame)
    }
}

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

    override func setUp() {
        super.setUp()
        app = XCUIApplication()
        app.launch()
        dashboardInteractor = DashboardViewInteractor(app: app)
    }

    override func tearDown() {
        super.tearDown()
    }

    func testStartAsFullscreen() {
        dashboardInteractor.fullscreenControledByApp = false
        dashboardInteractor.startAsFullscreen = true
        dashboardInteractor.startVideo()
        XCTAssert(container.frame == window.frame)
    }

    func testStartAsFullscreenWithFullscreenControledByApp() {
        dashboardInteractor.fullscreenControledByApp = true
        dashboardInteractor.startAsFullscreen = true
        dashboardInteractor.startVideo()
        XCTAssert(container.frame != window.frame)
    }

    func 
    
}

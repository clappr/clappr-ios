import XCTest

class FullscreenUITest: XCTestCase {

    var dashboardInteractor: DashboardViewInteractor!
    var app: XCUIApplication!

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

        let container = app.otherElements["Container"]
        let window = app.windows.element(boundBy: 0)
        XCTAssert(container.frame == window.frame)
    }
    
}

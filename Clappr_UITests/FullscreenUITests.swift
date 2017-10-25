import XCTest
import Quick
import Nimble

class FullscreenUITests: QuickSpec {
    override func spec() {

        var dashboardInteractor: DashboardViewInteractor!
        var playerInteractor: PlayerViewInteractor!
        var app: XCUIApplication!

        var window: XCUIElement {
            return app.windows.element(boundBy: 0)
        }

        describe("Fullscreen") {

            context("start as fullscreen") {

                beforeEach {
                    app = XCUIApplication()
                    app.launch()

                    dashboardInteractor = DashboardViewInteractor(app: app)
                    dashboardInteractor.startAsFullscreen = true

                    playerInteractor = PlayerViewInteractor(app: app)
                }

                it("player should have the same size of window") {
                    dashboardInteractor.fullscreenControledByApp = false
                    dashboardInteractor.startVideo()

                    XCTAssert(playerInteractor.containerFrame == window.frame)
                }

                it("player should not have the same size of window ") {
                    dashboardInteractor.fullscreenControledByApp = true
                    dashboardInteractor.startVideo()

                    XCTAssert(playerInteractor.containerFrame != window.frame)
                }
            }

            context("fullscreen controled by app") {

                beforeEach {
                    app = XCUIApplication()
                    app.launch()

                    dashboardInteractor = DashboardViewInteractor(app: app)
                    dashboardInteractor.fullscreenControledByApp = true

                    playerInteractor = PlayerViewInteractor(app: app)
                }

                it("player should not change the container size when taps on fullscreen button") {
                    dashboardInteractor.startAsFullscreen = false
                    dashboardInteractor.startVideo()

                    let currentFrame = playerInteractor.containerFrame
                    playerInteractor.tapOnContainer()
                    playerInteractor.tapOnFullscreen()
                    
                    XCTAssert(currentFrame == playerInteractor.containerFrame)
                }

                it("player should not change the container size when taps on fullscreen button") {
                    dashboardInteractor.startAsFullscreen = true
                    dashboardInteractor.startVideo()

                    let currentFrame = playerInteractor.containerFrame
                    playerInteractor.tapOnContainer()
                    playerInteractor.tapOnFullscreen()

                    XCTAssert(currentFrame == playerInteractor.containerFrame)
                }
            }
        }
    }
}

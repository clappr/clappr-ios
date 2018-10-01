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

        describe(".Fullscreen") {

            beforeEach {
                app = XCUIApplication()
                app.launch()
                XCUIDevice.shared.orientation = .portrait

                dashboardInteractor = DashboardViewInteractor(app: app)
                playerInteractor = PlayerViewInteractor(app: app)
            }

            afterEach {
                app.terminate()
            }

            describe("when the option of start as fullscreen is passed") {
                context("when fullscreen is controled by the app") {
                    it("doesn't sets fullscreen mode on player") {
                        dashboardInteractor.startAsFullscreen = true
                        dashboardInteractor.fullscreenControledByApp = true

                        dashboardInteractor.startVideo()

                        expect(playerInteractor.containerFrame != window.frame).toEventually(beTrue())
                    }
                }
            }
        }
    }
}

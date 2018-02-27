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

            context("when the option of start as fullscreen is passed") {

                beforeEach {
                    dashboardInteractor.startAsFullscreen = true
                }

                context("when fullscreen is controled by the player") {
                    it("sets the player as fullscreen") {
                        dashboardInteractor.fullscreenControledByApp = false

                        dashboardInteractor.startVideo()

                        expect(playerInteractor.containerFrame == window.frame).toEventually(beTrue())
                    }
                }

                context("when fullscreen is controled by the app") {
                    it("doesn't sets fullscreen mode on player") {
                        dashboardInteractor.fullscreenControledByApp = true

                        dashboardInteractor.startVideo()

                        expect(playerInteractor.containerFrame != window.frame).toEventually(beTrue())
                    }
                }
            }

            context("when the option of fullscreen controled by app is passed") {

                beforeEach {
                    playerInteractor = PlayerViewInteractor(app: app)
                }

                context("and user taps on fullscreen button") {

                    it("sets the player as fullscreen") {
                        dashboardInteractor.fullscreenControledByApp = true

                        dashboardInteractor.startVideo()
                        playerInteractor.tapOnContainer()
                        playerInteractor.tapOnFullscreen()

                        expect(playerInteractor.containerFrame == window.frame).toEventually(beTrue())
                    }
                }

                context("and user taps on fullscreen button after a previous tap") {
                    it("sets the player as embed mode") {
                        dashboardInteractor.fullscreenControledByApp = true

                        dashboardInteractor.startVideo()
                        playerInteractor.tapOnContainer()
                        playerInteractor.tapOnFullscreen()
                        playerInteractor.tapOnFullscreen()

                        expect(playerInteractor.containerFrame != window.frame).toEventually(beTrue())
                    }
                }
            }
        }
    }
}

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

            context("setFullscreen") {
                it("player should set to fullscreen when setFullscreen is called") {
                    dashboardInteractor.startAsFullscreen = false
                    dashboardInteractor.fullscreenControledByApp = false

                    dashboardInteractor.startVideo()
                    playerInteractor.tapOnContainer()
                    XCUIDevice.shared.orientation = .landscapeLeft

                    expect(playerInteractor.containerFrame == window.frame).to(beTrue())
                }
            }

            context("start as fullscreen") {

                beforeEach {
                    dashboardInteractor.startAsFullscreen = true
                }

                it("player should have the same size of window") {
                    dashboardInteractor.fullscreenControledByApp = false

                    dashboardInteractor.startVideo()

                    expect(playerInteractor.containerFrame == window.frame).to(beTrue())
                }

                it("player should not have the same size of window ") {
                    dashboardInteractor.fullscreenControledByApp = true

                    dashboardInteractor.startVideo()

                    expect(playerInteractor.containerFrame != window.frame).to(beTrue())
                }
            }

            context("fullscreen controled by app") {

                beforeEach {
                    playerInteractor = PlayerViewInteractor(app: app)
                }

                it("player should not change the container size when taps on fullscreen button") {
                    dashboardInteractor.startAsFullscreen = false

                    dashboardInteractor.startVideo()
                    let currentFrame = playerInteractor.containerFrame
                    playerInteractor.tapOnContainer()
                    playerInteractor.tapOnFullscreen()
                    
                    expect(currentFrame == playerInteractor.containerFrame).to(beTrue())
                }

                it("player should not change the container size when taps on fullscreen button") {
                    dashboardInteractor.startAsFullscreen = true

                    dashboardInteractor.startVideo()
                    let currentFrame = playerInteractor.containerFrame
                    playerInteractor.tapOnContainer()
                    playerInteractor.tapOnFullscreen()

                    expect(currentFrame == playerInteractor.containerFrame).to(beTrue())
                }
            }
        }
    }
}

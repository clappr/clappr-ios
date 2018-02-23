import XCTest
import Quick
import Nimble

class FullscreenUITests: BaseSpec {

    override func spec() {
        super.spec()

        var window: XCUIElement {
            return app.windows.element(boundBy: 0)
        }

        describe(".Fullscreen") {

            beforeEach {
                XCUIDevice.shared.orientation = .portrait
            }

            context("when the option of start as fullscreen is passed") {

                beforeEach {
                    self.dashboard.startAsFullscreen = true
                }

                context("when fullscreen is controled by the player") {
                    it("sets the player as fullscreen") {
                        self.dashboard.fullscreenControledByApp = false

                        self.dashboard.startVideo()

                        expect(self.player.containerFrame == window.frame).toEventually(beTrue())
                    }
                }

                context("when fullscreen is controled by the app") {
                    it("doesn't sets fullscreen mode on player") {
                        self.dashboard.fullscreenControledByApp = true

                        self.dashboard.startVideo()

                        expect(self.player.containerFrame != window.frame).toEventually(beTrue())
                    }
                }
            }

            context("when the option of fullscreen controled by app is passed") {

                context("and user taps on fullscreen button") {

                    it("sets the player as fullscreen") {
                        self.dashboard.fullscreenControledByApp = true

                        self.dashboard.startVideo()
                        self.player.tapOnContainer()
                        self.player.tapOnFullscreen()

                        expect(self.player.containerFrame == window.frame).toEventually(beTrue())
                    }
                }

                context("and user taps on fullscreen button after a previous tap") {
                    it("sets the player as embed mode") {
                        self.dashboard.fullscreenControledByApp = true

                        self.dashboard.startVideo()
                        self.player.tapOnContainer()
                        self.player.tapOnFullscreen()
                        self.player.tapOnFullscreen()

                        expect(self.player.containerFrame != window.frame).toEventually(beTrue())
                    }
                }
            }
        }
    }
}

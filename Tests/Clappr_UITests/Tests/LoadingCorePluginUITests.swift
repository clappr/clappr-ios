import XCTest
import Quick
import Nimble

class LoadingCorePluginUITests: BaseSpec {

    override func spec() {
        super.spec()

        describe(".SpinnerPlugin") {

            it("shows the spinner when the player is initialized") {
                self.dashboard.fullscreenControledByApp = false
                self.dashboard.startAsFullscreen = false

                self.dashboard.startVideo()
                self.player.tapOnContainer()

                expect(self.app.otherElements["LoadingCorePlugin"].exists).toEventually(beTrue())
            }

            it("hides the spinner when the video starts") {
                self.dashboard.fullscreenControledByApp = false
                self.dashboard.startAsFullscreen = false

                self.dashboard.startVideo()
                self.player.tapOnContainer()

                self.waitVOD { done in
                    expect(self.app.otherElements["LoadingCorePlugin"].exists).toEventually(beFalse())
                    done()
                }
            }
        }
    }
}

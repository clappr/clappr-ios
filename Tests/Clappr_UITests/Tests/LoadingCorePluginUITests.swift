import XCTest
import Quick
import Nimble

class LoadingCorePluginUITests: BaseSpec {

    override func spec() {
        super.spec()

        beforeEach {
            XCUIDevice.shared.orientation = .portrait
        }

        describe(".SpinnerPlugin") {
            it("shows the spinner when the player is initialized") {
                self.dashboard.fullscreenControledByApp = false

                self.dashboard.startVideo()
                self.player.tapOnContainer()
                self.player.tapOnFullscreen()

                expect(self.app.otherElements["LoadingCorePlugin"].exists).toEventually(beTrue())
            }

            it("hides the spinner when the video starts") {
                self.dashboard.fullscreenControledByApp = false

                self.dashboard.startVideo()
                self.player.tapOnContainer()
                self.player.tapOnPlay()

                self.waitVOD { done in
                    expect(self.app.otherElements["LoadingCorePlugin"].exists).to(beFalse())
                    done()
                }
            }
        }
    }
}

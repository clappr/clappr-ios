import Quick
import Nimble
@testable import Clappr

class FullscreenStateHandlerTests: QuickSpec {

    override func spec() {
        describe("FullscreenHandler") {

            context("when fullscreen is done by app") {

                it("should set property `fullscreen` of mediaControll to `true`") {
                    let core = Core(options: [kFullscreenByApp: true] as Options)
                    core.mediaControl?.fullscreen = false
                    core.fullscreenHandler.enterInFullscreen([:])
                    expect(core.mediaControl?.fullscreen).to(beTrue())
                }

                it("should set property `fullscreen` of mediaControll to `false`") {
                    let core = Core(options: [kFullscreenByApp: true] as Options)
                    core.mediaControl?.fullscreen = true
                    core.fullscreenHandler.exitFullscreen([:])
                    expect(core.mediaControl?.fullscreen).to(beFalse())
                }
            }

            context("when fullscreen is done by player") {

                it("should set property `fullscreen` of mediaControll to `true`") {
                    let core = Core()
                    core.mediaControl?.fullscreen = false
                    core.fullscreenHandler.enterInFullscreen([:])
                    expect(core.mediaControl?.fullscreen).to(beTrue())
                }

                it("should set property `fullscreen` of mediaControll to `false`") {
                    let core = Core()
                    core.mediaControl?.fullscreen = true
                    core.fullscreenHandler.exitFullscreen([:])
                    expect(core.mediaControl?.fullscreen).to(beFalse())
                }
            }
        }
    }
}

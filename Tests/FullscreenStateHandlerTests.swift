import Quick
import Nimble
@testable import Clappr

class FullscreenStateHandlerTests: QuickSpec {

    override func spec() {
        describe("FullscreenHandler") {

            context("when fullscreen is done by app") {

                var core: Core!

                beforeEach {
                    core = Core(options: [kFullscreenByApp: true] as Options)
                }

                it("should set property `fullscreen` of mediaControll to `true` when player enter in fullscreen mode") {
                    core.mediaControl?.fullscreen = false
                    core.fullscreenHandler.enterInFullscreen([:])
                    expect(core.mediaControl?.fullscreen).to(beTrue())
                }

                it("should set property `fullscreen` of mediaControll to `true` when player exit fullscreen mode") {
                    core.mediaControl?.fullscreen = false
                    core.fullscreenHandler.enterInFullscreen([:])
                    expect(core.mediaControl?.fullscreen).to(beTrue())
                }

                it("should post notification `requestFullscreen` when player enter in fullscreen mode") {
                    let fullscreenHandler = core.fullscreenHandler
                    self.expectation(forNotification: Event.requestFullscreen.rawValue, object: fullscreenHandler) { notification in
                        return true
                    }
                    fullscreenHandler.enterInFullscreen([:])
                    self.waitForExpectations(timeout: 2, handler: nil)
                }

                it("should post notification `exitFullscreen` when player exits fullscreen mode") {
                    let fullscreenHandler = core.fullscreenHandler
                    self.expectation(forNotification: Event.exitFullscreen.rawValue, object: fullscreenHandler) { notification in
                        return true
                    }
                    fullscreenHandler.exitFullscreen([:])
                    self.waitForExpectations(timeout: 2, handler: nil)
                }

            }

            context("when fullscreen is done by player") {

                var core: Core!

                beforeEach {
                    core = Core()
                }

                it("should set property `fullscreen` of mediaControll to `true` when player enter in fullscreen mode") {
                    core.mediaControl?.fullscreen = false
                    core.fullscreenHandler.enterInFullscreen([:])
                    expect(core.mediaControl?.fullscreen).to(beTrue())
                }

                it("should set property `fullscreen` of mediaControll to `true` when player exit fullscreen mode") {
                    core.mediaControl?.fullscreen = false
                    core.fullscreenHandler.enterInFullscreen([:])
                    expect(core.mediaControl?.fullscreen).to(beTrue())
                }

                it("should post notification `willEnterFullscreen` when player enter in fullscreen mode") {
                    let fullscreenHandler = core.fullscreenHandler
                    self.expectation(forNotification: InternalEvent.willEnterFullscreen.rawValue, object: fullscreenHandler) { notification in
                        return true
                    }
                    fullscreenHandler.enterInFullscreen([:])
                    self.waitForExpectations(timeout: 2, handler: nil)
                }

                it("should post notification `didEnterFullscreen` when player enter in fullscreen mode") {
                    let fullscreenHandler = core.fullscreenHandler
                    self.expectation(forNotification: InternalEvent.didEnterFullscreen.rawValue, object: fullscreenHandler) { notification in
                        return true
                    }
                    fullscreenHandler.enterInFullscreen([:])
                    self.waitForExpectations(timeout: 2, handler: nil)
                }

                it("should post notification `willExitFullscreen` when player exits fullscreen mode") {
                    let fullscreenHandler = core.fullscreenHandler
                    self.expectation(forNotification: InternalEvent.willExitFullscreen.rawValue, object: fullscreenHandler) { notification in
                        return true
                    }
                    fullscreenHandler.exitFullscreen([:])
                    self.waitForExpectations(timeout: 2, handler: nil)
                }

                it("should post notification `didExitFullscreen` when player exits fullscreen mode") {
                    let fullscreenHandler = core.fullscreenHandler
                    self.expectation(forNotification: InternalEvent.didExitFullscreen.rawValue, object: fullscreenHandler) { notification in
                        return true
                    }
                    fullscreenHandler.exitFullscreen([:])
                    self.waitForExpectations(timeout: 2, handler: nil)
                }
            }
        }
    }
}

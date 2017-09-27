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

                context("and player enter in fullscreen mode") {

                    it("should set property `fullscreen` of mediaControll to `true`") {
                        core.mediaControl?.fullscreen = false
                        core.fullscreenHandler.enterInFullscreen([:])
                        expect(core.mediaControl?.fullscreen).to(beTrue())
                    }

                    it("should post notification `requestFullscreen`") {
                        let fullscreenHandler = core.fullscreenHandler
                        self.expectation(forNotification: Event.requestFullscreen.rawValue, object: fullscreenHandler) { notification in
                            return true
                        }
                        fullscreenHandler.enterInFullscreen([:])
                        self.waitForExpectations(timeout: 2, handler: nil)
                    }
                }

                context("and player close fullscreen mode") {

                    it("should set property `fullscreen` of mediaControll to `true`") {
                        core.mediaControl?.fullscreen = false
                        core.fullscreenHandler.enterInFullscreen([:])
                        expect(core.mediaControl?.fullscreen).to(beTrue())
                    }



                    it("should post notification `exitFullscreen`") {
                        let fullscreenHandler = core.fullscreenHandler
                        self.expectation(forNotification: Event.exitFullscreen.rawValue, object: fullscreenHandler) { notification in
                            return true
                        }
                        fullscreenHandler.exitFullscreen([:])
                        self.waitForExpectations(timeout: 2, handler: nil)
                    }
                }
            }

            context("when fullscreen is done by player") {

                var core: Core!

                beforeEach {
                    core = Core()
                }

                context("and player enter in fullscreen mode") {

                    it("should set property `fullscreen` of mediaControll to `true`") {
                        core.mediaControl?.fullscreen = false
                        core.fullscreenHandler.enterInFullscreen([:])
                        expect(core.mediaControl?.fullscreen).to(beTrue())
                    }

                    it("should post notification `willEnterFullscreen`") {
                        let fullscreenHandler = core.fullscreenHandler
                        self.expectation(forNotification: InternalEvent.willEnterFullscreen.rawValue, object: fullscreenHandler) { notification in
                            return true
                        }
                        fullscreenHandler.enterInFullscreen([:])
                        self.waitForExpectations(timeout: 2, handler: nil)
                    }

                    it("should post notification `didEnterFullscreen`") {
                        let fullscreenHandler = core.fullscreenHandler
                        self.expectation(forNotification: InternalEvent.didEnterFullscreen.rawValue, object: fullscreenHandler) { notification in
                            return true
                        }
                        fullscreenHandler.enterInFullscreen([:])
                        self.waitForExpectations(timeout: 2, handler: nil)
                    }
                }

                context("and player close fullscreen mode") {

                    it("should set property `fullscreen` of mediaControll to `false`") {
                        core.mediaControl?.fullscreen = false
                        core.fullscreenHandler.exitFullscreen([:])
                        expect(core.mediaControl?.fullscreen).to(beFalse())
                    }

                    it("should post notification `willExitFullscreen`") {
                        let fullscreenHandler = core.fullscreenHandler
                        self.expectation(forNotification: InternalEvent.willExitFullscreen.rawValue, object: fullscreenHandler) { notification in
                            return true
                        }
                        fullscreenHandler.exitFullscreen([:])
                        self.waitForExpectations(timeout: 2, handler: nil)
                    }

                    it("should post notification `didExitFullscreen`") {
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
}

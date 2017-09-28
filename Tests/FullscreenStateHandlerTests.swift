import Quick
import Nimble
@testable import Clappr

class FullscreenStateHandlerTests: QuickSpec {

    override func spec() {
        describe("FullscreenHandler") {

            context("when fullscreen is done by app") {

                var core: Core!
                var fullscreenHandler: FullscreenStateHandler!

                beforeEach {
                    core = Core(options: [kFullscreenByApp: true] as Options)
                    fullscreenHandler = core.fullscreenHandler
                }

                context("and player enter in fullscreen mode") {

                    beforeEach {
                        fullscreenHandler.exitFullscreen()
                    }

                    it("should set property `fullscreen` of mediaControll to `true`") {
                        fullscreenHandler.enterInFullscreen()
                        core.setScreen(state: .fullscreen)
                        expect(core.mediaControl?.fullscreen).to(beTrue())
                    }

                    it("should post notification `requestFullscreen`") {
                        self.expectation(forNotification: Event.requestFullscreen.rawValue, object: fullscreenHandler) { notification in
                            return true
                        }
                        fullscreenHandler.enterInFullscreen()
                        self.waitForExpectations(timeout: 2, handler: nil)
                    }
                }

                context("and player close fullscreen mode") {

                    beforeEach {
                        fullscreenHandler.enterInFullscreen()
                    }

                    it("should set property `fullscreen` of mediaControll to `false`") {
                        fullscreenHandler.exitFullscreen()
                        core.setScreen(state: .embed)
                        expect(core.mediaControl?.fullscreen).to(beFalse())
                    }

                    it("should post notification `exitFullscreen`") {
                        self.expectation(forNotification: Event.exitFullscreen.rawValue, object: fullscreenHandler) { notification in
                            return true
                        }
                        fullscreenHandler.exitFullscreen()
                        self.waitForExpectations(timeout: 2, handler: nil)
                    }
                }
            }

            context("when fullscreen is done by player") {

                var core: Core!
                var fullscreenHandler: FullscreenStateHandler!

                beforeEach {
                    core = Core()
                    fullscreenHandler = core.fullscreenHandler
                }

                context("and player enter in fullscreen mode") {

                    beforeEach {
                        fullscreenHandler.exitFullscreen()
                    }

                    it("should set property `fullscreen` of mediaControll to `true`") {
                        fullscreenHandler.enterInFullscreen()
                        expect(core.mediaControl?.fullscreen).to(beTrue())
                    }

                    it("should post notification `willEnterFullscreen`") {
                        self.expectation(forNotification: InternalEvent.willEnterFullscreen.rawValue, object: fullscreenHandler) { notification in
                            return true
                        }
                        fullscreenHandler.enterInFullscreen()
                        self.waitForExpectations(timeout: 2, handler: nil)
                    }

                    it("should post notification `didEnterFullscreen`") {
                        self.expectation(forNotification: InternalEvent.didEnterFullscreen.rawValue, object: fullscreenHandler) { notification in
                            return true
                        }
                        fullscreenHandler.enterInFullscreen()
                        self.waitForExpectations(timeout: 2, handler: nil)
                    }

                    it("should set layout to fullscreen") {
                        fullscreenHandler.enterInFullscreen()
                        let controller = core.fullscreenController
                        expect(controller.view.backgroundColor).to(equal(UIColor.black))
                        expect(controller.modalPresentationStyle).to(equal(UIModalPresentationStyle.overFullScreen))
                        expect(controller.view.subviews.contains(core)).to(beTrue())
                    }
                }

                context("and player close fullscreen mode") {

                    beforeEach {
                        fullscreenHandler.enterInFullscreen()
                    }

                    it("should set property `fullscreen` of mediaControll to `false`") {
                        fullscreenHandler.exitFullscreen()
                        expect(core.mediaControl?.fullscreen).to(beFalse())
                    }

                    it("should post notification `willExitFullscreen`") {
                        self.expectation(forNotification: InternalEvent.willExitFullscreen.rawValue, object: fullscreenHandler) { notification in
                            return true
                        }
                        fullscreenHandler.exitFullscreen()
                        self.waitForExpectations(timeout: 2, handler: nil)
                    }

                    it("should post notification `didExitFullscreen`") {
                        self.expectation(forNotification: InternalEvent.didExitFullscreen.rawValue, object: fullscreenHandler) { notification in
                            return true
                        }
                        fullscreenHandler.exitFullscreen()
                        self.waitForExpectations(timeout: 2, handler: nil)
                    }

                    it("should set layout to embed") {
                        core.parentView = UIView()
                        fullscreenHandler.exitFullscreen()
                        expect(core.parentView?.subviews.contains(core)).to(beTrue())
                    }
                }
            }
        }
    }
}

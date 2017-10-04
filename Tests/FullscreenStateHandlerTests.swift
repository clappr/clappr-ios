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

                    beforeEach {
                        core.setFullscreen(false)
                    }

                    it("should set property `fullscreen` of mediaControll to `true`") {
                        core.setFullscreen(true)
                        expect(core.mediaControl?.fullscreen).to(beTrue())
                    }

                    it("should post notification `requestFullscreen`") {
                       self.expectation(forNotification: Event.requestFullscreen.rawValue, object: core) { notification in
                            return true
                        }

                        core.setFullscreen(true)
                        self.waitForExpectations(timeout: 2, handler: nil)
                    }

                    it("should listen to requestFullscreen event from player") {
                        let player = Player(options: core.options)
                        var callbackWasCalled = false

                        player.on(.requestFullscreen) { _ in
                            callbackWasCalled = true
                        }

                        player.attachTo(UIView(), controller: UIViewController())
                        player.setFullscreen(true)

                        expect(callbackWasCalled).toEventually(beTrue())
                    }
                }

                context("and player close fullscreen mode") {

                    beforeEach {
                        core.setFullscreen(true)
                    }

                    it("should set property `fullscreen` of mediaControll to `false`") {
                        core.setFullscreen(false)
                        expect(core.mediaControl?.fullscreen).to(beFalse())
                    }

                    it("should post notification `exitFullscreen`") {
                        self.expectation(forNotification: Event.exitFullscreen.rawValue, object: core) { notification in
                            return true
                        }

                        core.setFullscreen(false)
                        self.waitForExpectations(timeout: 2, handler: nil)
                    }

                    it("should listen event from player") {
                        let player = Player(options: core.options)
                        var callbackWasCalled = false

                        player.on(.exitFullscreen) { _ in
                            callbackWasCalled = true
                        }

                        player.attachTo(UIView(), controller: UIViewController())
                        player.setFullscreen(false)

                        expect(callbackWasCalled).toEventually(beTrue())
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
                        self.expectation(forNotification: InternalEvent.willEnterFullscreen.rawValue, object: core) { notification in
                            return true
                        }
                        fullscreenHandler.enterInFullscreen()
                        self.waitForExpectations(timeout: 2, handler: nil)
                    }

                    it("should post notification `didEnterFullscreen`") {
                        self.expectation(forNotification: InternalEvent.didEnterFullscreen.rawValue, object: core) { notification in
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

                    it("should trigger event on core") {
                        var callbackWasCalled = false

                        core.on(InternalEvent.didEnterFullscreen.rawValue) { _ in
                            callbackWasCalled = true
                        }

                        fullscreenHandler.enterInFullscreen()
                        expect(callbackWasCalled).toEventually(beTrue())
                    }

                    context("and call setFullscreen again") {
                        beforeEach {
                            core.setFullscreen(true)
                        }

                        it("should keep property `fullscreen` of mediaControll to `true`") {
                            core.setFullscreen(true)
                            expect(core.mediaControl?.fullscreen).to(beTrue())
                        }

                        it("shouldn't post notification `willEnterFullscreen`") {
                            let expectation = self.expectation(forNotification: InternalEvent.willEnterFullscreen.rawValue, object: core) { notification in
                                return true
                            }

                            expectation.isInverted = true
                            core.setFullscreen(true)
                            self.waitForExpectations(timeout: 2, handler: nil)
                        }

                        it("shouldn't post notification `didEnterFullscreen`") {
                            let expectation = self.expectation(forNotification: InternalEvent.didEnterFullscreen.rawValue, object: core) { notification in
                                return true
                            }
                            expectation.isInverted = true
                            core.setFullscreen(true)
                            self.waitForExpectations(timeout: 2, handler: nil)
                        }

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
                        self.expectation(forNotification: InternalEvent.willExitFullscreen.rawValue, object: core) { notification in
                            return true
                        }

                        fullscreenHandler.exitFullscreen()
                        self.waitForExpectations(timeout: 2, handler: nil)
                    }

                    it("should post notification `didExitFullscreen`") {
                        self.expectation(forNotification: InternalEvent.didExitFullscreen.rawValue, object: core) { notification in
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

                    it("should trigger event on core") {
                        var callbackWasCalled = false

                        core.on(InternalEvent.didExitFullscreen.rawValue) { _ in
                            callbackWasCalled = true
                        }

                        fullscreenHandler.exitFullscreen()
                        expect(callbackWasCalled).toEventually(beTrue())
                    }

                    context("and call setFullscreen twice") {
                        beforeEach {
                            core.setFullscreen(false)
                        }

                        it("should keep property `fullscreen` of mediaControll to `false`") {
                            core.setFullscreen(false)
                            expect(core.mediaControl?.fullscreen).to(beFalse())
                        }

                        it("shouldn't post notification `willExitFullscreen`") {
                            let expectation = self.expectation(forNotification: InternalEvent.willExitFullscreen.rawValue, object: core) { notification in
                                return true
                            }

                            expectation.isInverted = true
                            core.setFullscreen(false)
                            self.waitForExpectations(timeout: 2, handler: nil)
                        }

                        it("shouldn't post notification `didExitFullscreen`") {
                            let expectation = self.expectation(forNotification: InternalEvent.didExitFullscreen.rawValue, object: core) { notification in
                                return true
                            }

                            expectation.isInverted = true
                            core.setFullscreen(false)
                            self.waitForExpectations(timeout: 2, handler: nil)
                        }

                    }
                }
            }
        }
    }
}

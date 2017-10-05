import Quick
import Nimble
@testable import Clappr

class FullscreenStateHandlerTests: QuickSpec {

    override func spec() {
        describe("FullscreenHandler") {

            var player: Player!

            context("when fullscreen is done by app") {

                beforeEach {
                    player = Player(options: [kFullscreenByApp: true] as Options)
                    player.attachTo(UIView(), controller: UIViewController())
                }

                context("and player enter in fullscreen mode") {

                    beforeEach {
                        player.core?.setFullscreen(false)
                    }

                    it("should set property `fullscreen` of mediaControll to `true`") {
                        player.setFullscreen(true)
                        expect(player.core?.mediaControl?.fullscreen).to(beTrue())
                    }

                    it("should listen to requestFullscreen event from player") {
                        var callbackWasCalled = false
                        player.on(.requestFullscreen) { _ in
                            callbackWasCalled = true
                        }
                        player.setFullscreen(true)
                        expect(callbackWasCalled).toEventually(beTrue())
                    }
                }

                context("and player close fullscreen mode") {

                    beforeEach {
                        player.setFullscreen(true)
                    }

                    it("should set property `fullscreen` of mediaControll to `false`") {
                        player.setFullscreen(false)
                        expect(player.core?.mediaControl?.fullscreen).to(beFalse())
                    }

                    it("should listen event from player") {
                        var callbackWasCalled = false
                        player.on(.exitFullscreen) { _ in
                            callbackWasCalled = true
                        }
                        player.setFullscreen(false)
                        expect(callbackWasCalled).toEventually(beTrue())
                    }
                }
            }

            context("when fullscreen is done by player") {

                beforeEach {
                    player = Player()
                    player.attachTo(UIView(), controller: UIViewController())
                }

                context("and player enter in fullscreen mode") {

                    beforeEach {
                        player.setFullscreen(false)
                    }

                    it("should set property `fullscreen` of mediaControll to `true`") {
                        player.setFullscreen(true)
                        expect(player.core?.mediaControl?.fullscreen).to(beTrue())
                    }

                    it("should post notification `willEnterFullscreen`") {
                        var callbackWasCalled = false
                        player.on(.requestFullscreen) { _ in
                            callbackWasCalled = true
                        }
                        player.setFullscreen(true)
                        expect(callbackWasCalled).toEventually(beTrue())
                    }

                    it("should set layout to fullscreen") {
                        player.setFullscreen(true)
                        let controller = player.core!.fullscreenController
                        expect(controller.view.backgroundColor).to(equal(UIColor.black))
                        expect(controller.modalPresentationStyle).to(equal(UIModalPresentationStyle.overFullScreen))
                        expect(controller.view.subviews.contains(player.core!)).to(beTrue())
                    }

                    context("and call setFullscreen again") {
                        beforeEach {
                            player.setFullscreen(true)
                        }

                        it("should keep property `fullscreen` of mediaControll to `true`") {
                            player.setFullscreen(true)
                            expect(player.core!.mediaControl?.fullscreen).to(beTrue())
                        }

                        it("shouldn't post notification `willEnterFullscreen`") {
                            let expectation = self.expectation(forNotification: InternalEvent.willEnterFullscreen.rawValue, object: player.core!) { notification in
                                return true
                            }

                            expectation.isInverted = true
                            player.setFullscreen(true)
                            self.waitForExpectations(timeout: 2, handler: nil)
                        }

                        it("shouldn't post notification `didEnterFullscreen`") {
                            let expectation = self.expectation(forNotification: InternalEvent.didEnterFullscreen.rawValue, object: player.core!) { notification in
                                return true
                            }
                            expectation.isInverted = true
                            player.setFullscreen(true)
                            self.waitForExpectations(timeout: 2, handler: nil)
                        }

                    }
                }

                context("and player close fullscreen mode") {

                    beforeEach {
                        player.setFullscreen(true)
                    }

                    it("should set property `fullscreen` of mediaControll to `false`") {
                        player.setFullscreen(false)
                        expect(player.core?.mediaControl?.fullscreen).to(beFalse())
                    }

                    it("should set layout to embed") {
                        player.core!.parentView = UIView()
                        player.core!.fullscreenHandler.exitFullscreen()
                        expect(player.core!.parentView?.subviews.contains(player.core!)).to(beTrue())
                    }

                    it("should listen event from player") {
                        var callbackWasCalled = false
                        player.on(.exitFullscreen) { _ in
                            callbackWasCalled = true
                        }
                        player.setFullscreen(false)
                        expect(callbackWasCalled).toEventually(beTrue())
                    }

                    context("and call setFullscreen twice") {
                        beforeEach {
                            player.setFullscreen(false)
                        }

                        it("should keep property `fullscreen` of mediaControll to `false`") {
                            player.setFullscreen(false)
                            expect(player.core!.mediaControl?.fullscreen).to(beFalse())
                        }

                        it("shouldn't post notification `willExitFullscreen`") {
                            let expectation = self.expectation(forNotification: InternalEvent.willExitFullscreen.rawValue, object: player.core!) { notification in
                                return true
                            }

                            expectation.isInverted = true
                            player.setFullscreen(false)
                            self.waitForExpectations(timeout: 2, handler: nil)
                        }

                        it("shouldn't post notification `didExitFullscreen`") {
                            let expectation = self.expectation(forNotification: InternalEvent.didExitFullscreen.rawValue, object: player.core!) { notification in
                                return true
                            }

                            expectation.isInverted = true
                            player.setFullscreen(false)
                            self.waitForExpectations(timeout: 2, handler: nil)
                        }

                    }
                }
            }
        }
    }
}

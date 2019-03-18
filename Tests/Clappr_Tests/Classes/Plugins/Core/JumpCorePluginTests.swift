import Quick
import Nimble

@testable import Clappr

class JumpCorePluginTests: QuickSpec {

    override func spec() {
        describe(".JumpCorePluginTests") {
            var jumpPlugin: JumpCorePlugin!
            var core: CoreStub!
            var eventTrigger = false
            
            beforeEach {
                core = CoreStub()
                core.playbackMock?.videoDuration = 60.0
                jumpPlugin = JumpCorePlugin(context: core)
                core.addPlugin(jumpPlugin)
                core.view.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
                jumpPlugin.render()
                core._container?.on(InternalEvent.didTapQuickSeek.rawValue) { _ in
                    eventTrigger = true
                }
            }
            
            describe("pluginName") {
                it("has a name") {
                    expect(jumpPlugin.pluginName).to(equal("JumpCorePlugin"))
                }
            }
            
            describe("gesture recognizers") {
                it("has two gestures") {
                    expect(core.view.gestureRecognizers?.count).to(equal(2))
                }
            }
            
            describe("when jump is triggered") {
                context("and its position is less than half of the view (left)") {
                    it("seeks back 10 seconds") {
                        core.playbackMock?.set(position: 20.0)

                        jumpPlugin.jumpSeek(xPosition: 0)
                        
                        expect(eventTrigger).toEventually(beTrue())
                        expect(core.playbackMock?.didCallSeek).to(beTrue())
                        expect(core.playbackMock?.didCallSeekWithValue).to(equal(10))
                    }
                }
                
                context("and its position is higher than half of the view (right)") {
                    it("seeks forward 10 seconds") {
                        core.playbackMock?.set(position: 20.0)
                        
                        jumpPlugin.jumpSeek(xPosition: 100)

                        expect(eventTrigger).toEventually(beTrue())
                        expect(core.playbackMock?.didCallSeek).to(beTrue())
                        expect(core.playbackMock?.didCallSeekWithValue).to(equal(30))
                    }
                }
                
                describe("live video") {
                    context("with DVR") {
                        it("seeks forward") {
                            core.playbackMock?.set(playbackType: .live)
                            core.playbackMock?.set(isDvrAvailable: true)
                            core.playbackMock?.set(isDvrInUse: true)
                            core.playbackMock?.set(position: 0)
                            
                            jumpPlugin.jumpSeek(xPosition: core.view.frame.width)
                            
                            expect(core.playbackMock?.didCallSeek).to(beTrue())
                        }
                        
                        it("seeks backward") {
                            core.playbackMock?.set(playbackType: .live)
                            core.playbackMock?.set(isDvrAvailable: true)
                            
                            jumpPlugin.jumpSeek(xPosition: 0)
                            
                            expect(core.playbackMock?.didCallSeek).to(beTrue())
                        }
                        
                        context("with DVR not in use") {
                            it("does not seek forward") {
                                core.playbackMock?.set(playbackType: .live)
                                core.playbackMock?.set(isDvrAvailable: true)
                                core.playbackMock?.set(isDvrInUse: false)
                                
                                jumpPlugin.jumpSeek(xPosition: core.view.frame.width)
                                
                                expect(core.playbackMock?.didCallSeek).to(beFalse())
                            }
                        }
                    }
                    
                    context("without DVR") {
                        it("does not seek forward") {
                            core.playbackMock?.set(playbackType: .live)
                            core.playbackMock?.set(isDvrAvailable: false)
                            
                            jumpPlugin.jumpSeek(xPosition: core.view.frame.width)
                            
                            expect(core.playbackMock?.didCallSeek).to(beFalse())
                        }
                        
                        it("does not seek backward") {
                            core.playbackMock?.set(playbackType: .live)
                            core.playbackMock?.set(isDvrAvailable: false)
                            
                            jumpPlugin.jumpSeek(xPosition: 0)
                            
                            expect(core.playbackMock?.didCallSeek).to(beFalse())
                        }
                    }
                }
            }
        }
    }
}

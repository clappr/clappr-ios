import Quick
import Nimble

@testable import Clappr

class QuickSeekCorePluginTests: QuickSpec {

    override func spec() {
        describe(".QuickSeekCorePluginTests") {
            var quickSeekPlugin: QuickSeekCorePlugin!
            var core: CoreStub!
            var eventTrigger = false
            var eventParams: EventUserInfo = [:]

            beforeEach {
                core = CoreStub()
                core.playbackMock?.videoDuration = 60.0
                quickSeekPlugin = QuickSeekCorePlugin(context: core)
                core.addPlugin(quickSeekPlugin)
                core.view.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
                quickSeekPlugin.render()
                core._container?.on(InternalEvent.didQuickSeek.rawValue) { userInfo in
                    eventTrigger = true
                    eventParams = userInfo
                }
            }
            
            describe("pluginName") {
                it("has a name") {
                    expect(quickSeekPlugin.pluginName).to(equal("QuickSeekCorePlugin"))
                }
            }
            
            describe("gesture recognizers") {
                it("has two gestures") {
                    expect(core.view.gestureRecognizers?.count).to(equal(2))
                }
            }
            
            describe("when quickSeek is triggered") {
                context("and its position is less than half of the view (left)") {
                    it("seeks back 10 seconds") {
                        core.playbackMock?.set(position: 20.0)

                        quickSeekPlugin.quickSeek(xPosition: 0)
                        
                        expect(eventTrigger).toEventually(beTrue())
                        expect(eventParams?["duration"] as? Double).to(equal(-10.0))
                        expect(core.playbackMock?.didCallSeek).to(beTrue())
                        expect(core.playbackMock?.didCallSeekWithValue).to(equal(10))
                    }

                    it("triggers didDoubleTouchMediaControl event") {
                        var eventArguments: EventUserInfo = [:]
                        core.playbackMock?.set(position: 20.0)

                        core.activeContainer?.on(Event.didDoubleTouchMediaControl.rawValue) { userInfo in
                            eventArguments = userInfo
                        }

                        quickSeekPlugin.quickSeek(xPosition: 0)

                        expect(eventArguments?["position"] as? String).to(equal("left"))
                    }
                }

                context("and its position is higher than half of the view (right)") {
                    it("seeks forward 10 seconds") {
                        core.playbackMock?.set(position: 20.0)
                        
                        quickSeekPlugin.quickSeek(xPosition: 100)

                        expect(eventTrigger).toEventually(beTrue())
                        expect(eventParams?["duration"] as? Double).to(equal(10.0))
                        expect(core.playbackMock?.didCallSeek).to(beTrue())
                        expect(core.playbackMock?.didCallSeekWithValue).to(equal(30))
                    }

                    it("triggers didDoubleTouchMediaControl event") {
                        var eventArguments: EventUserInfo = [:]
                        core.playbackMock?.set(position: 20.0)

                        core.activeContainer?.on(Event.didDoubleTouchMediaControl.rawValue) { userInfo in
                            eventArguments = userInfo
                        }

                        quickSeekPlugin.quickSeek(xPosition: 100)

                        expect(eventArguments?["position"] as? String).to(equal("right"))
                    }
                }
                
                describe("live video") {
                    context("with DVR") {
                        it("seeks forward") {
                            core.playbackMock?.set(playbackType: .live)
                            core.playbackMock?.set(isDvrAvailable: true)
                            core.playbackMock?.set(isDvrInUse: true)
                            core.playbackMock?.set(position: 0)
                            
                            quickSeekPlugin.quickSeek(xPosition: core.view.frame.width)
                            
                            expect(core.playbackMock?.didCallSeek).to(beTrue())
                        }
                        
                        it("seeks backward") {
                            core.playbackMock?.set(playbackType: .live)
                            core.playbackMock?.set(isDvrAvailable: true)
                            
                            quickSeekPlugin.quickSeek(xPosition: 0)
                            
                            expect(core.playbackMock?.didCallSeek).to(beTrue())
                        }
                        
                        context("with DVR not in use") {
                            it("does not seek forward") {
                                core.playbackMock?.set(playbackType: .live)
                                core.playbackMock?.set(isDvrAvailable: true)
                                core.playbackMock?.set(isDvrInUse: false)
                                
                                quickSeekPlugin.quickSeek(xPosition: core.view.frame.width)
                                
                                expect(core.playbackMock?.didCallSeek).to(beFalse())
                            }
                        }
                    }
                    
                    context("without DVR") {
                        it("does not seek forward") {
                            core.playbackMock?.set(playbackType: .live)
                            core.playbackMock?.set(isDvrAvailable: false)
                            
                            quickSeekPlugin.quickSeek(xPosition: core.view.frame.width)
                            
                            expect(core.playbackMock?.didCallSeek).to(beFalse())
                        }
                        
                        it("does not seek backward") {
                            core.playbackMock?.set(playbackType: .live)
                            core.playbackMock?.set(isDvrAvailable: false)
                            
                            quickSeekPlugin.quickSeek(xPosition: 0)
                            
                            expect(core.playbackMock?.didCallSeek).to(beFalse())
                        }
                    }
                }
            }
        }
    }
}

import Quick
import Nimble

@testable import Clappr

class DoubleTapCorePluginTests: QuickSpec {

    override func spec() {
        describe(".DoubleTapCorePluginTests") {
            var doubleTapPlugin: DoubleTapCorePlugin!
            var core: CoreStub!
            
            beforeEach {
                core = CoreStub()
                core.playbackMock?.videoDuration = 60.0
                doubleTapPlugin = DoubleTapCorePlugin(context: core)
                core.addPlugin(doubleTapPlugin)
                core.view.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
                doubleTapPlugin.render()
            }
            
            describe("pluginName") {
                it("has a name") {
                    expect(doubleTapPlugin.pluginName).to(equal("DoubleTapCorePlugin"))
                }
            }
            
            describe("gesture recognizers") {
                it("has two gestures") {
                    expect(core.view.gestureRecognizers?.count).to(equal(2))
                }
            }
            
            describe("when double tap is triggered") {
                context("and its position is less than half of the view (left)") {
                    it("seeks back 10 seconds") {
                        core.playbackMock?.set(position: 20.0)
                        
                        doubleTapPlugin.doubleTapSeek(xPosition: 0)
                       
                        expect(core.playbackMock?.didCallSeek).to(beTrue())
                        expect(core.playbackMock?.didCallSeekWithValue).to(equal(10))
                    }
                }
                
                context("and its position is higher than half of the view (right)") {
                    it("seeks forward 10 seconds") {
                        core.playbackMock?.set(position: 20.0)
                        
                        doubleTapPlugin.doubleTapSeek(xPosition: 100)
                        
                        expect(core.playbackMock?.didCallSeek).to(beTrue())
                        expect(core.playbackMock?.didCallSeekWithValue).to(equal(30))
                    }
                }
                
                describe("live video") {
                    context("with DVR") {
                        it("should seek forward") {
                            core.playbackMock?.set(playbackType: .live)
                            core.playbackMock?.set(isDvrAvailable: true)
                            core.playbackMock?.set(isDvrInUse: true)
                            core.playbackMock?.set(position: 0)
                            
                            doubleTapPlugin.doubleTapSeek(xPosition: core.view.frame.width)
                            
                            expect(core.playbackMock?.didCallSeek).to(beTrue())
                        }
                        
                        it("should seek backward") {
                            core.playbackMock?.set(playbackType: .live)
                            core.playbackMock?.set(isDvrAvailable: true)
                            
                            doubleTapPlugin.doubleTapSeek(xPosition: 0)
                            
                            expect(core.playbackMock?.didCallSeek).to(beTrue())
                        }
                    }
                    
                    context("without DVR") {
                        it("should not seek forward") {
                            core.playbackMock?.set(playbackType: .live)
                            core.playbackMock?.set(isDvrAvailable: false)
                            
                            doubleTapPlugin.doubleTapSeek(xPosition: core.view.frame.width)
                            
                            expect(core.playbackMock?.didCallSeek).to(beFalse())
                        }
                        
                        it("should not seek backward") {
                            core.playbackMock?.set(playbackType: .live)
                            core.playbackMock?.set(isDvrAvailable: false)
                            
                            doubleTapPlugin.doubleTapSeek(xPosition: 0)
                            
                            expect(core.playbackMock?.didCallSeek).to(beFalse())
                        }
                    }
                }
            }
        }
    }
}

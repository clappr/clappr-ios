import Quick
import Nimble

@testable import Clappr

class QuickSeekMediaControlPluginTests: QuickSpec {
    
    override func spec() {
        describe(".QuickSeekMediaControlPluginTests") {
            var quickSeekPlugin: QuickSeekMediaControlPlugin!
            var core: CoreStub!
            var mediaControl: MediaControl!
            var playButton: PlayButton!
            
            beforeEach {
                Loader.shared.resetPlugins()
                core = CoreStub()
                core.playbackMock?.videoDuration = 60.0
                quickSeekPlugin = QuickSeekMediaControlPlugin(context: core)
                mediaControl = MediaControl(context: core)
                playButton = PlayButton(context: core)
                
                core.addPlugin(mediaControl)
                core.addPlugin(quickSeekPlugin)
                core.addPlugin(playButton)
                
                core.view.frame = CGRect(x: 0, y: 0, width: 320, height: 200)
                
                core.render()
                mediaControl.render()
                quickSeekPlugin.render()
            }
            
            describe("pluginName") {
                it("has a name") {
                    expect(quickSeekPlugin.pluginName).to(equal("QuickSeekMediaControlPlugin"))
                }
            }
            
            describe("gesture recognizers") {
                it("has two gestures") {
                    expect(mediaControl.mediaControlView.gestureRecognizers?.count).to(equal(2))
                }
            }
            
            describe("when quickSeek is triggered") {
                context("and its position is less than half of the view (left)") {
                    it("seeks back 10 seconds") {
                        mediaControl.show()
                        core.playbackMock?.set(position: 20.0)
                        
                        quickSeekPlugin.quickSeek(xPosition: core.view.frame.origin.x)
                        
                        expect(core.playbackMock?.didCallSeek).to(beTrue())
                        expect(core.playbackMock?.didCallSeekWithValue).to(equal(10))
                    }
                }
                
                context("and its position is more than half of the view (right)") {
                    it("seeks forward 10 seconds") {
                        mediaControl.show()
                        core.playbackMock?.set(position: 20.0)
                        
                        quickSeekPlugin.quickSeek(xPosition: core.view.frame.width)
                        
                        expect(core.playbackMock?.didCallSeek).to(beTrue())
                        expect(core.playbackMock?.didCallSeekWithValue).to(equal(30))
                    }
                }
                
                context("and it colides with another UICorePlugin") {
                    it("does not seek") {
                        playButton.view.layoutIfNeeded()
                        mediaControl.view.layoutIfNeeded()
                        
                        let shouldSeek = quickSeekPlugin.shouldSeek(point: CGPoint(x: 100, y: 100))
                        
                        expect(shouldSeek).to(beFalse())
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

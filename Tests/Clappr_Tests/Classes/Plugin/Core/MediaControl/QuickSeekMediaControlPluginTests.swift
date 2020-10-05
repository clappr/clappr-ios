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
            var overlayPlugin: OverlayPlugin!
            
            beforeEach {
                Loader.shared.resetPlugins()
                core = CoreStub()
                core.playbackMock?.videoDuration = 60.0
                quickSeekPlugin = QuickSeekMediaControlPlugin(context: core)
                mediaControl = MediaControl(context: core)
                
                core.addPlugin(mediaControl)
                core.addPlugin(quickSeekPlugin)
                
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
                
                describe("and there is another UICorePlugin") {
                    beforeEach {
                        playButton = PlayButton(context: core)
                        
                        core.addPlugin(playButton)
                        core.render()
                        
                        mediaControl.render()
                        playButton.view.layoutIfNeeded()
                        mediaControl.view.layoutIfNeeded()
                        
                    }
                    
                    context("and it collides with that plugin") {
                        it("does not seek") {
                            let coreStub: CoreStub = CoreStub()
                            let quickSeekPlugin: QuickSeekMediaControlPlugin = QuickSeekMediaControlPlugin(context: coreStub)
                            let mediaControl: MediaControl = MediaControl(context: coreStub)
                            let playButton: PlayButton = PlayButton(context: coreStub)
                            let rootView: UIView = UIView(frame: .init(origin: .zero, size: .init(width: 320, height: 200)))
                            
                            coreStub.playbackMock?.videoDuration = 60.0
                            coreStub.addPlugin(mediaControl)
                            coreStub.addPlugin(quickSeekPlugin)
                            coreStub.addPlugin(playButton)
                            
                            coreStub.attach(to: rootView, controller: UIViewController())
                            coreStub.render()
                            
                            rootView.layoutIfNeeded()
                            
                            let playButtonCenterInMediaControlCoordinate = playButton.view.convert(playButton.view.center, to: mediaControl.mediaControlView)
                            
                            let shouldSeek = quickSeekPlugin.shouldSeek(point: playButtonCenterInMediaControlCoordinate)
                            
                            expect(shouldSeek).to(beFalse())
                        }
                    }
                    
                    context("and it does not collide with that plugin") {
                        it("does seek") {
                            let pointOutsidePlayButton = CGPoint(x: playButton.view.frame.width + 1, y: playButton.view.frame.height + 1)
                            let outsidePointInMediaControlCoordinate = playButton.view.convert(pointOutsidePlayButton, to: mediaControl.mediaControlView)
                            
                            let shouldSeek = quickSeekPlugin.shouldSeek(point: outsidePointInMediaControlCoordinate)
                            
                            expect(shouldSeek).to(beTrue())
                        }
                    }
                    
                    context("and that plugin is not visible") {
                        it("does seek") {
                            let playButtonCenterInMediaControlCoordinate = playButton.view.convert(playButton.view.center, to: mediaControl.mediaControlView)
                            playButton.view.alpha = 0.0
                            
                            let shouldSeek = quickSeekPlugin.shouldSeek(point: playButtonCenterInMediaControlCoordinate)
                            
                            expect(shouldSeek).to(beTrue())
                        }
                    }
                }
                
                context("and there are not visible overlay plugins") {
                    it("ignores them and seeks") {
                        overlayPlugin = OverlayPluginStub(context: core)
                        core.addPlugin(overlayPlugin)
                        core.render()
                        overlayPlugin.render()
                        overlayPlugin.view.layoutIfNeeded()
                        let overlayPluginCenterInMediaControlCoordinate = overlayPlugin.view.convert(overlayPlugin.view.center, to: mediaControl.mediaControlView)

                        let shouldSeek = quickSeekPlugin.shouldSeek(point: overlayPluginCenterInMediaControlCoordinate)
                        
                        expect(shouldSeek).to(beTrue())
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

class OverlayPluginStub: OverlayPlugin {
    override var isModal: Bool {
        true
    }
    
    override class var name: String {
        "OverlayPluginStub"
    }
    
    override func bindEvents() {}
    
    override func render() {
        view.backgroundColor = .red
    }
}

import Quick
import Nimble

@testable import Clappr

class DoubleTapPluginTests: QuickSpec {

    override func spec() {
        describe(".DoubleTapPlugin") {
            var doubleTapPlugin: DoubleTapPlugin!
            var playButton: PlayButton!
            var mediaControl: MediaControl!
            var core: CoreStub!
            
            beforeEach {
                core = CoreStub()
                
                doubleTapPlugin = DoubleTapPlugin(context: core)
                mediaControl = MediaControl(context: core)
                playButton = PlayButton(context: core)
                
                core.addPlugin(mediaControl)
                core.addPlugin(doubleTapPlugin)
                core.addPlugin(playButton)
                
                core.view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
                core.render()
            }
            
            describe("pluginName") {
                it("has a name") {
                    let pluginName = String(describing: DoubleTapPlugin.self)
                    expect(doubleTapPlugin.pluginName).to(equal(pluginName))
                }
            }
            
            describe("gesture recognizers") {
                it("has two gestures") {
                    expect(doubleTapPlugin.doubleTapView.gestureRecognizers?.count).to(equal(2))
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
                
                context("and the poster is not being presented") {
                    it("should not trigger the double tap event") {
                        let colisionTest = doubleTapPlugin.doubleTapView.point(inside: .zero, with: nil)
                        
                        expect(colisionTest).to(beFalse())
                    }
                }
                
                context("and the poster is being presented") {
                    context("if visible") {
                        it("should not test mediaControl colisions") {
                            addPosterPlugin(isHidden: false)
                            
                            let colisionTest = doubleTapPlugin.doubleTapView.point(inside: .zero, with: nil)
                            
                            expect(colisionTest).to(beFalse())
                        }
                    }
                    context("if not visible") {
                        it("should test mediaControl colisions") {
                            addPosterPlugin()
                            
                            let colisionTest = doubleTapPlugin.doubleTapView.point(inside: .zero, with: nil)
                            
                            expect(colisionTest).to(beTrue())
                        }
                    }
                }
                
                context("and colides with another plugin") {
                    it("should test the colision returning false") {
                        addPosterPlugin()
                        playButton.view.layoutIfNeeded()
                        mediaControl.view.layoutIfNeeded()
                        mediaControl.view.isHidden = false
                        
                        let colisionTest = doubleTapPlugin.doubleTapView.point(inside: playButton.view.frame.origin, with: nil)
                        
                        expect(colisionTest).to(beFalse())
                    }
                }
            }
            
            func addPosterPlugin(isHidden: Bool = true) {
                let posterPlugin = PosterPlugin(context: core.activeContainer!)
                core.activeContainer?.addPlugin(posterPlugin)
                posterPlugin.view.isHidden = isHidden
            }
        }
    }
}

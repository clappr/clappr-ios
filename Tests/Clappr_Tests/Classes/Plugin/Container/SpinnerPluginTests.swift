import Quick
import Nimble

@testable import Clappr

class SpinnerPluginTests: QuickSpec {
    
    override func spec() {
        
        var core: CoreStub!
        var spinnerPlugin: SpinnerPlugin!
        var playback: AVFoundationPlaybackMock!
        
        beforeEach {
            core = CoreStub()
            spinnerPlugin = SpinnerPlugin(context: core)
            playback = core.playbackMock
        }
        
        describe("SpinnerPlugin") {
                       
            context("When Playback is changed") {
                
                var oldPlayback: Playback!
                
                beforeEach {
                    oldPlayback = core.activePlayback
                    core._container?.playback = Playback(options: [:])
                    core._container?.trigger(Event.didChangePlayback)
                }
                
                it("stops listening to the old playback"){
                    spinnerPlugin.view.isHidden = true
                    
                    oldPlayback.trigger(Event.stalling)
                    
                    expect(spinnerPlugin.view.isHidden).to(beTrue())
                }
            }
            
            describe("Playback events") {
                
                beforeEach {
                    spinnerPlugin.onDidChangePlayback()
                }
                
                context("When playback starts playing") {
                    
                    beforeEach {
                        playback.trigger(Event.playing.rawValue)
                    }
                    
                    it("hides the spinner") {
                        expect(spinnerPlugin.view.isHidden).toEventually(beTrue())
                    }
                    
                    it("sets the isAnimating to false") {
                        expect(spinnerPlugin.isAnimating).toEventually(beFalse())
                    }
                }
                
                context("When playback fails") {
                    
                    beforeEach {
                        playback.trigger(Event.error.rawValue)
                    }
                    
                    it("hides the spinner") {
                        expect(spinnerPlugin.view.isHidden).toEventually(beTrue())
                    }
                    
                    it("sets the isAnimating to false") {
                        expect(spinnerPlugin.isAnimating).toEventually(beFalse())
                    }
                }
                
                context("When playback completes") {
                    
                    beforeEach {
                        playback.trigger(Event.didComplete.rawValue)
                    }
                    
                    it("hides the spinner") {
                        expect(spinnerPlugin.view.isHidden).toEventually(beTrue())
                    }
                    
                    it("sets the isAnimating to false") {
                        expect(spinnerPlugin.isAnimating).toEventually(beFalse())
                    }
                }
                
                context("When playback stalls") {
                    
                    beforeEach {
                        playback.trigger(Event.stalling.rawValue)
                    }
                    
                    it("hides the spinner") {
                        expect(spinnerPlugin.view.isHidden).toEventually(beFalse())
                    }
                    
                    it("sets the isAnimating to false") {
                        expect(spinnerPlugin.isAnimating).toEventually(beTrue())
                    }
                }
                
                context("When playback pauses") {
                    
                    beforeEach {
                        playback.trigger(Event.didPause.rawValue)
                    }
                    
                    it("hides the spinner") {
                        expect(spinnerPlugin.view.isHidden).toEventually(beTrue())
                    }
                    
                    it("sets the isAnimating to false") {
                        expect(spinnerPlugin.isAnimating).toEventually(beFalse())
                    }
                }
                
                context("When playback stops") {
                    
                    beforeEach {
                        playback.trigger(Event.didStop.rawValue)
                    }
                    
                    it("hides the spinner") {
                        expect(spinnerPlugin.view.isHidden).toEventually(beTrue())
                    }
                    
                    it("sets the isAnimating to false") {
                        expect(spinnerPlugin.isAnimating).toEventually(beFalse())
                    }
                }
                
                context("When playback trigger a willPlay event") {
                    
                    beforeEach {
                        playback.trigger(Event.willPlay.rawValue)
                    }
                    
                    it("shows the spinner") {
                        expect(spinnerPlugin.view.isHidden).toEventually(beFalse())
                    }
                    
                    it("sets the isAnimating to false") {
                        expect(spinnerPlugin.isAnimating).toEventually(beTrue())
                    }
                }
            }
            
            describe("Modal events") {
                context("When a modal plugin will show") {
                    it("hides itself") {
                        spinnerPlugin.view.isHidden = false
                        
                        core.trigger(Event.willShowModal)
                        
                        expect(spinnerPlugin.view.isHidden).to(beTrue())
                    }
                }
                context("When a modal plugin will hide") {
                    context("and Playback is stalling") {
                        it("shows itself"){
                            spinnerPlugin.view.isHidden = true
                            playback.state = .stalling
                            
                            core.trigger(Event.willHideModal)
                            
                            expect(spinnerPlugin.view.isHidden).to(beFalse())
                        }
                    }
                    context("and Playback has no state") {
                        it("shows itself"){
                            spinnerPlugin.view.isHidden = true
                            playback.state = .none
                            
                            core.trigger(Event.willHideModal)
                            
                            expect(spinnerPlugin.view.isHidden).to(beFalse())
                        }
                    }
                    context("and Playback is not stalling") {
                        it("hides itself"){
                            spinnerPlugin.view.isHidden = false
                            playback.state = .error
                            
                            core.trigger(Event.willHideModal)
                            
                            expect(spinnerPlugin.view.isHidden).to(beTrue())
                        }
                    }
                }
            }
            
            context("When plugin is destoyed") {
                it("removes itself from superview") {
                    spinnerPlugin.destroy()
                    
                    expect(core.overlayView.subviews).notTo(contain(spinnerPlugin.view))
                }
            }
        }
    }
}

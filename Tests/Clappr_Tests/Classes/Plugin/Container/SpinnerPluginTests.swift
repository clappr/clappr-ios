import Quick
import Nimble

@testable import Clappr

class SpinnerPluginTests: QuickSpec {

    override func spec() {

        var container: Container!
        var spinnerPlugin: SpinnerPlugin!
        var playback: AVFoundationPlayback!

        beforeEach {
            container = Container()
            spinnerPlugin = SpinnerPlugin(context: container)
            playback = AVFoundationPlayback(options: [:])
            container.playback = playback
        }

        describe("SpinnerPlugin") {

            describe("#init") {

                it("sets the accessibilityIdentifier") {
                    expect(spinnerPlugin.view.accessibilityIdentifier).to(equal("SpinnerPlugin"))
                }

                it("sets the pluginName as spinner") {
                    expect(spinnerPlugin.pluginName).to(equal("spinner"))
                }

                it("is a container plugin") {
                    expect(spinnerPlugin).to(beAKindOf(UIContainerPlugin.self))
                }

                it("sets isUserInteractionEnabled to false") {
                    expect(spinnerPlugin.view.isUserInteractionEnabled).to(beFalse())
                }

                it("has a UIActivityIndicatorView as subview") {
                    expect(spinnerPlugin.view.subviews.contains(where: { $0 is UIActivityIndicatorView})).to(beTrue())
                }
            }

            describe("#destroy") {
                it("removes from itself from superview") {
                    spinnerPlugin.destroy()

                    expect(spinnerPlugin.view.superview).to(beNil())
                }
            }

            context("when the playback trigger a playing event") {

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

            context("when the playback trigger an error event") {

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

            context("when the playback trigger a didComplete event") {

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

            context("when the playback trigger a stalling event") {

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
            
            context("when the playback trigger a pause event") {

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
            
            context("when the playback trigger a stop event") {

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
        }
    }

    class PlaybackStub: Playback {
        override class var name: String { return "playbackstub" }
    }
}

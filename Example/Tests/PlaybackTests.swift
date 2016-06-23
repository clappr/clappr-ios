import Quick
import Nimble
import Clappr

class PlaybackTests: QuickSpec {

    override func spec() {
        describe("Playback") {
            var playback: StubPlayback!
            let options = [kSourceUrl : "http://globo.com/video.mp4"]

            beforeEach() {
                playback = StubPlayback(options: options)
            }

            it("Should have a play method") {
                let responds = playback.respondsToSelector(#selector(Playback.play))
                expect(responds).to(beTrue())
            }

            it("Should have a pause method") {
                let responds = playback.respondsToSelector(#selector(NSProgress.pause))
                expect(responds).to(beTrue())
            }

            it("Should have a stop method") {
                let responds = playback.respondsToSelector(#selector(NSNetService.stop))
                expect(responds).to(beTrue())
            }

            it("Should have a seek method receiving a time") {
                let responds = playback.respondsToSelector(#selector(Playback.seek(_:)))
                expect(responds).to(beTrue())
            }

            it("Should have a duration var with a default value 0") {
                expect(playback.duration()) == 0
            }

            it("Should have a isPlaying var with a default value false") {
                expect(playback.isPlaying()).to(beFalse())
            }

            it("Should have a type var with a default value Unknown") {
                expect(playback.playbackType()).to(equal(PlaybackType.Unknown))
            }

            it("Should have a isHighDefinitionInUse var with a default value false") {
                expect(playback.isHighDefinitionInUse()).to(beFalse())
            }

            it("Should be removed from superview when destroy is called") {
                let container = UIView()
                container.addSubview(playback)

                expect(playback.superview).toNot(beNil())
                playback.destroy()
                expect(playback.superview).to(beNil())
            }

            it("Should stop listening events after destroy has been called") {
                var callbackWasCalled = false

                playback.on("some-event") { userInfo in
                    callbackWasCalled = true
                }

                playback.destroy()
                playback.trigger("some-event")

                expect(callbackWasCalled) == false
            }

            it("Should have a class function to check if a source can be played with default value false") {
                let canPlay = Playback.canPlay([:])
                expect(canPlay) == false
            }

            context("AutoPlay") {
                it("Should have autoplay set to false if autoplay option is not set") {
                    expect(playback.autoPlay) == false
                }

                it("Should have autoplay set to false if autoplay option is false") {
                    let playback = StubPlayback(options: [kAutoPlay : false])
                    expect(playback.autoPlay) == false
                }

                it("Should have autoplay set to true if autoplay option is true") {
                    let playback = StubPlayback(options: [kAutoPlay : true])
                    expect(playback.autoPlay) == true
                }

                it("Should call play on render if auto play is set") {
                    let playback = StubPlayback(options: [kAutoPlay : true])
                    playback.render()
                    expect(playback.playWasCalled) == true
                }

                it("Should not call play on render if auto play is set to false") {
                    let playback = StubPlayback(options: [kAutoPlay : false])
                    playback.render()
                    expect(playback.playWasCalled) == false
                }
            }

            context("Playback source") {
                it("Should have a source property with the url sent via options") {
                    let playback = StubPlayback(options: [kSourceUrl: "someUrl"])
                    expect(playback.source) == "someUrl"
                }

                it("Should have a source property with nil if no source is set") {
                    let playback = StubPlayback(options: [:])
                    expect(playback.source).to(beNil())
                }
            }
        }
    }

    class StubPlayback: Playback {
        var playWasCalled = false

        override var pluginName: String {
            return "stupPlayback"
        }

        override func play() {
            playWasCalled = true
        }
    }
}

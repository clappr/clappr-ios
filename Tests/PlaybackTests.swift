import Quick
import Nimble
@testable import Clappr

class PlaybackTests: QuickSpec {

    override func spec() {
        describe("Playback") {
            var playback: StubPlayback!
            let options = [kSourceUrl: "http://globo.com/video.mp4"]

            beforeEach {
                playback = StubPlayback(options: options as Options)
            }

            it("set frame of Playback to CGRect.zero") {
                expect(playback.frame) == CGRect.zero
            }

            it("set backgroundColor to clear") {
                expect(playback.backgroundColor).to(beNil())
            }

            it("set isUserInteractionEnabled to false") {
                expect(playback.isUserInteractionEnabled) == false
            }

            it("have a play method") {
                let responds = playback.responds(to: #selector(Playback.play))
                expect(responds).to(beTrue())
            }

            it("have a pause method") {
                let responds = playback.responds(to: #selector(Progress.pause))
                expect(responds).to(beTrue())
            }

            it("have a stop method") {
                let responds = playback.responds(to: #selector(NetService.stop))
                expect(responds).to(beTrue())
            }

            it("have a seek method receiving a time") {
                let responds = playback.responds(to: #selector(Playback.seek(_:)))
                expect(responds).to(beTrue())
            }

            it("have a duration var with a default value 0") {
                expect(playback.duration) == 0
            }

            it("have a isPlaying var with a default value false") {
                expect(playback.isPlaying).to(beFalse())
            }

            it("have a type var with a default value Unknown") {
                expect(playback.playbackType).to(equal(PlaybackType.unknown))
            }

            it("have a isHighDefinitionInUse var with a default value false") {
                expect(playback.isHighDefinitionInUse).to(beFalse())
            }

            it("removed from superview when destroy is called") {
                let container = UIView()
                container.addSubview(playback)

                expect(playback.superview).toNot(beNil())
                playback.destroy()
                expect(playback.superview).to(beNil())
            }

            it("stop listening events after destroy has been called") {
                var callbackWasCalled = false

                playback.on("some-event") { _ in
                    callbackWasCalled = true
                }

                playback.destroy()
                playback.trigger("some-event")

                expect(callbackWasCalled) == false
            }

            it("have a class function to check if a source can be played with default value false") {
                let canPlay = Playback.canPlay([:])
                expect(canPlay) == false
            }

            context("StartAt") {
                it("set start at property from options") {
                    let playback = StubPlayback(options: [kStartAt: 10.0])
                    expect(playback.startAt) == 10.0
                }

                it("have startAt with 0 if no time is set on options") {
                    let playback = StubPlayback(options: [:])
                    expect(playback.startAt) == 0.0
                }

                it("seek video when rendering if startAt is set") {
                    let playback = StubPlayback(options: [kStartAt: 15.0])
                    playback.render()
                    playback.play()
                    expect(playback.seekWasCalledWithValue) == 15.0
                }
            }

            context("Playback source") {
                it("have a source property with the url sent via options") {
                    let playback = StubPlayback(options: [kSourceUrl: "someUrl"])
                    expect(playback.source) == "someUrl"
                }

                it("have a source property with nil if no source is set") {
                    let playback = StubPlayback(options: [:])
                    expect(playback.source).to(beNil())
                }
            }
        }
    }

    class StubPlayback: Playback {
        var playWasCalled = false
        var seekWasCalledWithValue: TimeInterval = -1

        override var pluginName: String {
            return "stupPlayback"
        }

        override func play() {
            trigger(.ready)
            playWasCalled = true
        }

        override func seek(_ timeInterval: TimeInterval) {
            seekWasCalledWithValue = timeInterval
        }
    }
}

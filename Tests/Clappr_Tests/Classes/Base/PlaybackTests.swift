import Quick
import Nimble
@testable import Clappr

class PlaybackTests: QuickSpec {

    override func spec() {
        describe("Playback") {
            var playback: Playback!
            let options = [kSourceUrl: "http://globo.com/video.mp4"]

            beforeEach {
                playback = Playback(options: options as Options)
            }

            describe("#name") {
                it("throws an exception because it is an `abstract` class") {
                    let expectedExceptionName = "MissingPlaybackName"
                    let expectedExceptionReason = "Playbacks should always declare a name. Playback does not."

                    expect(Playback.name).to(raiseException(named: expectedExceptionName, reason: expectedExceptionReason))
                }
            }

            it("sets frame of Playback to CGRect.zero") {
                expect(playback.view.frame) == CGRect.zero
            }

            it("sets backgroundColor to clear") {
                expect(playback.view.backgroundColor).to(beNil())
            }

            it("sets isUserInteractionEnabled to false") {
                expect(playback.view.isUserInteractionEnabled) == false
            }

            it("has a play method") {
                let responds = playback.responds(to: #selector(Playback.play))
                expect(responds).to(beTrue())
            }

            it("has a pause method") {
                let responds = playback.responds(to: #selector(Progress.pause))
                expect(responds).to(beTrue())
            }

            it("has a stop method") {
                let responds = playback.responds(to: #selector(NetService.stop))
                expect(responds).to(beTrue())
            }

            it("has a seek method receiving a time") {
                let responds = playback.responds(to: #selector(Playback.seek(_:)))
                expect(responds).to(beTrue())
            }

            it("has a duration var with a default value 0") {
                expect(playback.duration) == 0
            }

            it("have a type var with a default value Unknown") {
                expect(playback.playbackType).to(equal(PlaybackType.unknown))
            }

            it("has a isHighDefinitionInUse var with a default value false") {
                expect(playback.isHighDefinitionInUse).to(beFalse())
            }

            it("is removed from superview when destroy is called") {
                let container = UIView()
                container.addSubview(playback.view)

                expect(playback.view.superview).toNot(beNil())
                playback.destroy()
                expect(playback.view.superview).to(beNil())
            }

            it("stops listening to events after destroy has been called") {
                var callbackWasCalled = false

                playback.on("some-event") { _ in
                    callbackWasCalled = true
                }

                playback.destroy()
                playback.trigger("some-event")

                expect(callbackWasCalled) == false
            }
            
            it("calls stop when destroy is called") {
                let playbackSpy = PlaybackSpy(options: options)
                
                playbackSpy.destroy()
                
                expect(playbackSpy.didCallStop).to(beTrue())
            }

            it("has a class function to check if a source can be played with default value false") {
                let canPlay = Playback.canPlay([:])
                expect(canPlay) == false
            }

            it("has a canPlay flag set to false") {
                let playback = Playback(options: [:])
                expect(playback.canPlay).to(beFalse())
            }

            it("has a canPause flag set to false") {
                let playback = Playback(options: [:])
                expect(playback.canPause).to(beFalse())
            }

            it("has a canSeek flag set to false") {
                let playback = Playback(options: [:])
                expect(playback.canSeek).to(beFalse())
            }
            
            it("delegate render to PlaybackRenderer") {
                let playback = Playback(options: [:])
                let playbackRenderer = MockPlaybackRenderer()
                playback.playbackRenderer = playbackRenderer
                
                playback.render()
                
                expect(playbackRenderer.didCallRender).to(beTrue())
            }

            context("StartAt") {
                it("set start at property from options") {
                    let playback = Playback(options: [kStartAt: 10.0])
                    expect(playback.startAt) == 10.0
                }

                it("has startAt with 0 if no time is set on options") {
                    let playback = Playback(options: [:])
                    expect(playback.startAt) == 0.0
                }
            }
            
            context("LiveStartTime") {
                it("set start at property from options") {
                    let playback = Playback(options: [kLiveStartTime: 10000.0])
                    expect(playback.liveStartTime) == 10000.0
                }

                it("has liveStartTime with nil value if no time is set on options") {
                    let playback = Playback(options: [:])
                    expect(playback.liveStartTime).to(beNil())
                }
            }


            context("Playback source") {
                it("has a source property with the url sent via options") {
                    let playback = Playback(options: [kSourceUrl: "someUrl"])
                    expect(playback.source) == "someUrl"
                }

                it("has a source property with nil if no source is set") {
                    let playback = Playback(options: [:])
                    expect(playback.source).to(beNil())
                }
            }

            describe("#options") {
                it("triggers didUpdateOptions when setted") {
                    var didUpdateOptionsTriggered = false
                    playback.on(Event.didUpdateOptions.rawValue) { _ in
                        didUpdateOptionsTriggered = true
                    }

                    playback.options = [:]

                    expect(didUpdateOptionsTriggered).toEventually(beTrue())
                }
            }
        }
    }
}

class PlaybackSpy: Playback {
    var didCallStop = false
    
    override func stop() {
        didCallStop = true
    }
}

class MockPlaybackRenderer: PlaybackRendererProtocol {
    var didCallRender = false
    
    func render(playback: Playback) {
        didCallRender = true
    }
}

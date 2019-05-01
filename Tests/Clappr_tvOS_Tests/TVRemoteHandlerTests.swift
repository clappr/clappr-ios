import Quick
import Nimble
import AVKit

@testable import Clappr

class TVRemoteHandlerTests: QuickSpec {
    static let specialSource = "specialSource"

    override func spec() {
        describe("TV Remote Controller Handler") {

            let options = [kSourceUrl: "http://clappr.com/video.mp4"]

            var player: Player!
            var playback: Playback!
            var playerViewController: AVPlayerViewController!
            var handler: TVRemoteHandler!

            beforeEach {
                Loader.shared.resetPlugins()
                player = Player(options: options, externalPlugins: [SpecialStubPlayback.self, StubPlayback.self])
                playback = player.activePlayback
                playerViewController = AVPlayerViewController()
                handler = TVRemoteHandler(playerViewController: playerViewController, player: player)
            }

            describe("init") {
                it("adds gesture recognizer on the view controller") {
                    let playerViewController = AVPlayerViewController()
                    let gestureCount = playerViewController.view.gestureRecognizers?.count ?? 0

                    _ = TVRemoteHandler(playerViewController: playerViewController, player: player)

                    expect(playerViewController.view.gestureRecognizers?.count).to(equal(gestureCount + 1))
                }
            }

            describe("handleTvRemoteGesture") {
                context("when media is playing") {
                    it("pauses the playback") {
                        var callbackWasCalled = false
                        playback.play()
                        player.on(.willPause) { _ in
                            callbackWasCalled = true
                        }

                        handler.handleTvRemoteGesture()

                        expect(callbackWasCalled).to(beTrue())
                    }
                }

                context("when media is paused") {
                    it("plays the playback") {
                        var callbackWasCalled = false
                        playback.pause()
                        player.on(.willPlay) { _ in
                            callbackWasCalled = true
                        }

                        handler.handleTvRemoteGesture()

                        expect(callbackWasCalled).to(beTrue())
                    }
                }
            }
        }

        class StubPlayback: Playback {
            override var pluginName: String {
                return "StubPlayback"
            }

            override class func canPlay(_: Options) -> Bool {
                return true
            }
        }

        class SpecialStubPlayback: Playback {
            override var pluginName: String {
                return "SpecialStubPlayback"
            }

            override class func canPlay(_ options: Options) -> Bool {
                return options[kSourceUrl] as! String == PlayerTests.specialSource
            }
        }
    }
}

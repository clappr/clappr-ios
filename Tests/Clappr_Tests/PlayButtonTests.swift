import Quick
import Nimble

@testable import Clappr

class PlayButtonTests: QuickSpec {
    override func spec() {
        describe(".PlayButton") {

            describe("#init") {
                it("is an MediaControlPlugin type") {
                    let playButton = PlayButton()

                    expect(playButton).to(beAKindOf(MediaControlPlugin.self))
                }
            }

            describe("pluginName") {
                it("has a name") {
                    let playButton = PlayButton()

                    expect(playButton.pluginName).to(equal("PlayButton"))
                }
            }

            describe("panel") {
                it("is positioned in the center panel") {
                    let playButton = PlayButton()

                    expect(playButton.panel).to(equal(MediaControlPanel.center))
                }
            }

            describe("position") {
                it("is aligned in the center") {
                    let playButton = PlayButton()

                    expect(playButton.position).to(equal(MediaControlPosition.center))
                }
            }

            describe("when a video is loaded") {

                var coreStub: CoreStub!
                var playButton: PlayButton!

                beforeEach {
                    coreStub = CoreStub()
                    playButton = PlayButton(context: coreStub)
                }

                context("and video is vod") {
                    it("shows button") {
                        playButton.render()

                        coreStub.activeContainer?.trigger(Event.stalled.rawValue)

                        expect(playButton.view.isHidden).to(beFalse())
                    }
                }
            }

            context("when click on button") {

                var coreStub: CoreStub!
                var playButton: PlayButton!

                beforeEach {
                    coreStub = CoreStub()
                    playButton = PlayButton(context: coreStub)
                    playButton.render()
                }

                context("and enters in background and receive a didPause event") {
                    it("shows play button") {
                        coreStub.activePlayback?.trigger(Event.didPause)

                        expect(playButton.view.isHidden).toEventually(beFalse())
                    }
                }

                context("and a video is paused") {
                    beforeEach {
                        coreStub.playbackMock?.set(isPaused: true)
                    }

                    it("calls the playback play") {
                        playButton.button.sendActions(for: .touchUpInside)

                        expect(coreStub.playbackMock?.didCallPlay).to(beTrue())
                    }

                    it("shows play button") {
                        playButton.button.sendActions(for: .touchUpInside)

                        expect(playButton.view.isHidden).toEventually(beFalse())
                    }
                }
            }

            context("when click on button during playback") {

                var coreStub: CoreStub!
                var playButton: PlayButton!

                beforeEach {
                    coreStub = CoreStub()
                    playButton = PlayButton(context: coreStub)
                    playButton.render()
                }

                context("and a video is playing") {

                    beforeEach {
                        coreStub.playbackMock?.set(isPlaying: true)
                    }

                    it("calls the playback pause") {
                        playButton.button.sendActions(for: .touchUpInside)

                        expect(coreStub.playbackMock?.didCallPause).to(beTrue())
                    }

                    it("changes the image to a play icon") {
                        let playIcon = UIImage.from(name: "play")!

                        playButton.button.sendActions(for: .touchUpInside)

                        let currentButtonIcon = (playButton.button.imageView?.image)!
                        expect(currentButtonIcon.isEqualTo(image: playIcon)).toEventually(beTrue())
                    }

                    context("and is vod") {
                        it("shows button") {
                            let coreStub = CoreStub()
                            let playButton = PlayButton(context: coreStub)
                            playButton.render()
                            playButton.view.isHidden = true

                            coreStub.activePlayback?.trigger(Event.playing.rawValue)

                            expect(playButton.view.isHidden).to(beFalse())
                        }
                    }
                }

                context("and a video is paused") {

                    beforeEach {
                        coreStub.playbackMock?.set(isPaused: true)
                    }

                    it("calls the playback play") {
                        playButton.button.sendActions(for: .touchUpInside)

                        expect(coreStub.playbackMock?.didCallPlay).to(beTrue())
                    }

                    it("changes the image to a pause icon") {
                        let pauseIcon = UIImage.from(name: "pause")!

                        playButton.button.sendActions(for: .touchUpInside)

                        let currentButtonIcon = (playButton.button.imageView?.image)!
                        expect(currentButtonIcon.isEqualTo(image: pauseIcon)).toEventually(beTrue())
                    }

                    context("and is vod") {
                        it("shows button") {
                            let coreStub = CoreStub()
                            let playButton = PlayButton(context: coreStub)
                            playButton.render()
                            playButton.view.isHidden = true

                            coreStub.activePlayback?.trigger(Event.didPause.rawValue)

                            expect(playButton.view.isHidden).to(beFalse())
                        }
                    }
                }
            }

            describe("render") {

                it("set's acessibilityIdentifier to button") {
                    let playButton = PlayButton()

                    playButton.render()

                    expect(playButton.button.accessibilityIdentifier).to(equal("PlayPauseButton"))
                }

                describe("button") {
                    it("adds it in the view") {
                        let playButton = PlayButton()

                        playButton.render()

                        expect(playButton.view.subviews).to(contain(playButton.button))
                    }

                    it("has scaleAspectFit content mode") {
                        let playButton = PlayButton()

                        playButton.render()

                        expect(playButton.button.imageView?.contentMode).to(equal(UIViewContentMode.scaleAspectFit))
                    }
                }

            }

            context("when stalled") {
                it("hides the plugin") {
                    let coreStub = CoreStub()
                    let playButton = PlayButton(context: coreStub)

                    coreStub.activePlayback?.trigger(Event.stalled.rawValue)

                    expect(playButton.view.isHidden).to(beTrue())
                }

                it("hides the plugin") {
                    let coreStub = CoreStub()
                    let playButton = PlayButton(context: coreStub)

                    coreStub.activePlayback?.trigger(Event.playing.rawValue)

                    expect(playButton.view.isHidden).to(beFalse())
                }
            }
        }
    }
}

extension UIImage {

    func isEqualTo(image: UIImage) -> Bool {
        let data1: Data = UIImagePNGRepresentation(self)!
        let data2: Data = UIImagePNGRepresentation(image)!
        return data1 == data2
    }

}

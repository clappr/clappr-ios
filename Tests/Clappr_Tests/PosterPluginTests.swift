import Quick
import Nimble
@testable import Clappr

class PosterPluginTests: QuickSpec {

    override func spec() {

        describe(".PosterPlugin") {
            var container: Container!
            let options = [
                kSourceUrl: "http://globo.com/video.mp4",
                kPosterUrl: "http://clappr.io/poster.png",
            ]

            context("when container has no options") {
                it("hides itself") {
                    container = Container()
                    container.render()

                    let posterPlugin = self.getPosterPlugin(container)

                    expect(posterPlugin.isHidden).to(beTrue())
                }
            }

            context("when container doesnt have posterUrl option") {
                it("hides itself") {
                    container = Container(options: ["anotherOption": true])
                    container.render()

                    let posterPlugin = self.getPosterPlugin(container)

                    expect(posterPlugin.isHidden).to(beTrue())
                }
            }

            context("when container has posterUrl option") {
                it("it renders itself") {
                    container = Container(options: options)
                    container.render()

                    let posterPlugin = self.getPosterPlugin(container)

                    expect(posterPlugin.superview) == container
                }
            }

            context("when changes the activePlayback") {

                var posterPlugin: PosterPlugin!

                beforeEach {
                    container = Container()
                }

                context("to NoOpPlayback") {

                    beforeEach {
                        container.playback = NoOpPlayback()
                        posterPlugin = self.getPosterPlugin(container)
                    }

                    it("hides itself") {
                        expect(posterPlugin.isHidden).toEventually(beTrue())
                    }

                    it("isNoOpPlayback is true") {
                        expect(posterPlugin.isNoOpPlayback) == true
                    }

                    context("and change again to another playback") {

                        beforeEach {
                            container.playback = AVFoundationPlayback()
                            posterPlugin = self.getPosterPlugin(container)
                        }

                        it("hides itself") {
                            expect(posterPlugin.isHidden).toEventually(beTrue())
                        }
                    }
                }

                context("to another a playback diferent from NoOpPlayback") {

                    beforeEach {
                        container.playback = AVFoundationPlayback()
                        posterPlugin = self.getPosterPlugin(container)
                    }

                    it("reveal itself") {
                        expect(posterPlugin.isHidden).toEventually(beFalse())
                    }

                    it("isNoOpPlayback is true") {
                        expect(posterPlugin.isNoOpPlayback) == false
                    }
                }
            }

            describe("Playback Events") {
                var posterPlugin: PosterPlugin!

                beforeEach {
                    container = Container(options: options)
                    container.render()
                    posterPlugin = self.getPosterPlugin(container)
                }

                context("when playback trigger a play event") {
                    it("hides itself") {
                        expect(posterPlugin.isHidden).to(beFalse())
                        container.playback?.trigger(Event.playing.rawValue)
                        expect(posterPlugin.isHidden).to(beTrue())
                    }
                }

                context("when playback trigger a end event") {
                    it("reveal itself") {
                        container.playback?.trigger(Event.playing.rawValue)
                        container.playback?.trigger(Event.didComplete.rawValue)

                        expect(posterPlugin.isHidden).to(beFalse())
                    }
                }
            }

            describe("When receiving didUpdateOptions event") {
                var posterPlugin: PosterPlugin!

                beforeEach {
                    container = Container(options: options)
                    container.render()
                    posterPlugin = self.getPosterPlugin(container)
                }

                it("updates the poster") {
                    container.options[kPosterUrl] = "https://clappr.io/another-poster.png"

                    expect(posterPlugin.poster.kf.webURL?.absoluteString).to(equal("https://clappr.io/another-poster.png"))
                }
            }
        }
    }

    private func getPosterPlugin(_ container: Container) -> PosterPlugin {
        return container.plugins.filter({ $0.isKind(of: PosterPlugin.self) }).first as! PosterPlugin
    }
}

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

            context("when change a playback") {

                var posterPlugin: PosterPlugin!

                beforeEach {
                    container = Container()
                }

                context("and playback is NoOP") {

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
                }

                context("and playback isnt NoOp") {

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

            describe("Container Events") {
                var posterPlugin: PosterPlugin!

                beforeEach {
                    container = Container(options: options)
                    container.render()
                    posterPlugin = self.getPosterPlugin(container)
                }

                context("when container trigger a play event") {
                    it("hides itself") {
                        expect(posterPlugin.isHidden).to(beFalse())
                        container.playback?.trigger(Event.playing.rawValue)
                        expect(posterPlugin.isHidden).to(beTrue())
                    }
                }

                context("when container trigger a end event") {
                    it("reveal itself") {
                        container.playback?.trigger(Event.playing.rawValue)
                        container.playback?.trigger(Event.didComplete.rawValue)

                        expect(posterPlugin.isHidden).to(beFalse())
                    }
                }
            }
        }
    }

    private func getPosterPlugin(_ container: Container) -> PosterPlugin {
        return container.plugins.filter({ $0.isKind(of: PosterPlugin.self) }).first as! PosterPlugin
    }
}

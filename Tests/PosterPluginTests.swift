import Quick
import Nimble
import Clappr

class PosterPluginTests: QuickSpec {

    override func spec() {
        describe("Poster Plugin") {
            var container: Container!
            let options = [
                kSourceUrl: "http://globo.com/video.mp4",
                kPosterUrl: "http://clappr.io/poster.png",
            ]

            context("Initialization") {
                it("Should not be visible if container has no options") {
                    container = Container()
                    container.render()

                    let posterPlugin = self.getPosterPlugin(container)

                    expect(posterPlugin.isHidden).to(beTrue())
                }

                it("Should not be visible if container doesn't have posterUrl Option") {
                    container = Container(options: ["anotherOption": true])
                    container.render()

                    let posterPlugin = self.getPosterPlugin(container)

                    expect(posterPlugin.isHidden).to(beTrue())
                }

                it("Should be rendered if container have posterUrl Option") {
                    container = Container(options: options)
                    container.render()

                    let posterPlugin = self.getPosterPlugin(container)

                    expect(posterPlugin.superview) == container
                }

                it("Should be hidden if playback is a NoOp") {
                    container = Container(options: [kSourceUrl: "none", kPosterUrl: "http://clappr.io/poster.png"])
                    container.render()

                    let posterPlugin = self.getPosterPlugin(container)

                    expect(posterPlugin.isHidden).to(beTrue())
                }
            }

            context("State") {
                var posterPlugin: PosterPlugin!

                beforeEach {
                    container = Container(options: options)
                    container.render()
                    posterPlugin = self.getPosterPlugin(container)
                }

                it("Should be hidden after container Play event ") {
                    expect(posterPlugin.isHidden).to(beFalse())
                    container.playback?.trigger(Event.playing.rawValue)
                    expect(posterPlugin.isHidden).to(beTrue())
                }

                it("Should be not hidden after container Ended event") {
                    container.playback?.trigger(Event.playing.rawValue)
                    container.playback?.trigger(Event.didComplete.rawValue)

                    expect(posterPlugin.isHidden).to(beFalse())
                }
            }
        }
    }

    private func getPosterPlugin(_ container: Container) -> PosterPlugin {
        return container.plugins.filter({ $0.isKind(of: PosterPlugin.self) }).first as! PosterPlugin
    }
}

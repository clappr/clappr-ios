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
                    container = ContainerFactory.create(with: [:])
                    container.render()

                    let posterPlugin = self.getPosterPlugin(container)

                    expect(posterPlugin.view.isHidden).to(beTrue())
                }
            }

            context("when container doesnt have posterUrl option") {
                it("hides itself") {
                    container = ContainerFactory.create(with: ["anotherOption": true])
                    container.render()

                    let posterPlugin = self.getPosterPlugin(container)

                    expect(posterPlugin.view.isHidden).to(beTrue())
                }
            }

            context("when container has posterUrl option") {
                it("it renders itself") {
                    container = ContainerFactory.create(with: options)
                    container.render()

                    let posterPlugin = self.getPosterPlugin(container)

                    expect(posterPlugin.view.superview) == container.view
                }
            }

            context("when changes the activePlayback") {

                var posterPlugin: PosterPlugin!

                beforeEach {
                    container = ContainerFactory.create(with: [:])
                }

                context("to NoOpPlayback") {

                    beforeEach {
                        container.playback = NoOpPlayback(options: [:])
                        posterPlugin = self.getPosterPlugin(container)
                    }

                    it("hides itself") {
                        expect(posterPlugin.view.isHidden).toEventually(beTrue())
                    }

                    it("isNoOpPlayback is true") {
                        expect(posterPlugin.isNoOpPlayback) == true
                    }

                    context("and change again to another playback") {

                        beforeEach {
                            container.playback = AVFoundationPlayback(options: [:])
                            posterPlugin = self.getPosterPlugin(container)
                        }

                        it("hides itself") {
                            expect(posterPlugin.view.isHidden).toEventually(beTrue())
                        }
                    }
                }

                context("to another a playback diferent from NoOpPlayback") {

                    beforeEach {
                        container.playback = AVFoundationPlayback(options: [:])
                        posterPlugin = self.getPosterPlugin(container)
                    }

                    it("reveal itself") {
                        expect(posterPlugin.view.isHidden).toEventually(beFalse())
                    }

                    it("isNoOpPlayback is true") {
                        expect(posterPlugin.isNoOpPlayback) == false
                    }
                }
            }

            describe("Playback Events") {
                var posterPlugin: PosterPlugin!

                beforeEach {
                    container = ContainerFactory.create(with: options)
                    container.load(options[kSourceUrl]!)
                    container.render()
                    posterPlugin = self.getPosterPlugin(container)
                }

                context("when playback trigger a play event") {
                    it("hides itself") {
                        expect(posterPlugin.view.isHidden).to(beFalse())
                        container.playback?.trigger(Event.playing.rawValue)
                        expect(posterPlugin.view.isHidden).to(beTrue())
                    }
                }

                context("when playback trigger a end event") {
                    it("reveal itself") {
                        container.playback?.trigger(Event.playing.rawValue)
                        container.playback?.trigger(Event.didComplete.rawValue)

                        expect(posterPlugin.view.isHidden).to(beFalse())
                    }
                }
            }
        }
    }

    private func getPosterPlugin(_ container: Container) -> PosterPlugin {
        return container.plugins.filter({ $0.pluginName == PosterPlugin.name }).first as! PosterPlugin
    }
}

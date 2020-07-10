import Quick
import Nimble
@testable import Clappr

class PosterPluginTests: QuickSpec {

    override func spec() {

        describe(".PosterPlugin") {
            var core: Core!
            let options = [
                kSourceUrl: "http://globo.com/video.mp4",
                kPosterUrl: "http://clappr.io/poster.png",
            ]

            beforeEach {
                Loader.shared.register(plugins: [PosterPlugin.self])
            }

            afterEach {
                Loader.shared.resetPlugins()
            }

            context("when core has no options") {
                it("hides itself") {
                    core = CoreFactory.create(with: [:])
                    core.render()

                    let posterPlugin = self.getPosterPlugin(core.activeContainer)

                    expect(posterPlugin.view.isHidden).to(beTrue())
                }
            }

            context("when core doesnt have posterUrl option") {
                it("hides itself") {
                    core = CoreFactory.create(with: ["anotherOption": true])
                    core.render()

                    let posterPlugin = self.getPosterPlugin(core.activeContainer)

                    expect(posterPlugin.view.isHidden).to(beTrue())
                }
            }

            context("when core has posterUrl option") {
                it("it renders itself") {
                    core = CoreFactory.create(with: options)
                    core.render()

                    let posterPlugin = self.getPosterPlugin(core.activeContainer)

                    expect(posterPlugin.view.superview).to(equal(core.activeContainer?.view))
                }
            }

            context("when changes the activePlayback") {
                var posterPlugin: PosterPlugin!

                beforeEach {
                    core = CoreFactory.create(with: [:])
                }

                context("to NoOpPlayback") {
                    beforeEach {
                        core.activeContainer?.playback = NoOpPlayback(options: [:])
                        posterPlugin = self.getPosterPlugin(core.activeContainer)
                    }

                    it("hides itself") {
                        expect(posterPlugin.view.isHidden).toEventually(beTrue())
                    }

                    it("isNoOpPlayback is true") {
                        expect(posterPlugin.isNoOpPlayback).to(beTrue())
                    }

                    context("and change again to another playback") {
                        beforeEach {
                            core.activeContainer?.playback = AVFoundationPlayback(options: [:])
                            posterPlugin = self.getPosterPlugin(core.activeContainer)
                        }

                        it("hides itself") {
                            expect(posterPlugin.view.isHidden).toEventually(beTrue())
                        }
                    }
                }

                context("to another a playback diferent from NoOpPlayback") {

                    beforeEach {
                        core.activeContainer?.playback = AVFoundationPlayback(options: [:])
                        posterPlugin = self.getPosterPlugin(core.activeContainer)
                    }

                    it("reveal itself") {
                        expect(posterPlugin.view.isHidden).toEventually(beFalse())
                    }

                    it("isNoOpPlayback is false") {
                        expect(posterPlugin.isNoOpPlayback).to(beFalse())
                    }
                }
            }

            describe("Playback Events") {
                var posterPlugin: PosterPlugin!

                beforeEach {
                    core = CoreFactory.create(with: options)
                    core.load()
                    posterPlugin = self.getPosterPlugin(core.activeContainer)
                }

                context("when playback trigger a play event") {
                    it("hides itself") {
                        core.activeContainer?.playback?.trigger(Event.playing.rawValue)
                        expect(posterPlugin.view.isHidden).to(beTrue())
                    }
                }

                context("when playback trigger a end event") {
                    it("do not reveal itself") {
                        core.activeContainer?.playback?.trigger(Event.playing.rawValue)
                        core.activeContainer?.playback?.trigger(Event.didComplete.rawValue)

                        expect(posterPlugin.view.isHidden).to(beTrue())
                    }
                }
            }
        }
    }

    private func getPosterPlugin(_ container: Container?) -> PosterPlugin {
        return container?.plugins.first { $0.pluginName == PosterPlugin.name } as! PosterPlugin
    }
}

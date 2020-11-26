import Quick
import Nimble
@testable import Clappr

class PosterPluginTests: QuickSpec {

    override func spec() {

        describe(".PosterPlugin") {
            var core: Core!
            var layerComposer: LayerComposer!
            let options = [
                kSourceUrl: "http://globo.com/video.mp4",
                kPosterUrl: "http://clappr.io/poster.png",
            ]

            beforeEach {
                layerComposer = LayerComposer()
                Loader.shared.register(plugins: [PosterPlugin.self])
            }

            afterEach {
                layerComposer = nil
                Loader.shared.resetPlugins()
            }

            context("when core has no options") {
                it("hides itself") {
                    core = CoreFactory.create(with: [:], layerComposer: layerComposer)
                    core.render()

                    let posterPlugin = self.getPosterPlugin(core)

                    expect(posterPlugin.view.isHidden).to(beTrue())
                }
            }

            context("when core doesnt have posterUrl option") {
                it("hides itself") {
                    core = CoreFactory.create(with: ["anotherOption": true], layerComposer: layerComposer)
                    core.render()

                    let posterPlugin = self.getPosterPlugin(core)

                    expect(posterPlugin.view.isHidden).to(beTrue())
                }
            }

            context("when core has posterUrl option") {
                it("it renders itself") {
                    core = CoreFactory.create(with: options, layerComposer: layerComposer)
                    core.render()

                    let posterPlugin = self.getPosterPlugin(core)

                    expect(posterPlugin.view.superview).to(equal(core.overlayView))
                }
            }

            context("when changes the activePlayback") {
                var posterPlugin: PosterPlugin!

                beforeEach {
                    core = CoreFactory.create(with: [:], layerComposer: layerComposer)
                }

                context("to NoOpPlayback") {
                    beforeEach {
                        core.activeContainer?.playback = NoOpPlayback(options: [:])
                        posterPlugin = self.getPosterPlugin(core)
                    }

                    it("hides itself") {
                        expect(posterPlugin.view.isHidden).toEventually(beTrue())
                    }

                    it("isNoOpPlayback is true") {
                        expect(posterPlugin.activePlayback).to(beAKindOf(NoOpPlayback.self))
                    }

                    context("and change again to another playback") {
                        beforeEach {
                            core.activeContainer?.playback = AVFoundationPlayback(options: [:])
                            posterPlugin = self.getPosterPlugin(core)
                        }

                        it("hides itself") {
                            expect(posterPlugin.view.isHidden).toEventually(beTrue())
                        }
                    }
                }

                context("to another a playback diferent from NoOpPlayback") {

                    beforeEach {
                        core.activeContainer?.playback = AVFoundationPlayback(options: [:])
                        posterPlugin = self.getPosterPlugin(core)
                    }

                    it("reveal itself") {
                        expect(posterPlugin.view.isHidden).toEventually(beFalse())
                    }

                    it("isNoOpPlayback is false") {
                        expect(posterPlugin).toNot(beAKindOf(NoOpPlayback.self))
                    }
                }
            }

            describe("Playback Events") {
                var posterPlugin: PosterPlugin!

                beforeEach {
                    core = CoreFactory.create(with: options, layerComposer: layerComposer)
                    core.load()
                    posterPlugin = self.getPosterPlugin(core)
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

    private func getPosterPlugin(_ core: Core?) -> PosterPlugin {
        return core?.plugins.first { $0.pluginName == PosterPlugin.name } as! PosterPlugin
    }
}

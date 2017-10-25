import Quick
import Nimble
@testable import Clappr

class CoreTests: QuickSpec {
    override func spec() {
        class StubPlayback: Playback {
            override var pluginName: String {
                return "stupPlayback"
            }
        }

        class FakeCorePlugin: UICorePlugin {
            override var pluginName: String {
                return "FakeCorePLugin"
            }
        }

        let options = [kSourceUrl: "http//test.com"]
        var core: Core!
        let loader = Loader(externalPlugins: [StubPlayback.self])

        beforeEach {
            core = Core(loader: loader, options: options as Options)
        }

        describe("Core") {
            context("Options") {

                it("Should have a constructor with options") {
                    let options = ["SomeOption": true]
                    let core = Core(loader: loader, options: options as Options)

                    expect(core.options["SomeOption"] as? Bool) == true
                }

                context("Fullscreen") {
                    it("Should start as embed video when `kFullscreen: false`") {
                        let options: Options = [kFullscreen: false]
                        let core = Core(options: options)
                        core.parentView = UIView()

                        core.render()

                        expect(core.parentView?.subviews.contains(core)).to(beTrue())
                        expect(core.mediaControl?.fullscreen).to(beFalse())
                    }

                    it("Should start as embed video when `kFullscreen` was not passed") {
                        let core = Core()
                        core.parentView = UIView()

                        core.render()

                        expect(core.parentView?.subviews.contains(core)).to(beTrue())
                        expect(core.mediaControl?.fullscreen).to(beFalse())
                    }

                    it("Should start as fullscreen video when `kFullscreen: true` was passed") {
                        let options: Options = [kFullscreen: true]
                        let core = Core(options: options)
                        core.parentView = UIView()
                        var callbackWasCall = false
                        core.on(InternalEvent.didEnterFullscreen.rawValue) { _ in
                            callbackWasCall = true
                        }

                        core.render()

                        expect(callbackWasCall).toEventually(beTrue())
                        expect(core.parentView?.subviews.contains(core)).to(beFalse())
                        expect(core.fullscreenController.view.subviews.contains(core)).to(beTrue())
                        expect(core.mediaControl?.fullscreen).to(beTrue())
                    }

                    it("Should start as embed video when `kFullscreen: true` and `kFullscreenByApp: true` was passed") {
                        let options: Options = [kFullscreen: true, kFullscreenByApp: true]
                        let core = Core(options: options)
                        core.parentView = UIView()

                        core.render()

                        expect(core.parentView?.subviews.contains(core)).to(beTrue())
                        expect(core.mediaControl?.fullscreen).to(beFalse())
                    }

                    it("Should start as fullscreen video when `kFullscreen: true` and `kFullscreenByApp: false` was passed") {
                        let player = Player(options: [kFullscreen: true] as Options)
                        var callbackWasCalled = false
                        player.on(.requestFullscreen) { _ in
                            callbackWasCalled = true
                        }
                        player.attachTo(UIView(), controller: UIViewController())

                        player.setFullscreen(true)

                        expect(callbackWasCalled).toEventually(beTrue())
                        expect(player.core!.parentView?.subviews.contains(core)).to(beFalse())
                        expect(player.core!.mediaControl?.fullscreen).to(beTrue())
                    }

                    it("Should set to fullscreen video by call `setFullscreen(true)`") {
                        let core = Core()
                        core.parentView = UIView()

                        core.render()
                        core.setFullscreen(true)

                        expect(core.parentView?.subviews.contains(core)).to(beFalse())
                        expect(core.fullscreenController.view.subviews.contains(core)).to(beTrue())
                        expect(core.mediaControl?.fullscreen).to(beTrue())
                    }

                    it("Should not try to set fullscreen video twice by call `setFullscreen(true)` twice") {
                        let core = Core()
                        core.parentView = UIView()

                        core.render()
                        core.setFullscreen(true)
                        core.setFullscreen(true)

                        expect(core.parentView?.subviews.contains(core)).to(beFalse())
                        expect(core.fullscreenController.view.subviews.filter { $0 == core }.count).to(equal(1))
                        expect(core.mediaControl?.fullscreen).to(beTrue())
                    }
                }
            }

            context("Containers") {
                it("Should be created given a source") {
                    expect(core.activeContainer).toNot(beNil())
                    expect(core.plugins).to(beEmpty())
                    expect(core.containers).toNot(beEmpty())
                }
            }

            context("Media Control") {
                it("Should have container reference") {
                    expect(core.mediaControl).toNot(beNil())
                    expect(core.mediaControl?.container) == core.activeContainer
                }

                it("Should be the top view on core") {
                    core.render()

                    expect(core.subviews.last) == core.mediaControl
                }
            }

            describe("Plugins") {
                context("Addition") {
                    it("Should be able to add plugins") {
                        core.addPlugin(FakeCorePlugin())

                        expect(core.plugins.count) == 1
                    }

                    it("Should add plugin as subview after rendered") {
                        let plugin = FakeCorePlugin()
                        core.addPlugin(plugin)

                        core.render()

                        expect(plugin.superview) == core
                    }
                }

                context("Verification") {
                    it("Should return true if a plugin is installed") {
                        core.addPlugin(FakeCorePlugin())
                        let containsPlugin = core.hasPlugin(FakeCorePlugin.self)

                        expect(containsPlugin).to(beTrue())
                    }

                    it("Should return false if a plugin isn't installed") {
                        core.addPlugin(UICorePlugin())
                        let containsPlugin = core.hasPlugin(FakeCorePlugin.self)

                        expect(containsPlugin).to(beFalse())
                    }
                }
            }

            describe("OptionWrapper") {

                var optionsUnboxer: OptionsUnboxer!

                context("Default values or nil") {

                    beforeEach {
                        optionsUnboxer = OptionsUnboxer(options: [:])
                    }

                    it("should returns `false` for `fullscreen`") {
                        expect(optionsUnboxer.fullscreen).to(beFalse())
                    }

                    it("should returns `false` for `kFullscreenByApp`") {
                        expect(optionsUnboxer.fullscreenControledByApp).to(beFalse())
                    }
                }

                context("Set") {

                    it("should returns correct value for `fullscreen`") {
                        optionsUnboxer = OptionsUnboxer(options: [kFullscreen: true])

                        expect(optionsUnboxer.fullscreen).to(beTrue())

                    }

                    it("should returns correct value for `kFullscreenByApp`") {
                        optionsUnboxer = OptionsUnboxer(options: [kFullscreenByApp: true])

                        expect(optionsUnboxer.fullscreenControledByApp).to(beTrue())
                    }
                }
            }
        }
    }
}

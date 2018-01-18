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

        describe(".Core") {

            describe("#init") {

                beforeEach {
                    core = Core(loader: loader, options: options as Options)
                }
                
                it("set backgroundColor to black") {
                    expect(core.backgroundColor) == .black
                }

                it("set frame Rect to zero") {
                    expect(core.frame) == CGRect.zero
                }

                it("add gesture recognizer") {
                    expect(core.gestureRecognizers?.count) > 0
                }

                it("save options passed on parameter") {
                    let options = ["SomeOption": true]
                    let core = Core(loader: loader, options: options as Options)

                    expect(core.options["SomeOption"] as? Bool) == true
                }

                it("activeContainer is not nil") {
                    expect(core.activeContainer).toNot(beNil())
                }

                it("plugins is not empty") {
                    expect(core.plugins).to(beEmpty())
                }

                it("containers list is not empty") {
                    expect(core.containers).toNot(beEmpty())
                }

                it("activeContainer is referenced on mediaControl container") {
                    expect(core.mediaControl?.container) == core.activeContainer
                }

                it("media control is not nil") {
                    expect(core.mediaControl).toNot(beNil())
                }

                it("Should be the top view on core") {
                    core.render()

                    expect(core.subviews.last) == core.mediaControl
                }
            }

            describe("Fullscreen") {
                var options: Options!

                beforeEach {
                    options = [kFullscreen: false]
                }

                context("when kFullscreen is false") {
                    it("start as embed video") {
                        let core = Core(options: options)
                        core.parentView = UIView()

                        core.render()

                        expect(core.parentView?.subviews.contains(core)).to(beTrue())
                        expect(core.mediaControl?.fullscreen).to(beFalse())
                    }

                    it("start as embed video when `kFullscreenByApp: true`") {
                        options[kFullscreenByApp] = true
                        let core = Core(options: options)
                        core.parentView = UIView()

                        core.render()

                        expect(core.parentView?.subviews.contains(core)).to(beTrue())
                        expect(core.mediaControl?.fullscreen).to(beFalse())
                    }

                    it("start as fullscreen video when `kFullscreenByApp: false` and setFullscreen is called") {
                        options[kFullscreenByApp] = false
                        let player = Player(options: options)
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
                }

                context("when kFullscreen is true") {

                    it("start as fullscreen video") {
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

                    it("start as embed video when `kFullscreenByApp: true`") {
                        let options: Options = [kFullscreen: true, kFullscreenByApp: true]
                        let core = Core(options: options)
                        core.parentView = UIView()

                        core.render()

                        expect(core.parentView?.subviews.contains(core)).to(beTrue())
                        expect(core.mediaControl?.fullscreen).to(beFalse())
                    }

                    it("start as fullscreen video when `kFullscreenByApp: false`") {
                        let options: Options = [kFullscreenByApp: true]
                        let core = Core(options: options)
                        core.parentView = UIView()

                        core.render()

                        expect(core.parentView?.subviews.contains(core)).to(beTrue())
                        expect(core.mediaControl?.fullscreen).to(beFalse())
                    }
                }

                describe("#setFullscreen") {

                    it("set to fullscreen video by call `setFullscreen(true)`") {
                        let core = Core()
                        core.parentView = UIView()

                        core.render()
                        core.setFullscreen(true)

                        expect(core.parentView?.subviews.contains(core)).to(beFalse())
                        expect(core.fullscreenController.view.subviews.contains(core)).to(beTrue())
                        expect(core.mediaControl?.fullscreen).to(beTrue())
                    }

                    it("only set fullscreen video once by call `setFullscreen(true)` twice") {
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

                context("when no options of fullscreen was passed") {
                    it("start as embed video") {
                        let core = Core()
                        core.parentView = UIView()

                        core.render()

                        expect(core.parentView?.subviews.contains(core)).to(beTrue())
                        expect(core.mediaControl?.fullscreen).to(beFalse())
                    }
                }

                context("when only kFullscreenByApp is passed") {

                    it("start as embed video when its true") {
                        let options: Options = [kFullscreenByApp: true]
                        let core = Core(options: options)
                        core.parentView = UIView()

                        core.render()

                        expect(core.parentView?.subviews.contains(core)).to(beTrue())
                        expect(core.mediaControl?.fullscreen).to(beFalse())
                    }

                    it("start as fullscreen video when its false") {
                        let player = Player(options: [kFullscreenByApp: false] as Options)
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
                }
            }

            describe("#Destroy") {
                it("trigger willDestroy event") {
                    var didCallWillDestroy = false

                    core.on(InternalEvent.willDestroy.rawValue) { _ in
                        didCallWillDestroy = true
                    }
                    core.destroy()
                    
                    expect(didCallWillDestroy).toEventually(beTrue())
                }

                it("trigger didDestroy event") {
                    var didCallDidDestroy = false

                    core.on(InternalEvent.willDestroy.rawValue) { _ in
                        didCallDidDestroy = true
                    }
                    core.destroy()

                    expect(didCallDidDestroy).toEventually(beTrue())
                }

                it("remove listeners") {
                    var didTriggerEvent = false
                    let eventName = "teste"

                    core.listenTo(core, eventName: eventName) { _ in
                        didTriggerEvent = true
                    }

                    core.destroy()
                    core.trigger(eventName)

                    expect(didTriggerEvent).toEventually(beFalse())
                }

                it("remove all containers") {
                    var countOfDestroyedContainers = 0
                    core.containers.forEach { container in
                        container.on(InternalEvent.didDestroy.rawValue) { _ in
                            countOfDestroyedContainers += 1
                        }
                    }
                    let countOfContainers = core.containers.count

                    core.destroy()

                    expect(countOfContainers) == countOfDestroyedContainers
                }
            }

            context("when changes a activePlayback") {

                it("trigger willChangeActivePlayback event") {
                    let core = Core()
                    let container = Container()
                    var didCallEvent = false

                    core.on(InternalEvent.willChangeActivePlayback.rawValue)   { userInfo in
                        didCallEvent = true
                    }

                    core.activeContainer = container
                    core.activeContainer?.playback = AVFoundationPlayback()
                    expect(didCallEvent).toEventually(beTrue())
                }

                it("trigger willChangePlayback on container") {
                    let core = Core()
                    let container = Container()
                    var didCallEvent = false

                    container.on(InternalEvent.willChangePlayback.rawValue)   { userInfo in
                        didCallEvent = true
                    }

                    core.activeContainer = container
                    core.activeContainer?.playback = AVFoundationPlayback()
                    expect(didCallEvent).toEventually(beTrue())
                }
            }

            context("when changes a activeContainer") {

                it("trigger willChangeActiveContainer event") {
                    let core = Core()
                    var didCallEvent = false

                    core.on(InternalEvent.willChangeActiveContainer.rawValue)   { userInfo in
                        didCallEvent = true
                    }
                    core.activeContainer = Container()

                    expect(didCallEvent).toEventually(beTrue())
                }

                it("trigger didChangeActiveContainer event") {
                    let core = Core()
                    var didCallEvent = false

                    core.on(InternalEvent.didChangeActiveContainer.rawValue)   { userInfo in
                        didCallEvent = true
                    }
                    core.activeContainer = Container()

                    expect(didCallEvent).toEventually(beTrue())
                }

                it("removes events for old container") {
                    let core = Core()
                    let container = Container()
                    var didCallEvent = false

                    core.activeContainer = container
                    core.activeContainer?.playback = AVFoundationPlayback()
                    container.on(InternalEvent.didChangeActivePlayback.rawValue)   { userInfo in
                        didCallEvent = true
                    }

                    core.activeContainer = Container()
                    container.playback = AVFoundationPlayback()

                    expect(didCallEvent).toEventually(beFalse())
                }
            }

            context("when a plugin is added") {

                var plugin: FakeCorePlugin!

                beforeEach {
                    core = Core()
                    plugin = FakeCorePlugin()
                    core.addPlugin(plugin)
                }

                it("no default plugin is added") {
                    expect(core.plugins.count) == 1
                    expect(core.hasPlugin(FakeCorePlugin.self)) == true
                }

                it("add plugin as subview after rendered") {
                    core.render()

                    expect(plugin.superview) == core
                }

                it("Should return false if a plugin isn't installed") {
                    let core = Core()
                    expect(core.hasPlugin(UICorePlugin.self)) == false
                }
            }

            context("core position") {
                it("is positioned in front of Container view") {
                    let loader = Loader(externalPlugins: [FakeCorePlugin.self])
                    let core = Core(loader: loader, options: options as Options)

                    core.render()

                    expect(core.subviews.first).to(beAKindOf(Container.self))
                    expect(core.subviews[1]).to(beAKindOf(FakeCorePlugin.self))
                }
            }
        }
    }
}

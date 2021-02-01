import Quick
import Nimble
@testable import Clappr

class CoreTests: QuickSpec {
    override func spec() {
        
        class StubPlayback: Playback {
            override class var name: String {
                return "stupPlayback"
            }
        }
        
        class FakeCorePlugin: UICorePlugin {
            override class var name: String {
                return "FakeCorePLugin"
            }
            
            override func bindEvents() {  }
        }
        
        class LayerComposerSpy: LayerComposer {
            var didCallCompose = false
            var didCallAttachUICorePlugin = false
            var didCallAttachMediaControl = false
            var didCallShowUI = false
            var didCallHideUI = false
            
            override func compose(inside rootView: UIView) {
                didCallCompose = true
            }
            
            override func attachUICorePlugin(_ plugin: UICorePlugin) {
                didCallAttachUICorePlugin = true
            }
            
            override func attachMediaControl(_ view: UIView) {
                didCallAttachMediaControl = true
            }
            
            override func showUI() {
                didCallShowUI = true
            }
            
            override func hideUI() {
                didCallHideUI = true
            }
        }
        
        let options: Options = [kSourceUrl: "http//test.com"]
        var core: Core!
        var layerComposer: LayerComposer!
        
        beforeEach {
            layerComposer = LayerComposer()
            core = Core(options: options)
            Loader.shared.resetPlugins()
            Loader.shared.register(playbacks: [StubPlayback.self])
        }
        
        describe(".Core") {
            
            describe("#init") {
                
                beforeEach {
                    core = CoreFactory.create(with: options, layerComposer: layerComposer)
                    core.render()
                }
                
                it("set frame Rect to zero") {
                    expect(core.view.frame) == CGRect.zero
                }
                
                it("save options passed on parameter") {
                    let options = ["SomeOption": true]
                    let core = Core(options: options)
                    
                    expect(core.options["SomeOption"] as? Bool) == true
                }
                
                it("activeContainer is not nil") {
                    expect(core.activeContainer).toNot(beNil())
                }
                
                it("containers list is not empty") {
                    expect(core.containers).toNot(beEmpty())
                }
                
                it("stores plugin instances") {
                    Loader.shared.register(plugins: [UICorePluginMock.self, CorePluginMock.self])
                    
                    let core = CoreFactory.create(with: options, layerComposer: layerComposer)
                    
                    expect(core.plugins.count).to(equal(2))
                    expect(core.plugins.compactMap({ $0 as? UICorePluginMock })).toNot(beNil())
                    expect(core.plugins.compactMap({ $0 as? CorePluginMock })).toNot(beNil())
                }
                
                it("has an overlayView as a PassthroughView") {
                    expect(core.overlayView).to(beAnInstanceOf(PassthroughView.self))
                }
                
                #if os(iOS)
                it("has only one drawerPlugin with placeholder") {
                    Loader.shared.register(plugins: [
                        MockPlaceholderDrawerPluginOne.self,
                        UICorePluginMock.self,
                        MockPlaceholderDrawerPluginTwo.self,
                        CorePluginMock.self,
                    ])
                    
                    let core = CoreFactory.create(with: options, layerComposer: layerComposer)
                    
                    expect(core.plugins.count).to(equal(3))
                    expect(core.plugins.first).to(beAKindOf(MockPlaceholderDrawerPluginOne.self))
                }
                
                
                it("add gesture recognizer") {
                    expect(core.view.gestureRecognizers?.count).to(beGreaterThan(0))
                }
                
                it("does not add gesture recognizer when in Chromeless mode") {
                    let options = [kChromeless: true]
                    let core = Core(options: options)
                    
                    expect(core.view.gestureRecognizers).to(beNil())
                }
                #endif
            }
            
            describe("On view ready") {
                var parentView: UIView!
                var parentViewController: UIViewController!
                
                beforeEach {
                    parentView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
                    parentViewController = UIViewController()
                }
                
                context("when a parentView is set") {
                    it("triggers a core ready event") {
                        let core = CoreFactory.create(with: [:], layerComposer: layerComposer)
                        
                        var didTriggerEvent = false
                        core.listenTo(core, eventName: Event.didAttachView.rawValue) { _ in
                            didTriggerEvent = true
                        }
                        
                        core.attach(to: parentView, controller: parentViewController)
                        
                        expect(didTriggerEvent).to(beTrue())
                    }
                    
                    it("adds all visual layers") {
                        let layerComposerSpy = LayerComposerSpy()
                        let core = CoreFactory.create(with: options, layerComposer: layerComposerSpy)
                        
                        core.attach(to: parentView, controller: parentViewController)
                        
                        expect(layerComposerSpy.didCallCompose).to(beTrue())
                    }
                    
                    context("and there isn't an active container") {
                        it("fails to attach") {
                            let core = Core()
                            
                            var didAttachPlayer = false
                            core.listenTo(core, eventName: Event.didAttachView.rawValue) { _ in
                                didAttachPlayer = true
                            }
                            
                            core.attach(to: parentView, controller: parentViewController)
                            
                            expect(didAttachPlayer).to(beFalse())
                        }
                    }
                    
                    #if os(iOS)
                    context("when attach is called") {
                        it("should attach the MediaControl layer on LayerComposer") {
                            let layerComposerSpy = LayerComposerSpy()
                            let core = CoreFactory.create(with: [:], layerComposer: layerComposerSpy)
                            let mediaControlMock = MediaControlMock(context: core)
                            
                            core.addPlugin(mediaControlMock)
                            core.attach(to: .init(), controller: .init())
                            core.render()
                            
                            expect(layerComposerSpy.didCallAttachMediaControl).to(beTrue())
                        }
                    }
                    #endif
                }
            }
            
            describe("Core sharedData") {
                context("on a brand new instance") {
                    it("starts empty") {
                        core = CoreFactory.create(with: [:], layerComposer: layerComposer)
                        
                        expect(core.sharedData).to(beEmpty())
                    }
                }
                
                context("when stores a value on sharedData") {
                    beforeEach {
                        core = CoreFactory.create(with: [:], layerComposer: layerComposer)
                        core.sharedData["testKey"] = "testValue"
                    }
                    
                    it("retrieves stored value") {
                        expect(core.sharedData["testKey"] as? String) == "testValue"
                    }
                }
            }
            
            #if os(iOS)
            describe("Fullscreen") {
                var options: Options!
                
                beforeEach {
                    options = [kStartInFullscreen: false]
                }
                
                context("when kFullscreen is false") {
                    it("start as embed video") {
                        let core = Core(options: options)
                        core.parentView = UIView()
                        
                        core.render()
                        
                        expect(core.parentView?.subviews.contains(core.view)).to(beTrue())
                        expect(core.isFullscreen).to(beFalse())
                    }
                }
                
                context("when kFullscreen is true") {
                    
                    it("start as embed video when `kFullscreenByApp: true`") {
                        let options: Options = [kStartInFullscreen: true]
                        let core = Core(options: options)
                        core.parentView = UIView()
                        
                        core.render()
                        
                        expect(core.parentView?.subviews.contains(core.view)).to(beTrue())
                        expect(core.isFullscreen).to(beFalse())
                    }
                    
                }
                
                describe("Forward events") {
                    
                    var player: Player!
                    
                    beforeEach {
                        player = Player()
                        self.playerSetup(player: player)
                    }
                    
                    
                    context("when core trigger InternalEvent.userRequestEnterInFullscreen") {
                        it("triggers Event.requestFullscreen on player") {
                            var didTriggerEvent = false
                            player.on(.requestFullscreen) { _ in
                                didTriggerEvent = true
                            }
                            
                            player.core?.trigger(InternalEvent.userRequestEnterInFullscreen.rawValue)
                            
                            expect(didTriggerEvent).toEventually(beTrue())
                        }
                    }
                    
                    context("when core trigger InternalEvent.userRequestExitFullscreen") {
                        it("triggers Event.exitFullscreen on player") {
                            var didTriggerEvent = false
                            player.on(.exitFullscreen) { _ in
                                didTriggerEvent = true
                            }
                            
                            player.core?.trigger(InternalEvent.userRequestExitFullscreen.rawValue)
                            
                            expect(didTriggerEvent).toEventually(beTrue())
                        }
                    }
                }
                
                context("when fullscreen is controled by app") {
                    
                    beforeEach {
                        core.parentView = UIView()
                        core.render()
                    }
                    
                    context("and setFullscreen(true) is called") {
                        
                        beforeEach {
                            core.parentController = self.rootViewController()
                            core.setFullscreen(false)
                        }
                        
                        it("set isFullscreen to true") {
                            core.setFullscreen(true)
                            
                            expect(core.isFullscreen).to(beTrue())
                        }
                        
                        it("triggers InternalEvent.didEnterFullscreen") {
                            var didTriggerEvent = false
                            core.on(Event.didEnterFullscreen.rawValue) { _ in
                                didTriggerEvent = true
                            }
                            
                            core.setFullscreen(true)
                            
                            expect(didTriggerEvent).toEventually(beTrue())
                        }
                        
                    }
                    
                    context("and setFullscreen(false) is called") {
                        
                        beforeEach {
                            core.setFullscreen(true)
                        }
                        
                        it("set isFullscreen to false") {
                            core.setFullscreen(false)
                            
                            expect(core.isFullscreen).to(beFalse())
                        }
                        
                        it("triggers InternalEvent.didExitFullscreen") {
                            var didTriggerEvent = false
                            core.on(Event.didExitFullscreen.rawValue) { _ in
                                didTriggerEvent = true
                            }
                            
                            core.setFullscreen(false)
                            
                            expect(didTriggerEvent).to(beTrue())
                        }
                    }
                }
                
                context("when no options of fullscreen was passed") {
                    it("start as embed video") {
                        let core = Core()
                        core.parentView = UIView()
                        
                        core.render()
                        
                        expect(core.parentView?.subviews.contains(core.view)).to(beTrue())
                        expect(core.isFullscreen).to(beFalse())
                    }
                }
                
                context("when only kFullscreenByApp is true") {
                    
                    it("start as embed video") {
                        let options: Options = [:]
                        let core = Core(options: options)
                        core.parentView = UIView()
                        
                        core.render()
                        
                        expect(core.parentView?.subviews.contains(core.view)).to(beTrue())
                        expect(core.isFullscreen).to(beFalse())
                    }
                    
                    it("start as fullscreen video when its false") {
                        let player = Player(options: [:])
                        
                        self.playerSetup(player: player)
                        
                        player.setFullscreen(true)
                        
                        expect(player.core!.parentView?.subviews.contains(core.view)).to(beFalse())
                        expect(player.core!.isFullscreen).to(beTrue())
                    }
                }
                
                context("when only kFullscreenByApp is false") {
                    
                    it("start as fullscreen video") {
                        let player = Player(options: [:])
                        
                        self.playerSetup(player: player)
                        
                        player.setFullscreen(true)
                        
                        expect(player.core!.parentView?.subviews.contains(core.view)).to(beFalse())
                        expect(player.core!.isFullscreen).to(beTrue())
                    }
                }
            }
            #endif
            
            describe("#options") {
                it("updates the container options") {
                    core.options = ["foo": "bar"]
                    
                    core.containers.forEach { container in
                        expect(container.options["foo"] as? String).to(equal("bar"))
                    }
                }
                
                it("triggers didUpdateOptions when setted") {
                    var didUpdateOptionsTriggered = false
                    core.on(Event.didUpdateOptions.rawValue) { _ in
                        didUpdateOptionsTriggered = true
                    }
                    
                    core.options = [:]
                    
                    expect(didUpdateOptionsTriggered).to(beTrue())
                }
            }
            
            describe("#Destroy") {
                it("trigger willDestroy event") {
                    var didCallWillDestroy = false
                    
                    core.on(Event.willDestroy.rawValue) { _ in
                        didCallWillDestroy = true
                    }
                    core.destroy()
                    
                    expect(didCallWillDestroy).toEventually(beTrue())
                }
                
                it("trigger didDestroy event") {
                    var didCallDidDestroy = false
                    
                    core.on(Event.willDestroy.rawValue) { _ in
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
                        container.on(Event.didDestroy.rawValue) { _ in
                            countOfDestroyedContainers += 1
                        }
                    }
                    let countOfContainers = core.containers.count
                    
                    core.destroy()
                    
                    expect(countOfContainers) == countOfDestroyedContainers
                }
                
                #if os(iOS)
                it("clears fullscreenController reference") {
                    core.destroy()
                }
                
                it("clears fullscreenHandler reference") {
                    core.destroy()
                    
                    expect(core.fullscreenHandler).toEventually(beNil())
                }
                #endif
                
                it("protect the main thread when plugin crashes in render") {
                    let expectation = QuickSpec.current.expectation(description: "doesn't crash")
                    UICorePluginMock.crashOnDestroy = true
                    let core = Core()
                    let plugin = UICorePluginMock(context: core)
                    core.addPlugin(plugin)
                    
                    core.destroy()
                    
                    expectation.fulfill()
                    QuickSpec.current.waitForExpectations(timeout: 1)
                }
            }
            
            context("when changes a activePlayback") {
                
                it("trigger willChangeActivePlayback event") {
                    let core = Core()
                    let container = Container()
                    var didCallEvent = false
                    
                    core.on(Event.willChangeActivePlayback.rawValue)   { userInfo in
                        didCallEvent = true
                    }
                    
                    core.activeContainer = container
                    core.activeContainer?.playback = AVFoundationPlayback(options: [:])
                    expect(didCallEvent).toEventually(beTrue())
                }
                
                it("trigger willChangePlayback on container") {
                    let core = Core()
                    let container = Container()
                    var didCallEvent = false
                    
                    container.on(Event.willChangePlayback.rawValue)   { userInfo in
                        didCallEvent = true
                    }
                    
                    core.activeContainer = container
                    core.activeContainer?.playback = AVFoundationPlayback(options: [:])
                    expect(didCallEvent).toEventually(beTrue())
                }
            }
            
            context("when changes a activeContainer") {
                
                it("trigger willChangeActiveContainer event") {
                    let core = Core()
                    let container = Container()
                    var didCallEvent = false
                    
                    core.on(Event.willChangeActiveContainer.rawValue)   { userInfo in
                        didCallEvent = true
                    }
                    core.activeContainer = container
                    
                    expect(didCallEvent).toEventually(beTrue())
                }
                
                it("trigger didChangeActiveContainer event") {
                    let core = Core()
                    let container = Container()
                    var didCallEvent = false
                    
                    core.on(Event.didChangeActiveContainer.rawValue)   { userInfo in
                        didCallEvent = true
                    }
                    core.activeContainer = container
                    
                    expect(didCallEvent).toEventually(beTrue())
                }
                
                it("removes events for old container") {
                    let core = Core()
                    let container = Container()
                    var didCallEvent = false
                    
                    core.activeContainer = container
                    core.activeContainer?.playback = AVFoundationPlayback(options: [:])
                    container.on(Event.didChangeActivePlayback.rawValue)   { userInfo in
                        didCallEvent = true
                    }
                    
                    core.activeContainer = container
                    container.playback = AVFoundationPlayback(options: [:])
                    
                    expect(didCallEvent).toEventually(beFalse())
                }
            }
            
            describe("#render") {
                #if os(tvOS)
                context("core position") {
                    it("is positioned in front of Container view") {
                        Loader.shared.register(plugins: [FakeCorePlugin.self])
                        let core = CoreFactory.create(with: options, layerComposer: layerComposer)
                        
                        core.render()
                        
                        expect(core.view.subviews.count).to(equal(2))
                        expect(core.view.subviews.first?.accessibilityIdentifier).to(equal("Container"))
                        expect(core.view.subviews[1].accessibilityIdentifier).to(beNil())
                    }
                }
                #endif
                
                #if os(iOS)
                it("doesnt add plugin as subview if it is a MediaControlElement") {
                    let core = Core()
                    let plugin = MediaControlElementMock(context: core)
                    
                    core.addPlugin(plugin)
                    core.render()
                    
                    expect(plugin.view.superview).to(beNil())
                }
                
                it("renders MediaControlElements after CorePlugins") {
                    UICorePluginMock.crashOnRender = false
                    let core = Core()
                    let mediaControl = MediaControl(context: core)
                    let element = MediaControlElementMock(context: core)
                    let plugin = UICorePluginMock(context: core)
                    
                    var renderingOrder: [String] = []
                    element.on("render") { _ in
                        renderingOrder.append("element")
                    }
                    
                    plugin.on("render") { _ in
                        renderingOrder.append("plugin")
                    }
                    
                    core.addPlugin(mediaControl)
                    core.addPlugin(element)
                    core.addPlugin(plugin)
                    core.render()
                    
                    expect(renderingOrder).toEventually(equal(["plugin", "element"]))
                }
                
                it("calls the mediacontrol to add the elements into the panels") {
                    let core = CoreFactory.create(with: [:], layerComposer: layerComposer)
                    let mediaControlMock = MediaControlMock(context: core)
                    let mediaControlPluginMock = MediaControlElementMock(context: core)
                    
                    core.addPlugin(mediaControlMock)
                    core.addPlugin(mediaControlPluginMock)
                    core.render()
                    
                    expect(mediaControlMock.didCallRenderElements).to(beTrue())
                }
                
                describe("#UICorePlugins") {
                    context("when rendering UICorePlugins") {
                        it("uses LayerComposer") {
                            Loader.shared.resetPlugins()
                            Loader.shared.register(plugins: [UICorePluginStub.self])
                            let layerComposer = LayerComposerSpy()
                            let core = CoreFactory.create(with: options, layerComposer: layerComposer)
                            
                            core.render()
                            
                            expect(layerComposer.didCallAttachUICorePlugin).to(beTrue())
                        }
                        
                        it("calls render on Plugin") {
                            Loader.shared.resetPlugins()
                            Loader.shared.register(plugins: [UICorePluginStub.self])
                            let layerComposer = LayerComposer()
                            let core = CoreFactory.create(with: options, layerComposer: layerComposer)
                            let uiCorePlugin = core.plugins.first { $0.pluginName == "UICorePluginStub"} as? UICorePluginStub
                            
                            core.render()
                            
                            expect(uiCorePlugin?.didCallRender).to(beTrue())
                        }
                    }
                }
                
                #endif
                
                it("protect the main thread when plugin crashes in render") {
                    let expectation = QuickSpec.current.expectation(description: "doesn't crash")
                    UICorePluginMock.crashOnRender = true
                    let core = Core()
                    let plugin = UICorePluginMock(context: core)
                    core.addPlugin(plugin)
                    
                    core.render()
                    
                    expectation.fulfill()
                    QuickSpec.current.waitForExpectations(timeout: 1)
                }
            }
            
            describe("rendering") {
                context("when plugin is overlay") {
                    it("renders on the overlay view") {
                        Loader.shared.register(plugins: [OverlayPluginMock.self])
                        let core = CoreFactory.create(with: [:], layerComposer: layerComposer)
                        
                        core.render()
                        
                        expect(core.overlayView.subviews.count).to(equal(1))
                    }
                }
            }
            
            #if os(iOS)
            describe("#chromelessMode") {
                let layerComposer = LayerComposerSpy()
                
                context("when in chromeless mode by options") {
                    core = CoreFactory.create(with: [kSourceUrl: "http//test.com", kChromeless: true], layerComposer: layerComposer)
                    
                    it("hides LayerComposer layers") {
                        expect(layerComposer.didCallHideUI).to(beTrue())
                    }
                }
                
                context("when is not in chromeless mode by options") {
                    core = CoreFactory.create(with: [kSourceUrl: "http//test.com", kChromeless: false], layerComposer: layerComposer)
                    
                    it("shows LayerComposer layers") {
                        expect(layerComposer.didCallShowUI).to(beTrue())
                    }
                }
            }
            #endif
        }
    }
    
    private func playerSetup(player: Player) {
        #if os(iOS)
        player.attachTo(UIView(), controller: rootViewController())
        #else
        let controller = UIViewController()
        controller.addChild(player)
        player.view.frame = controller.view.bounds
        controller.view.addSubview(player.view)
        player.didMove(toParent: controller)
        #endif
    }
    
    private func rootViewController() -> UIViewController {
        let viewController = UIViewController()
        UIApplication.shared.keyWindow?.rootViewController = viewController
        return viewController
    }
}

class UICorePluginMock: UICorePlugin {
    static var didCallRender = false
    static var crashOnRender = false
    static var didCallDestroy = false
    static var crashOnDestroy = false
    
    override class var name: String {
        return "UICorePluginMock"
    }
    
    override func render() {
        UICorePluginMock.didCallRender = true
        
        if UICorePluginMock.crashOnRender {
            codeThatCrashes()
        }
        
        trigger("render")
    }
    
    override func bindEvents() {  }
    
    override func destroy() {
        UICorePluginMock.didCallDestroy = true
        
        if UICorePluginMock.crashOnDestroy {
            codeThatCrashes()
        }
    }
    
    static func reset() {
        UICorePluginMock.didCallRender = false
    }
    
    private func codeThatCrashes() {
        NSException(name:NSExceptionName(rawValue: "TestError"), reason:"Test Error", userInfo:nil).raise()
    }
}

class CorePluginMock: CorePlugin {
    override class var name: String {
        return "CorePluginMock"
    }
}

#if os(iOS)
private class MediaControlMock: MediaControl {
    var didCallRenderElements = false
    
    override func render(_ elements: [MediaControl.Element]) {
        didCallRenderElements = true
    }
}

class MockPlaceholderDrawerPluginOne: DrawerPlugin {
    override class var name: String {
        return "MockPlaceholderDrawerPluginOne"
    }
    
    override var placeholder: CGFloat {
        return 1
    }
}

class MockPlaceholderDrawerPluginTwo: DrawerPlugin {
    override class var name: String {
        return "MockPlaceholderDrawerPluginTwo"
    }
    
    override var placeholder: CGFloat {
        return 1
    }
}
#endif

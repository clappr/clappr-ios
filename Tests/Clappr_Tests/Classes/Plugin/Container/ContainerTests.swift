import Quick
import Nimble
@testable import Clappr

class ContainerTests: QuickSpec {

    override func spec() {
        describe(".Container") {

            var container: Container!

            describe("#Init") {

                context("with a invalid resource") {

                    beforeEach {
                        container = ContainerFactory.create(with: Resource.invalid)
                        container.load(Source.invalid.rawValue)
                        Loader.shared.resetPlugins()
                    }

                    it("creates a container with invalid playback") {
                        expect(container.playback?.pluginName) == "NoOp"
                    }
                }

                context("with a valid resource") {

                    beforeEach {
                        Loader.shared.register(playbacks: [AVFoundationPlayback.self])
                        container = ContainerFactory.create(with: Resource.valid)
                        container.load(Source.valid.rawValue)
                    }

                    it("creates a container with valid playback") {
                        expect(container.playback?.pluginName) == "AVPlayback"
                    }
                }

                context("when resource is not empty") {

                    beforeEach {
                        container = ContainerFactory.create(with: Resource.valid)
                        container.load(Source.valid.rawValue)
                    }

                    context("and add container plugins from loader") {
                        it("saves plugins on container") {
                            Loader.shared.register(plugins: [FakeContainerPlugin.self, AnotherFakeContainerPlugin.self])
                            container = ContainerFactory.create(with: [:])

                            container.load(Source.valid.rawValue)

                            expect(container.hasPlugin(FakeContainerPlugin.name)).to(beTrue())
                            expect(container.hasPlugin(AnotherFakeContainerPlugin.name)).to(beTrue())
                        }
                    }

                    it("set playback as subview") {
                        expect(container.playback?.view.superview) == container.view
                    }

                    it("set playback to front of container") {
                        expect(container.view.subviews.first) == container.playback?.view
                    }

                    it("set background color to `clear`") {
                        expect(container.view.backgroundColor) == .clear
                    }

                    it("set the frame of container as CGRect.zero") {
                        expect(container.view.frame) == CGRect.zero
                    }

                    it("set acessibility indentifier to 'Container'") {
                        expect(container.view.accessibilityIdentifier) == "Container"
                    }

                    it("save options without mutating") {
                        Loader.shared.register(playbacks: [AVFoundationPlayback.self])
                        Loader.shared.register(plugins: [SpinnerPlugin.self])

                        let options = ["aOption": "option"]
                        let container = ContainerFactory.create(with: options)
                        let option = container.options["aOption"] as! String

                        expect(option) == "option"
                    }

                    it("stores all plugin instances") {
                        Loader.shared.resetPlugins()
                        Loader.shared.register(plugins: [FakeContainerPlugin.self, AnotherFakeContainerPlugin.self])
                        let container = ContainerFactory.create(with: [:])

                        expect(container.plugins.count).to(equal(2))
                        expect(container.plugins.compactMap({ $0 as? FakeContainerPlugin })).toNot(beNil())
                        expect(container.plugins.compactMap({ $0 as? AnotherFakeContainerPlugin })).toNot(beNil())
                    }

                    it("add a container context to all UIContainerPlugin") {
                        Loader.shared.register(plugins: [FakeContainerPlugin.self, AnotherFakeContainerPlugin.self])
                        let container = ContainerFactory.create(with: [:])

                        expect(container.plugins).toNot(beEmpty())
                        container.plugins.compactMap({ $0 as? UIContainerPlugin }).forEach { plugin in
                            expect(plugin.container) == container
                        }
                    }

                    it("add a container context to all ContainerPlugin") {
                        Loader.shared.register(plugins: [FakeContainerPlugin.self, AnotherFakeContainerPlugin.self])
                        let container = ContainerFactory.create(with: [:])

                        expect(container.plugins).toNot(beEmpty())
                        container.plugins.compactMap({ $0 as? ContainerPlugin }).forEach { plugin in
                            expect(plugin.container) == container
                        }
                    }
                }

                context("when resource is empty") {

                    beforeEach {
                        container = ContainerFactory.create(with: [:])
                    }

                    it("set playback as subview") {
                        expect(container.playback?.view.superview).to(beNil())
                    }

                    it("set playback to front of container") {
                        expect(container.view.subviews.first).to(beNil())
                    }
                }
            }

            describe("#render") {
                it("protect the main thread when plugin crashes in render") {
                    let expectation = QuickSpec.current.expectation(description: "doesn't crash")
                    AnotherFakeContainerPlugin.crashOnRender = true
                    let container = Container()
                    let plugin = AnotherFakeContainerPlugin(context: container)
                    container.addPlugin(plugin)

                    container.render()

                    expectation.fulfill()
                    QuickSpec.current.waitForExpectations(timeout: 1)
                }
            }

            describe("#Destroy") {

                beforeEach {
                    container = ContainerFactory.create(with: [:])
                    Loader.shared.resetPlugins()
                }

                it("remove container from superview") {
                    let wrapperView = UIView()
                    wrapperView.addSubview(container.view)

                    container.destroy()

                    expect(container.view.superview).to(beNil())
                }

                it("destroy playback") {
                    container.destroy()
                    expect(container.playback?.view.superview).to(beNil())
                }

                it("stop listening events") {
                    var callbackWasCalled = false
                    container.on("some-event") { _ in
                        callbackWasCalled = true
                    }

                    container.destroy()
                    container.trigger("some-event")

                    expect(callbackWasCalled).toEventually(beFalse())
                }

                it("trigger willDestroy") {
                    var didCallEvent = false
                    container.on(Event.willDestroy.rawValue) { _ in
                        didCallEvent = true
                    }

                    container.destroy()

                    expect(didCallEvent).toEventually(beTrue())
                }

                it("trigger didDestroy") {
                    var didCallEvent = false
                    container.on(Event.didDestroy.rawValue) { _ in
                        didCallEvent = true
                    }

                    container.destroy()

                    expect(didCallEvent).toEventually(beTrue())
                }

                it("destroy all plugins and clear plugins list") {
                    Loader.shared.register(plugins: [FakeContainerPlugin.self])
                    let container = ContainerFactory.create(with: [:])
                    var countOfDestroyedPlugins = 0

                    container.plugins.forEach { plugin in
                        _ = plugin.on(Event.didDestroy.rawValue) { _ in
                            countOfDestroyedPlugins += 1
                        }
                    }

                    container.destroy()

                    expect(countOfDestroyedPlugins) == 1
                    expect(container.plugins.count) == 0
                }

                it("protect the main thread when plugin crashes in destroy") {
                    let expectation = QuickSpec.current.expectation(description: "doesn't crash")
                    AnotherFakeContainerPlugin.crashOnDestroy = true
                    let container = Container()
                    let plugin = AnotherFakeContainerPlugin(context: container)
                    container.addPlugin(plugin)

                    container.destroy()

                    expectation.fulfill()
                    QuickSpec.current.waitForExpectations(timeout: 1)
                }
            }

            describe("#load") {
                context("when pass a valid resource") {
                    beforeEach {
                        Loader.shared.register(playbacks: [AVFoundationPlayback.self])
                        container = ContainerFactory.create(with: [:])
                    }

                    it("loads a valid playback") {
                        container.load(Source.valid.rawValue)

                        expect(container.playback?.pluginName) == "AVPlayback"
                        expect(container.playback?.view.superview) == container.view
                    }

                    it("load a source with mime type") {
                        container.load(Source.valid.rawValue, mimeType: "video/mp4")

                        expect(container.playback?.pluginName) == "AVPlayback"
                        expect(container.playback?.view.superview) == container.view
                    }
                }

                context("when pass a invalid resource") {
                    beforeEach {
                        container = ContainerFactory.create(with: [:])
                        container.load(Source.invalid.rawValue)
                    }

                    it("set playback as a 'noop' playback") {
                        container.load(Source.invalid.rawValue)

                        expect(container.playback?.pluginName) == NoOpPlayback.name
                        expect(container.playback?.view.superview) == container.view
                    }

                    it("set playback as a 'noop' playback with mimetype") {
                        container.load(Source.valid.rawValue, mimeType: "video/mp4")

                        expect(container.playback?.pluginName) == "AVPlayback"
                        expect(container.playback?.view.superview) == container.view
                    }
                }

                it("keep just one playback as subview at time") {
                    Loader.shared.resetPlugins()
                    let container = ContainerFactory.create(with: [:])
                    container.load("anyVideo")
                    expect(container.view.subviews.count).to(equal(1))

                    container.load("anyOtherVideo")
                    expect(container.view.subviews.count).to(equal(1))
                }
            }

            context("when play event is trigger") {

                beforeEach {
                    Loader.shared.resetPlugins()
                    Loader.shared.register(playbacks: [StubPlayback.self])
                    container = ContainerFactory.create(with: Resource.valid)
                    container.load(Source.valid.rawValue)
                }

                it("reset startAt after first play event") {

                    let options = [kSourceUrl: "someUrl", kStartAt: 15.0] as Options
                    let container = ContainerFactory.create(with: options)
                    container.load(Source.invalid.rawValue)

                    expect(container.options[kStartAt] as? TimeInterval) == 15.0
                    expect(container.playback?.startAt) == 15.0

                    container.playback?.play()
                    container.load(Source.valid.rawValue)

                    expect(container.options[kStartAt] as? TimeInterval) == 0.0
                    expect(container.playback?.startAt) == 0.0
                }
            }

            describe("#options") {
                it("triggers didUpdateOptions when setted") {
                    var didUpdateOptionsTriggered = false
                    container.on(Event.didUpdateOptions.rawValue) { _ in
                        didUpdateOptionsTriggered = true
                    }

                    container.options = [:]
                    expect(didUpdateOptionsTriggered).to(beTrue())

                }
            }

            describe("Container sharedData") {
                context("on a brand new instance") {
                    it("starts empty") {
                        container = ContainerFactory.create(with: Resource.valid)

                        expect(container.sharedData).to(beEmpty())
                    }
                }

                context("when stores a value on sharedData") {
                    beforeEach {
                        container = ContainerFactory.create(with: Resource.valid)
                        container.sharedData["testKey"] = "testValue"
                    }

                    it("retrieves stored value") {
                        expect(container.sharedData["testKey"] as? String) == "testValue"
                    }
                }
            }

            context("when resized") {
                it("triggers didResize event") {
                    let container = Container()
                    container.view.superview?.addSubviewMatchingConstraints(container.view)
                    container.render()
                    container.view.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
                    var didResizeTriggered = false
                    var didResizeValue: CGSize? = .zero

                    container.on(Event.didResize.rawValue) { userInfo in
                        didResizeTriggered = true
                        didResizeValue = userInfo?["size"] as? CGSize
                    }

                    container.view.setWidthAndHeight(with: CGSize(width: 10, height: 10))
                    container.view.layoutIfNeeded()

                    expect(didResizeTriggered).toEventually(beTrue())
                    expect(didResizeValue?.width).toEventually(equal(10))
                    expect(didResizeValue?.height).toEventually(equal(10))
                }
            }
        }
    }

    class StubPlayback: Playback {
        override class var name: String {
            return "AVPlayback"
        }

        override class func canPlay(_: Options) -> Bool {
            return true
        }

        override func play() {
            trigger(.playing)
        }
    }

    class FakeContainerPlugin: ContainerPlugin {
        override class var name: String {
            return "FakeContainerPlugin"
        }

        override func destroy() {
            trigger(Event.didDestroy.rawValue)
        }
    }

    class AnotherFakeContainerPlugin: UIContainerPlugin {
        static var didCallRender = false
        static var crashOnRender = false
        static var didCallDestroy = false
        static var crashOnDestroy = false

         override class var name: String {
            return "AnotherFakeContainerPlugin"
        }

        override func bindEvents() { }
        
        override func render() {
            AnotherFakeContainerPlugin.didCallRender = true

            if AnotherFakeContainerPlugin.crashOnRender {
                codeThatCrashes()
            }
        }

        override func destroy() {
            AnotherFakeContainerPlugin.didCallDestroy = true

            if AnotherFakeContainerPlugin.crashOnDestroy {
                codeThatCrashes()
            }
        }

        static func reset() {
            AnotherFakeContainerPlugin.didCallRender = false
        }

        private func codeThatCrashes() {
            NSException(name:NSExceptionName(rawValue: "TestError"), reason:"Test Error", userInfo:nil).raise()
        }
    }
}

struct Resource {
    static let valid = [kSourceUrl: Source.valid]
    static let invalid = [kSourceUrl: Source.invalid]
}

enum Source: String {
    case valid = "http://clappr.com/video.mp4"
    case invalid = "invalid"
}

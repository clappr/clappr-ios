import Quick
import Nimble
@testable import Clappr

class ContainerTests: QuickSpec {

    override func spec() {

        struct Resource {
            static let invalid = [kSourceUrl: "invalid"]
            static let valid = [kSourceUrl: "http://clappr.com/video.mp4"]
        }

        describe(".Container") {

            var container: Container!

            describe("#Init") {

                context("with a invalid resource") {

                    beforeEach {
                        container = Container(options: Resource.invalid)
                        Loader.shared.resetPlugins()
                    }

                    it("creates a container with invalid playback") {
                        expect(container.playback?.pluginName) == "NoOp"
                    }
                }

                context("with a valid resource") {

                    beforeEach {
                        Loader.shared.register(plugins: [AVFoundationPlayback.self])
                        container = Container(options: Resource.valid)
                    }

                    it("creates a container with valid playback") {
                        expect(container.playback?.pluginName) == "AVPlayback"
                    }
                }

                context("when resource is not empty") {

                    beforeEach {
                        container = Container(options: Resource.valid)
                    }

                    context("and add container plugins from loader") {

                        beforeEach {
                            Loader.shared.register(plugins: [FakeContainerPlugin.self, AnotherFakeContainerPlugin.self])
                            container = Container(options: [:])
                        }

                        it("saves plugins on container") {
                            expect(container.hasPlugin(FakeContainerPlugin.self)).to(beTrue())
                            expect(container.hasPlugin(AnotherFakeContainerPlugin.self)).to(beTrue())
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
                        let options = ["aOption": "option"]
                        let container = Container(options: options)
                        let option = container.options["aOption"] as! String
                        let plugins: [Plugin.Type] = [AVFoundationPlayback.self, SpinnerPlugin.self]

                        Loader.shared.register(plugins: plugins)

                        expect(option) == "option"
                    }

                    it("add a container context to all plugins") {
                        expect(container.plugins).toNot(beEmpty())
                        container.plugins.forEach { plugin in
                            expect(plugin.container) == container
                        }
                    }
                }

                context("when resource is empty") {

                    beforeEach {
                        container = Container(options: [:])
                    }

                    it("set playback as subview") {
                        expect(container.playback?.view.superview).to(beNil())
                    }

                    it("set playback to front of container") {
                        expect(container.view.subviews.first).to(beNil())
                    }
                }
            }

            describe("#Destroy") {

                beforeEach {
                    container = Container(options: [:])
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
                    let container = Container(options: [:])
                    var countOfDestroyedPlugins = 0

                    container.plugins.forEach { plugin in
                        plugin.on(Event.didDestroy.rawValue) { _ in
                            countOfDestroyedPlugins += 1
                        }
                    }

                    container.destroy()

                    expect(countOfDestroyedPlugins) == 1
                    expect(container.plugins.count) == 0
                }
            }

            describe("#load") {

                context("when pass a valid resource") {

                    let source: String = Resource.valid[kSourceUrl]!

                    beforeEach {
                        Loader.shared.register(plugins: [AVFoundationPlayback.self])
                        container = Container(options: [:])
                    }

                    it("loads a valid playback") {
                        container.load(source)

                        expect(container.playback?.pluginName) == "AVPlayback"
                        expect(container.playback?.view.superview) == container.view
                    }

                    it("load a source with mime type") {
                        container.load(source, mimeType: "video/mp4")

                        expect(container.playback?.pluginName) == "AVPlayback"
                        expect(container.playback?.view.superview) == container.view
                    }
                }

                context("when pass a invalid resource") {

                    let source: String = Resource.invalid[kSourceUrl]!

                    beforeEach {
                        container = Container(options: [:])
                    }

                    it("set playback as a 'noop' playback") {
                        container.load(source)

                        expect(container.playback?.pluginName) == NoOpPlayback.name
                        expect(container.playback?.view.superview) == container.view
                    }

                    it("set playback as a 'noop' playback with mimetype") {
                        container.load(source, mimeType: "video/mp4")

                        expect(container.playback?.pluginName) == "AVPlayback"
                        expect(container.playback?.view.superview) == container.view
                    }
                }

                it("keep just one playback as subview at time") {
                    Loader.shared.resetPlugins()
                    let container = Container()
                    container.load("anyVideo")
                    expect(container.view.subviews.count).to(equal(1))

                    container.load("anyOtherVideo")
                    expect(container.view.subviews.count).to(equal(1))
                }
            }

            context("when play event is trigger") {

                beforeEach {
                    Loader.shared.resetPlugins()
                    Loader.shared.register(plugins: [StubPlayback.self])
                    container = Container(options: [kSourceUrl: "http://clappr.com/video.mp4"])
                }

                it("reset startAt after first play event") {

                    let options = [kSourceUrl: "someUrl", kStartAt: 15.0] as Options
                    let container = Container(options: options)

                    expect(container.options[kStartAt] as? TimeInterval) == 15.0
                    expect(container.playback?.startAt) == 15.0

                    container.playback?.play()
                    container.load("http://clappr.com/video.mp4")

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

                context("when stores a value on sharedData") {

                    beforeEach {
                        container = Container(options: Resource.valid)
                        container.sharedData.storeDictionary["testKey"] = "testValue"
                    }

                    it("retrieves stored value") {
                        expect(container.sharedData.storeDictionary["testKey"] as? String) == "testValue"
                    }
                }
            }
        }
    }

    class StubPlayback: Playback {
        override var pluginName: String {
            return "AVPlayback"
        }

        override class func canPlay(_: Options) -> Bool {
            return true
        }

        override func play() {
            trigger(.playing)
        }
    }

    class FakeContainerPlugin: UIContainerPlugin {
        override var pluginName: String {
            return "FakeContainerPlugin"
        }

        override func destroy() {
            trigger(Event.didDestroy.rawValue)
        }
    }

    class AnotherFakeContainerPlugin: UIContainerPlugin {
        override var pluginName: String {
            return "AnotherFakeContainerPlugin"
        }
    }
}

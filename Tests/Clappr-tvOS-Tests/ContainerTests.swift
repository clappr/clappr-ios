import Quick
import Nimble
import Clappr

class ContainerTests: QuickSpec {

    override func spec() {
        describe("Container") {
            let options: Options = [kSourceUrl: "http://clappr.com/video.mp4"]
            let optionsWithInvalidSource = [kSourceUrl: "invalid"]

            var container: Container!
            var playback: StubPlayback!
            var loader: Loader!

            beforeEach {
                loader = Loader()
                loader.addExternalPlugins([StubPlayback.self])
                container = Container(loader: loader, options: options)
                playback = container.playback as! StubPlayback
            }

            describe("Initialization") {
                it("Should create a container with valid playback for a valid source") {
                    let container = Container(options: options)

                    expect(container.playback?.pluginName) == "AVPlayback"
                }

                it("Should create a container with invalid playback for url that cannot be played") {
                    let container = Container(options: optionsWithInvalidSource)

                    expect(container.playback?.pluginName) == "NoOp"
                }

                it("Should have the playback as subview after rendered") {
                    container.render()
                    expect(playback.superview) == container
                }

                it("Should have a constructor that receive options") {
                    let options = ["aOption": "option"]
                    let container = Container(options: options)

                    let option = container.options["aOption"] as! String

                    expect(option) == "option"
                }

                it("Should add container plugins from loader") {
                    loader.addExternalPlugins([FakeContainerPlugin.self, AnotherFakeContainerPlugin.self])

                    let container = Container(loader: loader, options: options)

                    expect(container.hasPlugin(FakeContainerPlugin.self)).to(beTrue())
                    expect(container.hasPlugin(AnotherFakeContainerPlugin.self)).to(beTrue())
                }
            }

            describe("Destroy") {
                it("Should be removed from superview and destroy playback when destroy is called") {
                    let wrapperView = UIView()
                    wrapperView.addSubview(container)

                    container.destroy()

                    expect(playback.superview).to(beNil())
                    expect(container.superview).to(beNil())
                }

                it("Should stop listening to events after destroy is called") {
                    var callbackWasCalled = false
                    container.on("some-event") { _ in
                        callbackWasCalled = true
                    }

                    container.destroy()
                    container.trigger("some-event")

                    expect(callbackWasCalled) == false
                }
            }

            describe("Plugins") {
                class FakeUIContainerPlugin: UIContainerPlugin {}
                class AnotherUIContainerPlugin: UIContainerPlugin {}

                it("Should be able to add a new container UIPlugin") {
                    container.addPlugin(FakeUIContainerPlugin())
                    expect(container.plugins).toNot(beEmpty())
                }

                it("Should be able to check if has a plugin with given class") {
                    container.addPlugin(FakeUIContainerPlugin())
                    expect(container.hasPlugin(FakeUIContainerPlugin.self)).to(beTrue())
                }

                it("Should return false if plugin isn't on container") {
                    container.addPlugin(FakeUIContainerPlugin())
                    expect(container.hasPlugin(AnotherUIContainerPlugin.self)).to(beFalse())
                }

                it("Should not add self reference on the plugin") {
                    let plugin = FakeUIContainerPlugin()
                    container.addPlugin(plugin)
                    expect(plugin.container).to(beNil())
                }

                it("Should instantiate plugin with self reference") {
                    let plugin = FakeUIContainerPlugin(context: container)
                    container.addPlugin(plugin)
                    expect(plugin.container) == container
                }

                it("Should add plugin as subview after rendered") {
                    let plugin = FakeUIContainerPlugin()
                    container.addPlugin(plugin)
                    container.render()

                    expect(plugin.superview) == container
                }
            }

            describe("Source") {
                it("Should be able to load a source") {
                    let container = Container()

                    container.load("http://clappr.com/video.mp4")

                    expect(container.playback?.pluginName) == "AVPlayback"
                    expect(container.playback?.superview) == container
                }

                it("Should be able to load a source with mime type") {
                    let container = Container()

                    container.load("http://clappr.com/video", mimeType: "video/mp4")

                    expect(container.playback?.pluginName) == "AVPlayback"
                    expect(container.playback?.superview) == container
                }

                it("should keep just one playback as subview at time") {
                    let container = Container()
                    container.load("anyVideo")
                    expect(container.subviews.filter({ $0 is Playback }).count).to(equal(1))
                    container.load("anyOtherVideo")
                    expect(container.subviews.filter({ $0 is Playback }).count).to(equal(1))
                }
            }

            describe("Options") {
                it("Should reset startAt after first play event") {

                    let options = [kSourceUrl: "someUrl", kStartAt: 15.0] as Options
                    let container = Container(loader: loader, options: options)

                    expect(container.options[kStartAt] as? TimeInterval) == 15.0
                    expect(container.playback?.startAt) == 15.0

                    container.playback?.play()
                    container.load("http://clappr.com/video.mp4")

                    expect(container.options[kStartAt] as? TimeInterval) == 0.0
                    expect(container.playback?.startAt) == 0.0
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
    }

    class AnotherFakeContainerPlugin: UIContainerPlugin {
        override var pluginName: String {
            return "AnotherFakeContainerPlugin"
        }
    }
}

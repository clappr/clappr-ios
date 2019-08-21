import Quick
import Nimble

@testable import Clappr

class SimpleContainerPluginTests: QuickSpec {
    override func spec() {
        describe(".SimpleContainerPlugin") {
            context("#init") {
                it("calls bind events") {
                    let container = ContainerStub()
                    let simpleContainerPlugin = SimpleContainerStubPlugin(context: container)

                    expect(simpleContainerPlugin.didCallBindEvents).to(beTrue())
                }

                it("has a non nil container") {
                    let container = ContainerStub()
                    let simpleContainerPlugin = SimpleContainerStubPlugin(context: container)

                    expect(simpleContainerPlugin.container).toNot(beNil())
                }

                it("has a non nil playback") {
                    let container = ContainerStub()
                    let simpleContainerPlugin = SimpleContainerStubPlugin(context: container)

                    expect(simpleContainerPlugin.playback).to(equal(container.playback))
                }
            }
        }
    }
}

private class SimpleContainerStubPlugin: SimpleContainerPlugin {
    var didCallBindEvents = false

    override func bindEvents() {
        didCallBindEvents = true
    }
}

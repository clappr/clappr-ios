import Quick
import Nimble

@testable import Clappr

class SimpleCorePluginTests: QuickSpec {
    override func spec() {
        describe(".SimpleCorePlugin") {
            context("#init") {
                it("calls bind events") {
                    let core = CoreStub()
                    let simpleCorePlugin = SimpleCoreStubPlugin(context: core)

                    expect(simpleCorePlugin.didCallBindEvents).to(beTrue())
                }

                it("has a non nil core") {
                    let core = CoreStub()
                    let simpleCorePlugin = SimpleCoreStubPlugin(context: core)

                    expect(simpleCorePlugin.core).toNot(beNil())
                }

                it("has a non nil activeContainer") {
                    let core = CoreStub()
                    let simpleCorePlugin = SimpleCoreStubPlugin(context: core)

                    expect(simpleCorePlugin.activeContainer).to(equal(core.activeContainer))
                }
            }
        }
    }
}

private class SimpleCoreStubPlugin: SimpleCorePlugin {
    var didCallBindEvents = false

    override func bindEvents() {
        didCallBindEvents = true
    }
}

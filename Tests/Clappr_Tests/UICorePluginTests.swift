import Quick
import Nimble
@testable import Clappr

class UICorePluginTests: QuickSpec {
    override func spec() {
        describe(".UICorePluginTests") {
            describe("#init") {
                it("has a name") {
                    expect(NoNameCorePlugin.name).to(raiseException(named: "MissingPluginName"))
                    expect(StubCorePlugin.name) == "StubCorePlugin"
                }

                it("has a view") {
                    let core = Core()
                    let plugin = StubCorePlugin(context: core)

                    expect(plugin.view).toNot(beNil())
                }

                it("is initialized with a Core") {
                    let core = Core()
                    let plugin = StubCorePlugin(context: core)

                    expect(plugin.core).to(equal(core))
                }

                it("cannot be initialized with wrong context") {
                    let context = UIObject()

                    expect(StubCorePlugin(context: context)).to(raiseException(named: "WrongContextType"))
                }
            }

            describe("#render") {
                it("crashes if render is not overriden") {
                    let core = Core()
                    let plugin = StubCorePlugin(context: core)
                    let expectedExceptionName = "RenderNotOverriden"
                    let expectedExceptionReason = "UICorePlugins should always override the render method"

                    expect(plugin.render()).to(raiseException(named: expectedExceptionName, reason: expectedExceptionReason))
                }
            }
        }
    }

    class StubCorePlugin: UICorePlugin {
        override class var name: String {
            return "StubCorePlugin"
        }

        override func bindEvents() { }
    }

    class NoNameCorePlugin: UICorePlugin {

        override func bindEvents() { }
    }
}

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
        }
    }

    class StubCorePlugin: UICorePlugin {
        override var pluginName: String {
            return "StubCorePlugin"
        }
    }

    class NoNameCorePlugin: UICorePlugin {
    }
}

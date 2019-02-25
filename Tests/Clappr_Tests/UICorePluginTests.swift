import Quick
import Nimble
@testable import Clappr

class UICorePluginTests: QuickSpec {

    override func spec() {
        it("Should have a name") {
            expect(NoNameCorePlugin.name).to(raiseException(named: "MissingPluginName"))
            expect(StubCorePlugin.name) == "StubCorePlugin"
        }

        describe("Instantiation") {
            it("Should be initializaed with a Core") {
                let core = Core()
                let plugin = StubCorePlugin(context: core)

                expect(plugin.core) == core
            }

            it("Should not be initializaed with wrong context") {
                let context = UIObject()
                expect(StubCorePlugin(context: context)).to(raiseException(named: "WrongContextType"))

                let container = Container()
                expect(StubCorePlugin(context: container)).to(raiseException(named: "WrongContextType"))
            }
            
            it("crashes if render is not overriden") {
                let core = Core()
                let plugin = StubCorePlugin(context: core)
                let expectedExceptionName = "RenderNotOverriden"
                let expectedExceptionReason = "UICorePlugins should always override the render method"
                
                expect(plugin.render()).to(raiseException(named: expectedExceptionName, reason: expectedExceptionReason))
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

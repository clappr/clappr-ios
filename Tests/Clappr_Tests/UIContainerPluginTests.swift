import Quick
import Nimble
@testable import Clappr

class UIContainerPluginTests: QuickSpec {

    override func spec() {
        it("Should have a name") {
            expect(NoNameContainerPlugin.name).to(raiseException(named: "MissingPluginName"))
            expect(StubContainerPlugin.name) == "StubContainerPlugin"
        }

        describe("Instantiation") {
            it("Should be initializaed with a Container") {
                let container = Container()
                let plugin = StubContainerPlugin(context: container)

                expect(plugin.container) == container
            }

            it("Should not be initializaed with wrong context") {
                let context = UIObject()
                expect(StubContainerPlugin(context: context)).to(raiseException(named: "WrongContextType"))

                let core = Core()
                expect(StubContainerPlugin(context: core)).to(raiseException(named: "WrongContextType"))
            }
        }
    }

    class StubContainerPlugin: UIContainerPlugin {
        override var pluginName: String {
            return "StubContainerPlugin"
        }
    }

    class NoNameContainerPlugin: UIContainerPlugin {
    }
}

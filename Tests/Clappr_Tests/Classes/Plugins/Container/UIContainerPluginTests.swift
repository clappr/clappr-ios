import Quick
import Nimble
@testable import Clappr

class UIContainerPluginTests: QuickSpec {
    override func spec() {
        describe(".UIContainerPluginTests") {
            describe("#init") {
                it("has a name") {
                    expect(NoNameContainerPlugin.name).to(raiseException(named: "MissingPluginName"))
                    expect(StubContainerPlugin.name) == "StubContainerPlugin"
                }
                
                it("has a view") {
                    let container = Container()
                    let plugin = StubContainerPlugin(context: container)
                    
                    expect(plugin.view).toNot(beNil())
                }
                
                it("is initialized with a Container") {
                    let container = Container()
                    let plugin = StubContainerPlugin(context: container)
                    
                    expect(plugin.container).to(equal(container))
                }

                it("cannot be initialized with wrong context") {
                    let context = UIObject()

                    expect(StubContainerPlugin(context: context)).to(raiseException(named: "WrongContextType"))
                }
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

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

            describe("#render") {
                it("crashes if render is not overriden") {
                    let container = Container()
                    let plugin = StubContainerPlugin(context: container)
                    let expectedExceptionName = "RenderNotOverriden"
                    let expectedExceptionReason = "UIContainerPlugins should always override the render method"

                    expect(plugin.render()).to(raiseException(named: expectedExceptionName, reason: expectedExceptionReason))
                }
            }
        }
    }
    
    class StubContainerPlugin: UIContainerPlugin {
        override class var name: String {
            return "StubContainerPlugin"
        }

        override func bindEvents() { }
    }

    class NoNameContainerPlugin: UIContainerPlugin {

        override func bindEvents() { }
    }
}

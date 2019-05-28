import Quick
import Nimble
@testable import Clappr

class CorePluginTests: QuickSpec {
    override func spec() {
        describe(".CorePluginTests") {
            describe("#init") {
                it("returns a core passing in constructor") {
                    let core = CoreStub()
                    let corePlugin = CorePlugin(context: core)
                    
                    expect(corePlugin.core).to(equal(core))
                }
                
                it("returns an exception when context is not Core type") {
                    let container = ContainerStub()
                    let expectedExceptionName = "WrongContextType"
                    let expectedExceptionReason = "Core Plugins should always be initialized with a Core context"
                    
                    expect(CorePlugin(context: container)).to(raiseException(named: expectedExceptionName, reason: expectedExceptionReason))
                }
            }
            
            describe("#plugin type") {
                it("returns a core") {
                    expect(CorePlugin.type).to(equal(.core))
                }
            }
            
            describe("#plugin name") {
                it("returns an exception") {
                    let core = CoreStub()
                    let corePlugin = CorePlugin(context: core)
                    let expectedExceptionName = "MissingPluginName"
                    let expectedExceptionReason = "Core Plugins should always declare a name. CorePlugin does not."
                    expect(corePlugin.pluginName).to(raiseException(named: expectedExceptionName, reason: expectedExceptionReason))
                }
            }
            
            describe("#name") {
                it("returns an exception") {
                    let expectedExceptionName = "MissingPluginName"
                    let expectedExceptionReason = "Core Plugins should always declare a name. CorePlugin does not."
                    
                    expect(CorePlugin.name).to(raiseException(named: expectedExceptionName, reason: expectedExceptionReason))
                }
            }
            
            describe("#destroy") {
                it("stops listening to container events") {
                    let core = CoreStub()
                    let corePlugin = CorePluginStub(context: core)
                    var callbackWasCalled = false
                    corePlugin.listenTo(core, eventName: "some-event") { _ in
                        callbackWasCalled = true
                    }
                    corePlugin.destroy()
                    corePlugin.trigger("some-event")
                    expect(callbackWasCalled).toEventually(beFalse())
                }
            }
        }
    }
}

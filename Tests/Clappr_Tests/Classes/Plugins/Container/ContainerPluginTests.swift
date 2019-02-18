import Quick
import Nimble
@testable import Clappr

class ContainerPluginTests: QuickSpec {
    override func spec() {
        describe(".ContainerPluginTests") {
            describe("#init") {
                it("should return a container passing in constructor") {
                    let container = ContainerStub()
                    let containerPlugin = ContainerPlugin(context: container)

                    expect(containerPlugin.container).to(equal(container))
                }

                it("should return an exception when context is not Container type") {
                    let core = CoreStub()
                    let expectedExceptionName = "WrongContextType"
                    let expectedExceptionReason = "Container Plugins should always be initialized with a Container context"

                    expect(ContainerPlugin(context: core)).to(raiseException(named: expectedExceptionName, reason: expectedExceptionReason))
                }
            }

            describe("#plugin type") {
                it("should return container") {
                    expect(ContainerPlugin.type).to(equal(.container))
                }
            }

            describe("#plugin name") {
                it("should return an exception") {
                    let container = ContainerStub()
                    let containerPlugin = ContainerPlugin(context: container)
                    let expectedExceptionName = "MissingPluginName"
                    let expectedExceptionReason = "Container Plugins should always declare a name"
                    expect(containerPlugin.pluginName).to(raiseException(named: expectedExceptionName, reason: expectedExceptionReason))
                }
            }

            describe("#name") {
                it("should return an exception") {
                    let expectedExceptionName = "MissingPluginName"
                    let expectedExceptionReason = "Container Plugins should always declare a name"

                    expect(ContainerPlugin.name).to(raiseException(named: expectedExceptionName, reason: expectedExceptionReason))
                }
            }
        }
    }
}

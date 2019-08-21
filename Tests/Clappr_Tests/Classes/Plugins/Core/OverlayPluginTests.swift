import Quick
import Nimble
@testable import Clappr

class OverlayPluginTests: QuickSpec {
    override func spec() {
        describe("OverlayPlugin") {
            describe("#init") {
                it("has a name") {
                    let core = CoreStub()
                    let plugin = OverlayPlugin(context: core)

                    expect(plugin.pluginName).to(equal("OverlayPlugin"))
                }

                it("is a kind of UICorePlugin") {
                    let core = CoreStub()
                    let plugin = OverlayPlugin(context: core)

                    expect(plugin).to(beAKindOf(UICorePlugin.self))
                }

                it("starts with modal flag set to false") {
                    let core = CoreStub()
                    let plugin = OverlayPlugin(context: core)

                    expect(plugin.isModal).to(beFalse())
                }
            }
        }
    }
}

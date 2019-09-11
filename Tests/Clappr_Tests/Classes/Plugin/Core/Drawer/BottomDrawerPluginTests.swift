import Quick
import Nimble

@testable import Clappr

class BottomDrawerPluginTests: QuickSpec {

    override func spec() {
        describe(".BottomDrawerPlugin") {
            context("#init") {
                it("has a name") {
                    let core = CoreStub()
                    let plugin = BottomDrawerPlugin(context: core)

                    expect(plugin.pluginName).to(equal("BottomDrawerPlugin"))
                }

                it("has bottom as position") {
                    let core = CoreStub()
                    let plugin = BottomDrawerPlugin(context: core)

                    expect(plugin.position).to(equal(.bottom))
                }

                it("has size with the same width and the half of the height from parentView") {
                    let core = CoreStub()
                    let plugin = BottomDrawerPlugin(context: core)

                    core.view = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 100))

                    expect(plugin.size).to(equal(CGSize(width: 320, height: 50)))
                }
            }
        }
    }
}


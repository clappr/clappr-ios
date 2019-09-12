import Quick
import Nimble

@testable import Clappr

class BottomDrawerPluginTests: QuickSpec {

    override func spec() {
        describe(".BottomDrawerPlugin") {
            context("#init") {
                var core: CoreStub!
                var plugin: BottomDrawerPlugin!

                beforeEach {
                    core = CoreStub()
                    plugin = BottomDrawerPlugin(context: core)
                }

                it("has a name") {
                    expect(plugin.pluginName).to(equal("BottomDrawerPlugin"))
                }

                it("has bottom as position") {
                    expect(plugin.position).to(equal(.bottom))
                }

                it("has size with the same width and the half of the height from parentView") {
                    core.view = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 100))

                    expect(plugin.size).to(equal(CGSize(width: 320, height: 50)))
                }
            }

            context("#render") {
                it("has origin x on zero and y equal to parentView height") {
                    let core = CoreStub()
                    let plugin = BottomDrawerPlugin(context: core)
                    core.view = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 100))

                    plugin.render()

                    expect(plugin.view.frame.origin.y).to(equal(100))
                    expect(plugin.view.frame.origin.x).to(equal(.zero))
                }
            }

            context("when the showDrawerPlugin event is triggered") {
                it("up the drawer to his height") {
                    let core = CoreStub()
                    let plugin = BottomDrawerPlugin(context: core)
                    core.view = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 100))

                    plugin.render()
                    core.trigger(.showDrawerPlugin)

                    expect(plugin.view.frame.origin.y).to(equal(plugin.size.height))
                    expect(plugin.view.frame.origin.x).to(equal(.zero))
                }
            }
        }
    }
}


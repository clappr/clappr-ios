import Quick
import Nimble

@testable import Clappr

class BottomDrawerPluginTests: QuickSpec {

    override func spec() {
        describe(".BottomDrawerPlugin") {

            let coreViewHeight = CGFloat(100)
            let coreViewWidth = CGFloat(320)

            context("#init") {
                var core: CoreStub!
                var plugin: BottomDrawerPlugin!

                beforeEach {
                    core = CoreStub()
                    plugin = BottomDrawerPlugin(context: core)
                }

                it("has bottom as position") {
                    expect(plugin.position).to(equal(.bottom))
                }

                it("has size with the same width and the half of the height from parentView") {
                    core.view = UIView(frame: CGRect(x: 0, y: 0, width: coreViewWidth, height: coreViewHeight))

                    expect(plugin.size).to(equal(CGSize(width: coreViewWidth, height: coreViewHeight/2)))
                }
            }

            describe("#render") {
                var core: CoreStub!
                var plugin: BottomDrawerPlugin!

                beforeEach {
                    core = CoreStub()
                    plugin = BottomDrawerPlugin(context: core)
                    core.view = UIView(frame: CGRect(x: 0, y: 0, width: coreViewWidth, height: coreViewHeight))
                }

                it("has origin x on zero and y equal to parentView height") {
                    plugin.render()

                    expect(plugin.view.frame.origin).to(equal(CGPoint(x: .zero, y: coreViewHeight)))
                }

                it("has a view frame size equals to his size") {
                    plugin.render()

                    expect(plugin.view.frame.size).to(equal(CGSize(width: coreViewWidth, height: coreViewHeight/2)))
                }

                context("when plugin request a height greater then the limit") {
                    it("uses the height limit instead") {
                        core.view = UIView(frame: CGRect(x: 0, y: 0, width: coreViewWidth, height: coreViewHeight))
                        let pluginMock = BottomDrawerPluginMock(context: core)

                        pluginMock.render()

                        expect(pluginMock.view.frame.size).to(equal(CGSize(width: coreViewWidth, height: coreViewHeight/2)))
                    }
                }
            }

            describe("#events") {
                var core: CoreStub!
                var plugin: BottomDrawerPlugin!

                beforeEach {
                    Loader.shared.resetPlugins()
                    core = CoreStub()
                    plugin = BottomDrawerPlugin(context: core)
                    core.view = UIView(frame: CGRect(x: 0, y: 0, width: coreViewWidth, height: coreViewHeight))
                    plugin.render()
                }

                context("when the showDrawerPlugin event is triggered") {
                    it("push up the drawer to half of core height") {
                        core.trigger(.showDrawerPlugin)

                        expect(plugin.view.frame.origin.y).to(equal(coreViewHeight/2))
                    }
                }

                context("when the hideDrawer event is triggered") {
                    it("push down the drawer to core height") {
                        core.trigger(.hideDrawerPlugin)

                        expect(plugin.view.frame.origin.y).to(equal(coreViewHeight))
                    }
                }
            }
        }
    }
}

class BottomDrawerPluginMock: BottomDrawerPlugin {

    override var height: CGFloat {
        return 1000
    }
}

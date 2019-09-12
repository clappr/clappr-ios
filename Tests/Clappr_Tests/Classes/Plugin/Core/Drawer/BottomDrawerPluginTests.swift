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

                it("has bottom as position") {
                    expect(plugin.position).to(equal(.bottom))
                }

                it("has size with the same width and the half of the height from parentView") {
                    core.view = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 100))

                    expect(plugin.size).to(equal(CGSize(width: 320, height: 50)))
                }
            }

            context("#render") {
                var core: CoreStub!
                var plugin: BottomDrawerPlugin!

                beforeEach {
                    core = CoreStub()
                    plugin = BottomDrawerPlugin(context: core)
                    core.view = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 100))
                }

                it("has origin x on zero and y equal to parentView height") {
                    plugin.render()

                    expect(plugin.view.frame.origin).to(equal(CGPoint(x: .zero, y: 100)))
                }

                it("has a view frame size equals to his size") {
                    plugin.render()

                    expect(plugin.view.frame.size).to(equal(CGSize(width: 320, height: 50)))
                }
            }

            describe("#events") {
                var core: CoreStub!
                var plugin: BottomDrawerPlugin!

                beforeEach {
                    core = CoreStub()
                    plugin = BottomDrawerPlugin(context: core)
                    core.view = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 100))
                    plugin.render()
                }

                context("when the showDrawerPlugin event is triggered") {
                    it("push up the drawer to half of core height") {
                        core.trigger(.showDrawerPlugin)

                        expect(plugin.view.frame.origin).to(equal(CGPoint(x: .zero, y: 50)))
                    }
                }

                context("when the hideDrawer event is triggered") {
                    it("push down the drawer to core height") {
                        core.trigger(.hideDrawerPlugin)

                        expect(plugin.view.frame.origin).to(equal(CGPoint(x: .zero, y: 100)))
                    }
                }

                context("when the didTappedCore event is triggered") {
                    it("calls hideDrawer event") {
                        var didCallHideDrawer = false
                        core.on(Event.hideDrawerPlugin.rawValue) { _ in didCallHideDrawer.toggle() }
                        core.trigger(.showDrawerPlugin)

                        core.trigger(InternalEvent.didTappedCore.rawValue)

                        expect(didCallHideDrawer).to(beTrue())
                    }
                }
            }
        }
    }
}

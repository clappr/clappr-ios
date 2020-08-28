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

                it("sets touches in view for UIPanGestureRecognizer") {
                    let panGestureRecognizer = plugin.view.gestureRecognizers?.first(where: {$0 is UIPanGestureRecognizer})

                    expect(panGestureRecognizer?.cancelsTouchesInView).to(beTrue())
                }

                it("disables touches in view for UITapGestureRecognizer") {
                    let tapGestureRecognizer = plugin.view.gestureRecognizers?.first(where: {$0 is UITapGestureRecognizer})

                    expect(tapGestureRecognizer?.cancelsTouchesInView).to(beFalse())
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

                context("width anchor") {
                    it("has a width anchor") {
                        let view = UIView(frame: .zero)
                        view.addSubview(plugin.view)

                        plugin.render()

                        let widthConstraint = plugin.view.superview?.constraints.first { $0.firstAttribute == .width }
                        expect(widthConstraint?.constant).to(equal(0))
                    }
                }

                context("height anchor") {
                    context("and the maxHeight is smaller than height") {
                        it("has a height anchor on superview") {
                            let view = UIView(frame: .zero)
                            view.addSubview(plugin.view)

                            plugin.render()

                            let heightConstraint = plugin.view.superview?.constraints.first { $0.firstAttribute == .height }
                            expect(heightConstraint?.constant).to(equal(0))
                        }
                    }

                    context("and the maxHeight is greater than height") {
                        it("has a height anchor on superview") {
                            let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 2002))
                            let pluginMock = BottomDrawerPluginMock(context: core)
                            view.addSubview(pluginMock.view)

                            pluginMock.render()

                            let heightConstraint = pluginMock.view.constraints.first { $0.firstAttribute == .height }
                            expect(heightConstraint?.constant).to(equal(1000))
                        }
                    }
                }

                context("when plugin request a height greater then the limit") {
                    it("uses the height limit instead") {
                        let view = UIView(frame: CGRect(x: 0, y: 0, width: coreViewWidth, height: coreViewHeight))
                        view.heightAnchor.constraint(equalToConstant: 200).isActive = true
                        let pluginMock = BottomDrawerPluginMock(context: core)
                        view.addSubview(pluginMock.view)

                        pluginMock.render()

                        let heightConstraint = pluginMock.view.superview?.constraints.first { $0.firstAttribute == .height }
                        expect(heightConstraint?.constant).to(equal(200))
                    }
                }
            }

            describe("#events") {
                var core: CoreStub!
                var plugin: BottomDrawerPlugin!
                var view: UIView!

                beforeEach {
                    core = CoreStub()
                    plugin = BottomDrawerPluginMock(context: core)
                    core.view = UIView(frame: CGRect(x: 0, y: 0, width: coreViewWidth, height: coreViewHeight))
                    view = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
                    view.addSubview(plugin.view)

                    plugin.render()
                }

                context("when the showDrawerPlugin event is triggered") {
                    it("push up the drawer to half of super view height") {
                        core.trigger(.showDrawerPlugin)

                        let heightConstraint = plugin.view.superview?.constraints.first { $0.firstAttribute == .top }
                        expect(heightConstraint?.constant).to(equal(-25))
                    }

                    it("enables user interaction on plugin's subviews") {
                        let view = UIView(frame: .zero)
                        view.isUserInteractionEnabled = false
                        plugin.view.addSubview(view)

                        core.trigger(.showDrawerPlugin)

                        expect(view.isUserInteractionEnabled).to(beTrue())
                    }
                }

                context("when the hideDrawer event is triggered") {
                    it("push down the drawer to placeholder") {
                        core.trigger(.hideDrawerPlugin)

                        let heightConstraint = plugin.view.superview?.constraints.first { $0.firstAttribute == .top }
                        expect(heightConstraint?.constant).to(equal(-18))
                    }

                    it("disables user interaction on plugin's subviews") {
                          let view = UIView(frame: .zero)
                          view.isUserInteractionEnabled = true
                          plugin.view.addSubview(view)

                          core.trigger(.hideDrawerPlugin)

                          expect(view.isUserInteractionEnabled).to(beFalse())
                      }
                }
            }
        }
    }
}

class BottomDrawerPluginMock: BottomDrawerPlugin {
    override var height: CGFloat { 1000 }
    override var placeholder: CGFloat { 18 }
}

import Quick
import Nimble
@testable import Clappr

class DrawerPluginTests: QuickSpec {
    override func spec() {
        describe(".DrawerPluginTests") {
            var plugin: DrawerPlugin!
            var core: CoreStub!

            beforeEach {
                core = CoreStub()
                plugin = DrawerPlugin(context: core)
            }

            describe("#init") {
                it("has a position") {
                    expect(plugin.position).to(equal(.undefined))
                }

                it("has a size") {
                    expect(plugin.size).to(equal(.zero))
                }

                it("starts closed") {
                    expect(plugin.isClosed).to(beTrue())
                }

                it("has a placeholder") {
                    expect(plugin.placeholder).to(equal(.zero))
                }

                it("starts with alpha zero") {
                    expect(plugin.view.alpha).to(equal(.zero))
                }
            }

            describe("event listening") {
                var triggeredEvents: [Event] = []

                beforeEach {
                    triggeredEvents.removeAll()

                    core.on(Event.willHideDrawerPlugin.rawValue) {_ in
                        triggeredEvents.append(.willHideDrawerPlugin)
                    }

                    core.on(Event.didHideDrawerPlugin.rawValue) {_ in
                        triggeredEvents.append(.didHideDrawerPlugin)
                    }

                    core.on(Event.willShowDrawerPlugin.rawValue) {_ in
                        triggeredEvents.append(.willShowDrawerPlugin)
                    }

                    core.on(Event.didShowDrawerPlugin.rawValue) {_ in
                        triggeredEvents.append(.didShowDrawerPlugin)
                    }
                }

                context("when showDrawerPlugin is triggered") {
                    it("opens the drawer") {
                        core.trigger(.showDrawerPlugin)

                        expect(plugin.isClosed).to(beFalse())
                        expect(triggeredEvents).to(equal([.willShowDrawerPlugin, .didShowDrawerPlugin]))
                    }
                }

                context("when hideDrawerPlugin is triggered") {
                    it("closes the drawer") {
                        core.trigger(.hideDrawerPlugin)

                        expect(plugin.isClosed).to(beTrue())
                        expect(triggeredEvents).to(equal([.willHideDrawerPlugin, .didHideDrawerPlugin]))
                    }
                }

                context("when open and closes drawer") {
                    it("triggers the will show and will hide drawer events") {
                        core.trigger(.showDrawerPlugin)
                        core.trigger(.hideDrawerPlugin)

                        expect(plugin.isClosed).to(beTrue())
                        expect(triggeredEvents).to(equal([.willShowDrawerPlugin, .didShowDrawerPlugin, .willHideDrawerPlugin, .didHideDrawerPlugin]))
                    }
                }

                context("when media control is going to be presented") {
                    it("sets drawer plugin alpha to 1") {
                        plugin.view.alpha = 0
                        
                        core.trigger(.willShowMediaControl)

                        expect(plugin.view.alpha).toEventually(equal(1))
                    }
                }

                context("when media control is going to be dismissed") {
                    it("sets drawer plugin alpha to 1") {
                        plugin.view.alpha = 1

                        core.trigger(.willHideMediaControl)

                        expect(plugin.view.alpha).toEventually(equal(0))
                    }
                }

                context("when drawer is opened") {
                    context("and media control will be dismissed") {
                        it("keeps the drawer with alpha 1") {
                            core.trigger(.showDrawerPlugin)
                            core.trigger(.willShowMediaControl)
                            core.trigger(.willHideMediaControl)

                            expect(plugin.view.alpha).toEventually(equal(1))
                        }
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

            describe("rendering") {
                context("when placeholder is greater than zero") {
                    it("triggers requestPadding event") {
                        let core = CoreStub()
                        let plugin = MockDrawerPlugin(context: core)
                        plugin._placeholder = 32.0
                        var paddingRequested: CGFloat = .zero

                        core.on(Event.requestPadding.rawValue) { info in
                            paddingRequested = info?["padding"] as? CGFloat ?? .zero
                        }

                        plugin.render()

                        expect(plugin.placeholder).to(equal(32))
                        expect(paddingRequested).to(equal(32))
                    }
                }

                context("when placeholder less than or equal zero") {
                    it("doesn't trigger requestPadding event") {
                        let core = CoreStub()
                        let plugin = MockDrawerPlugin(context: core)
                        plugin._placeholder = .zero
                        var didCallRequestPadding = false

                        core.on(Event.requestPadding.rawValue) { info in
                            didCallRequestPadding.toggle()
                        }

                        plugin.render()

                        expect(plugin.placeholder).to(equal(.zero))
                        expect(didCallRequestPadding).to(beFalse())
                    }
                }
            }
        }
    }
}

class MockDrawerPlugin: DrawerPlugin {
    var _placeholder: CGFloat = .zero
    var didCallRender = false

    override var placeholder: CGFloat {
        return _placeholder
    }

    override func render() {
        super.render()
        didCallRender = true
    }
}

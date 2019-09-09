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

                it("has a padding") {
                    expect(plugin.padding).to(equal(.zero))
                }
            }

            fdescribe("event listening") {
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

                context("when drawer is closed") {
                    it("doesn't trigger willHide and didHide events") {
                        core.trigger(.hideDrawerPlugin)

                        expect(plugin.isClosed).to(beTrue())
                        expect(triggeredEvents).to(equal([]))
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
                        expect(triggeredEvents).to(beEmpty())
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
                            core.trigger(.willHideMediaControl)

                            expect(plugin.view.alpha).toEventually(equal(1))
                        }
                    }
                }
            }
        }
    }
}

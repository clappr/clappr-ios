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
            }
        }
    }
}

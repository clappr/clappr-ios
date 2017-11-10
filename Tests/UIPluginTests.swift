import Quick
import Nimble
@testable import Clappr

class UIPluginTests: QuickSpec {

    override func spec() {
        describe("Instantiation") {

            it("Should enable plugin by default") {
                let plugin = UIPlugin()
                expect(plugin.enabled).to(beTrue())
            }
        }

        describe("Behavior") {
            var plugin: UIPlugin!

            beforeEach {
                plugin = UIPlugin()
            }

            context("Enabling") {
                it("Should not be hidden") {
                    plugin.enabled = false
                    plugin.enabled = true
                    expect(plugin.isHidden).to(beFalse())
                }
            }

            context("Disabling") {
                it("Should be hidden") {
                    plugin.enabled = false
                    expect(plugin.isHidden).to(beTrue())
                }

                it("Should stop listening to events") {
                    var eventWasCalled = false
                    plugin.on("event") { _ in
                        eventWasCalled = true
                    }

                    plugin.enabled = false
                    plugin.trigger("event")

                    expect(eventWasCalled).to(beFalse())
                }
            }
        }
    }
}

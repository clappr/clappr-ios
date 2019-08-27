import Quick
import Nimble
@testable import Clappr

class OverlayPluginTests: QuickSpec {
    override func spec() {
        describe("OverlayPlugin") {
            describe("#init") {
                var core: CoreStub!
                var plugin: OverlayPlugin!

                beforeEach {
                    core = CoreStub()
                    plugin = OverlayPluginMock(context: core)
                }

                it("has a name") {
                    expect(plugin.pluginName).to(equal("OverlayPlugin"))
                }

                it("is a kind of UICorePlugin") {
                    expect(plugin).to(beAKindOf(UICorePlugin.self))
                }

                it("starts with modal flag set to false") {
                    expect(plugin.isModal).to(beFalse())
                }
            }

            describe("rendering") {
                context("when it is not modal") {
                    it("renders with its own frame") {
                        let core = CoreStub()
                        let plugin = OverlayPluginMock(context: core)
                        let parentView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
                        core.parentView = parentView
                        plugin.view = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
                        core.addPlugin(plugin)

                        core.render()

                        expect(plugin.view.frame.size).to(equal(CGSize(width: 10, height: 10)))
                    }
                }

                context("when it is modal") {
                    it("fits the parentView bounds") {
                        let core = CoreStub()
                        let parentView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
                        core.parentView = parentView
                        let plugin = OverlayPluginMock(context: core)
                        plugin._isModal = true
                        plugin.view = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
                        core.addPlugin(plugin)

                        core.render()

                        expect(plugin.view.frame.size).to(equal(parentView.frame.size))
                    }
                }
            }
        }
    }
}

class OverlayPluginMock: OverlayPlugin {
    var _isModal: Bool = false

    override var isModal: Bool {
        return _isModal
    }

    override func bindEvents() { }
}


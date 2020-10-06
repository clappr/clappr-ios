import Quick
import Nimble
@testable import Clappr

class CoreLayerTests: QuickSpec {
    override func spec() {
        describe(".CoreLayer") {
            context("When a UICorePlugin is attached") {
                it("is added as a CoreLayer subview") {
                    let uiCorePlugin = UICorePluginStub(context: CoreStub())
                    let coreLayer = CoreLayer()

                    coreLayer.attachPlugin(uiCorePlugin)

                    expect(uiCorePlugin.view.superview).to(equal(coreLayer))
                }
            }
        }
    }
}

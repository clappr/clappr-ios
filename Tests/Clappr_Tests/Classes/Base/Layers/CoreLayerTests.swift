import Quick
import Nimble
@testable import Clappr

class CoreLayerTests: QuickSpec {
    override func spec() {
        describe(".CoreLayer") {
            context("When a UICorePlugin is attached") {
                it("adds on CoreLayer as subview") {
                    let uiCorePlugin = UICorePluginStub(context: CoreStub())
                    let coreLayer = CoreLayer()

                    coreLayer.attachPlugin(uiCorePlugin)

                    expect(coreLayer.subviews.count).to(equal(1))
                }
            }
        }
    }
}

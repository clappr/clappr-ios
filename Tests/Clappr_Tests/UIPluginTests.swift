import Quick
import Nimble
@testable import Clappr

class UIPluginTests: QuickSpec {

    override func spec() {
        describe("UIPlugin") {
            it("conforms with UIObject protocol") {
                let uiPlugin = UIPluginStub(context: CoreStub())

                expect(uiPlugin as UIPlugin).toNot(beNil())
            }

            describe("#view") {
                it("stores a view") {
                    let view = UIView()
                    let uiPlugin = UIPluginStub()
                    uiPlugin.view = view
                    
                    expect(uiPlugin.view).to(equal(view))
                }
            }
        }
    }
}

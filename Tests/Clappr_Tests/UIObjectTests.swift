import Quick
import Nimble
@testable import Clappr

class UIObjectTests: QuickSpec {

    override func spec() {
        describe("UIObject") {
            it("Should handle EventListeners callbacks when triggered") {
                let uiObject = UIObject()
                var callbackWasCalled = false

                uiObject.on("some-event") { _ in
                    callbackWasCalled = true
                }
                uiObject.trigger("some-event")

                expect(callbackWasCalled) == true
            }
        }
    }
}

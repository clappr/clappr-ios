import Quick
import Nimble
@testable import Clappr

class EventHandlerSpec: QuickSpec {
    override func spec() {
        describe("EventHandler") {

            it("Should receive the user info back") {
                var control: String!
                let info = "result"

                let eventHandler = EventHandler(callback: { (userInfo) -> Void in
                    let userInfo = userInfo as! [String: String]
                    control = userInfo["testCase"]
                })

                eventHandler.handleEvent(Notification(name: Notification.Name(rawValue: ""), object: self, userInfo: ["testCase": info]))

                expect(control) == info
            }

            it("protect the main thread") {
                let expectation = QuickSpec.current.expectation(description: "doesn't crash")
                let eventHandler = EventHandler(callback: { (userInfo) -> Void in
                    NSException(name:NSExceptionName(rawValue: "TestError"), reason:"Test Error", userInfo:nil).raise()
                })

                eventHandler.handleEvent(Notification(name: Notification.Name(rawValue: ""), object: self, userInfo: nil))

                expectation.fulfill()
                QuickSpec.current.waitForExpectations(timeout: 1)
            }
        }
    }
}

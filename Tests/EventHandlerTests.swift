import Quick
import Nimble
import Clappr

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
        }
    }
}

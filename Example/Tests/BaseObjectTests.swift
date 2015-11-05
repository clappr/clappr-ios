import Quick
import Nimble
import Clappr

class BaseObjectTests: QuickSpec {
    private let eventName = "some-event"
    
    override func spec() {
        describe("BaseObject") {
            
            var baseObject: BaseObject!
            
            beforeEach {
                baseObject = BaseObject()
            }
            
            describe("on") {
                var callbackWasCalled: Bool!
                
                beforeEach {
                    callbackWasCalled = false
                }
                
                it("Callback should be called on event trigger") {
                    baseObject.on(self.eventName) { userInfo in
                        callbackWasCalled = true
                    }
                    
                    baseObject.trigger(self.eventName)
                    
                    expect(callbackWasCalled) == true
                }
                
            }
        }
    }
}
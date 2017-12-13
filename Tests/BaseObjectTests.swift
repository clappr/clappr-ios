import Quick
import Nimble
@testable import Clappr

class BaseObjectTests: QuickSpec {

    class ConcreteBaseObject: BaseObject { }

    override func spec() {
        describe("BaseObject") {

            var baseObject: ConcreteBaseObject!
            var callbackWasCalled: Bool!

            let eventName = "some-event"
            let callback: EventCallback = { _ in
                callbackWasCalled = true
            }

            beforeEach {
                baseObject = ConcreteBaseObject()
                callbackWasCalled = false
            }

            context("initialization") {
                it("doesn't initialize EventDispatcher twice") {
                    expect(baseObject.eventDispatcher) == baseObject.eventDispatcher
                }
            }

            context("events") {
                describe("on") {
                    it("executes callback function") {
                        baseObject.on(eventName, callback: callback)
                        baseObject.trigger(eventName)

                        expect(callbackWasCalled) == true
                    }

                    it("receives userInfo when triggered with params") {
                        var value = "Not Expected"

                        baseObject.on(eventName) { userInfo in
                            value = userInfo?["new_value"] as! String
                        }
                        baseObject.trigger(eventName, userInfo: ["new_value": "Expected"])

                        expect(value) == "Expected"
                    }

                    it("executes multiple callback functions") {
                        var secondCallbackWasCalled = false

                        baseObject.on(eventName, callback: callback)
                        baseObject.on(eventName) { _ in
                            secondCallbackWasCalled = true
                        }
                        baseObject.trigger(eventName)

                        expect(callbackWasCalled) == true
                        expect(secondCallbackWasCalled) == true
                    }

                    it("doesn't execute callback for another event") {
                        baseObject.on(eventName, callback: callback)
                        baseObject.trigger("another-event")

                        expect(callbackWasCalled) == false
                    }

                    it("doesn't executes callback for another context object") {
                        let anotherBaseObject = ConcreteBaseObject()

                        baseObject.on(eventName, callback: callback)
                        anotherBaseObject.trigger(eventName)

                        expect(callbackWasCalled) == false
                    }
                }

                describe("once") {
                    it("executes callback function") {
                        baseObject.once(eventName, callback: callback)
                        baseObject.trigger(eventName)

                        expect(callbackWasCalled) == true
                    }

                    it("doesn't execute callback function twice") {
                        baseObject.once(eventName, callback: callback)

                        baseObject.trigger(eventName)
                        callbackWasCalled = false
                        baseObject.trigger(eventName)

                        expect(callbackWasCalled) == false
                    }

                    it("doesn't execute callback function when it is removed") {
                        let listenId = baseObject.once(eventName, callback: callback)
                        baseObject.off(listenId)
                        baseObject.trigger(eventName)

                        expect(callbackWasCalled) == false
                    }
                }

                describe("listenTo") {
                    it("executes callback function for an event on a given context object") {
                        let anotherBaseObject = ConcreteBaseObject()

                        baseObject.listenTo(anotherBaseObject, eventName: eventName, callback: callback)
                        anotherBaseObject.trigger(eventName)

                        expect(callbackWasCalled) == true
                    }
                }

                describe("listenToOnce") {
                    it("executes callback function just one time for an event on a given context object") {
                        let anotherBaseObject = ConcreteBaseObject()

                        baseObject.listenToOnce(anotherBaseObject, eventName: eventName, callback: callback)
                        anotherBaseObject.trigger(eventName)

                        expect(callbackWasCalled) == true

                        callbackWasCalled = false
                        anotherBaseObject.trigger(eventName)

                        expect(callbackWasCalled) == false
                    }
                }

                describe("off") {
                    it("doesn't executes callback function if it is removed") {
                        let listenId = baseObject.on(eventName, callback: callback)
                        baseObject.off(listenId)
                        baseObject.trigger(eventName)

                        expect(callbackWasCalled) == false
                    }
                    it("doesn't execute callback if it is removed, but the others are called") {
                        var anotherCallbackWasCalled = false
                        let anotherCallback: EventCallback = { _ in
                            anotherCallbackWasCalled = true
                        }

                        let listenId = baseObject.on(eventName, callback: callback)
                        baseObject.on(eventName, callback: anotherCallback)

                        baseObject.off(listenId)
                        baseObject.trigger(eventName)

                        expect(callbackWasCalled) == false
                        expect(anotherCallbackWasCalled) == true
                    }
                }

                describe("stopListening") {
                    it("disables all callbacks") {
                        baseObject.on(eventName, callback: callback)
                        baseObject.on("another-event", callback: callback)

                        baseObject.stopListening()

                        baseObject.trigger(eventName)
                        baseObject.trigger("another-event")

                        expect(callbackWasCalled) == false
                    }

                    it("cancels all callback functions on only one context object") {
                        let anotherBaseObject = ConcreteBaseObject()
                        var anotherCallbackWasCalled = false

                        anotherBaseObject.on(eventName) { _ in
                            anotherCallbackWasCalled = true
                        }
                        baseObject.on(eventName, callback: callback)
                        baseObject.stopListening()
                        baseObject.trigger(eventName)
                        anotherBaseObject.trigger(eventName)

                        expect(callbackWasCalled) == false
                        expect(anotherCallbackWasCalled) == true
                    }

                    it("cancels a specific callback function for an event on a given context object") {
                        let anotherBaseObject = ConcreteBaseObject()

                        let listenId = baseObject.listenTo(anotherBaseObject, eventName: eventName, callback: callback)
                        baseObject.stopListening(listenId)
                        anotherBaseObject.trigger(eventName)

                        expect(callbackWasCalled) == false
                    }
                }
            }
        }
    }
}

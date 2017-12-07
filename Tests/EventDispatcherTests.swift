import Quick
import Nimble
import Clappr

class EventDispatcherTests: QuickSpec {

    override func spec() {
        describe("BaseObject") {

            var baseObject: EventDispatcher!
            var callbackWasCalled: Bool!

            let eventName = "some-event"
            let callback: EventCallback = { _ in
                callbackWasCalled = true
            }

            beforeEach {
                baseObject = EventDispatcher()
                callbackWasCalled = false
            }

            describe("on") {
                it("Callback should be called on event trigger") {
                    baseObject.on(eventName, callback: callback)
                    baseObject.trigger(eventName)

                    expect(callbackWasCalled) == true
                }

                it("Callback should receive userInfo on trigger with params") {
                    var value = "Not Expected"
                    baseObject.on(eventName) { userInfo in
                        value = userInfo?["new_value"] as! String
                    }

                    baseObject.trigger(eventName, userInfo: ["new_value": "Expected"])

                    expect(value) == "Expected"
                }

                it("Callback should be called for every callback registered") {
                    baseObject.on(eventName, callback: callback)

                    var secondCallbackWasCalled = false
                    baseObject.on(eventName) { _ in
                        secondCallbackWasCalled = true
                    }

                    baseObject.trigger(eventName)

                    expect(callbackWasCalled) == true
                    expect(secondCallbackWasCalled) == true
                }

                it("Callback should not be called for another event trigger") {
                    baseObject.on(eventName, callback: callback)

                    baseObject.trigger("another-event")

                    expect(callbackWasCalled) == false
                }

                it("Callback should not be called for another context object") {
                    let anotherObject = EventDispatcher()

                    baseObject.on(eventName, callback: callback)

                    anotherObject.trigger(eventName)

                    expect(callbackWasCalled) == false
                }
            }

            describe("once") {
                it("Callback should be called on event trigger") {
                    baseObject.once(eventName, callback: callback)
                    baseObject.trigger(eventName)

                    expect(callbackWasCalled) == true
                }

                it("Callback should not be called twice") {
                    baseObject.once(eventName, callback: callback)

                    baseObject.trigger(eventName)
                    callbackWasCalled = false
                    baseObject.trigger(eventName)

                    expect(callbackWasCalled) == false
                }

                it("Callback should not be called if removed") {
                    let listenId = baseObject.once(eventName, callback: callback)
                    baseObject.off(listenId)
                    baseObject.trigger(eventName)

                    expect(callbackWasCalled) == false
                }
            }

            describe("listenTo") {
                it("Should fire callback for an event on a given context object") {
                    let contextObject = EventDispatcher()

                    baseObject.listenTo(contextObject, eventName: eventName, callback: callback)
                    contextObject.trigger(eventName)

                    expect(callbackWasCalled) == true
                }
            }

            describe("listenToOnce") {
                it("Should fire callback just one time for an event on a given context object") {
                    let contextObject = EventDispatcher()

                    baseObject.listenToOnce(contextObject, eventName: eventName, callback: callback)
                    contextObject.trigger(eventName)

                    expect(callbackWasCalled) == true

                    callbackWasCalled = false
                    contextObject.trigger(eventName)

                    expect(callbackWasCalled) == false
                }
            }

            describe("off") {
                it("Callback should not be called if removed") {
                    let listenId = baseObject.on(eventName, callback: callback)
                    baseObject.off(listenId)
                    baseObject.trigger(eventName)

                    expect(callbackWasCalled) == false
                }
                it("Callback should not be called if removed, but the others should") {
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
                it("Should cancel all event handlers") {
                    baseObject.on(eventName, callback: callback)
                    baseObject.on("another-event", callback: callback)

                    baseObject.stopListening()

                    baseObject.trigger(eventName)
                    baseObject.trigger("another-event")

                    expect(callbackWasCalled) == false
                }

                it("Should cancel event handlers only on context object") {
                    let anotherObject = EventDispatcher()
                    var anotherCallbackWasCalled = false
                    anotherObject.on(eventName) { _ in
                        anotherCallbackWasCalled = true
                    }

                    baseObject.on(eventName, callback: callback)

                    baseObject.stopListening()

                    baseObject.trigger(eventName)
                    anotherObject.trigger(eventName)

                    expect(callbackWasCalled) == false
                    expect(anotherCallbackWasCalled) == true
                }

                it("Should cancel handler for an event on a given context object") {
                    let contextObject = EventDispatcher()

                    let listenId = baseObject.listenTo(contextObject, eventName: eventName, callback: callback)
                    baseObject.stopListening(listenId)

                    contextObject.trigger(eventName)

                    expect(callbackWasCalled) == false
                }
            }
        }
    }
}

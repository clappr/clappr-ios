import Quick
import Nimble
import Clappr

class EventDispatcherTests: QuickSpec {

    override func spec() {
        describe("EventDispatcher") {

            var eventDispatcher: EventDispatcher!
            var callbackWasCalled: Bool!

            let eventName = "some-event"
            let callback: EventCallback = { _ in
                callbackWasCalled = true
            }

            beforeEach {
                eventDispatcher = EventDispatcher()
                callbackWasCalled = false
            }

            describe("on") {
                it("executes callback function") {
                    eventDispatcher.on(eventName, callback: callback)
                    eventDispatcher.trigger(eventName)

                    expect(callbackWasCalled) == true
                }

                it("receives userInfo when triggered with params") {
                    var value = "Not Expected"
                    eventDispatcher.on(eventName) { userInfo in
                        value = userInfo?["new_value"] as! String
                    }

                    eventDispatcher.trigger(eventName, userInfo: ["new_value": "Expected"])

                    expect(value) == "Expected"
                }

                it("executes multiple callback functions") {
                    eventDispatcher.on(eventName, callback: callback)

                    var secondCallbackWasCalled = false
                    eventDispatcher.on(eventName) { _ in
                        secondCallbackWasCalled = true
                    }

                    eventDispatcher.trigger(eventName)

                    expect(callbackWasCalled) == true
                    expect(secondCallbackWasCalled) == true
                }

                it("doesn't execute callback for another event") {
                    eventDispatcher.on(eventName, callback: callback)

                    eventDispatcher.trigger("another-event")

                    expect(callbackWasCalled) == false
                }

                it("doesn't executes callback for another context object") {
                    let anotherDispatcher = EventDispatcher()

                    eventDispatcher.on(eventName, callback: callback)

                    anotherDispatcher.trigger(eventName)

                    expect(callbackWasCalled) == false
                }
            }

            describe("once") {
                it("executes callback function") {
                    eventDispatcher.once(eventName, callback: callback)
                    eventDispatcher.trigger(eventName)

                    expect(callbackWasCalled) == true
                }

                it("doesn't execute callback function twice") {
                    eventDispatcher.once(eventName, callback: callback)

                    eventDispatcher.trigger(eventName)
                    callbackWasCalled = false
                    eventDispatcher.trigger(eventName)

                    expect(callbackWasCalled) == false
                }

                it("doesn't execute callback function when it is removed") {
                    let listenId = eventDispatcher.once(eventName, callback: callback)
                    eventDispatcher.off(listenId)
                    eventDispatcher.trigger(eventName)

                    expect(callbackWasCalled) == false
                }
            }

            describe("listenTo") {
                it("executes callback function for an event on a given context object") {
                    let anotherDispatcher = EventDispatcher()

                    eventDispatcher.listenTo(anotherDispatcher, eventName: eventName, callback: callback)
                    anotherDispatcher.trigger(eventName)

                    expect(callbackWasCalled) == true
                }
            }

            describe("listenToOnce") {
                it("executes callback function just one time for an event on a given context object") {
                    let anotherDispatcher = EventDispatcher()

                    eventDispatcher.listenToOnce(anotherDispatcher, eventName: eventName, callback: callback)
                    anotherDispatcher.trigger(eventName)

                    expect(callbackWasCalled) == true

                    callbackWasCalled = false
                    anotherDispatcher.trigger(eventName)

                    expect(callbackWasCalled) == false
                }
            }

            describe("off") {
                it("doesn't executes callback function if it is removed") {
                    let listenId = eventDispatcher.on(eventName, callback: callback)
                    eventDispatcher.off(listenId)
                    eventDispatcher.trigger(eventName)

                    expect(callbackWasCalled) == false
                }
                it("doesn't execute callback if it is removed, but the others are called") {
                    var anotherCallbackWasCalled = false
                    let anotherCallback: EventCallback = { _ in
                        anotherCallbackWasCalled = true
                    }

                    let listenId = eventDispatcher.on(eventName, callback: callback)
                    eventDispatcher.on(eventName, callback: anotherCallback)

                    eventDispatcher.off(listenId)
                    eventDispatcher.trigger(eventName)

                    expect(callbackWasCalled) == false
                    expect(anotherCallbackWasCalled) == true
                }
            }

            describe("stopListening") {
                it("disables all callbacks") {
                    eventDispatcher.on(eventName, callback: callback)
                    eventDispatcher.on("another-event", callback: callback)

                    eventDispatcher.stopListening()

                    eventDispatcher.trigger(eventName)
                    eventDispatcher.trigger("another-event")

                    expect(callbackWasCalled) == false
                }

                it("cancels all callback functions on only one context object") {
                    let anotherDispatcher = EventDispatcher()
                    var anotherCallbackWasCalled = false
                    anotherDispatcher.on(eventName) { _ in
                        anotherCallbackWasCalled = true
                    }

                    eventDispatcher.on(eventName, callback: callback)

                    eventDispatcher.stopListening()

                    eventDispatcher.trigger(eventName)
                    anotherDispatcher.trigger(eventName)

                    expect(callbackWasCalled) == false
                    expect(anotherCallbackWasCalled) == true
                }

                it("cancels a specific callback function for an event on a given context object") {
                    let anotherDispatcher = EventDispatcher()

                    let listenId = eventDispatcher.listenTo(anotherDispatcher, eventName: eventName, callback: callback)
                    eventDispatcher.stopListening(listenId)

                    anotherDispatcher.trigger(eventName)

                    expect(callbackWasCalled) == false
                }
            }
        }
    }
}

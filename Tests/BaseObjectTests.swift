import Quick
import Nimble
@testable import Clappr

fileprivate var eventDispatcherPointer: UInt8 = 0
class BaseObjectTests: QuickSpec {

    class FakeBaseObject: BaseObject { }

    override func spec() {
        describe("BaseObject") {

            var fake: FakeBaseObject!
            var callbackWasCalled: Bool!

            let eventName = "some-event"
            let callback: EventCallback = { _ in
                callbackWasCalled = true
            }

            beforeEach {
                fake = FakeBaseObject()
                callbackWasCalled = false
            }

            context("initialization") {
                it("Should not initialize EventDispatcher twice") {
                    expect(fake.eventDispatcher) == fake.eventDispatcher
                }
            }

            context("events") {

                describe("on") {
                    it("Callback should be called on event trigger") {
                        fake.on(eventName, callback: callback)
                        fake.trigger(eventName)

                        expect(callbackWasCalled) == true
                    }

                    it("Callback should receive userInfo on trigger with params") {
                        var value = "Not Expected"

                        fake.on(eventName) { userInfo in
                            value = userInfo?["new_value"] as! String
                        }
                        fake.trigger(eventName, userInfo: ["new_value": "Expected"])

                        expect(value) == "Expected"
                    }

                    it("Callback should be called for every callback registered") {
                        var secondCallbackWasCalled = false

                        fake.on(eventName, callback: callback)
                        fake.on(eventName) { _ in
                            secondCallbackWasCalled = true
                        }
                        fake.trigger(eventName)

                        expect(callbackWasCalled) == true
                        expect(secondCallbackWasCalled) == true
                    }

                    it("Callback should not be called for another event trigger") {
                        fake.on(eventName, callback: callback)
                        fake.trigger("another-event")

                        expect(callbackWasCalled) == false
                    }

                    it("Callback should not be called for another context object") {
                        let anotherFake = FakeBaseObject()

                        fake.on(eventName, callback: callback)
                        anotherFake.trigger(eventName)

                        expect(callbackWasCalled) == false
                    }
                }

                describe("once") {
                    it("Callback should be called on event trigger") {
                        fake.once(eventName, callback: callback)
                        fake.trigger(eventName)

                        expect(callbackWasCalled) == true
                    }

                    it("Callback should not be called twice") {
                        fake.once(eventName, callback: callback)

                        fake.trigger(eventName)
                        callbackWasCalled = false
                        fake.trigger(eventName)

                        expect(callbackWasCalled) == false
                    }

                    it("Callback should not be called if removed") {
                        let listenId = fake.once(eventName, callback: callback)
                        fake.off(listenId)
                        fake.trigger(eventName)

                        expect(callbackWasCalled) == false
                    }
                }

                describe("listenTo") {
                    it("Should fire callback for an event on a given context object") {
                        let anotherFake = FakeBaseObject()

                        fake.listenTo(anotherFake, eventName: eventName, callback: callback)
                        anotherFake.trigger(eventName)

                        expect(callbackWasCalled) == true
                    }
                }

                describe("listenToOnce") {
                    it("Should fire callback just one time for an event on a given context object") {
                        let anotherFake = FakeBaseObject()

                        fake.listenToOnce(anotherFake, eventName: eventName, callback: callback)
                        anotherFake.trigger(eventName)

                        expect(callbackWasCalled) == true

                        callbackWasCalled = false
                        anotherFake.trigger(eventName)

                        expect(callbackWasCalled) == false
                    }
                }

                describe("off") {
                    it("Callback should not be called if removed") {
                        let listenId = fake.on(eventName, callback: callback)
                        fake.off(listenId)
                        fake.trigger(eventName)

                        expect(callbackWasCalled) == false
                    }
                    it("Callback should not be called if removed, but the others should") {
                        var anotherCallbackWasCalled = false
                        let anotherCallback: EventCallback = { _ in
                            anotherCallbackWasCalled = true
                        }

                        let listenId = fake.on(eventName, callback: callback)
                        fake.on(eventName, callback: anotherCallback)

                        fake.off(listenId)
                        fake.trigger(eventName)

                        expect(callbackWasCalled) == false
                        expect(anotherCallbackWasCalled) == true
                    }
                }

                describe("stopListening") {
                    it("Should cancel all event handlers") {
                        fake.on(eventName, callback: callback)
                        fake.on("another-event", callback: callback)

                        fake.stopListening()

                        fake.trigger(eventName)
                        fake.trigger("another-event")

                        expect(callbackWasCalled) == false
                    }

                    it("Should cancel event handlers only on context object") {
                        let anotherFake = FakeBaseObject()
                        var anotherCallbackWasCalled = false

                        anotherFake.on(eventName) { _ in
                            anotherCallbackWasCalled = true
                        }
                        fake.on(eventName, callback: callback)
                        fake.stopListening()
                        fake.trigger(eventName)
                        anotherFake.trigger(eventName)

                        expect(callbackWasCalled) == false
                        expect(anotherCallbackWasCalled) == true
                    }

                    it("Should cancel handler for an event on a given context object") {
                        let anotherFake = FakeBaseObject()

                        let listenId = fake.listenTo(anotherFake, eventName: eventName, callback: callback)
                        fake.stopListening(listenId)
                        anotherFake.trigger(eventName)

                        expect(callbackWasCalled) == false
                    }
                }
            }
        }
    }
}

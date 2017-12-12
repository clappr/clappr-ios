import Quick
import Nimble
@testable import Clappr

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
                it("doesn't initialize EventDispatcher twice") {
                    expect(fake.eventDispatcher) == fake.eventDispatcher
                }
            }

            context("events") {
                describe("on") {
                    it("executes callback function") {
                        fake.on(eventName, callback: callback)
                        fake.trigger(eventName)

                        expect(callbackWasCalled) == true
                    }

                    it("receives userInfo when triggered with params") {
                        var value = "Not Expected"

                        fake.on(eventName) { userInfo in
                            value = userInfo?["new_value"] as! String
                        }
                        fake.trigger(eventName, userInfo: ["new_value": "Expected"])

                        expect(value) == "Expected"
                    }

                    it("executes multiple callback functions") {
                        var secondCallbackWasCalled = false

                        fake.on(eventName, callback: callback)
                        fake.on(eventName) { _ in
                            secondCallbackWasCalled = true
                        }
                        fake.trigger(eventName)

                        expect(callbackWasCalled) == true
                        expect(secondCallbackWasCalled) == true
                    }

                    it("doesn't execute callback for another event") {
                        fake.on(eventName, callback: callback)
                        fake.trigger("another-event")

                        expect(callbackWasCalled) == false
                    }

                    it("doesn't executes callback for another context object") {
                        let anotherFake = FakeBaseObject()

                        fake.on(eventName, callback: callback)
                        anotherFake.trigger(eventName)

                        expect(callbackWasCalled) == false
                    }
                }

                describe("once") {
                    it("executes callback function") {
                        fake.once(eventName, callback: callback)
                        fake.trigger(eventName)

                        expect(callbackWasCalled) == true
                    }

                    it("doesn't execute callback function twice") {
                        fake.once(eventName, callback: callback)

                        fake.trigger(eventName)
                        callbackWasCalled = false
                        fake.trigger(eventName)

                        expect(callbackWasCalled) == false
                    }

                    it("doesn't execute callback function when it is removed") {
                        let listenId = fake.once(eventName, callback: callback)
                        fake.off(listenId)
                        fake.trigger(eventName)

                        expect(callbackWasCalled) == false
                    }
                }

                describe("listenTo") {
                    it("executes callback function for an event on a given context object") {
                        let anotherFake = FakeBaseObject()

                        fake.listenTo(anotherFake, eventName: eventName, callback: callback)
                        anotherFake.trigger(eventName)

                        expect(callbackWasCalled) == true
                    }
                }

                describe("listenToOnce") {
                    it("executes callback function just one time for an event on a given context object") {
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
                    it("doesn't executes callback function if it is removed") {
                        let listenId = fake.on(eventName, callback: callback)
                        fake.off(listenId)
                        fake.trigger(eventName)

                        expect(callbackWasCalled) == false
                    }
                    it("doesn't execute callback if it is removed, but the others are called") {
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
                    it("disables all callbacks") {
                        fake.on(eventName, callback: callback)
                        fake.on("another-event", callback: callback)

                        fake.stopListening()

                        fake.trigger(eventName)
                        fake.trigger("another-event")

                        expect(callbackWasCalled) == false
                    }

                    it("cancels all callback functions on only one context object") {
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

                    it("cancels a specific callback function for an event on a given context object") {
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

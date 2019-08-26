import Quick
import Nimble

@testable import Clappr

class MediaControlElementTests: QuickSpec {
    override func spec() {
        var mediaControlElement: MediaControl.Element!
        var core: Core!

        beforeEach {
            core = CoreStub()
            mediaControlElement = StubMediaControlElement(context: core)
        }

        describe("MediaControlElement") {
            it("is a UICorePlugin") {
                expect(mediaControlElement).to(beAKindOf(UICorePlugin.self))
            }

            it("has a view") {
                expect(mediaControlElement.view).to(beAKindOf(UIView.self))
                expect(mediaControlElement.view).toNot(beNil())
            }

            it("calls bind events") {
                let core = CoreStub()
                let mediaControlElement = StubMediaControlElement(context: core)

                expect(mediaControlElement.didCallBindEvents).to(beTrue())
            }

            it("has a non nil core") {
                let core = CoreStub()
                let mediaControlElement = StubMediaControlElement(context: core)

                expect(mediaControlElement.core).toNot(beNil())
            }

            it("has a non nil activeContainer") {
                let core = CoreStub()
                let mediaControlElement = StubMediaControlElement(context: core)

                expect(mediaControlElement.activeContainer).to(equal(core.activeContainer))
            }

            it("has a non nil activePlayback") {
                let core = CoreStub()
                let mediaControlElement = StubMediaControlElement(context: core)

                expect(mediaControlElement.activePlayback).to(equal(core.activePlayback))
            }
        }

        describe("panel") {
            it("is a MediaControlPanel type") {
                expect(mediaControlElement.panel).to(beAKindOf(MediaControlPanel.self))
            }

            it("has top, center, bottom and modal properties") {
                expect(MediaControlPanel.top).to(beAKindOf(MediaControlPanel.self))
                expect(MediaControlPanel.center).to(beAKindOf(MediaControlPanel.self))
                expect(MediaControlPanel.bottom).to(beAKindOf(MediaControlPanel.self))
                expect(MediaControlPanel.modal).to(beAKindOf(MediaControlPanel.self))
            }
        }

        describe("position") {
            it("is a MediaControlPosition type") {
                expect(mediaControlElement.position).to(beAKindOf(MediaControlPosition.self))
            }

            it("has left, center, right and none properties") {
                expect(MediaControlPosition.left).to(beAKindOf(MediaControlPosition.self))
                expect(MediaControlPosition.center).to(beAKindOf(MediaControlPosition.self))
                expect(MediaControlPosition.right).to(beAKindOf(MediaControlPosition.self))
                expect(MediaControlPosition.none).to(beAKindOf(MediaControlPosition.self))
            }
        }
    }
}

class StubMediaControlElement: MediaControl.Element {
    var didCallBindEvents = false

    override func bindEvents() {
        didCallBindEvents = true
    }
}

import Quick
import Nimble

@testable import Clappr

class MediaControlPluginTests: QuickSpec {
    override func spec() {
        describe("MediaControlPlugin") {
            it("is a UICorePlugin") {
                let mediaControlPlugin = MediaControlPlugin()

                expect(mediaControlPlugin).to(beAKindOf(UICorePlugin.self))
            }

            it("has a view") {
                let mediaControlPlugin = MediaControlPlugin()

                expect(mediaControlPlugin.view).to(beAKindOf(UIView.self))
                expect(mediaControlPlugin.view).toNot(beNil())
            }
        }

        describe("panel") {
            it("is a MediaControlPanel type") {
                let mediaControlPlugin = MediaControlPlugin()

                expect(mediaControlPlugin.panel).to(beAKindOf(MediaControlPanel.self))
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
                let mediaControlPlugin = MediaControlPlugin()

                expect(mediaControlPlugin.position).to(beAKindOf(MediaControlPosition.self))
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

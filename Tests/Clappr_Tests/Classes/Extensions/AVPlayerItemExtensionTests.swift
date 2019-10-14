import Quick
import Nimble
import AVFoundation
@testable import Clappr

class AVPlayerItemExtensionTests: QuickSpec {
    override func spec() {
        describe("AVPlayerItemExtension") {
            describe("seek") {
                it("seeks to desired interval") {
                    let item = AVPlayerItemSpy(url: URL(string: "http://asset.com")!)
                    var didCallComplete = false

                    item.seek(to: 10) {
                        didCallComplete.toggle()
                    }

                    expect(didCallComplete).toEventually(beTrue())
                    expect(item.timeInterval).to(equal(10))
                }
            }
        }
    }
}

class AVPlayerItemSpy: AVPlayerItem {
    var timeInterval: TimeInterval!

    override func seek(to timeInterval: TimeInterval, _ completion: (() -> Void)? = nil) {
        self.timeInterval = timeInterval
        super.seek(to: timeInterval, completion)
    }
}

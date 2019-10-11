import Quick
import Nimble
import AVFoundation

@testable import Clappr

class TimeIntervalExtensionTests: QuickSpec {

    override func spec() {
       describe("TimeIntervalExtensions") {
            context("seek") {
                it("returns the expected time and tolerance values") {
                    let timeInterval: TimeInterval = 100.0
                    expect(timeInterval.seek().time).to(equal(CMTimeMakeWithSeconds(100, preferredTimescale: Int32(NSEC_PER_SEC))))
                    expect(timeInterval.seek().tolerance).to(equal(CMTimeMakeWithSeconds(0, preferredTimescale: Int32(NSEC_PER_SEC))))
                }
            }
        }
    }
}

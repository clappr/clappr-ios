import Quick
import Nimble
@testable import Clappr

class OptionsUnboxerTests: QuickSpec {
    override func spec() {

        describe(".OptionsUnboxer") {

            var optionsUnboxer: OptionsUnboxer!

            context("when no options is passed") {

                beforeEach {
                    optionsUnboxer = OptionsUnboxer(options: [:])
                }

                it("returns `false` for `fullscreen`") {
                    expect(optionsUnboxer.startInFullscreen).to(beFalse())
                }

            }

            context("when options is passed") {

                beforeEach {
                    optionsUnboxer = OptionsUnboxer(options: [kStartInFullscreen: true])
                }

                it("returns correct value for `fullscreen`") {
                    expect(optionsUnboxer.startInFullscreen).to(beTrue())
                }

            }
        }
    }
}


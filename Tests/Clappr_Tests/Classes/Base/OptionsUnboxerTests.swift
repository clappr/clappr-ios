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
                    expect(optionsUnboxer.fullscreen).to(beFalse())
                }

                it("returns `false` for `kFullscreenByApp`") {
                    expect(optionsUnboxer.fullscreenControledByApp).to(beFalse())
                }
            }

            context("when options is passed") {

                beforeEach {
                    optionsUnboxer = OptionsUnboxer(options: [kFullscreen: true, kFullscreenByApp: true])
                }

                it("returns correct value for `fullscreen`") {
                    expect(optionsUnboxer.fullscreen).to(beTrue())
                }

                it("returns correct value for `kFullscreenByApp`") {
                    expect(optionsUnboxer.fullscreenControledByApp).to(beTrue())
                }
            }
        }
    }
}


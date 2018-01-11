import Quick
import Nimble
@testable import Clappr

class ClapprDateFormatterTests: QuickSpec {

    override func spec() {
        context("Player Date Formatter") {
            it("Should format time smaller than minute") {
                let expected = "00:23"
                let result = ClapprDateFormatter.formatSeconds(23)
                expect(result) == expected
            }

            it("Should format time smaller than 1 hour") {
                let expected = "01:14"
                let result = ClapprDateFormatter.formatSeconds(74)
                expect(result) == expected
            }

            it("Should format time greater than 1 hour") {
                let expected = "01:54:32"
                let result = ClapprDateFormatter.formatSeconds(3600 + (54 * 60) + 32)
                expect(result) == expected
            }
        }
    }
}

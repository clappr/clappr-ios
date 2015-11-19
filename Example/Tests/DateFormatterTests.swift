import Quick
import Nimble
import Clappr

class DateFormatterTests: QuickSpec {
    
    override func spec() {
        context("Player Date Formatter") {
            it("Should format time smaller than minute") {
                let expected = "00:23"
                let result = DateFormatter.formatSeconds(23)
                expect(result) == expected
            }
            
            it("Should format time smaller than 1 hour") {
                let expected = "01:14"
                let result = DateFormatter.formatSeconds(74)
                expect(result) == expected
            }
            
            it("Should format time greater than 1 hour") {
                let expected = "01:54:32"
                let result = DateFormatter.formatSeconds((1 * 60 * 60) + (54 * 60) + 32)
                expect(result) == expected
            }
        }
    }
}
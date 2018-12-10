import Quick
import Nimble

@testable import Clappr

class DictionaryStartAtTests: QuickSpec {
    override func spec() {
        describe("Dictionary+startAt") {
            describe("#startAt") {
                it("returns a Double value if it's a Double") {
                    let dict: Options = [kStartAt: Double(10)]

                    expect(dict.startAt).to(beAKindOf(Double.self))
                    expect(dict.startAt).to(equal(10.0))
                }

                it("returns a Double value if it's a Int") {
                    let dict: Options = [kStartAt: Int(10)]

                    expect(dict.startAt).to(beAKindOf(Double.self))
                    expect(dict.startAt).to(equal(10.0))
                }

                it("returns a Double value if it's a String") {
                    let dict: Options = [kStartAt: String(10)]

                    expect(dict.startAt).to(beAKindOf(Double.self))
                    expect(dict.startAt).to(equal(10.0))
                }

                it("returns nil if it's not a String, Int or Double") {
                    let dict: Options = [kStartAt: []]

                    expect(dict.startAt).to(beNil())
                }
            }
        }
    }
}

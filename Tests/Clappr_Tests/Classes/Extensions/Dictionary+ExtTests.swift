import Quick
import Nimble

@testable import Clappr

class DictionaryExtensionTests: QuickSpec {
    override func spec() {
        describe("Dictionary+Ext") {
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
            
            describe("#bool") {
                context("when has a bool option in dictionary") {
                    it("returns true") {
                        let options: Options = ["foo": true]
                        
                        expect(options.bool("foo")).to(beTrue())
                    }
                    
                    it("returns false") {
                        let options: Options = ["foo": false]
                        
                        expect(options.bool("foo")).to(beFalse())
                    }
                }
                
                context("when doesn't have the bool option in dictionary") {
                    it("returns whichever boolean value we choose") {
                        let options: Options = [:]
                        
                        expect(options.bool("foo", or: true)).to(beTrue())
                        expect(options.bool("foo", or: false)).to(beFalse())
                    }
                }
            }
        }
    }
}

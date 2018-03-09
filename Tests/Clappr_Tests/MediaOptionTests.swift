import Quick
import Nimble

@testable import Clappr

class MediaOptionTests: QuickSpec {
    override func spec() {
        describe("MediaOption") {
            describe("#init") {
                var name: String!
                var type: MediaOptionType!
                var language: String!
                var raw: String!
                var mediaOption: MediaOption!

                beforeEach {
                    name = "name"
                    type = MediaOptionType.audioSource
                    language = "language"
                    raw = "raw"
                    mediaOption = MediaOption(name: name, type: type, language: language, raw: raw as AnyObject)
                }

                it("has name") {
                    expect(mediaOption.name).to(equal(name))
                }

                it("has type") {
                    expect(mediaOption.type).to(equal(type))
                }

                it("has language") {
                    expect(mediaOption.language).to(equal(language))
                }

                it("has raw") {
                    expect(mediaOption.raw as? String).to(equal(raw))
                }
            }

            describe("#equals") {
                let option1 = MediaOption(name: "name", type: MediaOptionType.subtitle, language: "language")
                let option2 = MediaOption(name: "name", type: MediaOptionType.subtitle, language: "language")

                expect(option1 == option2).to(beTrue())
            }
        }
    }
}

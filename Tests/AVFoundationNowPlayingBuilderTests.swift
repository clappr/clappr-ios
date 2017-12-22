import Quick
import Nimble

@testable import Clappr

class AVFoundationNowPlayingBuilderTests: QuickSpec {

    override func spec() {
        describe(".AVFoundationNowPlayingBuilder") {

            var nowPlayingBuilder: AVFoundationNowPlayingBuilder?
            var metadata: [String: Any]?

            context("When metadata has kMetaDataTitle") {

                beforeEach {
                    metadata = [kMetaDataTitle: "Foo"]
                    nowPlayingBuilder = AVFoundationNowPlayingBuilder(metadata: metadata!)
                }

                it("returns non nil for title property") {
                    expect(nowPlayingBuilder?.title).toNot(beNil())
                }

                it("sets the item to the list of items") {
                    expect(nowPlayingBuilder?.items.contains(nowPlayingBuilder!.title!)).to(beTrue())
                }
            }

            context("When metadata hasn't kMetaDataTitle") {

                beforeEach {
                    metadata = [:]
                    nowPlayingBuilder = AVFoundationNowPlayingBuilder(metadata: metadata!)
                }

                it("returns nil for title property") {
                    expect(nowPlayingBuilder?.title).to(beNil())
                }
            }

            context("When options has kMetaDataDescription") {

                beforeEach {
                    metadata = [kMetaDataDescription: "Foo"]
                    nowPlayingBuilder = AVFoundationNowPlayingBuilder(metadata: metadata!)
                }

                it("returns non nil item") {
                    expect(nowPlayingBuilder?.description).toNot(beNil())
                }

                it("sets the item to the list of items") {
                    expect(nowPlayingBuilder?.items.contains(nowPlayingBuilder!.description!)).to(beTrue())
                }
            }

            context("When options hasn't kMetaDataDescription") {

                beforeEach {
                    metadata = [:]
                    nowPlayingBuilder = AVFoundationNowPlayingBuilder(metadata: metadata!)
                }

                it("returns nil for description item") {
                    expect(nowPlayingBuilder?.description).to(beNil())
                }
            }

            context("When options has kMetaDataDate") {

                beforeEach {
                    metadata = [kMetaDataDate: Date()]
                    nowPlayingBuilder = AVFoundationNowPlayingBuilder(metadata: metadata!)
                }

                it("returns non nil item") {
                    expect(nowPlayingBuilder?.date).toNot(beNil())
                }

                it("sets the item to the list of items") {
                    expect(nowPlayingBuilder?.items.contains(nowPlayingBuilder!.date!)).to(beTrue())
                }
            }

            context("When options hasn't kMetaDataDate") {

                beforeEach {
                    metadata = [:]
                    nowPlayingBuilder = AVFoundationNowPlayingBuilder(metadata: metadata!)
                }

                it("returns nil item") {
                    expect(nowPlayingBuilder?.date).to(beNil())
                }
            }
        }
    }
}

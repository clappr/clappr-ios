import Quick
import Nimble

@testable import Clappr

class AVFoundationNowPlayingBuilderTests: QuickSpec {

    override func spec() {
        fdescribe(".AVFoundationNowPlayingBuilder") {

            var nowPlayingBuilder: AVFoundationNowPlayingBuilder?
            var metadata: [String: Any]?

            context("When metadata has kMetaDataWatchedTime") {

                beforeEach {
                    metadata = [kMetaDataContentIdentifier: "Foo"]
                    nowPlayingBuilder = AVFoundationNowPlayingBuilder(metadata: metadata!)
                }

                it("returns non nil for contentIdentifier property") {
                    expect(nowPlayingBuilder?.contentIdentifier).toNot(beNil())
                }

                it("sets the item to the list of items") {
                    let filteredItem = nowPlayingBuilder?.items.filter{ $0 == nowPlayingBuilder?.contentIdentifier }
                    expect(filteredItem).toNot(beEmpty())
                }
            }

            context("When metadata hasn't kMetaDataContentIdentifier") {

                beforeEach {
                    metadata = [:]
                    nowPlayingBuilder = AVFoundationNowPlayingBuilder(metadata: metadata!)
                }

                it("returns nil for contentIdentifier property") {
                    expect(nowPlayingBuilder?.contentIdentifier).to(beNil())
                }

                it("doesn't set the item to the list of items") {
                    let filteredItem = nowPlayingBuilder?.items.filter{ $0 == nowPlayingBuilder?.contentIdentifier }
                    expect(filteredItem).to(beEmpty())
                }
            }

            context("When metadata has kMetaDataWatchedTime") {

                beforeEach {
                    metadata = [kMetaDataWatchedTime: 0.5]
                    nowPlayingBuilder = AVFoundationNowPlayingBuilder(metadata: metadata!)
                }

                it("returns non nil for whatched time property") {
                    expect(nowPlayingBuilder?.watchedTime).toNot(beNil())
                }

                it("sets the item to the list of items") {
                    let filteredItem = nowPlayingBuilder?.items.filter{ $0 == nowPlayingBuilder?.watchedTime }
                    expect(filteredItem).toNot(beEmpty())
                }
            }

            context("When metadata hasn't kMetaDataWatchedTime") {

                beforeEach {
                    metadata = [:]
                    nowPlayingBuilder = AVFoundationNowPlayingBuilder(metadata: metadata!)
                }

                it("returns nil for watchedTime property") {
                    expect(nowPlayingBuilder?.watchedTime).to(beNil())
                }

                it("doesn't set the item to the list of items") {
                    let filteredItem = nowPlayingBuilder?.items.filter{ $0 == nowPlayingBuilder?.watchedTime }
                    expect(filteredItem).to(beEmpty())
                }
            }

            context("When metadata has kMetaDataTitle") {

                beforeEach {
                    metadata = [kMetaDataTitle: "Foo"]
                    nowPlayingBuilder = AVFoundationNowPlayingBuilder(metadata: metadata!)
                }

                it("returns non nil for title property") {
                    expect(nowPlayingBuilder?.title).toNot(beNil())
                }

                it("sets the item to the list of items") {
                    let filteredItem = nowPlayingBuilder?.items.filter{ $0 == nowPlayingBuilder?.title }
                    expect(filteredItem).toNot(beEmpty())
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

                it("doesn't set the item to the list of items") {
                    let filteredItem = nowPlayingBuilder?.items.filter{ $0 == nowPlayingBuilder?.title }
                    expect(filteredItem).to(beEmpty())
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
                    let filteredItem = nowPlayingBuilder?.items.filter{ $0 == nowPlayingBuilder?.description }
                    expect(filteredItem).toNot(beEmpty())
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

                it("doesn't set the item to the list of items") {
                    let filteredItem = nowPlayingBuilder?.items.filter{ $0 == nowPlayingBuilder?.date }
                    expect(filteredItem).to(beEmpty())
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
                    let filteredItem = nowPlayingBuilder?.items.filter{ $0 == nowPlayingBuilder?.date }
                    expect(filteredItem).toNot(beEmpty())
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

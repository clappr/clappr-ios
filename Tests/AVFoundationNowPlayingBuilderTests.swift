import Quick
import Nimble
import MediaPlayer

@testable import Clappr

class AVFoundationNowPlayingBuilderTests: QuickSpec {

    override func spec() {
        fdescribe(".AVFoundationNowPlayingBuilder") {

            var nowPlayingBuilder: AVFoundationNowPlayingBuilder?
            var metadata: [String: Any]?

            describe("#getContentIdentifier") {
                context("When metadata has kMetaDataWatchedTime") {

                    beforeEach {
                        metadata = [kMetaDataContentIdentifier: "Foo"]
                        nowPlayingBuilder = AVFoundationNowPlayingBuilder(metadata: metadata!)
                    }

                    it("returns non nil value") {
                        expect(nowPlayingBuilder?.getContentIdentifier()).toNot(beNil())
                    }

                    it("sets the item to the list of items") {
                        let filteredItem = nowPlayingBuilder?.items.filter{ $0.identifier == MPNowPlayingInfoPropertyExternalContentIdentifier }
                        expect(filteredItem).toNot(beEmpty())
                    }
                }

                context("When metadata hasn't kMetaDataContentIdentifier") {

                    beforeEach {
                        metadata = [:]
                        nowPlayingBuilder = AVFoundationNowPlayingBuilder(metadata: metadata!)
                    }

                    it("returns nil value") {
                        expect(nowPlayingBuilder?.getContentIdentifier()).to(beNil())
                    }

                    it("doesn't set the item to the list of items") {
                        let filteredItem = nowPlayingBuilder?.items.filter{ $0.identifier == MPNowPlayingInfoPropertyExternalContentIdentifier }
                        expect(filteredItem).to(beEmpty())
                    }
                }
            }

            describe("getWatchedTime") {
                context("When metadata has kMetaDataWatchedTime") {

                    beforeEach {
                        metadata = [kMetaDataWatchedTime: 0.5]
                        nowPlayingBuilder = AVFoundationNowPlayingBuilder(metadata: metadata!)
                    }

                    it("returns non nil value") {
                        expect(nowPlayingBuilder?.getWatchedTime()).toNot(beNil())
                    }

                    it("sets the item to the list of items") {
                        let filteredItem = nowPlayingBuilder?.items.filter{ $0.identifier == MPNowPlayingInfoPropertyPlaybackProgress }
                        expect(filteredItem).toNot(beEmpty())
                    }
                }

                context("When metadata hasn't kMetaDataWatchedTime") {

                    beforeEach {
                        metadata = [:]
                        nowPlayingBuilder = AVFoundationNowPlayingBuilder(metadata: metadata!)
                    }

                    it("returns nil value") {
                        expect(nowPlayingBuilder?.getWatchedTime()).to(beNil())
                    }

                    it("doesn't set the item to the list of items") {
                        let filteredItem = nowPlayingBuilder?.items.filter{ $0.identifier == MPNowPlayingInfoPropertyPlaybackProgress }
                        expect(filteredItem).to(beEmpty())
                    }
                }
            }

            describe("#getTitle()") {
                context("When metadata has kMetaDataTitle") {

                    beforeEach {
                        metadata = [kMetaDataTitle: "Foo"]
                        nowPlayingBuilder = AVFoundationNowPlayingBuilder(metadata: metadata!)
                    }

                    it("returns non nil value") {
                        expect(nowPlayingBuilder?.getTitle()).toNot(beNil())
                    }

                    it("sets the item to the list of items") {
                        let filteredItem = nowPlayingBuilder?.items.filter{ $0.identifier == AVMetadataCommonIdentifierTitle }
                        expect(filteredItem).toNot(beEmpty())
                    }
                }

                context("When metadata hasn't kMetaDataTitle") {

                    beforeEach {
                        metadata = [:]
                        nowPlayingBuilder = AVFoundationNowPlayingBuilder(metadata: metadata!)
                    }

                    it("returns nil value") {
                        expect(nowPlayingBuilder?.getTitle()).to(beNil())
                    }

                    it("doesn't set the item to the list of items") {
                        let filteredItem = nowPlayingBuilder?.items.filter{ $0.identifier == AVMetadataCommonIdentifierTitle }
                        expect(filteredItem).to(beEmpty())
                    }
                }
            }

            describe("#getDescription()") {
                context("When options has kMetaDataDescription") {

                    beforeEach {
                        metadata = [kMetaDataDescription: "Foo"]
                        nowPlayingBuilder = AVFoundationNowPlayingBuilder(metadata: metadata!)
                    }

                    it("returns non nil value") {
                        expect(nowPlayingBuilder?.getDescription()).toNot(beNil())
                    }

                    it("sets the item to the list of items") {
                        let filteredItem = nowPlayingBuilder?.items.filter{ $0.identifier == AVMetadataCommonIdentifierDescription }
                        expect(filteredItem).toNot(beEmpty())
                    }
                }

                context("When options hasn't kMetaDataDescription") {

                    beforeEach {
                        metadata = [:]
                        nowPlayingBuilder = AVFoundationNowPlayingBuilder(metadata: metadata!)
                    }

                    it("returns nil value") {
                        expect(nowPlayingBuilder?.getDescription()).to(beNil())
                    }

                    it("doesn't set the item to the list of items") {
                        let filteredItem = nowPlayingBuilder?.items.filter{ $0.identifier == AVMetadataCommonIdentifierDescription }
                        expect(filteredItem).to(beEmpty())
                    }
                }
            }

            describe("#getDate()") {
                context("When options has kMetaDataDate") {

                    beforeEach {
                        metadata = [kMetaDataDate: Date()]
                        nowPlayingBuilder = AVFoundationNowPlayingBuilder(metadata: metadata!)
                    }

                    it("returns non nil value") {
                        expect(nowPlayingBuilder?.getDate()).toNot(beNil())
                    }

                    it("sets the item to the list of items") {
                        let filteredItem = nowPlayingBuilder?.items.filter{ $0.identifier == AVMetadataCommonIdentifierCreationDate }
                        expect(filteredItem).toNot(beEmpty())
                    }
                }

                context("When options hasn't kMetaDataDate") {

                    beforeEach {
                        metadata = [:]
                        nowPlayingBuilder = AVFoundationNowPlayingBuilder(metadata: metadata!)
                    }

                    it("returns nil value") {
                        expect(nowPlayingBuilder?.getDate()).to(beNil())
                    }

                    it("doesn't set the item to the list of items") {
                        let filteredItem = nowPlayingBuilder?.items.filter{ $0.identifier == AVMetadataCommonIdentifierCreationDate }
                        expect(filteredItem).to(beEmpty())
                    }
                }
            }
        }
    }
}

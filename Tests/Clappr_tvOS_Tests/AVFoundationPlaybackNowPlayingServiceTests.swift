import Quick
import Nimble
import MediaPlayer

@testable import Clappr

class AVFoundationNowPlayingServiceTests: QuickSpec {

    override func spec() {
        describe("AVFoundationNowPlayingService") {

            var nowPlayingService: AVFoundationNowPlayingService?
            var options: Options!

            describe("#setItems(to, with options)") {

                beforeEach {
                    nowPlayingService = AVFoundationNowPlayingService()
                }

                context("when has no metadata items") {

                    beforeEach {
                        options = [:]
                    }

                    it("doesn't set externalMetadata to item") {
                        let url = URL(string: "http://test.com")
                        let playerItem = AVPlayerItem(url: url!)

                        nowPlayingService?.setItems(to: playerItem, with: options)

                        let items = nowPlayingService?.nowPlayingBuilder?.build().flatMap{ $0.identifier } ?? []
                        let externalMetadataIdentifiers = playerItem.externalMetadata.map({ $0.identifier ?? AVMetadataIdentifier(rawValue: "") })
                        let didSetAllItems = !items.flatMap({ externalMetadataIdentifiers.contains($0) }).contains(true)
                        expect(didSetAllItems).to(beTrue())
                    }
                }

                context("when has metadata items") {

                    beforeEach {
                        let metadata = [kMetaDataTitle: "Foo",
                                    kMetaDataDescription: "Lorem ipsum lorem",
                                    kMetaDataContentIdentifier: "Foo v2",
                                    kMetaDataDate: Date(),
                                    kMetaDataWatchedTime: 1] as [String : Any]
                        options = [kMetaData: metadata]

                    }

                    it("doesn't set externalMetadata to item") {
                        let url = URL(string: "http://test.com")
                        let playerItem = AVPlayerItem(url: url!)

                        nowPlayingService?.setItems(to: playerItem, with: options)

                        let items = nowPlayingService?.nowPlayingBuilder?.build().flatMap{ $0.identifier } ?? []
                        let externalMetadataIdentifiers = playerItem.externalMetadata.map({ $0.identifier ?? AVMetadataIdentifier(rawValue: "") })
                        let didSetAllItems = !items.flatMap({ externalMetadataIdentifiers.contains($0) }).contains(false)
                        expect(didSetAllItems).to(beTrue())
                    }
                }
            }
        }
    }
}

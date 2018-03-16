import Quick
import Nimble
import MediaPlayer

@testable import Clappr

class AVFoundationNowPlayingBuilderTests: QuickSpec {

    override func spec() {
        describe("AVFoundationNowPlayingBuilder") {

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
                        let filteredItem = nowPlayingBuilder!.build().filter{ $0.identifier!.rawValue == AVFoundationNowPlayingBuilder.Keys.contentIdentifier }

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
                        let filteredItem = nowPlayingBuilder!.build().filter{ $0.identifier!.rawValue == AVFoundationNowPlayingBuilder.Keys.contentIdentifier }

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
                        let filteredItem = nowPlayingBuilder?.build().filter{ $0.identifier!.rawValue == AVFoundationNowPlayingBuilder.Keys.playbackProgress }

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
                        let filteredItem = nowPlayingBuilder?.build().filter{ $0.identifier!.rawValue == AVFoundationNowPlayingBuilder.Keys.playbackProgress }
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
                        let filteredItem = nowPlayingBuilder?.build().filter{ $0.identifier == AVMetadataIdentifier.commonIdentifierTitle }

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
                        let filteredItem = nowPlayingBuilder?.build().filter{ $0.identifier == AVMetadataIdentifier.commonIdentifierTitle }
                        
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
                        let filteredItem = nowPlayingBuilder?.build().filter{ $0.identifier == AVMetadataIdentifier.commonIdentifierDescription }

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
                        let filteredItem = nowPlayingBuilder?.build().filter{ $0.identifier == AVMetadataIdentifier.commonIdentifierDescription }
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
                        let filteredItem = nowPlayingBuilder?.build().filter{ $0.identifier == AVMetadataIdentifier.commonIdentifierCreationDate }
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
                        let filteredItem = nowPlayingBuilder?.build().filter{ $0.identifier == AVMetadataIdentifier.commonIdentifierCreationDate }
                        expect(filteredItem).to(beEmpty())
                    }
                }
            }

            describe("#getArtwork(with options)") {

                context("When has MetaDataArtwork") {

                    beforeEach {
                        metadata = [kMetaDataArtwork: self.generateNewImage()]
                        nowPlayingBuilder = AVFoundationNowPlayingBuilder(metadata: metadata!)
                    }

                    it("returns non nil value") {
                        waitUntil() { done in
                            nowPlayingBuilder?.getArtwork(with: [:]) { item in
                                expect(item).toNot(beNil())
                                done()
                            }
                        }
                    }
                }

                context("When doesn't have metadata image") {

                    beforeEach {
                        metadata = [:]
                        nowPlayingBuilder = AVFoundationNowPlayingBuilder(metadata: metadata!)
                    }

                    it("loads poster image") {
                        waitUntil(timeout: 10) { done in
                            let url = "https://cloud.githubusercontent.com/assets/1156242/16349649/54f233e2-3a30-11e6-98e4-42eb5284b730.png"
                            nowPlayingBuilder?.getArtwork(with: [kPosterUrl: url]) { item in
                                expect(item).toNot(beNil())
                                done()
                            }
                        }
                    }
                }
            }

            describe("#getArtwork(with image)") {

                beforeEach {
                    metadata = [:]
                    nowPlayingBuilder = AVFoundationNowPlayingBuilder(metadata: metadata!)
                }

                it("returns non nil value") {
                    expect(nowPlayingBuilder?.getArtwork(with: self.generateNewImage())).toNot(beNil())
                }
            }
        }
    }

    func generateNewImage() -> UIImage {
        let size = CGSize(width: 20, height: 20)
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        UIColor.red.setFill()
        UIRectFill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
}

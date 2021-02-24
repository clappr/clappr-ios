import Quick
import Nimble
import AVFoundation
#if os(tvOS)
import AVKit
#endif

@testable import Clappr

class AVPlayerItemInfoTests: QuickSpec {
    
    override func spec() {
        
        describe(".AVPlayerItemInfo") {
            var itemInfo: AVPlayerItemInfo!
            var playerItem: AVPlayerItemStub!
            var delegateSpy: AVPlayerItemInfoDelegateSpy!
            
            beforeEach {
                delegateSpy = AVPlayerItemInfoDelegateSpy()
                let url = URL(string: "http://clappr.io/highline.mp4")
                playerItem = AVPlayerItemStub(url: url!)
                itemInfo = AVPlayerItemInfo(item: playerItem, delegate: delegateSpy)
            }
            
            context("When item info is created") {
                context("and AVPlayerItem duration is indefinite") {
                    it("sets playback type to live") {
                        playerItem._duration = .indefinite
                        playerItem._status = .readyToPlay
                        expect(itemInfo.playbackType).to(equal(.live))
                    }
                    
                    it("sets duration to match item seekableTimeRanges") {
                        playerItem._duration = .indefinite
                        playerItem._status = .readyToPlay
                        let start = CMTime(seconds: 10, preferredTimescale: 1)
                        let duration = CMTime(seconds: 20, preferredTimescale: 1)
                        let timeRange = CMTimeRange(start: start, duration: duration)
                        playerItem._seekableTimeRanges.append(.init(timeRange: timeRange))
                        expect(itemInfo.duration).to(equal(20))
                        playerItem._seekableTimeRanges.append(.init(timeRange: timeRange))
                        expect(itemInfo.duration).to(equal(40))
                    }
                }
                
                context("and AVPlayerItem duration is valid") {
                    it("sets playback type to vod") {
                        playerItem._duration = CMTime(seconds: 10, preferredTimescale: 1)
                        playerItem._status = .readyToPlay
                        expect(itemInfo.playbackType).to(equal(.vod))
                    }
                    
                    it("sets duration to match item duration") {
                        playerItem._duration = CMTime(seconds: 10, preferredTimescale: 1)
                        playerItem._status = .readyToPlay
                        expect(itemInfo.duration).to(equal(10))
                    }
                }
                
                context("and AVPlayerItem status is not ready") {
                    it("sets playback type to unknown") {
                        playerItem._status = .unknown
                        expect(itemInfo.playbackType).to(equal(.unknown))
                    }
                    
                    it("sets duration to zero") {
                        playerItem._status = .unknown
                        expect(itemInfo.duration).to(equal(.zero))
                    }
                }
            }
            
            context("when the item info is created by the playback"){
                it("setup observers for changes on item status") {
                    let player = AVPlayerStub()
                    let options: Options = [kSourceUrl: "http://clappr.io/highline.mp4", kLoop: true]
                    let playback = AVFoundationPlayback(options: options)
                    playerItem._status = .readyToPlay
                    player.set(currentItem: playerItem)
                    playback.player = player

                    
                    var callDidUpdateDuration = false
                    playback.on(Event.didUpdateDuration.rawValue) { userInfo in
                        callDidUpdateDuration = true
                    }
                    
                    var callAssetReady = false
                    playback.on(Event.assetReady.rawValue) { userInfo in
                        callAssetReady = true
                    }
                    playback.render()
                    playback.play()
                    

                    expect(callDidUpdateDuration).toEventually(beTrue(), timeout: 5)
                    expect(callAssetReady).toEventually(beTrue(),timeout: 5)
                }
            }
        }
    }
    
    class AVPlayerItemInfoDelegateSpy: AVPlayerItemInfoDelegate {
        var callDidLoadDuration = false
        var callDidLoadCharacteristics = false
        func didLoadDuration() {
            callDidLoadDuration = true
        }
        
        func didLoadCharacteristics() {
            callDidLoadCharacteristics = true
        }
    }
}

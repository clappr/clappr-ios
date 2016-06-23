import Quick
import Nimble
import Clappr

class AVFoundationPlaybackTests: QuickSpec {
    
    override func spec() {
        describe("AVFoundationPlayback Tests") {
            
            context("canPlay") {
                it("Should return true for valid url with mp4 path extension") {
                    let options = [kSourceUrl: "http://clappr.io/highline.mp4"]
                    let canPlay = AVFoundationPlayback.canPlay(options)
                    expect(canPlay) == true
                }
                
                it("Should return true for valid url with m3u8 path extension") {
                    let options = [kSourceUrl: "http://clappr.io/highline.m3u8"]
                    let canPlay = AVFoundationPlayback.canPlay(options)
                    expect(canPlay) == true
                }
                
                it("Should return false for invalid url") {
                    let options = [kSourceUrl: "123123"]
                    let canPlay = AVFoundationPlayback.canPlay(options)
                    expect(canPlay) == false
                }
                
                it("Should return false for url with invalid path extension") {
                    let options = [kSourceUrl: "http://clappr.io/highline.zip"]
                    let canPlay = AVFoundationPlayback.canPlay(options)
                    expect(canPlay) == false
                }
            }
        }
    }
}
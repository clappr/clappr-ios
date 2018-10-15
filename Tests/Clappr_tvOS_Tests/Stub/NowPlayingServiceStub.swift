import AVFoundation

@testable import Clappr

class NowPlayingServiceStub: AVFoundationNowPlayingService {
    var countOfCallsOfSetItems = 0
    
    override func setItems(to playerItem: AVPlayerItem, with options: Options) {
        countOfCallsOfSetItems += 1
    }
}

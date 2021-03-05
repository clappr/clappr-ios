import Foundation
import XCTest

enum VideoState: String {
    case playing = "AVFoundationPlaybackPlaying"
    case paused = "AVFoundationPlaybackPaused"
    case stalling = "AVFoundationPlaybackstalling"
}

extension XCUIApplication {

    func isVideoIn(state: VideoState) -> Bool {
        return XCTWaiter().waitFor(element: otherElements[state.rawValue])
    }
}



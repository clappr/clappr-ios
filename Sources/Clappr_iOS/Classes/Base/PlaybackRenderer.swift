import Foundation

class PlaybackRenderer: PlaybackRendererProtocol {
    func render(playback: Playback) {
        if playback.isChromeless {
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                playback.play()
            }
        }
    }
}

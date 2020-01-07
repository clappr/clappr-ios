import Foundation

class PlaybackRenderer: PlaybackRendererProtocol {
    func render(playback: Playback) {
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            playback.play()
        }
    }
}

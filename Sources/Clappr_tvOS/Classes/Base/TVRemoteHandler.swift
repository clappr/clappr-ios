import AVKit

class TVRemoteHandler {
    weak var playerViewController: AVPlayerViewController?
    weak var player: Player?

    private var tvRemoteGesture: UITapGestureRecognizer?

    init(playerViewController: AVPlayerViewController, player: Player) {
        self.playerViewController = playerViewController
        self.player = player

        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTvRemoteGesture))
        gestureRecognizer.allowedPressTypes = [NSNumber(value: UIPress.PressType.playPause.rawValue),
                                               NSNumber(value: UIPress.PressType.select.rawValue)]

        playerViewController.view.addGestureRecognizer(gestureRecognizer)
        tvRemoteGesture = gestureRecognizer
    }

    @objc func handleTvRemoteGesture() {
        guard let playback = player?.activePlayback else { return }
        if playback.isPaused {
            playback.play()
        } else {
            playback.pause()
        }
    }
}

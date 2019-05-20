import AVKit

class DecoratedPressAVPlayerViewController: AVPlayerViewController {
    let clapprPlayer: Player

    init(player: Player) {
        self.clapprPlayer = player
        super.init(nibName: nil, bundle: nil)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private var isPaused: Bool {
        return clapprPlayer.activePlayback?.isPaused ?? false
    }

    private var isPlaying: Bool {
        return clapprPlayer.activePlayback?.isPlaying ?? false
    }

    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        if presses.containsAny(pressTypes: [.select, .playPause]) && isPaused {
            clapprPlayer.activePlayback?.trigger(.willPlay)
        }

        if presses.containsAny(pressTypes: [.select, .playPause]) && isPlaying {
            clapprPlayer.activePlayback?.trigger(.willPause)
        }

        super.pressesBegan(presses, with: event)
    }
}

extension Set where Element == UIPress {
    func containsAny(pressTypes: [UIPress.PressType]) -> Bool {
        return self.contains { pressTypes.contains($0.type) }
    }
}

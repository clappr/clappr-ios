open class PlaybackFactory {
    fileprivate var options: Options

    public init(options: Options = [:]) {
        self.options = options
    }

    open func createPlayback() -> Playback {
        let availablePlaybacks = Loader.shared.playbacks.first { playback in canPlay(playback) }
        if let playback = availablePlaybacks as? Playback.Type {
            return playback.init(options: options)
        }
        return NoOpPlayback(options: options)
    }

    fileprivate func canPlay(_ type: Plugin.Type) -> Bool {
        guard let type = type as? Playback.Type else {
            return false
        }

        return type.canPlay(options)
    }
}

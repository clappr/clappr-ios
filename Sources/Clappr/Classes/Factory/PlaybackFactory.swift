open class PlaybackFactory {
    fileprivate var options: Options

    public init(options: Options = [:]) {
        self.options = options
    }

    open func createPlayback() -> Playback {
        let availablePlayback = Loader.shared.playbacks.first { playback in canPlay(playback) }
        guard let playback = availablePlayback, playback.type == .playback else {
            return NoOpPlayback(options: options)
        }
        return playback.init(options: options)
    }

    fileprivate func canPlay(_ type: Plugin.Type) -> Bool {
        guard let type = type as? Playback.Type else {
            return false
        }

        return type.canPlay(options)
    }
}

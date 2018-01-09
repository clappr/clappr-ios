open class PlaybackFactory {
    fileprivate var loader: Loader
    fileprivate var options: Options

    public init(loader: Loader = Loader(), options: Options = [:]) {
        self.loader = loader
        self.options = options
    }

    open func createPlayback() -> Playback {
        let availablePlaybacks = loader.playbackPlugins.first { type in canPlay(type) }
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

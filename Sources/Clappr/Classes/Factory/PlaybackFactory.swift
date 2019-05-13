open class PlaybackFactory {
    fileprivate var options: Options

    public init(options: Options = [:]) {
        self.options = options
    }

    open func createPlayback() -> Playback {
        let playback = Loader.shared.playbacks.first(where: canPlay) ?? NoOpPlayback.self
        return playback.init(options: options)
    }

    fileprivate func canPlay(_ type: Playback.Type) -> Bool {
        return type.canPlay(options)
    }
}

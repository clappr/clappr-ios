open class PlaybackFactory {
    fileprivate var loader: Loader
    fileprivate var options: Options
    
    public init(loader: Loader = Loader(), options: Options = [:]) {
        self.loader = loader
        self.options = options
    }
    
    open func createPlayback() -> Playback {
        var availablePlaybacks = loader.playbackPlugins.filter({type in canPlay(type)})
        let playback = availablePlaybacks[0] as! Playback.Type
        return playback.init(options: options)
    }
    
    fileprivate func canPlay(_ type: Plugin.Type) -> Bool {
        guard let type = type as? Playback.Type else {
            return false
        }
        
        return type.canPlay(self.options)
    }
}

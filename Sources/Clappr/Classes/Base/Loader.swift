open class Loader {

    public static let shared = Loader()
    public var plugins: [Plugin.Type] = []
    public var playbacks: [Playback.Type] = []

    var containerPlugins: [Plugin.Type] {
        return plugins.filter { $0.type == .container }.map { return $0 }
    }

    var corePlugins: [Plugin.Type] {
        return plugins.filter { $0.type == .core }.map { return $0 }
    }

    private init() {
    }

    open func register(plugins: [Plugin.Type]) {
        self.plugins.appendOrReplace(contentsOf: plugins)
    }
    
    open func register(playbacks: [Playback.Type]) {
        self.playbacks.appendOrReplace(contentsOf: playbacks)
    }
}

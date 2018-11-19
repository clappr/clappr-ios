import Foundation

open class Container: UIObject {
    @objc internal(set) open var plugins: [UIContainerPlugin] = []
    @objc open var sharedData = SharedData()
    @objc open var options: Options {
        didSet {
            trigger(Event.didUpdateOptions)
        }
    }

    @objc open var mediaControlEnabled = false {
        didSet {
            let eventToTrigger: Event = mediaControlEnabled ? .enableMediaControl : .disableMediaControl
            trigger(eventToTrigger)
        }
    }

    @objc internal(set) open var playback: Playback? {
        willSet {
            if self.playback != newValue {
                trigger(Event.willChangePlayback.rawValue)
            }
        }
        didSet {
            if self.playback != oldValue {
                self.playback?.view.removeFromSuperview()
                self.playback?.once(Event.playing.rawValue) { [weak self] _ in self?.options[kStartAt] = 0.0 }
                trigger(Event.didChangePlayback.rawValue)
            }
        }
    }

    public init(options: Options = [:]) {
        Logger.logDebug("loading with \(options)", scope: "\(type(of: self))")
        self.options = options

        super.init()

        self.sharedData.container = self
        view.backgroundColor = UIColor.clear
        Loader.shared.loadPlugins(in: self)
        view.accessibilityIdentifier = "Container"
        if let source = options[kSourceUrl] as? String {
            load(source, mimeType: options[kMimeType] as? String)
        }
    }

    @objc open func load(_ source: String, mimeType: String? = nil) {
        trigger(Event.willLoadSource.rawValue)

        options[kSourceUrl] = source
        options[kMimeType] = mimeType

        self.playback?.destroy()

        let playbackFactory = PlaybackFactory(options: options)
        self.playback = playbackFactory.createPlayback()

        if playback is NoOpPlayback {
            render()
            trigger(Event.error.rawValue)
        } else {
            renderPlayback()
            trigger(Event.didLoadSource.rawValue)
        }
    }

    open override func render() {
        plugins.forEach(renderPlugin)
        renderPlayback()
    }

    fileprivate func renderPlayback() {
        guard let playback = playback else {
            return
        }

        view.addSubviewMatchingConstraints(playback.view)
        playback.render()
        view.sendSubview(toBack: playback.view)
    }

    fileprivate func renderPlugin(_ plugin: UIContainerPlugin) {
        view.addSubview(plugin.view)
        plugin.render()
    }

    func addPlugin(_ plugin: UIContainerPlugin) {
        plugins.append(plugin)
    }

    @objc open func hasPlugin(_ pluginClass: AnyClass) -> Bool {
        return plugins.filter({ $0.isKind(of: pluginClass) }).count > 0
    }

    @objc open func destroy() {
        Logger.logDebug("destroying", scope: "Container")

        trigger(Event.willDestroy.rawValue)

        Logger.logDebug("destroying playback", scope: "Container")
        playback?.destroy()

        Logger.logDebug("destroying plugins", scope: "Container")
        plugins.forEach { plugin in plugin.destroy() }
        plugins.removeAll()

        view.removeFromSuperview()

        trigger(Event.didDestroy.rawValue)
        Logger.logDebug("destroying listeners", scope: "Container")
        stopListening()
        Logger.logDebug("destroyed", scope: "Container")
    }
}

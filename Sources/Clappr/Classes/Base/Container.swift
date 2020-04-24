import Foundation

open class Container: UIObject {
    private(set) var plugins: [Plugin] = []
    @objc open var sharedData = SharedData()
    private var shouldReload = false
    private var source: String?
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

    private var boundsObservation: NSKeyValueObservation?

    public init(options: Options = [:]) {
        Logger.logDebug("loading with \(options)", scope: "\(type(of: self))")
        self.options = options

        super.init()

        view.backgroundColor = .clear
        view.accessibilityIdentifier = "Container"
    }
    
    open func setNeedsReload() {
        shouldReload = true
    }
    
    open func play() {
        guard let activePlayback = playback, activePlayback.canPlay else { return }
        
        if shouldReload {
            reload()
        } else {
            seekToDVRStartIfNeeded()
            activePlayback.play()
        }
    }
    
    private func seekToDVRStartIfNeeded() {
        guard let playback = playback, playback.isDvrAvailable, playback.position < 0 else { return }

        let securityMargin: TimeInterval = 30
        let timeInterval: TimeInterval = playback.dvrWindowStart + securityMargin
        playback.seek(timeInterval)
    }
    
    open func pause() {
        guard let activePlayback = playback, activePlayback.canPause else { return }
        
        activePlayback.pause()
    }

    @objc open func load(_ source: String, mimeType: String? = nil) {
        self.source = source
        
        trigger(Event.willLoadSource.rawValue)

        options[kSourceUrl] = source
        options[kMimeType] = mimeType

        playback?.destroy()

        let playbackFactory = PlaybackFactory(options: options)
        playback = playbackFactory.createPlayback()

        if playback is NoOpPlayback {
            render()
            trigger(Event.didNotLoadSource.rawValue)
        } else {
            renderPlayback()
            trigger(Event.didLoadSource.rawValue)
        }
    }

    private func reload() {
        shouldReload = false
        
        guard let source = self.source else { return }
        
        let mimeType = options[kMimeType] as? String
        
        extractDefaultLanguageOptions()

        load(source, mimeType: mimeType)
    }
    
    private func extractDefaultLanguageOptions() {
        options[kDefaultSubtitle] = playback?.selectedSubtitle?.language
        options[kDefaultAudioSource] = playback?.selectedAudioSource?.language
    }
    
    open override func render() {
        plugins.forEach(renderPlugin)

        renderPlayback()

        observeWhenViewChangeBounds()
    }

    fileprivate func renderPlayback() {
        guard let playback = playback else {
            return
        }

        view.addSubviewMatchingConstraints(playback.view)
        playback.render()
        view.sendSubviewToBack(playback.view)
    }

    fileprivate func renderPlugin(_ plugin: Plugin) {
        if let plugin = plugin as? UIContainerPlugin {
            view.addSubview(plugin.view)
            do {
                try ObjC.catchException {
                    plugin.render()
                }
            } catch {
                Logger.logError("\((plugin as Plugin).pluginName) crashed during render (\(error.localizedDescription))", scope: "Container")
            }
        }
    }

    func addPlugin(_ plugin: Plugin) {
        plugins.append(plugin)
    }
    
    private func findPlugin(_ name: String) -> Plugin? {
        return plugins.first(where: { $0.pluginName == name })
    }

    @objc open func hasPlugin(_ name: String) -> Bool {
        return findPlugin(name) != nil
    }
    
    open func getPlugin(_ name: String) -> Plugin? {
        return findPlugin(name)
    }

    private func observeWhenViewChangeBounds() {
        boundsObservation = view.observe(\.bounds) { [weak self] (view, _) in
            self?.trigger(Event.didResize, userInfo: ["size": view.bounds.size])
        }
    }

    @objc open func destroy() {
        Logger.logDebug("destroying", scope: "Container")

        trigger(Event.willDestroy.rawValue)

        Logger.logDebug("destroying playback", scope: "Container")
        playback?.destroy()

        Logger.logDebug("destroying plugins", scope: "Container")
        plugins.forEach { plugin in
            do {
                try ObjC.catchException {
                    plugin.destroy()
                }
            } catch {
                Logger.logError("\((plugin as Plugin).pluginName) crashed during destroy (\(error.localizedDescription))", scope: "Container")
            }
        }
        plugins.removeAll()

        view.removeFromSuperview()

        boundsObservation?.invalidate()
        trigger(Event.didDestroy.rawValue)
        Logger.logDebug("destroying listeners", scope: "Container")
        stopListening()
        Logger.logDebug("destroyed", scope: "Container")
    }
}

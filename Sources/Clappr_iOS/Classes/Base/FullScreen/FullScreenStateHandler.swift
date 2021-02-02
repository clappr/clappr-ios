protocol FullscreenStateHandler {
    var core: Core { get }

    init(core: Core)

    func set(fullscreen: Bool)
    func enterInFullscreen()
    func exitFullscreen()
    func destroy()
}

extension FullscreenStateHandler {
    func enterInFullscreen() { }
    func exitFullscreen() { }
    func destroy() { }
}

struct FullscreenHandler: FullscreenStateHandler {
    var core: Core

    func set(fullscreen: Bool) {
        guard core.isFullscreen != fullscreen else { return }
        core.isFullscreen = fullscreen
        if fullscreen {
            core.trigger(Event.didEnterFullscreen.rawValue)
        } else {
            core.trigger(Event.didExitFullscreen.rawValue)
        }
    }
}

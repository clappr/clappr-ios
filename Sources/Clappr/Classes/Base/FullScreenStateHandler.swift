protocol FullscreenStateHandler {

    var core: Core { get }
    var isOnFullscreen: Bool { get }

    init(core: Core)

    func set(fullscreen: Bool)
    func enterInFullscreen(_: EventUserInfo)
    func enterInFullscreen()

    func exitFullscreen(_: EventUserInfo)
    func exitFullscreen()
}

extension FullscreenStateHandler {

    func enterInFullscreen() {
        enterInFullscreen([:])
    }

    func exitFullscreen() {
        exitFullscreen([:])
    }

    var isOnFullscreen: Bool {
        return core.mediaControl?.fullscreen ?? false
    }
}

struct FullscreenByApp: FullscreenStateHandler {

    var core: Core

    func set(fullscreen: Bool) {
        core.mediaControl?.fullscreen = fullscreen
    }

    func enterInFullscreen(_: EventUserInfo = [:]) {
        guard !isOnFullscreen else { return }
        core.trigger(InternalEvent.userRequestEnterInFullscreen.rawValue)
    }

    func exitFullscreen(_: EventUserInfo = [:]) {
        guard isOnFullscreen else { return }
        core.trigger(InternalEvent.userRequestExitFullscreen.rawValue)
    }
}

struct FullscreenByPlayer: FullscreenStateHandler {

    var core: Core

    func set(fullscreen: Bool) {
        if shouldChange(fullscreen: fullscreen) {
            fullscreen ? enterInFullscreen() : exitFullscreen()
        }
    }

    func shouldChange(fullscreen: Bool) -> Bool {
        guard let mediaControl = core.mediaControl else { return false }
        return mediaControl.fullscreen != fullscreen
    }

    func enterInFullscreen(_: EventUserInfo = [:]) {
        guard !isOnFullscreen else { return }
        core.trigger(InternalEvent.willEnterFullscreen.rawValue)
        core.mediaControl?.fullscreen = true
        core.fullscreenController.view.backgroundColor = UIColor.black
        core.fullscreenController.modalPresentationStyle = .overFullScreen
        core.parentController?.present(core.fullscreenController, animated: false, completion: nil)
        core.fullscreenController.view.addSubviewMatchingConstraints(core)
        core.trigger(InternalEvent.didEnterFullscreen.rawValue)
    }

    func exitFullscreen(_: EventUserInfo = [:]) {
        guard isOnFullscreen else { return }
        core.trigger(InternalEvent.willExitFullscreen.rawValue)
        core.mediaControl?.fullscreen = false
        core.parentView?.addSubviewMatchingConstraints(core)
        core.fullscreenController.dismiss(animated: false, completion: nil)
        core.trigger(InternalEvent.didExitFullscreen.rawValue)
    }
}

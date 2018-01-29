protocol FullscreenStateHandler {

    var core: Core { get }

    init(core: Core)

    func set(fullscreen: Bool)
    func enterInFullscreen()
    func exitFullscreen()
}

struct FullscreenByApp: FullscreenStateHandler {

    var core: Core

    func set(fullscreen: Bool) {
        guard core.isFullscreen != fullscreen else { return }
        core.isFullscreen = fullscreen
        if fullscreen {
            core.trigger(InternalEvent.willEnterFullscreen.rawValue)
            core.trigger(InternalEvent.didEnterFullscreen.rawValue)
        } else {
            core.trigger(InternalEvent.willExitFullscreen.rawValue)
            core.trigger(InternalEvent.didExitFullscreen.rawValue)
        }
    }

    func enterInFullscreen() {
        guard !core.isFullscreen else { return }
        core.trigger(InternalEvent.userRequestEnterInFullscreen.rawValue)
    }

    func exitFullscreen() {
        guard core.isFullscreen else { return }
        core.trigger(InternalEvent.userRequestExitFullscreen.rawValue)
    }
}

struct FullscreenByPlayer: FullscreenStateHandler {

    var core: Core

    func set(fullscreen: Bool) {
        guard core.isFullscreen != fullscreen else { return }
        fullscreen ? enterInFullscreen() : exitFullscreen()
    }

    func enterInFullscreen() {
        guard !core.isFullscreen else { return }
        core.trigger(InternalEvent.willEnterFullscreen.rawValue)
        core.isFullscreen = true
        core.fullscreenController.view.backgroundColor = UIColor.black
        core.fullscreenController.modalPresentationStyle = .overFullScreen
        core.parentController?.present(core.fullscreenController, animated: false, completion: nil)
        core.fullscreenController.view.addSubviewMatchingConstraints(core)
        core.trigger(InternalEvent.didEnterFullscreen.rawValue)
    }

    func exitFullscreen() {
        guard core.isFullscreen else { return }
        core.trigger(InternalEvent.willExitFullscreen.rawValue)
        core.isFullscreen = false
        core.parentView?.addSubviewMatchingConstraints(core)
        core.fullscreenController.dismiss(animated: false, completion: nil)
        core.trigger(InternalEvent.didExitFullscreen.rawValue)
    }
}

protocol FullscreenStateHandler {

    var core: Core { get }

    init(core: Core)

    func set(fullscreen: Bool)
    func enterInFullscreen()
    func exitFullscreen()
    func destroy()
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

    func enterInFullscreen() { }

    func exitFullscreen() { }

    func destroy() { }
}

struct FullscreenByPlayer: FullscreenStateHandler {

    var core: Core

    func set(fullscreen: Bool) {
        guard core.isFullscreen != fullscreen else { return }
        fullscreen ? enterInFullscreen() : exitFullscreen()
    }

    func enterInFullscreen() {
        guard let fullscreenController = core.fullscreenController else { return }
        guard !core.isFullscreen else { return }
        core.trigger(InternalEvent.willEnterFullscreen.rawValue)
        core.isFullscreen = true
        fullscreenController.view.backgroundColor = UIColor.black
        fullscreenController.modalPresentationStyle = .overFullScreen
        core.parentController?.present(fullscreenController, animated: false, completion: nil)
        fullscreenController.view.addSubviewMatchingConstraints(core)
        core.trigger(InternalEvent.didEnterFullscreen.rawValue)
    }

    func exitFullscreen() {
        guard core.isFullscreen else { return }
        core.trigger(InternalEvent.willExitFullscreen.rawValue)
        core.isFullscreen = false
        handleExit()
        core.trigger(InternalEvent.didExitFullscreen.rawValue)
    }

    private func handleExit() {
        core.parentView?.addSubviewMatchingConstraints(core)
        core.fullscreenController?.dismiss(animated: false, completion: nil)
    }

    func destroy() {
        guard core.isFullscreen else { return }
        handleExit()
    }
}

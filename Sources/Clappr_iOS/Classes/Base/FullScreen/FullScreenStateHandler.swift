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

struct FullscreenByApp: FullscreenStateHandler {
    var core: Core

    func set(fullscreen: Bool) {
        guard core.isFullscreen != fullscreen else { return }

        core.isFullscreen = fullscreen
        if fullscreen {
            core.trigger(Event.willEnterFullscreen.rawValue)
            core.trigger(Event.didEnterFullscreen.rawValue)
        } else {
            core.trigger(Event.willExitFullscreen.rawValue)
            core.trigger(Event.didExitFullscreen.rawValue)
        }
    }
}

struct FullscreenByPlayer: FullscreenStateHandler {
    var core: Core

    func set(fullscreen: Bool) {
        guard core.isFullscreen != fullscreen else { return }

        fullscreen ? enterInFullscreen() : exitFullscreen()
    }

    func enterInFullscreen() {
        guard let fullscreenController = core.fullscreenController, !core.isFullscreen else { return }

        core.trigger(Event.willEnterFullscreen.rawValue)
        core.isFullscreen = true
        fullscreenController.view.backgroundColor = UIColor.black
        fullscreenController.modalPresentationStyle = .overFullScreen
        core.parentController?.present(fullscreenController, animated: false) {
            fullscreenController.view.addSubviewMatchingConstraints(self.core.view)
            self.core.trigger(Event.didEnterFullscreen.rawValue)
        }
    }

    func exitFullscreen() {
        guard core.isFullscreen else { return }

        core.trigger(Event.willExitFullscreen.rawValue)
        core.isFullscreen = false
        handleExit()
    }

    private func handleExit() {
        core.fullscreenController?.dismiss(animated: false) {
            self.core.parentView?.addSubviewMatchingConstraints(self.core.view)
            self.core.trigger(Event.didExitFullscreen.rawValue)
        }
    }

    func destroy() {
        guard core.isFullscreen else { return }

        handleExit()
    }
}

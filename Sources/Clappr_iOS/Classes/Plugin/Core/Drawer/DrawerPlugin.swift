class DrawerPlugin: OverlayPlugin {
    enum Position {
        case undefined
    }

    var position: DrawerPlugin.Position {
        return .undefined
    }

    var size: CGSize {
        return .zero
    }

    var padding: CGFloat {
        return .zero
    }

    private func willSetClosed(with newValue: Bool) {
        let event: Event = newValue ? .willHideDrawerPlugin : .willShowDrawerPlugin
        core?.trigger(event)
    }

    private func didSetClosed(with newValue: Bool) {
        let event: Event = newValue ? .didHideDrawerPlugin : .didShowDrawerPlugin
        core?.trigger(event)
    }

    private(set) var isClosed: Bool = true {
        willSet {
            willSetClosed(with: newValue)
        }
        didSet {
            didSetClosed(with: isClosed)
        }
    }

    override func bindEvents() {
        guard let core = core else { return }

        listenTo(core, event: .willShowMediaControl) { [weak self] _ in
            UIView.animate(withDuration: ClapprAnimationDuration.mediaControlShow) {
                self?.view.alpha = 1
            }
        }

        listenTo(core, event: .willHideMediaControl) { [weak self] _ in
            guard self?.isClosed == true else { return }
            UIView.animate(withDuration: ClapprAnimationDuration.mediaControlHide) {
                self?.view.alpha = 0
            }
        }

        listenTo(core, event: .showDrawerPlugin) { [weak self] _ in
            guard self?.isClosed != false else { return }
            self?.isClosed = false
        }

        listenTo(core, event: .hideDrawerPlugin) { [weak self] _ in
            guard self?.isClosed != true else { return }
            self?.isClosed = true
        }
    }
}

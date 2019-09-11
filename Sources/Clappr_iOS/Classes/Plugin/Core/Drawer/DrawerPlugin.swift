open class DrawerPlugin: OverlayPlugin {
    public enum Position {
        case undefined
    }

    open var position: DrawerPlugin.Position {
        return .undefined
    }

    open var size: CGSize {
        return .zero
    }

    open var placeholder: CGFloat {
        return .zero
    }

    private(set) var isClosed: Bool = true {
        willSet {
            let event: Event = newValue ? .willHideDrawerPlugin : .willShowDrawerPlugin
            core?.trigger(event)
        }
        didSet {
            let event: Event = isClosed ? .didHideDrawerPlugin : .didShowDrawerPlugin
            core?.trigger(event)
        }
    }

    public required init(context: UIObject) {
        super.init(context: context)
        view.alpha = .zero
    }

    open override func bindEvents() {
        bindMediaControlEvents()
        bindDrawerEvents()
    }

    private func bindMediaControlEvents() {
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
    }

    private func bindDrawerEvents() {
        guard let core = core else { return }

        listenTo(core, event: .showDrawerPlugin) { [weak self] _ in
            guard self?.isClosed != false else { return }
            self?.isClosed = false
        }

        listenTo(core, event: .hideDrawerPlugin) { [weak self] _ in
            guard self?.isClosed != true else { return }
            self?.isClosed = true
        }
    }

    override open func render() {
        requestPaddingIfNeeded()
    }

    private func requestPaddingIfNeeded() {
        if placeholder > 0 {
            core?.trigger(.requestPadding, userInfo: ["padding": CGFloat(32)])
        }
    }
}

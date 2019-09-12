class BottomDrawerPlugin: DrawerPlugin {
    required init(context: UIObject) {
        super.init(context: context)

        self.addTapGesture()
    }

    override var position: DrawerPlugin.Position {
        return .bottom
    }

    override var size: CGSize {
        return CGSize(width: coreViewBounds.width, height: coreViewBounds.height/2)
    }

    private var coreViewBounds: CGRect {
        guard let core = core else { return .zero }
        return core.view.frame
    }

    override func render() {
        super.render()

        adjustSize()
        moveDown()
    }

    override func onDrawerShow() {
        moveUp()
    }

    override func onDrawerHide() {
        moveDown()
    }

    private func adjustSize() {
        view.frame.size = size
    }

    private func moveUp() {
        view.setVerticalPoint(to: size.height, duration: ClapprAnimationDuration.mediaControlShow)
    }

    private func moveDown() {
        let point = coreViewBounds.height - placeholder
        view.setVerticalPoint(to: point, duration: ClapprAnimationDuration.mediaControlHide)
    }

    private func addTapGesture() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapView))
        view.addGestureRecognizer(gesture)
    }

    @objc private func didTapView() {
        showDrawerPlugin()
        hideMediaControl()
    }

    private func showDrawerPlugin() {
        core?.trigger(.showDrawerPlugin)
    }

    private func hideMediaControl() {
        activeContainer?.trigger(.disableMediaControl)
    }
}

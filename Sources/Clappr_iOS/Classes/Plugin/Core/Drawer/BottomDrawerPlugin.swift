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

        moveDown()
    }

    override func bindEvents() {
        guard let core = core else { return }
        super.bindEvents()

        listenTo(core, event: .showDrawerPlugin) { [weak self] _ in
            self?.moveUp()
        }
    }

    private func moveUp() {
        setVerticalPoint(to: size.height)
    }

    private func moveDown() {
        setVerticalPoint(to: coreViewBounds.height)
    }

    private func setVerticalPoint(to point: CGFloat) {
        view.frame.origin.y = point
    }
}

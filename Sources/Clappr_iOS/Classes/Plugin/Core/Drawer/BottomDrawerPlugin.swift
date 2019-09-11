class BottomDrawerPlugin: DrawerPlugin {

    open class override var name: String {
        return "BottomDrawerPlugin"
    }

    override var position: DrawerPlugin.Position {
        return .bottom
    }

    override var size: CGSize {
        guard let core = self.core else { return .zero }
        return CGSize(width: core.view.bounds.width, height: core.view.bounds.height/2)
    }
}

import UIKit

final class CoreLayer: Layer {
    func attachPlugin(_ plugin: UICorePlugin) {
        addSubview(plugin.view)
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let result = super.hitTest(point, with: event)
        if result == self { return nil }
        return result
    }
}

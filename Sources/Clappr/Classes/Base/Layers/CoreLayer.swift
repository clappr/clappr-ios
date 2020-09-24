import UIKit

final class CoreLayer: Layer {
    func attachPlugin(_ plugin: UICorePlugin) {
        addSubview(plugin.view)
    }
}

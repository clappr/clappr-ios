import Foundation

import Foundation

protocol LayersComposer {
    func attach(containers: [Container])
    func attach(corePlugins: [UICorePlugin])
}

protocol Layer {
    func attach(plugin: UIPlugin)
}

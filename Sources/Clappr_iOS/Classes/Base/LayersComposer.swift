import Foundation

import Foundation

protocol LayersComposer {
    func attach(containers: [Container])
    func attach(corePlugins: [UICorePlugin])
}

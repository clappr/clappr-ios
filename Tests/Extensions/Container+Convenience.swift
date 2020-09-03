import Foundation
@testable import Clappr

extension Container {
    convenience init(options: Options = [:]) {
        self.init(options: options, layerComposer: LayerComposer())
    }
}

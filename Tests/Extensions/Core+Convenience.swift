import Foundation
@testable import Clappr

extension Core {
    convenience init(options: Options = [:]) {
        self.init(options: options, layerComposer: LayerComposer())
    }
}

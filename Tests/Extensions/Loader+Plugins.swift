@testable import Clappr

extension Loader {

    func resetPlugins() {
        Loader.shared.plugins = [:]
    }
}

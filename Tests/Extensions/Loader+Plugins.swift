@testable import Clappr

extension Loader {

    func resetPlugins() {
        Loader.shared.plugins = []
        #if os(iOS)
            Player.hasAlreadyRegisteredPlugins = false
        #endif
    }
}

@testable import Clappr

extension Loader {

    func resetPlugins() {
        Loader.shared.plugins = []
        #if os(iOS)
            Player.hasAlreadyRegisteredPlugins = false
        #endif
    }
    
    func resetPlaybacks() {
        Loader.shared.playbacks = []
        #if os(iOS)
        Player.hasAlreadyRegisteredPlaybacks = false
        #endif
    }
}

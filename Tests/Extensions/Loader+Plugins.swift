@testable import Clappr

extension Loader {

    func resetPlugins() {
        Loader.shared.playbacks = [AVFoundationPlayback.self, NoOpPlayback.self]
        #if os (iOS)
        Loader.shared.containerPlugins = [PosterPlugin.self, SpinnerPlugin.self]
        #else
        Loader.shared.containerPlugins = []
        #endif
        Loader.shared.corePlugins = []
        Loader.shared.externalPlugins = []
    }
}

import Foundation

extension Array where Element == Plugin.Type {
    mutating func appendOrReplace(contentsOf plugins: [Plugin.Type]) {
        self.append(contentsOf: plugins)
        
        var result = [Plugin.Type]()
        for plugin in self.reversed() {
            if !result.contains(where: { $0.name == plugin.name }) {
                result.append(plugin)
            }
        }
        result = result.reversed()
        
        self.removeAll()
        self.append(contentsOf: result)
    }
}

extension Array where Element == Playback.Type {
    mutating func appendOrReplace(contentsOf plugins: [Playback.Type]) {
        self.append(contentsOf: plugins)
        
        var result = [Playback.Type]()
        for plugin in self.reversed() {
            if !result.contains(where: { $0.name == plugin.name }) {
                result.append(plugin)
            }
        }
        result = result.reversed()
        
        self.removeAll()
        self.append(contentsOf: result)
    }
}

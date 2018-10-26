import Foundation

extension Array where Element == Plugin.Type {
    var uniques: [Element] {
        var result = [Plugin.Type]()
        
        for plugin in self.reversed() {
            if !result.contains(where: { $0.name == plugin.name }) {
                result.append(plugin)
            }
        }
        
        return result.reversed()
    }
}

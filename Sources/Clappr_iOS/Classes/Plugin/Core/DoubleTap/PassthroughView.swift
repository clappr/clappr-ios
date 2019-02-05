import UIKit

class PassthroughView: UIView {
    
    var core: Core?
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if isPosterPluginVisible() {
            return false
        }
        return mediaControlPluginsColidesWithTouch(point: point, event: event)
    }
    
    private func isPosterPluginVisible() -> Bool {
        let posterPlugin = core?.activeContainer?.plugins.first(where: { $0 is PosterPlugin })
        return !(posterPlugin?.view.isHidden ?? true)
    }
    
    private func mediaControlPluginsColidesWithTouch(point: CGPoint, event: UIEvent?) -> Bool {
        guard let mediaControlPlugin = core?.plugins.first(where: { $0.pluginName == MediaControl.name }) else { return false }
        
        let pluginColidingWithGesture = filteredOutModalPlugins()?.first(where: {
            pluginColideWithTouch($0, point: point, event: event)
        })
        
        return pluginColidingWithGesture == nil || mediaControlPlugin.view.isHidden
    }
    
    private func filteredOutModalPlugins() -> [UICorePlugin]? {
        let pluginsWithoutMediaControl = core?.plugins.filter({ $0.pluginName != MediaControl.name })
        return pluginsWithoutMediaControl?.filter({ ($0 as? MediaControlPlugin)?.panel != .modal })
    }
    
    private func pluginColideWithTouch(_ plugin: UICorePlugin, point: CGPoint, event: UIEvent?) -> Bool {
        return plugin.view.point(inside: self.convert(point, to: plugin.view), with: event)
    }
}

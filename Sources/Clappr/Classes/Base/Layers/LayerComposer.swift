import UIKit

public class LayerComposer {
    private weak var rootView: UIView?
    private let backgroundLayer = BackgroundLayer()
    private let playbackLayer = PlaybackLayer()
    private let mediaControlLayer = MediaControlLayer()
    private let coreLayer = CoreLayer()
    private let overlayLayer = OverlayLayer()

    public init() { }
    
    func compose(inside rootView: UIView) {
        self.rootView = rootView
        
        backgroundLayer.attach(to: rootView, at: 0)
        playbackLayer.attach(to: rootView, at: 1)
        mediaControlLayer.attach(to: rootView, at: 2)
        coreLayer.attach(to: rootView, at: 3)
        overlayLayer.attach(to: rootView, at: 4)
    }
    
    func attachContainer(_ view: UIView) {
        playbackLayer.attach(view)
    }

    func attachUICorePlugin(_ plugin: UICorePlugin) {
        coreLayer.attachPlugin(plugin)
    }
    
    func attachMediaControl(_ view: UIView) {
        mediaControlLayer.attachMediaControl(view)
    }

    func attachOverlay(_ view: UIView) {
        overlayLayer.attachOverlay(view)
    }
}

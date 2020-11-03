import UIKit

public class LayerComposer {
    private weak var rootView: UIView?
    private let backgroundLayer = BackgroundLayer()
    private let playbackLayer = PlaybackLayer()
    private let containerLayer = ContainerLayer()
    private let mediaControlLayer = MediaControlLayer()
    private let coreLayer = CoreLayer()
    private let overlayLayer = OverlayLayer()

    public init() { }
    
    func compose(inside rootView: UIView) {
        self.rootView = rootView
        
        backgroundLayer.attach(to: rootView, at: 0)
        playbackLayer.attach(to: rootView, at: 1)
        containerLayer.attach(to: rootView, at: 2)
        mediaControlLayer.attach(to: rootView, at: 3)
        coreLayer.attach(to: rootView, at: 4)
        overlayLayer.attach(to: rootView, at: 5)
    }
    
    func attachContainer(_ view: UIView) {
        containerLayer.attachContainer(view)
    }
    
    func attachPlayback(_ view: UIView) {
        playbackLayer.attachPlayback(view)
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

import UIKit

public class LayerComposer {
    private weak var rootView: UIView?
    private let backgroundLayer = BackgroundLayer()
    private let playbackLayer = PlaybackLayer()
    private let containerLayer = ContainerLayer()
    
    func compose(inside rootView: UIView) {
        self.rootView = rootView
        
        backgroundLayer.attach(to: rootView, at: 0)
        playbackLayer.attach(to: rootView, at: 1)
        containerLayer.attach(to: rootView, at: 2)
    }
    
    func attachContainer(_ view: UIView) {
        containerLayer.attachContainer(view)
    }
    
    func attachPlayback(_ view: UIView) {
        playbackLayer.attachPlayback(view)
    }
}

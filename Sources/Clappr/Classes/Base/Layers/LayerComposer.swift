import UIKit

class LayerComposer {
    private weak var rootView: UIView?
    private let backgroundLayer = BackgroundLayer()
    private let playbackLayer = PlaybackLayer()
    private let containerLayer = ContainerLayer()
    
    func compose(inside rootView: UIView, adding containerView: UIView) {
        self.rootView = rootView
        
        backgroundLayer.attach(to: rootView, at: 0)
        playbackLayer.attach(to: rootView, at: 1)
        
        containerLayer.attach(to: rootView, at: 2)
        containerLayer.attachContainer(containerView)
    }
}

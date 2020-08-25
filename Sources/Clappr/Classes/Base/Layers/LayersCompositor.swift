import UIKit

class LayersCompositor {
    private weak var rootView: UIView?
    private let backgroundLayer = BackgroundLayer()
    private let playbackLayer = PlaybackLayer()
    
    func compose(inside rootView: UIView) {
        self.rootView = rootView
        
        backgroundLayer.attach(to: rootView, at: 0)
        playbackLayer.attach(to: rootView, at: 1)
    }
}

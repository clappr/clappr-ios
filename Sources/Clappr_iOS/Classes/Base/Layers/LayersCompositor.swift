import UIKit

class LayersCompositor {
    private weak var rootView: UIView?
    private var backgroundLayer: BackgroundLayer?
    
    func compose(inside rootView: UIView) {
        self.rootView = rootView
        
        let backgroundLayer = BackgroundLayer()
        self.backgroundLayer = backgroundLayer
        backgroundLayer.attach(to: rootView)
        rootView.sendSubviewToBack(backgroundLayer)
    }
}

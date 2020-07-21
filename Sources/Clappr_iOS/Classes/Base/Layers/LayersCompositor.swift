import UIKit

class LayersCompositor {
    
    private weak var rootView: UIView?
    
    private let backgroundLayer: BackgroundLayer
    
    init(for rootView: UIView) {
        self.rootView = rootView
        
        backgroundLayer = BackgroundLayer()
        backgroundLayer.attach(to: rootView)
        rootView.sendSubviewToBack(backgroundLayer)
    }
}

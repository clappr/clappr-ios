import UIKit

class LayersCompositor {
    
    private weak var rootView: UIView?
    
    private let backgroundLayer: BackgroundLayer
    
    init(for rootView: UIView) {
        self.rootView = rootView
        
        self.backgroundLayer = BackgroundLayer(frame: rootView.bounds)
        rootView.addSubview(backgroundLayer)
        rootView.sendSubviewToBack(backgroundLayer)
    }
}

import UIKit

class LayersCompositor {
    private weak var rootView: UIView?
    private let backgroundLayer = BackgroundLayer()
    
    func compose(inside rootView: UIView) {
        self.rootView = rootView
        
        backgroundLayer.attach(to: rootView, at: 0)
    }
}

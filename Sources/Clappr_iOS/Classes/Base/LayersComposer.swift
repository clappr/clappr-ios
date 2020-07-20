import Foundation

final class BackgroundLayer: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.black
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class LayersCompositor {
    
    private weak var rootView: UIView?
    
    private let backgroundLayer: BackgroundLayer
    
    init(rootView: UIView) {
        self.rootView = rootView
        
        self.backgroundLayer = BackgroundLayer(frame: rootView.bounds)
        rootView.addSubview(backgroundLayer)
        rootView.sendSubviewToBack(backgroundLayer)
    }
}

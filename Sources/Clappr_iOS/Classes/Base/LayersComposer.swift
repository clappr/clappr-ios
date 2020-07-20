import Foundation

protocol LayersComposer {
    func attach(containers: [Container])
    func attach(corePlugins: [UICorePlugin])
}

protocol Layer {
    func attach(plugin: UIPlugin)
}

class BackgroundLayer: UIView, Layer {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.black
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func attach(plugin: UIPlugin) {}
}

class LayersCompositor: LayersComposer {
    
    private weak var rootView: UIView?
    
    private let backgroundLayer: BackgroundLayer
    
    init(rootView: UIView) {
        self.rootView = rootView
        
        self.backgroundLayer = BackgroundLayer(frame: rootView.bounds)
        rootView.addSubview(backgroundLayer)
        rootView.sendSubviewToBack(backgroundLayer)
    }
    
    func attach(containers: [Container]){}
    func attach(corePlugins: [UICorePlugin]){}
}

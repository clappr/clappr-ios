import Foundation

protocol LayersComposer {
    func attach(containers: [Container])
    func attach(corePlugins: [UICorePlugin])
}

protocol Layer {
    func attach(plugin: UIPlugin)
}

class BackgroundLayer: UIView, Layer {
    func attach(plugin: UIPlugin) {}
}

class LayersCompositor: LayersComposer {
    
    private weak var rootView: UIView?
    
    private let backgroundLayer = BackgroundLayer()
    
    init(rootView: UIView) {
        self.rootView = rootView
        
        rootView.addSubview(backgroundLayer)
        rootView.sendSubviewToBack(backgroundLayer)
    }
    
    func attach(containers: [Container]){}
    func attach(corePlugins: [UICorePlugin]){}
}

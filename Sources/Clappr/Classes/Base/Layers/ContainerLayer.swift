import UIKit

final class ContainerLayer: Layer {   
    func attachContainer(_ container: UIView) {
        addSubview(container)
        
        container.translatesAutoresizingMaskIntoConstraints = false
        
        container.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        container.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        
        container.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        container.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
}

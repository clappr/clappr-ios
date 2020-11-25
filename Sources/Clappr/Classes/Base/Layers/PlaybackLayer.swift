import UIKit

final class PlaybackLayer: Layer {
    func attach(_ view: UIView) {
        addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        view.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        
        view.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        view.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true

        layoutIfNeeded()
    }
}

import UIKit

final class MediaControlLayer: Layer {
    func attachMediaControl(_ mediaControl: UIView) {
        addSubview(mediaControl)
        
        mediaControl.translatesAutoresizingMaskIntoConstraints = false
        
        mediaControl.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        mediaControl.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        
        mediaControl.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        mediaControl.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true

        mediaControl.layoutIfNeeded()
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let result = super.hitTest(point, with: event)
        if result == self { return nil }
        return result
    }
}

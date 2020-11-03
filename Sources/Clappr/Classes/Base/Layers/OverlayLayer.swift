import Foundation

final class OverlayLayer: Layer {
    func attachOverlay(_ overlayView: UIView) {
        addSubview(overlayView)
        
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        
        overlayView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        overlayView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        
        overlayView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        overlayView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        layoutIfNeeded()
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let result = super.hitTest(point, with: event)
        if result == self { return nil }
        return result
    }
}

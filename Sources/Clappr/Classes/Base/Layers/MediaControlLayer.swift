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
}

import UIKit

final class PlaybackLayer: Layer {
    func attachPlayback(_ playback: UIView) {
        addSubview(playback)
        
        playback.translatesAutoresizingMaskIntoConstraints = false
        
        playback.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        playback.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        
        playback.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        playback.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true

        layoutIfNeeded()
    }
}

import AVFoundation

extension AVFoundationPlayback {

    func setupMaxResolution(for size: CGSize) {
        if #available(tvOS 11.0, iOS 11.0, *) {
            player?.currentItem?.preferredMaximumResolution = size
        }
    }
}

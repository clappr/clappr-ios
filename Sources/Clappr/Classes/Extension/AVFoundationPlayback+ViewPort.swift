import AVFoundation

extension AVFoundationPlayback {

    @available(iOS 11.0, *)
    @available(tvOS 11.0, *)
    func setupMaxResolution(for size: CGSize) {
        player?.currentItem?.preferredMaximumResolution = size
    }
}

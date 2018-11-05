import AVFoundation

extension AVFoundationPlayback {

    func setupMaxResolution(for size: CGSize) {
        #if os(iOS)
        if #available(iOS 11.0, *) {
            let screenScale = UIScreen.main.scale
            let screenSize = CGSize(width: size.width * screenScale, height: size.height * screenScale)
            player?.currentItem?.preferredMaximumResolution = screenSize
        }
        #endif
    }
}

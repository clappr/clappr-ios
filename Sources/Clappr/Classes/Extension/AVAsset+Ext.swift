import AVKit

public enum AVAssetProperty: String {
    case duration = "duration"
    case characteristics = "availableMediaCharacteristicsWithMediaSelectionOptions"
}

public extension AVAsset {
    func wait(for property: AVAssetProperty, then completion: @escaping () -> Void) {
        self.loadValuesAsynchronously(forKeys: [property.rawValue]) {
            DispatchQueue.main.async {
                completion()
            }
        }
    }
}

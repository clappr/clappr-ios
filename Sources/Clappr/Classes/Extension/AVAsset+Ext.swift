import AVKit

public enum AVAssetProperty: String, CaseIterable {
    case duration = "duration"
    case characteristics = "availableMediaCharacteristicsWithMediaSelectionOptions"
}

public extension AVAsset {
    func wait(for property: AVAssetProperty, then completion: @escaping () -> Void) {
        wait(for: [property], then: completion)
    }

    func wait(for properties: [AVAssetProperty], then completion: @escaping () -> Void) {
        self.loadValuesAsynchronously(forKeys: properties.map { $0.rawValue }) {
            DispatchQueue.main.async {
                completion()
            }
        }
    }
}

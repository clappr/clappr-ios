import AVFoundation

public enum AVAssetProperty: String {
    case duration = "duration"
    case characteristics = "availableMediaCharacteristicsWithMediaSelectionOptions"
}

class AVAssetInfo {
    var asset: AVAsset
    
    init(asset: AVAsset) {
        self.asset = asset
    }
    
    func wait(for property: AVAssetProperty, then completion: @escaping () -> Void) {
        asset.loadValuesAsynchronously(forKeys: [property.rawValue]) {
            DispatchQueue.main.async {
                completion()
            }
        }
    }
}

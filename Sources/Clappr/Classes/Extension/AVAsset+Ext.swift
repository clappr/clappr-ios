import AVKit

public extension AVAsset {
    func wait(for property: String, then completion: @escaping () -> Void) {
        self.loadValuesAsynchronously(forKeys: [property]) {
            DispatchQueue.main.async {
                completion()
            }
        }
    }
}

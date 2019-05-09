import AVKit

public extension AVAsset {
    func wait(for property: String, then completion: @escaping () -> ()) {
        self.loadValuesAsynchronously(forKeys: [property]) {
            DispatchQueue.main.async {
                completion()
            }
        }
    }
}

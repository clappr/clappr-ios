import AVKit

public extension AVAsset {
    func wait(for property: String, then completion: @escaping () -> ()) {
        wait(for: [property], then: completion)
    }

    func wait(for properties: [String], then completion: @escaping () -> ()) {
        self.loadValuesAsynchronously(forKeys: properties) {
            DispatchQueue.main.async {
                completion()
            }
        }
    }
}

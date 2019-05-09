import AVKit

public typealias AsyncResult<T> = ((_ value: T?) -> ())
public extension AVAsset {
    func async<T>(get property: String, completion: @escaping AsyncResult<T>) {
        self.loadValuesAsynchronously(forKeys: [property]) { [weak self] in
            var error: NSError? = nil
            let status: AVKeyValueStatus = self?.statusOfValue(forKey: property, error: &error) ?? .failed
            switch status {
            case .loaded:
                completion(self?.value(forKey: property) as? T)
            default:
                completion(nil)
            }
        }
    }
}

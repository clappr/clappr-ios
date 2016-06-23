import AVFoundation

extension AudioSource {
    class func fromAVMediaSelectionOption(option: AVMediaSelectionOption?) -> AudioSource? {
        if let option = option {
            return AudioSource(name: option.displayName, raw: option)
        }
        
        return nil
    }
}
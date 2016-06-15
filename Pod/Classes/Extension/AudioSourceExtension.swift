import AVFoundation

extension AudioSource {
    class func fromAVMediaSelectionOption(option: AVMediaSelectionOption?) -> AudioSource? {
        if let option = option {
            return AudioSource(name: option.displayName, raw: option)
        }
        
        return nil
    }
    
    class func fromAVMediaSelectionOptions(options: [AVMediaSelectionOption?]?) -> [AudioSource]? {
        return options?.flatMap({fromAVMediaSelectionOption($0)})
    }
}
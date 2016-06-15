import AVFoundation

extension Subtitle {
    class func fromAVMediaSelectionOption(option: AVMediaSelectionOption?) -> Subtitle? {
        if let option = option {
            return Subtitle(name: option.displayName, raw: option)
        }
        
        return nil
    }
    
    class func fromAVMediaSelectionOptions(options: [AVMediaSelectionOption?]?) -> [Subtitle]? {
        return options?.flatMap({fromAVMediaSelectionOption($0)})
    }
}
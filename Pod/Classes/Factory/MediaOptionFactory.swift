import AVFoundation

class MediaOptionFactory {
    class func fromAVMediaOption(option: AVMediaSelectionOption?, type: MediaOptionType) -> MediaOption? {
        if let option = option {
            return MediaOption(name: option.displayName, type: type, raw: option)
        }
        
        return nil
    }
}
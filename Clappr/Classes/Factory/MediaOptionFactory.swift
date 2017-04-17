import AVFoundation

class MediaOptionFactory {
    class func fromAVMediaOption(_ option: AVMediaSelectionOption?, type: MediaOptionType) -> MediaOption? {
        if let option = option, let language = option.extendedLanguageTag {
            return MediaOption(name: option.displayName, type: type, language: language, raw: option)
        }

        return nil
    }

    class func offSubtitle() -> MediaOption {
        return MediaOption(name: "Off", type: .subtitle, language: "off", raw: nil)
    }
}

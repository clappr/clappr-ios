import AVFoundation

open class AvailableMediaOptions {
    open let sources: [MediaOption]
    open let hasDefaultSelected: Bool

    init(_ sources: [MediaOption], hasDefaultSelected: Bool) {
        self.sources = sources
        self.hasDefaultSelected = hasDefaultSelected
    }
}

import AVFoundation

open class AvailableMediaOptions {
    let sources: [MediaOption]
    let hasDefaultSelected: Bool

    init(_ sources: [MediaOption], hasDefaultSelected: Bool) {
        self.sources = sources
        self.hasDefaultSelected = hasDefaultSelected
    }
}

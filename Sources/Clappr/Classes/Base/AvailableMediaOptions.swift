public struct AvailableMediaOptions {
    public let sources: [MediaOption]
    public let hasDefaultSelected: Bool

    public init(_ sources: [MediaOption], hasDefaultSelected: Bool) {
        self.sources = sources
        self.hasDefaultSelected = hasDefaultSelected
    }
}

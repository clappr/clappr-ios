open class AvailableMediaOptions {
    open let sources: [MediaOption]
    open let hasDefaultSelected: Bool

    public init(_ sources: [MediaOption], hasDefaultSelected: Bool) {
        self.sources = sources
        self.hasDefaultSelected = hasDefaultSelected
    }
}

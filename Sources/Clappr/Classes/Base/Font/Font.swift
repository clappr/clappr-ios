import CoreMedia

public enum Font {
    case `default`
    case serif
    case sansSerif
    case monospace
    case proportionalSerif
    case proportionalSansSerif
    case monospaceSerif
    case monospaceSansSerif
    case casual
    case cursive
    case fantasy
    case smallCapital
    case custom(String)

    var key: String {
        switch self {
        case .custom: return String(kCMTextMarkupAttribute_FontFamilyName)
        default: return String(kCMTextMarkupAttribute_GenericFontFamilyName)
        }
    }

    var value: String {
        switch self {
        case .default: return String(kCMTextMarkupGenericFontName_Default)
        case .serif: return String(kCMTextMarkupGenericFontName_Serif)
        case .sansSerif: return String(kCMTextMarkupGenericFontName_SansSerif)
        case .monospace: return String(kCMTextMarkupGenericFontName_Monospace)
        case .proportionalSerif: return String(kCMTextMarkupGenericFontName_ProportionalSerif)
        case .proportionalSansSerif: return String(kCMTextMarkupGenericFontName_ProportionalSansSerif)
        case .monospaceSerif: return String(kCMTextMarkupGenericFontName_MonospaceSerif)
        case .monospaceSansSerif: return String(kCMTextMarkupGenericFontName_MonospaceSansSerif)
        case .casual: return String(kCMTextMarkupGenericFontName_Casual)
        case .cursive: return String(kCMTextMarkupGenericFontName_Cursive)
        case .fantasy: return String(kCMTextMarkupGenericFontName_Fantasy)
        case .smallCapital: return String(kCMTextMarkupGenericFontName_SmallCapital)
        case .custom(let value): return value
        }
    }
}

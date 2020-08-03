import AVKit

enum EdgeStyle {
    case none
    case raised
    case depressed
    case uniform
    case dropShadow

    var value: CFString {
        switch self {
        case .none: return kCMTextMarkupCharacterEdgeStyle_None
        case .raised: return kCMTextMarkupCharacterEdgeStyle_Raised
        case .depressed: return kCMTextMarkupCharacterEdgeStyle_Depressed
        case .uniform: return kCMTextMarkupCharacterEdgeStyle_Uniform
        case .dropShadow: return kCMTextMarkupCharacterEdgeStyle_DropShadow
        }
    }
}

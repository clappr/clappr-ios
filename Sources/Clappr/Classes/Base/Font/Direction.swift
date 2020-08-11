import CoreMedia

public enum Direction {
    case ltr, rtl

    var value: String {
        switch self {
        case .ltr: return String(kCMTextVerticalLayout_LeftToRight)
        case .rtl: return String(kCMTextVerticalLayout_RightToLeft)
        }
    }
}

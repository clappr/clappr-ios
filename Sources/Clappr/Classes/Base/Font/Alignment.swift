import CoreMedia

enum Alignment: String, Equatable {
    case start, middle, end, left, right

    var value: String {
        switch self {
        case .start: return String(kCMTextMarkupAlignmentType_Start)
        case .middle: return String(kCMTextMarkupAlignmentType_Middle)
        case .end: return String(kCMTextMarkupAlignmentType_End)
        case .left: return String(kCMTextMarkupAlignmentType_Left)
        case .right: return String(kCMTextMarkupAlignmentType_Right)
        }
    }
}

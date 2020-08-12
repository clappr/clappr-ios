import AVKit
import UIKit

public enum TextStyle {
    case characterBackground(UIColor)
    case background(UIColor)
    case foreground(UIColor)
    case fontSizePercentage(Double)
    case bold
    case italic
    case underline
    case edge(EdgeStyle)
    case font(Font)
    case alignment(Alignment)
    case direction(Direction)

    var key: String {
        switch self {
        case .background: return String(kCMTextMarkupAttribute_BackgroundColorARGB)
        case .characterBackground: return String(kCMTextMarkupAttribute_CharacterBackgroundColorARGB)
        case .foreground: return String(kCMTextMarkupAttribute_ForegroundColorARGB)
        case .fontSizePercentage: return String(kCMTextMarkupAttribute_BaseFontSizePercentageRelativeToVideoHeight)
        case .bold: return String(kCMTextMarkupAttribute_BoldStyle)
        case .underline: return String(kCMTextMarkupAttribute_UnderlineStyle)
        case .italic: return String(kCMTextMarkupAttribute_ItalicStyle)
        case .edge: return String(kCMTextMarkupAttribute_CharacterEdgeStyle)
        case .alignment: return String(kCMTextMarkupAttribute_Alignment)
        case .direction: return String(kCMTextMarkupAttribute_VerticalLayout)
        default: return ""
        }
    }

    var value: AVTextStyleRule {
        switch self {
        case .bold, .italic, .underline:
            return AVTextStyleRule(textMarkupAttributes: [ self.key: true])!
        case .fontSizePercentage(let size):
            return AVTextStyleRule(textMarkupAttributes: [ self.key: size])!
        case .background(let color), .characterBackground(let color), .foreground(let color):
            return AVTextStyleRule(textMarkupAttributes: [ self.key: color.argb])!
        case .edge(let edge):
            return AVTextStyleRule(textMarkupAttributes: [ self.key: edge.value])!
        case .font(let font):
            return AVTextStyleRule(textMarkupAttributes: [ font.key: font.value])!
        case .alignment(let alignment):
            return AVTextStyleRule(textMarkupAttributes: [ self.key: alignment.value])!
        case .direction(let direction):
            return AVTextStyleRule(textMarkupAttributes: [ self.key: direction.value])!
        }
    }
}

extension TextStyle: Equatable {
    public static func == (lhs: TextStyle, rhs: TextStyle) -> Bool {
        lhs.key == rhs.key && lhs.value == rhs.value
    }
}

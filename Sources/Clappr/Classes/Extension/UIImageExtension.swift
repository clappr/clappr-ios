
public extension UIImage {
    static func from(name named: String, aClass: AnyClass = Player.self) -> UIImage? {
        return UIImage(named: named, in: Bundle(for: aClass), compatibleWith: nil)
    }
}

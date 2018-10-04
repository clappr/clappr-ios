public extension UIImage {
    static func fromName(_ name: String) -> UIImage? {
        return UIImage(named: name, in: Bundle(for: self), compatibleWith: nil)
    }
}

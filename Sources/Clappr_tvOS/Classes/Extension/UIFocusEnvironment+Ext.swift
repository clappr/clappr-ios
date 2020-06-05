extension UIFocusEnvironment {
    var isFocusable: Bool {
        guard let view = self as? UIView else { return false }

        return view.alpha > 0 && view.canBecomeFocused && !view.isHidden && view.isUserInteractionEnabled
    }
}
